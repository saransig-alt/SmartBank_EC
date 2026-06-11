class UserModel {
  final String uid;
  final String nombres;
  final String apellidos;
  final String correo;
  final String telefono;
  final String numeroCuenta;
  final double saldo;

  UserModel({
    required this.uid,
    required this.nombres,
    required this.apellidos,
    required this.correo,
    required this.telefono,
    required this.numeroCuenta,
    required this.saldo,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      nombres: map['nombres'] ?? '',
      apellidos: map['apellidos'] ?? '',
      correo: map['correo'] ?? '',
      telefono: map['telefono'] ?? '',
      numeroCuenta: map['numeroCuenta'] ?? '',
      saldo: (map['saldo'] ?? 0.0).toDouble(),
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
    };
  }
}