import 'package:equatable/equatable.dart';

/// Entidad pura del usuario del dominio.
/// No tiene dependencias externas ni de Firebase.
class UserEntity extends Equatable {
  final String uid;
  final String nombres;
  final String apellidos;
  final String correo;
  final String telefono;
  final String numeroCuenta;
  final double saldo;
  final String? photoUrl;
  final List<String> favoritos;

  const UserEntity({
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