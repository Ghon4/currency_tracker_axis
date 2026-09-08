import 'package:currency_tracker_axis/core/constants/app_constants.dart';
import 'package:currency_tracker_axis/core/error/error_mapper.dart';

/// Retry helper for transient network/server failures.
///
/// Retries at most [AppConstants.maxRetries] times with exponential backoff
/// (`300ms * attempt`). Parse, empty, and cache failures are never retried.
class RetryPolicy {
  RetryPolicy._();

  static const ErrorMapper _errorMapper = ErrorMapper();

  /// Runs [action], retrying when the thrown error maps to a retryable
  /// [Failure].
  static Future<T> execute<T>(Future<T> Function() action) async {
    var attempt = 0;
    while (true) {
      try {
        return await action();
      } catch (error) {
        final failure = _errorMapper.map(error);
        final canRetry =
            failure.isRetryable && attempt < AppConstants.maxRetries;
        if (!canRetry) rethrow;

        attempt++;
        await Future<void>.delayed(AppConstants.retryBaseDelay * attempt);
      }
    }
  }
}
