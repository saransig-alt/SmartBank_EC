import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

/// Mapper para convertir entre [UserEntity] (dominio) y [UserModel] (datos).
class UserMapper {
  UserMapper._();

  /// Convierte de Model a Entity (de datos a dominio).
  static UserEntity toEntity(UserModel model) {
    return UserEntity(
      uid: model.uid,
      nombres: model.nombres,
      apellidos: model.apellidos,
      correo: model.correo,
      telefono: model.telefono,
      numeroCuenta: model.numeroCuenta,
      saldo: model.saldo,
      photoUrl: model.photoUrl,
      favoritos: model.favoritos,
    );
  }

  /// Convierte de Entity a Model (de dominio a datos).
  static UserModel toModel(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      nombres: entity.nombres,
      apellidos: entity.apellidos,
      correo: entity.correo,
      telefono: entity.telefono,
      numeroCuenta: entity.numeroCuenta,
      saldo: entity.saldo,
      photoUrl: entity.photoUrl,
      favoritos: entity.favoritos,
    );
  }
}