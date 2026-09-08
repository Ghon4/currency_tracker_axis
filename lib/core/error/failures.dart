import 'package:freezed_annotation/freezed_annotation.dart';

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
  const factory Failure.unknown([String? message]) = UnknownFailure;

  /// User-facing message suitable for snackbars / error views.
  String get userMessage => when(
        network: (m) => m ?? 'No internet connection.',
        server: (m, _) => m ?? 'Exchange rates service is unavailable.',
        cache: (m) => m ?? 'Could not read local cache.',
        parse: (m) => m ?? 'Unexpected data from the server.',
        empty: (m) => m ?? 'No exchange rate data available.',
        unknown: (m) => m ?? 'Something went wrong. Please try again.',
      );

  /// Whether this failure is eligible for automatic retry.
  bool get isRetryable => maybeWhen(
        network: (_) => true,
        server: (_, _) => true,
        orElse: () => false,
      );
}
