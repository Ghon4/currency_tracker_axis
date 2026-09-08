import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:currency_tracker_axis/core/error/exceptions.dart';

/// Rejects outgoing requests when the device appears offline.
class ConnectivityInterceptor extends Interceptor {
  ConnectivityInterceptor(this._isOnline);

  final bool Function() _isOnline;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!_isOnline()) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: const NetworkException(
            message: 'No internet connection.',
          ),
          message: 'No internet connection.',
        ),
      );
      return;
    }
    handler.next(options);
  }
}

/// Maps [DioException]s into domain [Exception] types for repositories.
class ErrorMappingInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final mapped = _mapDioException(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: mapped,
        message: mapped is Exception ? mapped.toString() : err.message,
      ),
    );
  }

  Object _mapDioException(DioException err) {
    if (err.error is NetworkException ||
        err.error is ServerException ||
        err.error is ParseException) {
      return err.error!;
    }

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return NetworkException(
          message: err.message ?? 'Connection failed. Please try again.',
        );
      case DioExceptionType.badCertificate:
        return const ServerException(
          message: 'Secure connection could not be verified.',
        );
      case DioExceptionType.badResponse:
        return ServerException(
          message: err.response?.statusMessage ??
              'Unexpected response from the server.',
          statusCode: err.response?.statusCode,
        );
      case DioExceptionType.cancel:
        return const NetworkException(message: 'Request was cancelled.');
      case DioExceptionType.unknown:
      case DioExceptionType.transformTimeout:
        return NetworkException(
          message: err.message ?? 'An unexpected network error occurred.',
        );
    }
  }
}

/// Debug-only request/response logger.
Interceptor? createDebugLogInterceptor() {
  if (!kDebugMode) return null;
  return LogInterceptor(
    requestBody: false,
    responseBody: true,
    error: true,
  );
}
