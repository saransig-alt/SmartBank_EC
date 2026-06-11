import '../../repositories/i_auth_repository.dart';

/// Caso de uso: Cerrar sesión.
class SignOutUseCase {
  final IAuthRepository _repository;

  SignOutUseCase(this._repository);

  Future<void> execute() {
    return _repository.signOut();
  }
}