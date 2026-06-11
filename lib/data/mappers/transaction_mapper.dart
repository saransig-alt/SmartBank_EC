import '../../domain/entities/transaction_entity.dart';
import '../models/transaction_model.dart';

/// Mapper para convertir entre [TransactionEntity] (dominio) y [TransactionModel] (datos).
class TransactionMapper {
  TransactionMapper._();

  /// Convierte de Model a Entity (de datos a dominio).
  static TransactionEntity toEntity(TransactionModel model) {
    return TransactionEntity(
      id: model.id,
      fecha: model.fecha,
      hora: model.hora,
      tipo: model.tipo,
      monto: model.monto,
      cuentaOrigen: model.cuentaOrigen,
      cuentaDestino: model.cuentaDestino,
    );
  }

  /// Convierte de Entity a Model (de dominio a datos).
  static TransactionModel toModel(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      fecha: entity.fecha,
      hora: entity.hora,
      tipo: entity.tipo,
      monto: entity.monto,
      cuentaOrigen: entity.cuentaOrigen,
      cuentaDestino: entity.cuentaDestino,
    );
  }
}