import '../constants/app_constants.dart';

/// Validadores reutilizables para formularios de la aplicación.
class Validators {
  Validators._();

  /// Valida que un campo no esté vacío.
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es requerido';
    }
    return null;
  }

  /// Valida formato de correo electrónico.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingrese su correo';
    }
    if (!value.contains('@') || !value.contains('.')) {
      return 'Formato de correo inválido';
    }
    return null;
  }

  /// Valida contraseña: mínimo 8 caracteres, debe contener letras y números.
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingrese una contraseña';
    }
    if (value.length < AppConstants.minPasswordLength) {
      return 'Mínimo ${AppConstants.minPasswordLength} caracteres';
    }
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(value)) {
      return 'Debe incluir letras y números';
    }
    return null;
  }

  /// Valida monto de transferencia: debe ser número positivo y mayor a cero.
  static String? amount(String? value, {double? maxAmount}) {
    if (value == null || value.isEmpty) {
      return 'Ingrese el monto a enviar';
    }

    final monto = double.tryParse(value);
    if (monto == null || monto <= 0) {
      return 'El monto debe ser un número mayor a cero';
    }

    if (maxAmount != null && monto > maxAmount) {
      return 'Fondos insuficientes. Saldo disponible: \$${maxAmount.toStringAsFixed(2)}';
    }

    return null;
  }

  /// Valida cuenta destino: no vacía y que no sea la propia cuenta.
  static String? destinationAccount(String? value, {String? currentAccount}) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingrese la cuenta de destino';
    }
    if (currentAccount != null && value.trim() == currentAccount) {
      return 'No puede transferirse dinero a su propia cuenta';
    }
    return null;
  }

  /// Valida que un campo de texto no esté vacío (para nombres, teléfono, etc.).
  static String? notEmpty(String? value, [String fieldName = 'Este campo']) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingrese $fieldName';
    }
    return null;
  }
}