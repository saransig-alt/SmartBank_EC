import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/user_model.dart';

/// DataSource remoto para operaciones de autenticación con Firebase Auth.
class AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  AuthRemoteDataSource({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    FirebaseStorage? storage,
  })  : _auth = auth,
        _firestore = firestore,
        _storage = storage ?? FirebaseStorage.instance;

  /// Registra un nuevo usuario en Firebase Auth.
  Future<UserCredential> signUpWithEmail({
    required String correo,
    required String contrasena,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: correo,
        password: contrasena,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw ServerException('Error inesperado al registrar: $e');
    }
  }

  /// Inicia sesión con correo y contraseña.
  Future<UserCredential> signInWithEmail({
    required String correo,
    required String contrasena,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: correo,
        password: contrasena,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw ServerException('Error inesperado al iniciar sesión: $e');
    }
  }

  /// Cierra la sesión del usuario actual.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Envía un correo de recuperación de contraseña.
  Future<void> sendPasswordResetEmail({required String correo}) async {
    try {
      await _auth.sendPasswordResetEmail(email: correo);
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw ServerException('Error inesperado: $e');
    }
  }

  /// Obtiene el UID del usuario actualmente autenticado (si existe).
  String? getCurrentUid() {
    return _auth.currentUser?.uid;
  }

  /// Guarda el perfil del usuario en Firestore.
  Future<void> saveUserProfile(UserModel user) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(user.toMap());
    } catch (e) {
      throw ServerException('Error al guardar perfil: $e');
    }
  }

  /// Actualiza los campos del perfil del usuario en Firestore.
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw ServerException('Error al actualizar perfil: $e');
    }
  }

  /// Obtiene el perfil del usuario desde Firestore.
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw ServerException('Error al obtener perfil: $e');
    }
  }

  /// Sube una foto de perfil a Firebase Storage y retorna la URL de descarga.
  Future<String> uploadProfilePhoto({
    required String uid,
    required List<int> imageBytes,
    required String extension,
  }) async {
    try {
      final ref = _storage.ref().child('fotos_perfil/$uid.$extension');
      final uploadTask = ref.putData(
        Uint8List.fromList(imageBytes),
        SettableMetadata(contentType: 'image/$extension'),
      );
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw ServerException('Error al subir foto: $e');
    }
  }

  /// Mapea errores de Firebase Auth a excepciones de la aplicación.
  AuthException _mapAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return const AuthException('Este correo ya está registrado.', code: 'email-already-in-use');
      case 'invalid-email':
        return const AuthException('El formato del correo no es válido.', code: 'invalid-email');
      case 'weak-password':
        return const AuthException('La contraseña debe tener al menos 6 caracteres.', code: 'weak-password');
      // Nuevo código unificado de Firebase para credenciales incorrectas
      case 'invalid-credential':
      case 'INVALID_LOGIN_CREDENTIALS':
        return const AuthException('Correo o contraseña incorrectos.', code: 'invalid-credential');
      case 'user-not-found':
        return const AuthException('No existe una cuenta con este correo.', code: 'user-not-found');
      case 'wrong-password':
        return const AuthException('Contraseña incorrecta.', code: 'wrong-password');
      case 'user-disabled':
        return const AuthException('Esta cuenta ha sido deshabilitada.', code: 'user-disabled');
      case 'too-many-requests':
        return const AuthException('Demasiados intentos fallidos. Intenta más tarde.', code: 'too-many-requests');
      case 'network-request-failed':
        return const AuthException('Error de conexión. Verifica tu internet.', code: 'network-request-failed');
      case 'operation-not-allowed':
        return const AuthException('Este método de inicio de sesión no está habilitado.', code: 'operation-not-allowed');
      default:
        // Mostrar el mensaje real de Firebase como último recurso
        return AuthException(
          e.message ?? 'Error de autenticación (${e.code}).',
          code: e.code,
        );
    }
  }
}