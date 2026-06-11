import '../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../datasources/remote/bank_remote_datasource.dart';
import '../mappers/user_mapper.dart';
import '../models/user_model.dart';

/// Implementación concreta del repositorio de autenticación.
/// Orquesta AuthRemoteDataSource (Firebase Auth) y BankRemoteDataSource (Firestore).
class AuthRepositoryImpl implements IAuthRepository {
  final AuthRemoteDataSource _authDataSource;
  final BankRemoteDataSource _bankDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource authDataSource,
    required BankRemoteDataSource bankDataSource,
  })  : _authDataSource = authDataSource,
        _bankDataSource = bankDataSource;

  @override
  Future<UserEntity> signUp({
    required String nombres,
    required String apellidos,
    required String correo,
    required String telefono,
    required String contrasena,
  }) async {
    try {
      await _authDataSource.signUpWithEmail(
        correo: correo,
        contrasena: contrasena,
      );

      final uid = _authDataSource.getCurrentUid();
      if (uid == null) {
        throw const AuthFailure('No se pudo crear la sesión del usuario.');
      }

      // Guardar datos iniciales en Firestore (saldo, número de cuenta, bono)
      final userModel = await _bankDataSource.saveInitialUserData(
        uid: uid,
        nombres: nombres,
        apellidos: apellidos,
        correo: correo,
        telefono: telefono,
      );

      return UserMapper.toEntity(userModel);
    } catch (e) {
      if (e is Failure) rethrow;
      // Propagamos el mensaje real en lugar de ocultarlo
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<UserEntity> signIn({
    required String correo,
    required String contrasena,
  }) async {
    try {
      await _authDataSource.signInWithEmail(
        correo: correo,
        contrasena: contrasena,
      );

      final uid = _authDataSource.getCurrentUid();
      if (uid == null) {
        throw const AuthFailure('No se pudo iniciar sesión.');
      }

      UserModel? userModel = await _authDataSource.getUserProfile(uid);

      // Si el usuario existe en Firebase Auth pero NO en Firestore
      // (p. ej. creado directamente desde Firebase Console), creamos el perfil.
      userModel ??= await _bankDataSource.saveInitialUserData(
        uid: uid,
        nombres: correo.split('@').first,
        apellidos: '',
        correo: correo,
        telefono: '',
      );

      return UserMapper.toEntity(userModel);
    } catch (e) {
      if (e is Failure) rethrow;
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _authDataSource.signOut();
    } catch (e) {
      if (e is Failure) rethrow;
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<void> resetPassword({required String correo}) async {
    try {
      await _authDataSource.sendPasswordResetEmail(correo: correo);
    } catch (e) {
      if (e is Failure) rethrow;
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final uid = _authDataSource.getCurrentUid();
      if (uid == null) return null;

      final userModel = await _authDataSource.getUserProfile(uid);
      if (userModel == null) return null;

      return UserMapper.toEntity(userModel);
    } catch (e) {
      if (e is Failure) rethrow;
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<void> updateUserProfile(UserEntity user) async {
    try {
      final userModel = UserMapper.toModel(user);
      await _authDataSource.updateUserProfile(userModel);
    } catch (e) {
      if (e is Failure) rethrow;
      throw AuthFailure(e.toString());
    }
  }
}