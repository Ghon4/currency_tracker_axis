import 'package:dio/dio.dart';
import 'package:hive/hive.dart';

import 'package:currency_tracker_axis/core/error/error_messages.dart';
import 'package:currency_tracker_axis/core/error/exceptions.dart';
import 'package:currency_tracker_axis/core/error/failures.dart';

/// Maps low-level errors (exceptions, Dio, Hive) into domain [Failure]s.
class ErrorMapper {
  const ErrorMapper();

  Failure map(Object error, [StackTrace? _]) {
    if (error is Failure) return error;
    if (error is NetworkException) {
      return Failure.network(error.message ?? ErrorMessages.network);
    }
    if (error is RequestTimeoutException) {
      return Failure.timeout(error.message ?? ErrorMessages.timeout);
    }
    if (error is ServerException) {
      return Failure.server(
        error.message ?? ErrorMessages.server,
        error.statusCode,
      );
    }
    if (error is CacheException) {
      return Failure.cache(error.message ?? ErrorMessages.cache);
    }
    if (error is ParseException) {
      return Failure.parse(error.message ?? ErrorMessages.parse);
    }
    if (error is EmptyDataException) {
      return Failure.empty(error.message ?? ErrorMessages.empty);
    }
    if (error is RateUnavailableException) {
      return Failure.empty(error.message ?? ErrorMessages.rateUnavailable);
    }
    if (error is InvalidRateException) {
      return Failure.parse(error.message ?? ErrorMessages.parse);
    }
    if (error is DioException) return _fromDio(error);
    if (error is HiveError) {
      return Failure.cache(error.message);
    }
    if (error is FormatException) {
      return Failure.parse(error.message);
    }
    return Failure.unknown(error.toString());
  }

  Failure _fromDio(DioException e) {
    // Prefer already-mapped domain exceptions from ErrorMappingInterceptor.
    final nested = e.error;
    if (nested is NetworkException) {
      return Failure.network(nested.message ?? ErrorMessages.network);
    }
    if (nested is RequestTimeoutException) {
      return Failure.timeout(nested.message ?? ErrorMessages.timeout);
    }
    if (nested is ServerException) {
      return Failure.server(
        nested.message ?? ErrorMessages.server,
        nested.statusCode,
      );
    }
    if (nested is ParseException) {
      return Failure.parse(nested.message ?? ErrorMessages.parse);
    }
    if (nested is CacheException) {
      return Failure.cache(nested.message ?? ErrorMessages.cache);
    }
    if (nested is EmptyDataException) {
      return Failure.empty(nested.message ?? ErrorMessages.empty);
    }
    if (nested is RateUnavailableException) {
      return Failure.empty(nested.message ?? ErrorMessages.rateUnavailable);
    }
    if (nested is InvalidRateException) {
      return Failure.parse(nested.message ?? ErrorMessages.parse);
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Failure.timeout(e.message ?? ErrorMessages.timeout);
      case DioExceptionType.connectionError:
        return Failure.network(e.message ?? ErrorMessages.network);
      case DioExceptionType.badResponse:
        return Failure.server(
          e.message ?? ErrorMessages.server,
          e.response?.statusCode,
        );
      case DioExceptionType.cancel:
        return const Failure.unknown('Request cancelled');
      case DioExceptionType.badCertificate:
        return Failure.network(e.message ?? ErrorMessages.network);
      case DioExceptionType.unknown:
      case DioExceptionType.transformTimeout:
        return Failure.network(e.message ?? ErrorMessages.network);
    }
  }
}
