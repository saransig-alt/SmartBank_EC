import 'package:equatable/equatable.dart';

/// Modelo de datos para transacciones en Firestore (DTO).
/// Incluye serialización/deserialización JSON.
class TransactionModel extends Equatable {
  final String id;
  final String fecha;
  final String hora;
  final String tipo;
  final double monto;
  final String cuentaOrigen;
  final String cuentaDestino;

  const TransactionModel({
    required this.id,
    required this.fecha,
    required this.hora,
    required this.tipo,
    required this.monto,
    required this.cuentaOrigen,
    required this.cuentaDestino,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map, String id) {
    return TransactionModel(
      id: id,
      fecha: map['fecha'] ?? '',
      hora: map['hora'] ?? '',
      tipo: map['tipo'] ?? '',
      monto: (map['monto'] ?? 0.0).toDouble(),
      cuentaOrigen: map['cuentaOrigen'] ?? '',
      cuentaDestino: map['cuentaDestino'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fecha': fecha,
      'hora': hora,
      'tipo': tipo,
      'monto': monto,
      'cuentaOrigen': cuentaOrigen,
      'cuentaDestino': cuentaDestino,
    };
  }

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