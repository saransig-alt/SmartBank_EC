import '../../entities/transaction_entity.dart';
import '../../repositories/i_bank_repository.dart';

/// Caso de uso: Ejecutar una transferencia de dinero.
class TransferMoneyUseCase {
  final IBankRepository _repository;

  TransferMoneyUseCase(this._repository);

  Future<TransactionEntity> execute({
    required String uidOrigen,
    required String cuentaDestino,
    required double monto,
  }) {
    return _repository.transfer(
      uidOrigen: uidOrigen,
      cuentaDestino: cuentaDestino,
      monto: monto,
    );
  }
}