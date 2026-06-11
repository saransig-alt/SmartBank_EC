import '../../entities/user_entity.dart';
import '../../repositories/i_auth_repository.dart';

/// Caso de uso: Registrar un nuevo usuario.
class SignUpUseCase {
  final IAuthRepository _repository;

  SignUpUseCase(this._repository);

  Future<UserEntity> execute({
    required String nombres,
    required String apellidos,
    required String correo,
    required String telefono,
    required String contrasena,
  }) {
    return _repository.signUp(
      nombres: nombres,
      apellidos: apellidos,
      correo: correo,
      telefono: telefono,
      contrasena: contrasena,
    );
  }
}