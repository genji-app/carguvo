abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException({required this.message, this.statusCode});

  @override
  String toString() => message;
}

class ServerException extends AppException {
  const ServerException({required super.message, super.statusCode});
}

class NetworkException extends AppException {
  const NetworkException({super.message = 'No internet connection'});
}

class CacheException extends AppException {
  const CacheException({super.message = 'Cache error occurred'});
}

class ParseException extends AppException {
  const ParseException({super.message = 'Failed to parse data'});
}

class AuthenticationException extends AppException {
  const AuthenticationException({
    super.message = 'Authentication failed',
    super.statusCode = 401,
  });
}

class AuthorizationException extends AppException {
  const AuthorizationException({
    super.message = 'Access denied',
    super.statusCode = 403,
  });
}

class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'Resource not found',
    super.statusCode = 404,
  });
}

class TimeoutException extends AppException {
  const TimeoutException({super.message = 'Request timeout'});
}

class ValidationException extends AppException {
  final Map<String, dynamic>? errors;

  const ValidationException({
    super.message = 'Validation failed',
    super.statusCode = 422,
    this.errors,
  });
}
