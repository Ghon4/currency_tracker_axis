import 'package:currency_tracker_axis/core/constants/app_constants.dart';
import 'package:currency_tracker_axis/core/utils/date_utils.dart';
import 'package:currency_tracker_axis/features/exchange_rates/data/models/exchange_rates_response.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/cached_rates.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/currency_rate.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/historical_point.dart';

/// Maps API DTOs / cache snapshots into domain entities with rate inversion.
class RateMapper {
  const RateMapper();

  /// Inverts raw-from-EGP map from [response] into uppercase code → EGP/unit.
  ///
  /// Skips null-equivalent missing keys and zero raw rates.
  Map<String, double> invertedMap(ExchangeRatesResponse response) {
    final inverted = <String, double>{};
    for (final code in AppConstants.targetCurrencies) {
      final rate = invertedRateFor(response, code);
      if (rate != null) {
        inverted[code] = rate;
      }
    }
    return inverted;
  }

  /// Returns inverted EGP-per-unit for [code], or `null` if missing/zero.
  double? invertedRateFor(ExchangeRatesResponse response, String code) {
    final rawKey = code.toLowerCase();
    final raw = response.egp[rawKey];
    if (raw == null || raw == 0) return null;
    return 1 / raw;
  }

  /// Builds [CurrencyRate] list from today's response and optional yesterday
  /// inverted map (uppercase keys).
  ///
  /// When [yesterdayInverted] is null or missing a code, change fields are null.
  List<CurrencyRate> toCurrencyRates(
    ExchangeRatesResponse today, {
    Map<String, double>? yesterdayInverted,
    required bool isFromCache,
    DateTime? lastUpdatedOverride,
  }) {
    final lastUpdated = lastUpdatedOverride ??
        _parseLastUpdated(today.date) ??
        DateTime.now().toUtc();

    final rates = <CurrencyRate>[];

    for (final code in AppConstants.targetCurrencies) {
      final invertedToday = invertedRateFor(today, code);
      if (invertedToday == null) continue;

      double? change;
      double? changePercentage;

      final invertedYesterday = yesterdayInverted?[code];
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
          isFromCache: isFromCache,
        ),
      );
    }

    return rates;
  }

  /// Maps a domain [CachedRates] snapshot into [CurrencyRate] entities.
  List<CurrencyRate> fromCached(
    CachedRates cached, {
    required bool isFromCache,
  }) {
    final lastUpdated = _parseLastUpdated(cached.apiDate ?? '') ??
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
          isFromCache: isFromCache,
        ),
      );
    }

    return rates;
  }

  /// Maps a date + inverted rate into a [HistoricalPoint].
  HistoricalPoint toHistoricalPoint({
    required DateTime date,
    required double invertedRate,
  }) {
    return HistoricalPoint(date: date, rate: invertedRate);
  }

  /// Builds uppercase inverted map from a [CurrencyRate] list.
  Map<String, double> invertedMapFromRates(List<CurrencyRate> rates) {
    return {
      for (final rate in rates) rate.code.toUpperCase(): rate.rate,
    };
  }

  DateTime? _parseLastUpdated(String apiDate) {
    if (apiDate.isEmpty) return null;
    try {
      return AppDateUtils.parseApiDate(apiDate);
    } on FormatException {
      return null;
    }
  }
}
