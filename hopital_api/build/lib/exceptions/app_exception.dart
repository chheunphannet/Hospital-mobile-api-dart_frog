sealed class AppException implements Exception {
  const AppException(
    this.message, {
    required this.statusCode,
    required this.code,
  });

  final String message;
  final int statusCode;
  final String code;
}

class NotFoundException extends AppException {
  const NotFoundException(String message)
    : super(
        message,
        statusCode: 404,
        code: 'NOT_FOUND',
      ); // : for initializer list
}

class ValidationException extends AppException {
  const ValidationException(String message)
    : super(message, statusCode: 400, code: 'VALIDATION_ERROR');
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([
    String message = 'Unauthorized',
  ]) //Optional Positional
  : super(message, statusCode: 401, code: 'UNAUTHORIZED');
}

class ForbiddenException extends AppException {
  const ForbiddenException([
    String message = 'Forbidden: Insufficient permissions',
  ]) : super(message, statusCode: 403, code: 'FORBIDDEN');
}

class ConflictException extends AppException {
  const ConflictException(String message)
    : super(message, statusCode: 409, code: 'CONFLICT');
}

class TokenExpiredException extends AppException {
  const TokenExpiredException()
    : super('Token expired', statusCode: 401, code: 'TOKEN_EXPIRED');
}
