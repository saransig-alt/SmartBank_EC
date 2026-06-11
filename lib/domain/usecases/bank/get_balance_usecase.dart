import '../../repositories/i_bank_repository.dart';

/// Caso de uso: Obtener el saldo actual del usuario.
class GetBalanceUseCase {
  final IBankRepository _repository;

  GetBalanceUseCase(this._repository);

  Future<double> execute(String uid) {
    return _repository.getBalance(uid);
  }
}