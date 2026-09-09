import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/cached_rates.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/historical_point.dart';

/// Session-scoped in-memory cache checked before Hive.
class MemoryRatesCache {
  CachedRates? rates;
  final Map<String, List<HistoricalPoint>> historical = {};

  void saveRates(CachedRates value) => rates = value;

  CachedRates? getRates() => rates;

  void saveHistorical(String code, List<HistoricalPoint> points) {
    historical[code.toUpperCase()] = points;
  }

  List<HistoricalPoint>? getHistorical(String code) =>
      historical[code.toUpperCase()];

  void clear() {
    rates = null;
    historical.clear();
  }
}
