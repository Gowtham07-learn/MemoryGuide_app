abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  final int? statusCode;
  final String? code;
  const ServerFailure([super.message = 'Server communication error', this.statusCode, this.code]);
}

class AuthFailure extends Failure {
  final String code;
  const AuthFailure([super.message = 'Authentication failed', this.code = 'AUTHENTICATION_FAILED']);
}

class LocationPermissionFailure extends Failure {
  const LocationPermissionFailure(
      [super.message = 'Location permission was denied']);
}

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
