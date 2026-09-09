import 'package:dio/dio.dart';

import 'package:currency_tracker_axis/core/error/exceptions.dart';

/// Categories controlling automatic retry behavior.
enum RetryCategory {
  /// Transient connectivity issues — up to 3 attempts with backoff.
  network,

  /// Upstream 5xx / retryable server faults — up to 2 attempts.
  server,

  /// Cache / parse / non-retryable — fail fast (1 attempt).
  none,
}

/// Executes remote work with category-specific retry + exponential backoff.
class RetryPolicy {
  const RetryPolicy();

  /// Runs [action], retrying according to [category].
  Future<T> execute<T>(
    Future<T> Function() action, {
    RetryCategory category = RetryCategory.network,
  }) async {
    final maxAttempts = switch (category) {
      RetryCategory.network => 3,
      RetryCategory.server => 2,
      RetryCategory.none => 1,
    };

    var attempt = 0;
    while (true) {
      attempt++;
      try {
        return await action();
      } catch (e) {
        final retryable = _isRetryable(e, category);
        if (!retryable || attempt >= maxAttempts) rethrow;
        final delay = Duration(milliseconds: 300 * (1 << (attempt - 1)));
        await Future<void>.delayed(delay);
      }
    }
  }

  bool _isRetryable(Object e, RetryCategory category) {
    if (category == RetryCategory.none) return false;
    if (e is CacheException ||
        e is ParseException ||
        e is EmptyDataException ||
        e is RateUnavailableException ||
        e is InvalidRateException) {
      return false;
    }
    if (e is NetworkException) return category == RetryCategory.network;
    if (e is ServerException) {
      final code = e.statusCode ?? 0;
      if (code >= 400 && code < 500 && code != 408) return false;
      return category == RetryCategory.server ||
          category == RetryCategory.network;
    }
    if (e is DioException) {
      return e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionError ||
          (e.response?.statusCode ?? 0) >= 500;
    }
    return false;
  }
}
