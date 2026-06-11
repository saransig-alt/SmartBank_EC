import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.model.dart';
import '../models/transaction.model.dart';

class BankProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  UserModel? _currentUser;
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;

  // ASIGNACIÓN DE SALDO INICIAL Y BONO AL REGISTRARSE
  Future<void> registrarDatosIniciales({
    required String uid,
    required String nombres,
    required String apellidos,
    required String correo,
    required String telefono,
  }) async {
    _setLoading(true);
    try {
      String numeroCuenta = '';
      const int maxIntentos = 10;

      for (int intento = 0; intento < maxIntentos; intento++) {
        final randomPart = (DateTime.now().microsecondsSinceEpoch + uid.hashCode + intento)
            .abs()
            .toString()
            .substring(0, 6);

        final candidato = "CTA-$randomPart";
        final existe = await _firestore
            .collection('usuarios')
            .where('numeroCuenta', isEqualTo: candidato)
            .limit(1)
            .get();

        if (existe.docs.isEmpty) {
          numeroCuenta = candidato;
          break;
        }
      }


      if (numeroCuenta.isEmpty) {
        numeroCuenta = "CTA-${uid.substring(0, 6)}";
      }


      // 2. Crear el objeto de usuario con el saldo reglamentario de $1000
      UserModel nuevoUsuario = UserModel(
        uid: uid,
        nombres: nombres,
        apellidos: apellidos,
        correo: correo,
        telefono: telefono,
        numeroCuenta: numeroCuenta,
        saldo: 1000.0, 
      );

      // 3. Guardar el usuario en la colección principal "usuarios" de Firestore
      await _firestore.collection('usuarios').doc(uid).set(nuevoUsuario.toMap());

      // 4. Registrar de inmediato la primera transacción del Bono de Bienvenida
      DateTime ahora = DateTime.now();
      TransactionModel bonoTransaccion = TransactionModel(
        id: '',
        fecha: "${ahora.day}/${ahora.month}/${ahora.year}",
        hora: "${ahora.hour}:${ahora.minute}",
        tipo: "Bono de Bienvenida",
        monto: 200.0,
        cuentaOrigen: "SMARTBANK_EC",
        cuentaDestino: numeroCuenta,
      );

      await _firestore
          .collection('usuarios')
          .doc(uid)
          .collection('transacciones')
          .add(bonoTransaccion.toMap());

      _currentUser = nuevoUsuario;
    } catch (e) {
      debugPrint("Error al registrar datos iniciales: $e");
    } finally {
      _setLoading(false);
    }
  }

  void escucharUsuarioDatos(String uid) {
    _firestore.collection('usuarios').doc(uid).snapshots().listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        _currentUser = UserModel.fromMap(snapshot.data()!, snapshot.id);
        notifyListeners(); // Notifica de forma reactiva a las pantallas móviles
      }
    });

    _firestore
        .collection('usuarios')
        .doc(uid)
        .collection('transacciones')
        .snapshots()
        .listen((snapshot) {
      _transactions = snapshot.docs
          .map((doc) => TransactionModel.fromMap(doc.data(), doc.id))
          .toList();
      notifyListeners();
    });
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}