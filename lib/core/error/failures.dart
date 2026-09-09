import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:currency_tracker_axis/core/error/error_messages.dart';

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
  const factory Failure.timeout([String? message]) = TimeoutFailure;
  const factory Failure.unknown([String? message]) = UnknownFailure;

  /// User-facing message suitable for snackbars / error views.
  String get userMessage => when(
        network: (m) => m ?? ErrorMessages.network,
        server: (m, _) => m ?? ErrorMessages.server,
        cache: (m) => m ?? ErrorMessages.cache,
        parse: (m) => m ?? ErrorMessages.parse,
        empty: (m) => m ?? ErrorMessages.empty,
        timeout: (m) => m ?? ErrorMessages.timeout,
        unknown: (m) => m ?? ErrorMessages.unexpected,
      );

  /// Whether this failure is eligible for automatic retry.
  bool get isRetryable => maybeWhen(
        network: (_) => true,
        server: (_, _) => true,
        timeout: (_) => true,
        orElse: () => false,
      );
}
