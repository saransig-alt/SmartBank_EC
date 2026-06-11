/// Clase base para excepciones específicas de la aplicación.
/// Estas son usadas internamente en la capa de datos.
class ServerException implements Exception {
  final String message;
  final String? code;
  const ServerException(this.message, {this.code});

  @override
  String toString() => 'ServerException: $message (code: $code)';
}

/// Excepción lanzada cuando falla la autenticación con Firebase.
class AuthException implements Exception {
  final String message;
  final String? code;
  const AuthException(this.message, {this.code});

  @override
  String toString() => 'AuthException: $message (code: $code)';
}

/// Excepción lanzada cuando no se encuentra un recurso en Firestore.
class NotFoundException implements Exception {
  final String message;
  const NotFoundException(this.message);

  @override
  String toString() => 'NotFoundException: $message';
}

/// Excepción lanzada cuando hay un error de caché local.
class CacheException implements Exception {
  final String message;
  const CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}

/// Excepción lanzada cuando ocurre un error en operaciones bancarias.
class BankException implements Exception {
  final String message;
  const BankException(this.message);

  @override
  String toString() => 'BankException: $message';
}
