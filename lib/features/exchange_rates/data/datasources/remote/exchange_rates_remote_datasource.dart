import 'package:dio/dio.dart';

import 'package:currency_tracker_axis/core/constants/app_constants.dart';
import 'package:currency_tracker_axis/core/error/exceptions.dart';
import 'package:currency_tracker_axis/core/error/retry_policy.dart';
import 'package:currency_tracker_axis/core/network/dio_client.dart';
import 'package:currency_tracker_axis/core/utils/date_utils.dart';
import 'package:currency_tracker_axis/features/exchange_rates/data/models/exchange_rates_response.dart';

/// Remote data source contract for currency API calls.
abstract class ExchangeRatesRemoteDataSource {
  /// Fetches the latest rates snapshot for the base currency.
  Future<ExchangeRatesResponse> getLatestRates({CancelToken? cancelToken});

  /// Fetches rates for a specific UTC calendar [date].
  Future<ExchangeRatesResponse> getHistoricalRates(
    DateTime date, {
    CancelToken? cancelToken,
  });
}

/// Dio-backed implementation of [ExchangeRatesRemoteDataSource].
class ExchangeRatesRemoteDataSourceImpl
    implements ExchangeRatesRemoteDataSource {
  ExchangeRatesRemoteDataSourceImpl(
    this._client, {
    RetryPolicy retryPolicy = const RetryPolicy(),
  }) : _retry = retryPolicy;

  final DioClient _client;
  final RetryPolicy _retry;

  @override
  Future<ExchangeRatesResponse> getLatestRates({
    CancelToken? cancelToken,
  }) {
    return _retry.execute(
      () => _fetch(AppConstants.latestRatesUrl(), cancelToken: cancelToken),
      category: RetryCategory.network,
    );
  }

  @override
  Future<ExchangeRatesResponse> getHistoricalRates(
    DateTime date, {
    CancelToken? cancelToken,
  }) {
    final apiDate = AppDateUtils.toApiDate(date);
    final url = AppConstants.historicalRatesUrl(apiDate);
    return _retry.execute(
      () => _fetch(url, cancelToken: cancelToken),
      category: RetryCategory.network,
    );
  }

  Future<ExchangeRatesResponse> _fetch(
    String url, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        url,
        cancelToken: cancelToken,
      );
      return _parse(response.data);
    } on NetworkException {
      rethrow;
    } on ServerException {
      rethrow;
    } on ParseException {
      rethrow;
    } on EmptyDataException {
      rethrow;
    } on DioException catch (e) {
      throw _mapDio(e);
    } catch (e) {
      throw ParseException(message: e.toString());
    }
  }

  ExchangeRatesResponse _parse(Map<String, dynamic>? data) {
    if (data == null) {
      throw const EmptyDataException(message: 'Empty response body');
    }
    try {
      return ExchangeRatesResponse.fromJson(data);
    } catch (e) {
      throw ParseException(message: e.toString());
    }
  }

  Exception _mapDio(DioException e) {
    final nested = e.error;
    if (nested is NetworkException ||
        nested is ServerException ||
        nested is ParseException ||
        nested is EmptyDataException ||
        nested is CacheException ||
        nested is RequestTimeoutException) {
      return nested as Exception;
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const RequestTimeoutException(message: 'Request timed out');
      case DioExceptionType.connectionError:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
      case DioExceptionType.transformTimeout:
        return NetworkException(message: e.message);
      case DioExceptionType.badResponse:
        return ServerException(
          message: e.message,
          statusCode: e.response?.statusCode,
        );
      case DioExceptionType.cancel:
        return const NetworkException(message: 'Request was cancelled.');
    }
  }
}
