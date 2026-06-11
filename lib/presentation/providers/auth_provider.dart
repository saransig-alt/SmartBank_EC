import 'package:flutter/material.dart';
import '../../core/di/injection_container.dart' as di;
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/usecases/auth/sign_in_usecase.dart';
import '../../domain/usecases/auth/sign_up_usecase.dart';
import '../../domain/usecases/auth/sign_out_usecase.dart';
import '../../domain/usecases/auth/reset_password_usecase.dart';
import '../../domain/usecases/auth/update_profile_usecase.dart';
import 'bank_provider.dart';


class AuthProvider extends ChangeNotifier {
  final SignInUseCase _signInUseCase = di.sl<SignInUseCase>();
  final SignUpUseCase _signUpUseCase = di.sl<SignUpUseCase>();
  final SignOutUseCase _signOutUseCase = di.sl<SignOutUseCase>();
  final ResetPasswordUseCase _resetPasswordUseCase = di.sl<ResetPasswordUseCase>();
  final UpdateProfileUseCase _updateProfileUseCase = di.sl<UpdateProfileUseCase>();

  UserEntity? _currentUser;
  bool _isLoading = false;

  UserEntity? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

 
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
      _currentUser = await _signUpUseCase.execute(
        nombres: nombres,
        apellidos: apellidos,
        correo: correo,
        telefono: telefono,
        contrasena: contrasena,
      );

      // Refrescar listeners de datos bancarios
      if (_currentUser != null) {
        bankProvider.escucharUsuarioDatos(_currentUser!.uid);
      }

      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _setLoading(false);
    }
  }

 
  Future<String?> iniciarSesion({
    required String correo,
    required String contrasena,
    required BankProvider bankProvider,
  }) async {
    _setLoading(true);
    try {
      _currentUser = await _signInUseCase.execute(
        correo: correo,
        contrasena: contrasena,
      );

    
      if (_currentUser != null) {
        bankProvider.escucharUsuarioDatos(_currentUser!.uid);
      }

      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> cerrarSesion() async {
    await _signOutUseCase.execute();
    _currentUser = null;
    notifyListeners();
  }


  Future<String?> resetPassword({required String correo}) async {
    _setLoading(true);
    try {
      await _resetPasswordUseCase.execute(correo: correo);
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _setLoading(false);
    }
  }

  
  Future<String?> updateProfile({
    required String nombres,
    required String apellidos,
    required String correo,
    required String telefono,
    String? photoUrl,
  }) async {
    if (_currentUser == null) return 'Usuario no autenticado';

    _setLoading(true);
    try {
      final updated = UserEntity(
        uid: _currentUser!.uid,
        nombres: nombres,
        apellidos: apellidos,
        correo: correo,
        telefono: telefono,
        numeroCuenta: _currentUser!.numeroCuenta,
        saldo: _currentUser!.saldo,
        photoUrl: photoUrl ?? _currentUser!.photoUrl,
        favoritos: _currentUser!.favoritos,
      );

      await _updateProfileUseCase.execute(updated);

  
      final repo = di.sl<IAuthRepository>();
      _currentUser = await repo.getCurrentUser();

      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadCurrentUser({required BankProvider bankProvider}) async {
    try {
      final repo = di.sl<IAuthRepository>();
      _currentUser = await repo.getCurrentUser();
    } catch (_) {
      _currentUser = null;
    }

    if (_currentUser != null) {
      bankProvider.escucharUsuarioDatos(_currentUser!.uid);
    }

    notifyListeners();
  }
}
