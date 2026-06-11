import 'dart:async';
import '../entities/transaction_entity.dart';
import '../entities/user_entity.dart';

/// Contrato abstracto para el repositorio bancario.
/// La capa de datos implementará esta interfaz.
abstract class IBankRepository {
  /// Registra los datos iniciales del usuario (saldo, número de cuenta, bono).
  Future<UserEntity> registerInitialData({
    required String uid,
    required String nombres,
    required String apellidos,
    required String correo,
    required String telefono,
  });

  /// Escucha en tiempo real los datos del usuario (saldo, perfil).
  Stream<UserEntity> listenUserData(String uid);

  /// Escucha en tiempo real las transacciones del usuario.
  Stream<List<TransactionEntity>> listenTransactions(String uid);

  /// Ejecuta una transferencia atómica entre dos cuentas.
  Future<TransactionEntity> transfer({
    required String uidOrigen,
    required String cuentaDestino,
    required double monto,
  });

  /// Verifica si un número de cuenta existe en Firestore.
  Future<bool> accountExists(String numeroCuenta);

  /// Obtiene el UID de un usuario dado su número de cuenta.
  Future<String?> getUidByAccountNumber(String numeroCuenta);

  /// Obtiene el saldo actual del usuario.
  Future<double> getBalance(String uid);
}