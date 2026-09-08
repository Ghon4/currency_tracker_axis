/// Thrown when the remote API returns an unexpected HTTP status or payload.
class ServerException implements Exception {
  const ServerException({this.message, this.statusCode});

  final String? message;
  final int? statusCode;

  @override
  String toString() =>
      'ServerException(message: $message, statusCode: $statusCode)';
}

/// Thrown when the device is offline or a connection cannot be established.
class NetworkException implements Exception {
  const NetworkException({this.message});

  final String? message;

  @override
  String toString() => 'NetworkException(message: $message)';
}

/// Thrown when reading from or writing to local cache fails.
class CacheException implements Exception {
  const CacheException({this.message});

  final String? message;

  @override
  String toString() => 'CacheException(message: $message)';
}

/// Thrown when API JSON cannot be parsed into expected models.
class ParseException implements Exception {
  const ParseException({this.message});

  final String? message;

  @override
  String toString() => 'ParseException(message: $message)';
}

/// Thrown when a successful response contains no usable rate data.
class EmptyDataException implements Exception {
  const EmptyDataException({this.message});

  final String? message;

  @override
  String toString() => 'EmptyDataException(message: $message)';
}
