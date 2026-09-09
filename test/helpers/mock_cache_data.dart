import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/cached_rates.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/currency_rate.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/historical_point.dart';

/// Shared API-shaped maps for remote datasource / mapper tests.
Map<String, dynamic> mockLatestRatesJson({
  double usd = 0.019227,
  String date = '2026-03-20',
}) {
  return {
    'date': date,
    'egp': {
      'usd': usd,
      'eur': 0.0178,
      'gbp': 0.0149,
      'sar': 0.0721,
      'jpy': 2.89,
    },
  };
}

CachedRates freshCachedRates({DateTime? timestamp}) {
  final ts = timestamp ?? DateTime.now().toUtc();
  return CachedRates(
    rates: const {
      'USD': 52.01,
      'EUR': 56.18,
      'GBP': 67.11,
      'SAR': 13.87,
      'JPY': 0.346,
    },
    yesterdayRates: const {
      'USD': 51.50,
      'EUR': 55.90,
      'GBP': 66.80,
      'SAR': 13.80,
      'JPY': 0.344,
    },
    timestamp: ts,
    apiDate: '2026-03-20',
  );
}

CachedRates staleCachedRates() {
  return freshCachedRates(
    timestamp: DateTime.now().toUtc().subtract(const Duration(hours: 25)),
  );
}

CurrencyRate sampleUsdRate({
  DateTime? lastUpdated,
  bool isFromCache = false,
}) {
  return CurrencyRate(
    code: 'USD',
    name: 'US Dollar',
    rate: 52.01,
    change: 0.51,
    changePercentage: 0.99,
    lastUpdated: lastUpdated ?? DateTime.utc(2026, 3, 20, 12),
    isFromCache: isFromCache,
  );
}

List<HistoricalPoint> sampleHistoryPoints({int count = 7}) {
  final base = DateTime.utc(2026, 3, 14);
  return List.generate(
    count,
    (i) => HistoricalPoint(
      date: base.add(Duration(days: i)),
      rate: 51 + (i * 0.2),
    ),
  );
}
