import 'package:currency_tracker_axis/core/constants/app_constants.dart';
import 'package:currency_tracker_axis/core/error/exceptions.dart';
import 'package:currency_tracker_axis/core/utils/date_utils.dart';
import 'package:currency_tracker_axis/features/exchange_rates/data/models/exchange_rates_response.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/currency_rate.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/historical_point.dart';

/// Maps API DTOs / raw maps into domain entities with rate inversion.
class RateMapper {
  RateMapper._();

  /// Builds [CurrencyRate] list from today's response and optional yesterday map.
  ///
  /// [yesterdayRawFromEgp] uses lowercase keys matching the API (`usd`, …).
  /// Currencies missing from today are skipped. Zero raw rates are skipped
  /// (caller may treat an empty result as [EmptyDataException]).
  static List<CurrencyRate> toCurrencyRates({
    required ExchangeRatesResponse today,
    Map<String, double>? yesterdayRawFromEgp,
    bool isFromCache = false,
    DateTime? lastUpdatedOverride,
  }) {
    final lastUpdated = lastUpdatedOverride ??
        _parseLastUpdated(today.date) ??
        DateTime.now().toUtc();

    final rates = <CurrencyRate>[];

    for (final code in AppConstants.targetCurrencies) {
      final rawKey = code.toLowerCase();
      final rawToday = today.egp[rawKey];
      if (rawToday == null) continue;
      if (rawToday == 0) {
        // Avoid division by zero; skip invalid entry.
        continue;
      }

      final invertedToday = 1 / rawToday;
      var change = 0.0;
      var changePercentage = 0.0;

      final rawYesterday = yesterdayRawFromEgp?[rawKey];
      if (rawYesterday != null && rawYesterday != 0) {
        final invertedYesterday = 1 / rawYesterday;
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
          isFromCache: isFromCache,
        ),
      );
    }

    return rates;
  }

  /// Inverts a raw-from-EGP map into uppercase code → EGP-per-unit.
  static Map<String, double> invertRatesMap(Map<String, double> rawFromEgp) {
    final inverted = <String, double>{};
    rawFromEgp.forEach((key, value) {
      if (value == 0) {
        throw ParseException(
          message: 'Cannot invert zero rate for currency "$key".',
        );
      }
      inverted[key.toUpperCase()] = 1 / value;
    });
    return inverted;
  }

  /// Maps a date + inverted rate into a [HistoricalPoint].
  static HistoricalPoint toHistoricalPoint({
    required DateTime date,
    required double invertedRate,
  }) {
    return HistoricalPoint(date: date, rate: invertedRate);
  }

  static DateTime? _parseLastUpdated(String apiDate) {
    try {
      return AppDateUtils.parseApiDate(apiDate);
    } on FormatException {
      return null;
    }
  }
}
