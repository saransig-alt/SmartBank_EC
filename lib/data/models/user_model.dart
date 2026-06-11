import 'package:equatable/equatable.dart';
import '../../core/constants/app_constants.dart';

/// Modelo de datos para Firestore (DTO).
/// Incluye serialización/deserialización JSON.
class UserModel extends Equatable {
  final String uid;
  final String nombres;
  final String apellidos;
  final String correo;
  final String telefono;
  final String numeroCuenta;
  final double saldo;
  final String? photoUrl;
  final List<String> favoritos;

  const UserModel({
    required this.uid,
    required this.nombres,
    required this.apellidos,
    required this.correo,
    required this.telefono,
    required this.numeroCuenta,
    required this.saldo,
    this.photoUrl,
    this.favoritos = const [],
  });

  /// Construye un [UserModel] inicial con saldo y bono de bienvenida.
  factory UserModel.initial({
    required String uid,
    required String nombres,
    required String apellidos,
    required String correo,
    required String telefono,
    required String numeroCuenta,
  }) {
    return UserModel(
      uid: uid,
      nombres: nombres,
      apellidos: apellidos,
      correo: correo,
      telefono: telefono,
      numeroCuenta: numeroCuenta,
      saldo: AppConstants.initialBalance,
      photoUrl: null,
      favoritos: const [],
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      nombres: map['nombres'] ?? '',
      apellidos: map['apellidos'] ?? '',
      correo: map['correo'] ?? '',
      telefono: map['telefono'] ?? '',
      numeroCuenta: map['numeroCuenta'] ?? '',
      saldo: (map['saldo'] ?? 0.0).toDouble(),
      photoUrl: map['photoUrl'],
      favoritos: List<String>.from(map['favoritos'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombres': nombres,
      'apellidos': apellidos,
      'correo': correo,
      'telefono': telefono,
      'numeroCuenta': numeroCuenta,
      'saldo': saldo,
      'photoUrl': photoUrl,
      'favoritos': favoritos,
    };
  }

  @override
  List<Object?> get props => [
        uid,
        nombres,
        apellidos,
        correo,
        telefono,
        numeroCuenta,
        saldo,
        photoUrl,
        favoritos,
      ];
}