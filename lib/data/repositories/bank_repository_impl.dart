import 'dart:async';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/i_bank_repository.dart';
import '../datasources/remote/bank_remote_datasource.dart';
import '../mappers/transaction_mapper.dart';
import '../mappers/user_mapper.dart';

/// Implementación concreta del repositorio bancario.
class BankRepositoryImpl implements IBankRepository {
  final BankRemoteDataSource _remoteDataSource;

  BankRepositoryImpl({required BankRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<UserEntity> registerInitialData({
    required String uid,
    required String nombres,
    required String apellidos,
    required String correo,
    required String telefono,
  }) async {
    try {
      final userModel = await _remoteDataSource.saveInitialUserData(
        uid: uid,
        nombres: nombres,
        apellidos: apellidos,
        correo: correo,
        telefono: telefono,
      );
      return UserMapper.toEntity(userModel);
    } catch (e) {
      if (e is Failure) rethrow;
      throw const BankFailure('Error al registrar datos iniciales.');
    }
  }

  @override
  Stream<UserEntity> listenUserData(String uid) {
    return _remoteDataSource
        .listenUserData(uid)
        .map((model) => UserMapper.toEntity(model));
  }

  @override
  Stream<List<TransactionEntity>> listenTransactions(String uid) {
    return _remoteDataSource
        .listenTransactions(uid)
        .map((models) => models.map((m) => TransactionMapper.toEntity(m)).toList());
  }

  @override
  Future<TransactionEntity> transfer({
    required String uidOrigen,
    required String cuentaDestino,
    required double monto,
  }) async {
    try {
      final txnModel = await _remoteDataSource.executeTransfer(
        uidOrigen: uidOrigen,
        cuentaDestino: cuentaDestino,
        monto: monto,
      );
      return TransactionMapper.toEntity(txnModel);
    } catch (e) {
      if (e is Failure) rethrow;
      if (e is BankException) throw BankFailure(e.message);
      throw const BankFailure('Error al ejecutar transferencia.');
    }
  }

  @override
  Future<bool> accountExists(String numeroCuenta) async {
    try {
      return await _remoteDataSource.accountExists(numeroCuenta);
    } catch (e) {
      throw const BankFailure('Error al verificar cuenta.');
    }
  }

  @override
  Future<String?> getUidByAccountNumber(String numeroCuenta) async {
    try {
      return await _remoteDataSource.getUidByAccountNumber(numeroCuenta);
    } catch (e) {
      throw const BankFailure('Error al buscar cuenta.');
    }
  }

  @override
  Future<double> getBalance(String uid) async {
    try {
      return await _remoteDataSource.getBalance(uid);
    } catch (e) {
      if (e is Failure) rethrow;
      throw const BankFailure('Error al obtener saldo.');
    }
  }
}