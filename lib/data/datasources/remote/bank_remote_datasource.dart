import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/utils/date_utils.dart';
import '../../models/transaction_model.dart';
import '../../models/user_model.dart';

/// DataSource remoto para operaciones bancarias con Firestore.
class BankRemoteDataSource {
  final FirebaseFirestore _firestore;

  BankRemoteDataSource({required FirebaseFirestore firestore}) : _firestore = firestore;

  /// Guarda el perfil inicial del usuario en Firestore.
  Future<UserModel> saveInitialUserData({
    required String uid,
    required String nombres,
    required String apellidos,
    required String correo,
    required String telefono,
  }) async {
    try {
      final numeroCuenta = await _generateUniqueAccountNumber(uid);

      final user = UserModel.initial(
        uid: uid,
        nombres: nombres,
        apellidos: apellidos,
        correo: correo,
        telefono: telefono,
        numeroCuenta: numeroCuenta,
      );

      await _firestore.collection(AppConstants.usersCollection).doc(uid).set(user.toMap());

      // Registrar bono de bienvenida
      await _registerWelcomeBonus(uid, numeroCuenta);

      return user;
    } catch (e) {
      if (e is ServerException) rethrow;
      // En write rules failure u otros errores de Firestore se propaga para que UI muestre el motivo real.
      if (e is FirebaseException) {
        throw ServerException('Error al registrar datos iniciales: ${e.message}');
      }
      throw ServerException('Error al registrar datos iniciales: $e');
    }
  }

