import 'package:equatable/equatable.dart';

/// Domain cache snapshot of inverted rates (EGP per 1 foreign unit).
///
/// Pure Dart — never imports Hive. Hive models live in `core/cache`.
class CachedRates extends Equatable {
  const CachedRates({
    required this.rates,
    required this.yesterdayRates,
    required this.timestamp,
    this.apiDate,
  });

  /// Inverted rates: EGP per 1 unit of foreign currency, keyed by code (USD, …).
  final Map<String, double> rates;

  /// Previous-day inverted rates for change calculations.
  final Map<String, double> yesterdayRates;

  /// When this snapshot was written locally (UTC).
  final DateTime timestamp;

  /// API-reported date (`yyyy-MM-dd`), when available.
  final String? apiDate;

  @override
  List<Object?> get props => [rates, yesterdayRates, timestamp, apiDate];
}
