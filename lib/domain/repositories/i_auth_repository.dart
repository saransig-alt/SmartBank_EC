import '../entities/user_entity.dart';

/// Contrato abstracto para el repositorio de autenticación.
/// La capa de datos implementará esta interfaz.
abstract class IAuthRepository {
  /// Registra un nuevo usuario con correo y contraseña.
  /// Retorna el [UserEntity] del usuario creado.
  Future<UserEntity> signUp({
    required String nombres,
    required String apellidos,
    required String correo,
    required String telefono,
    required String contrasena,
  });

  /// Inicia sesión con correo y contraseña.
  /// Retorna el [UserEntity] del usuario autenticado.
  Future<UserEntity> signIn({
    required String correo,
    required String contrasena,
  });

  /// Cierra la sesión del usuario actual.
  Future<void> signOut();

  /// Envía correo de recuperación de contraseña.
  Future<void> resetPassword({required String correo});

  /// Obtiene el usuario actualmente autenticado, si existe.
  Future<UserEntity?> getCurrentUser();

  /// Actualiza los datos del perfil del usuario (nombres, apellidos, teléfono, foto, etc).
  Future<void> updateUserProfile(UserEntity user);
}