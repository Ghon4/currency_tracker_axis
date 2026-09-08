import 'package:currency_tracker_axis/core/constants/app_constants.dart';
import 'package:currency_tracker_axis/core/utils/date_utils.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/cached_rates.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/currency_rate.dart';

/// Presentation mapper from domain [CachedRates] → [CurrencyRate] list.
///
/// Keeps the data-layer [RateMapper] out of the BLoC while mirroring the same
/// inversion / change math already stored in the cache snapshot.
abstract final class CachedRatesPresenter {
  static List<CurrencyRate> map(CachedRates cached) {
    final lastUpdated = _parseLastUpdated(cached.apiDate) ??
        cached.timestamp.toUtc();

    final rates = <CurrencyRate>[];

    for (final code in AppConstants.targetCurrencies) {
      final invertedToday = cached.rates[code];
      if (invertedToday == null || invertedToday == 0) continue;

      double? change;
      double? changePercentage;

      final invertedYesterday = cached.yesterdayRates[code];
      if (invertedYesterday != null && invertedYesterday != 0) {
        change = invertedToday - invertedYesterday;
        changePercentage = (change / invertedYesterday) * 100;
      }

      rates.add(
        CurrencyRate(
          code: code,
          name: AppConstants.currencyNames[code] ?? code,
          rate: invertedToday,
          change: change,
          changePercentage: changePercentage,
          lastUpdated: lastUpdated,
          isFromCache: true,
        ),
      );
    }

    return rates;
  }

  static DateTime? _parseLastUpdated(String? apiDate) {
    if (apiDate == null || apiDate.isEmpty) return null;
    try {
      return AppDateUtils.parseApiDate(apiDate);
    } on FormatException {
      return null;
    }
  }
}
