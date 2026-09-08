import 'package:equatable/equatable.dart';

/// Domain model for a foreign currency quoted against EGP.
class CurrencyRate extends Equatable {
  const CurrencyRate({
    required this.code,
    required this.name,
    required this.rate,
    required this.change,
    required this.changePercentage,
    required this.lastUpdated,
    this.isFromCache = false,
  });

  /// ISO currency code (e.g. `USD`).
  final String code;

  /// Display name (e.g. `US Dollar`).
  final String name;

  /// EGP per 1 foreign unit (inverted from API raw value).
  final double rate;

  /// Absolute day-over-day change in inverted rate.
  ///
  /// Null when yesterday's rate is unavailable.
  final double? change;

  /// Percentage day-over-day change.
  ///
  /// Null when yesterday's rate is unavailable.
  final double? changePercentage;

  /// When the underlying API snapshot was taken / last known.
  final DateTime lastUpdated;

  /// Whether this value was served from local cache.
  final bool isFromCache;

  /// Whether day-over-day change fields are present.
  bool get hasChange => change != null && changePercentage != null;

  /// Fewer EGP per foreign unit ⇒ EGP strengthened.
  bool get isEgpStrengthening => (change ?? 0) < 0;

  /// More EGP per foreign unit ⇒ EGP weakened.
  bool get isEgpWeakening => (change ?? 0) > 0;

  @override
  List<Object?> get props => [
        code,
        name,
        rate,
        change,
        changePercentage,
        lastUpdated,
        isFromCache,
      ];
}
