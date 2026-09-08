import 'package:dio/dio.dart';
import 'package:hive/hive.dart';

import 'package:currency_tracker_axis/core/error/exceptions.dart';
import 'package:currency_tracker_axis/core/error/failures.dart';

/// Maps low-level errors (exceptions, Dio, Hive) into domain [Failure]s.
class ErrorMapper {
  const ErrorMapper();

  Failure map(Object error, [StackTrace? _]) {
    if (error is Failure) return error;
    if (error is NetworkException) return Failure.network(error.message);
    if (error is ServerException) {
      return Failure.server(error.message, error.statusCode);
    }
    if (error is CacheException) return Failure.cache(error.message);
    if (error is ParseException) return Failure.parse(error.message);
    if (error is EmptyDataException) return Failure.empty(error.message);
    if (error is DioException) return _fromDio(error);
    if (error is HiveError) return Failure.cache(error.message);
    if (error is FormatException) {
      return Failure.parse(error.message);
    }
    return Failure.unknown(error.toString());
  }

  Failure _fromDio(DioException e) {
    // Prefer already-mapped domain exceptions from ErrorMappingInterceptor.
    final nested = e.error;
    if (nested is NetworkException) return Failure.network(nested.message);
    if (nested is ServerException) {
      return Failure.server(nested.message, nested.statusCode);
    }
    if (nested is ParseException) return Failure.parse(nested.message);
    if (nested is CacheException) return Failure.cache(nested.message);
    if (nested is EmptyDataException) return Failure.empty(nested.message);

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return Failure.network(e.message);
      case DioExceptionType.badResponse:
        return Failure.server(
          e.message,
          e.response?.statusCode,
        );
      case DioExceptionType.cancel:
        return const Failure.unknown('Request cancelled');
      case DioExceptionType.badCertificate:
        return Failure.network(e.message);
      case DioExceptionType.unknown:
      case DioExceptionType.transformTimeout:
        return Failure.network(e.message);
    }
  }
}
