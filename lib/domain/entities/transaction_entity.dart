import 'package:equatable/equatable.dart';

/// Entidad pura de transacción del dominio.
/// No tiene dependencias externas ni de Firebase.
class TransactionEntity extends Equatable {
  final String id;
  final String fecha;
  final String hora;
  final String tipo;
  final double monto;
  final String cuentaOrigen;
  final String cuentaDestino;

  const TransactionEntity({
    required this.id,
    required this.fecha,
    required this.hora,
    required this.tipo,
    required this.monto,
    required this.cuentaOrigen,
    required this.cuentaDestino,
  });

  @override
  List<Object?> get props => [
        id,
        fecha,
        hora,
        tipo,
        monto,
        cuentaOrigen,
        cuentaDestino,
      ];
}