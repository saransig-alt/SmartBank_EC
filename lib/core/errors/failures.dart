/// Clase base para todos los Failure de la aplicación.
/// Representa errores manejables que la UI puede mostrar.
abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

/// Fracaso relacionado con autenticación.
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Fracaso relacionado con operaciones bancarias (saldo, transferencias, etc.).
class BankFailure extends Failure {
  const BankFailure(super.message);
}

/// Fracaso por datos no encontrados (usuario, cuenta, transacción).
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// Fracaso por validación de entrada.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Fracaso por problemas de red o servidor.
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Error de conexión con el servidor']);
}

/// Fracaso por caché local.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Error al acceder a datos locales']);
}