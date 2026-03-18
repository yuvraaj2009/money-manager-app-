class AppException implements Exception {
  final String message;
  final String code;
  final int? statusCode;

  AppException({
    required this.message,
    this.code = 'UNKNOWN',
    this.statusCode,
  });

  @override
  String toString() => 'AppException($code): $message';
}

class NetworkException extends AppException {
  NetworkException({super.message = 'Network error. Check your connection.'})
      : super(code: 'NETWORK_ERROR');
}

class AuthException extends AppException {
  AuthException({super.message = 'Authentication failed.'})
      : super(code: 'AUTH_ERROR', statusCode: 401);
}

class ServerException extends AppException {
  ServerException({
    super.message = 'Server error.',
    super.code = 'SERVER_ERROR',
    super.statusCode,
  });
}

class ValidationException extends AppException {
  ValidationException({super.message = 'Validation error.'})
      : super(code: 'VALIDATION_ERROR', statusCode: 422);
}
