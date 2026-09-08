import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:currency_tracker_axis/core/error/exceptions.dart';

part 'failures.freezed.dart';

/// Domain-level failure types surfaced to presentation layers.
@freezed
abstract class Failure with _$Failure {
  const Failure._();

  const factory Failure.network([String? message]) = NetworkFailure;
  const factory Failure.server([String? message, int? statusCode]) =
      ServerFailure;
  const factory Failure.cache([String? message]) = CacheFailure;
  const factory Failure.parse([String? message]) = ParseFailure;
  const factory Failure.empty([String? message]) = EmptyDataFailure;
  const factory Failure.unexpected([String? message]) = UnexpectedFailure;

  /// User-facing message suitable for snackbars / error views.
  String get userMessage => when(
        network: (m) =>
            m ?? 'No internet connection. Showing cached data if available.',
        server: (m, _) => m ?? 'Could not reach the exchange rates service.',
        cache: (m) => m ?? 'Could not read local cache.',
        parse: (m) => m ?? 'Received unexpected data from the server.',
        empty: (m) => m ?? 'No exchange rate data available.',
        unexpected: (m) => m ?? 'Something went wrong. Please try again.',
      );

  /// Whether this failure is eligible for automatic retry.
  bool get isRetryable => maybeWhen(
        network: (_) => true,
        server: (_, _) => true,
        orElse: () => false,
      );
}

/// Maps low-level [Exception]s (and unknown errors) to [Failure].
Failure mapExceptionToFailure(Object error) {
  if (error is NetworkException) return Failure.network(error.message);
  if (error is ServerException) {
    return Failure.server(error.message, error.statusCode);
  }
  if (error is CacheException) return Failure.cache(error.message);
  if (error is ParseException) return Failure.parse(error.message);
  if (error is EmptyDataException) return Failure.empty(error.message);
  return Failure.unexpected(error.toString());
}
