class ApiException implements Exception {
  final int statusCode;
  final String code;
  final String message;
  final dynamic details;

  ApiException({
    required this.statusCode,
    required this.code,
    required this.message,
    this.details,
  });

  @override
  String toString() => message;
}

class AuthFailure implements Exception {
  final String message;
  final String code;

  const AuthFailure([this.message = 'Authentication failed', this.code = 'AUTHENTICATION_FAILED']);

  @override
  String toString() => message;
}
