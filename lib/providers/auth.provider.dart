import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../providers/bank.provider.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _firebaseUser;
  bool _isLoading = false;

  User? get firebaseUser => _firebaseUser;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Registro de usuario y creación de perfil en Firestore.
  /// - Crea cuenta con Firebase Authentication.
  /// - Genera el perfil en `usuarios/{uid}`.
  /// - Registra saldo inicial y transacción de bono mediante [BankProvider].
  Future<String?> registrarUsuario({
    required String nombres,
    required String apellidos,
    required String correo,
    required String telefono,
    required String contrasena,
    required BankProvider bankProvider,
  }) async {
    _setLoading(true);
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: correo,
        password: contrasena,
      );

      _firebaseUser = credential.user;
      if (_firebaseUser == null) {
        return 'No se pudo crear la sesión del usuario.';
      }

      // Crear datos iniciales en Firestore
      await bankProvider.registrarDatosIniciales(
        uid: _firebaseUser!.uid,
        nombres: nombres,
        apellidos: apellidos,
        correo: correo,
        telefono: telefono,
      );

      // (Opcional) refrescar listeners de saldo/transactions
      bankProvider.escucharUsuarioDatos(_firebaseUser!.uid);

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'Este correo ya está registrado.';
        case 'invalid-email':
          return 'Correo inválido.';
        case 'weak-password':
          return 'La contraseña es muy débil.';
        default:
          return e.message ?? 'Error al registrar usuario.';
      }
    } catch (e) {
      return 'Error inesperado al registrar: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Inicia sesión con correo y contraseña.
  Future<String?> iniciarSesion({
    required String correo,
    required String contrasena,
    required BankProvider bankProvider,
  }) async {
    _setLoading(true);
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: correo,
        password: contrasena,
      );

      _firebaseUser = credential.user;
      if (_firebaseUser == null) {
        return 'No se pudo iniciar sesión.';
      }

      // Escuchar perfil y transacciones del usuario actual
      bankProvider.escucharUsuarioDatos(_firebaseUser!.uid);

      // Garantiza existencia del documento (si no existe, puede ser por datos incompletos)
      final doc = await _firestore.collection('usuarios').doc(_firebaseUser!.uid).get();
      if (!doc.exists) {
        // En este proyecto, el perfil debería existir tras el registro.
        return 'Perfil no encontrado. Registra una cuenta primero.';
      }

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-credential':
        case 'user-not-found':
          return 'Correo o contraseña incorrectos.';
        case 'invalid-email':
          return 'Correo inválido.';
        case 'wrong-password':
          return 'Correo o contraseña incorrectos.';
        default:
          return e.message ?? 'Error al iniciar sesión.';
      }
    } catch (e) {
      return 'Error inesperado al iniciar sesión: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Cierra sesión.
  Future<void> cerrarSesion() async {
    await _auth.signOut();
    _firebaseUser = null;
    notifyListeners();
  }

  /// Recuperación de contraseña por correo.
  Future<String?> resetPassword({required String correo}) async {
    _setLoading(true);
    try {
      await _auth.sendPasswordResetEmail(email: correo);
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return 'Correo inválido.';
        case 'user-not-found':
          return 'No existe una cuenta con ese correo.';
        default:
          return e.message ?? 'Error al enviar correo de recuperación.';
      }
    } catch (e) {
      return 'Error inesperado: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Atajo para saber si el usuario ya está logueado.
  Future<void> loadCurrentUser({required BankProvider bankProvider}) async {
    final user = _auth.currentUser;
    _firebaseUser = user;

    if (_firebaseUser != null) {
      bankProvider.escucharUsuarioDatos(_firebaseUser!.uid);
    }

    notifyListeners();
  }
}

