import '../../entities/user_entity.dart';
import '../../repositories/i_auth_repository.dart';

/// Caso de uso: Iniciar sesión.
/// Orquesta la lógica de negocio para autenticar al usuario.
class SignInUseCase {
  final IAuthRepository _repository;

  SignInUseCase(this._repository);

  Future<UserEntity> execute({
    required String correo,
    required String contrasena,
  }) {
    return _repository.signIn(
      correo: correo,
      contrasena: contrasena,
    );
  }
}