  /// Escucha en tiempo real los datos del perfil del usuario.
  Stream<UserModel> listenUserData(String uid) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        throw const NotFoundException('Perfil de usuario no encontrado');
      }
      return UserModel.fromMap(snapshot.data()!, snapshot.id);
    });
  }

  /// Escucha en tiempo real las transacciones del usuario.
  Stream<List<TransactionModel>> listenTransactions(String uid) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .collection(AppConstants.transactionsCollection)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TransactionModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Ejecuta una transferencia utilizando una transacción atómica de Firestore.
  Future<TransactionModel> executeTransfer({
    required String uidOrigen,
    required String cuentaDestino,
    required double monto,
  }) async {
    try {
      // Validación del lado del servidor: monto debe ser positivo
      if (monto <= 0) {
        throw const BankException('El monto debe ser mayor a cero');
      }

      // Obtener UID del destinatario
      final uidDestino = await getUidByAccountNumber(cuentaDestino);
      if (uidDestino == null) {
        throw const NotFoundException('La cuenta destino no existe');
      }

      // Ejecutar transacción atómica
      final result = await _firestore.runTransaction((transaction) async {
        // Leer documentos origen y destino
        final docOrigenRef = _firestore
            .collection(AppConstants.usersCollection)
            .doc(uidOrigen);
        final docDestinoRef = _firestore
            .collection(AppConstants.usersCollection)
            .doc(uidDestino);

        final docOrigen = await transaction.get(docOrigenRef);
        final docDestino = await transaction.get(docDestinoRef);

        if (!docOrigen.exists) {
          throw const NotFoundException('Cuenta origen no encontrada');
        }
        if (!docDestino.exists) {
          throw const NotFoundException('Cuenta destino no encontrada');
        }

        final saldoOrigen = (docOrigen.data()!['saldo'] ?? 0.0).toDouble();
        final saldoDestino = (docDestino.data()!['saldo'] ?? 0.0).toDouble();

        if (saldoOrigen < monto) {
          throw const BankException('Fondos insuficientes');
        }

        // Actualizar saldos
        transaction.update(docOrigenRef, {'saldo': saldoOrigen - monto});
        transaction.update(docDestinoRef, {'saldo': saldoDestino + monto});

        // Crear transacción para el origen
        final txnOrigenRef = docOrigenRef
            .collection(AppConstants.transactionsCollection)
            .doc();
        final txnOrigen = TransactionModel(
          id: txnOrigenRef.id,
          fecha: DateUtilsApp.currentDate(),
          hora: DateUtilsApp.currentTime(),
          tipo: 'Enviada',
          monto: monto,
          cuentaOrigen: docOrigen.data()!['numeroCuenta'] ?? '',
          cuentaDestino: cuentaDestino,
        );
        transaction.set(txnOrigenRef, txnOrigen.toMap());

        // Crear transacción para el destino
        final txnDestinoRef = docDestinoRef
            .collection(AppConstants.transactionsCollection)
            .doc();
        final txnDestino = TransactionModel(
          id: txnDestinoRef.id,
          fecha: DateUtilsApp.currentDate(),
          hora: DateUtilsApp.currentTime(),
          tipo: 'Recibida',
          monto: monto,
          cuentaOrigen: docOrigen.data()!['numeroCuenta'] ?? '',
          cuentaDestino: cuentaDestino,
        );
        transaction.set(txnDestinoRef, txnDestino.toMap());

        return txnOrigen;
      });

      return result;
    } on NotFoundException {
      rethrow;
    } on BankException {
      rethrow;
    } catch (e) {
      throw ServerException('Error al ejecutar transferencia: $e');
    }
  }

  /// Verifica si un número de cuenta existe en Firestore.
  Future<bool> accountExists(String numeroCuenta) async {
    try {
      final result = await _firestore
          .collection(AppConstants.usersCollection)
          .where('numeroCuenta', isEqualTo: numeroCuenta)
          .limit(1)
          .get();
      return result.docs.isNotEmpty;
    } catch (e) {
      throw ServerException('Error al verificar cuenta: $e');
    }
  }

  /// Obtiene el UID de un usuario dado su número de cuenta.
  Future<String?> getUidByAccountNumber(String numeroCuenta) async {
    try {
      final result = await _firestore
          .collection(AppConstants.usersCollection)
          .where('numeroCuenta', isEqualTo: numeroCuenta)
          .limit(1)
          .get();
      if (result.docs.isEmpty) return null;
      return result.docs.first.id;
    } catch (e) {
      throw ServerException('Error al buscar cuenta: $e');
    }
  }

  /// Obtiene el saldo actual de un usuario.
  Future<double> getBalance(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();
      if (!doc.exists || doc.data() == null) {
        throw const NotFoundException('Usuario no encontrado');
      }
      return (doc.data()!['saldo'] ?? 0.0).toDouble();
    } on NotFoundException {
      rethrow;
    } catch (e) {
      throw ServerException('Error al obtener saldo: $e');
    }
  }

  /// Genera un número de cuenta único.
  Future<String> _generateUniqueAccountNumber(String uid) async {
    const maxIntentos = AppConstants.maxAccountAttempts;

    for (int intento = 0; intento < maxIntentos; intento++) {
      final randomPart = (DateTime.now().microsecondsSinceEpoch + uid.hashCode + intento)
          .abs()
          .toString()
          .substring(0, 6);

      final candidato = '${AppConstants.accountPrefix}$randomPart';
      final existe = await _firestore
          .collection(AppConstants.usersCollection)
          .where('numeroCuenta', isEqualTo: candidato)
          .limit(1)
          .get();

      if (existe.docs.isEmpty) {
        return candidato;
      }
    }

    // Fallback: usar hash del uid
    return '${AppConstants.accountPrefix}${uid.substring(0, 6)}';
  }

  /// Registra la transacción de bono de bienvenida.
  Future<void> _registerWelcomeBonus(String uid, String numeroCuenta) async {
    final bono = TransactionModel(
      id: '',
      fecha: DateUtilsApp.currentDate(),
      hora: DateUtilsApp.currentTime(),
      tipo: 'Bono de Bienvenida',
      monto: AppConstants.welcomeBonus,
      cuentaOrigen: 'SMARTBANK_EC',
      cuentaDestino: numeroCuenta,
    );

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .collection(AppConstants.transactionsCollection)
        .add(bono.toMap());
  }
}