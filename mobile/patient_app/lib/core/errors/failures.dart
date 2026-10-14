abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server communication error']);
}

class LocationPermissionFailure extends Failure {
  const LocationPermissionFailure(
      [super.message = 'Location permission was denied']);
}
