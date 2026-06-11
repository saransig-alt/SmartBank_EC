import '../../repositories/i_auth_repository.dart';

/// Caso de uso: Enviar correo de recuperación de contraseña.
class ResetPasswordUseCase {
  final IAuthRepository _repository;

  ResetPasswordUseCase(this._repository);

  Future<void> execute({required String correo}) {
    return _repository.resetPassword(correo: correo);
  }
}