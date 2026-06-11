import 'dart:async';
import '../../entities/transaction_entity.dart';
import '../../repositories/i_bank_repository.dart';

/// Caso de uso: Escuchar las transacciones del usuario en tiempo real.
class GetTransactionsUseCase {
  final IBankRepository _repository;

  GetTransactionsUseCase(this._repository);

  Stream<List<TransactionEntity>> execute(String uid) {
    return _repository.listenTransactions(uid);
  }
}