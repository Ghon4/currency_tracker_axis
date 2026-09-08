import 'package:dio/dio.dart';

import 'package:currency_tracker_axis/core/connectivity/connectivity_service.dart';
import 'package:currency_tracker_axis/core/constants/app_constants.dart';
import 'package:currency_tracker_axis/core/network/network_interceptor.dart';

/// Thin Dio wrapper with shared timeouts and interceptors.
///
/// No single [BaseOptions.baseUrl] — latest and historical hosts differ.
class DioClient {
  DioClient({
    Dio? dio,
    required this.connectivity,
  }) : dio = dio ?? Dio() {
    this.dio.options = BaseOptions(
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      sendTimeout: AppConstants.sendTimeout,
      responseType: ResponseType.json,
      headers: const {'Accept': 'application/json'},
    );

    final interceptors = <Interceptor>[
      ConnectivityInterceptor(() => connectivity.isOnline),
      ErrorMappingInterceptor(),
    ];

    final logInterceptor = createDebugLogInterceptor();
    if (logInterceptor != null) {
      interceptors.add(logInterceptor);
    }

    this.dio.interceptors.addAll(interceptors);
  }

  final Dio dio;
  final ConnectivityService connectivity;

  /// Performs a GET against a full [url].
  Future<Response<T>> get<T>(
    String url, {
    CancelToken? cancelToken,
    Map<String, dynamic>? queryParameters,
  }) {
    return dio.get<T>(
      url,
      cancelToken: cancelToken,
      queryParameters: queryParameters,
    );
  }
}
