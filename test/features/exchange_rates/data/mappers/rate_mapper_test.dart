import 'package:flutter_test/flutter_test.dart';

import 'package:currency_tracker_axis/features/exchange_rates/data/mappers/rate_mapper.dart';
import 'package:currency_tracker_axis/features/exchange_rates/data/models/exchange_rates_response.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/cached_rates.dart';

void main() {
  const mapper = RateMapper();

  group('RateMapper', () {
    final today = ExchangeRatesResponse(
      date: '2024-01-15',
      egp: const {
        'usd': 0.02, // inverted = 50
        'eur': 0.025, // inverted = 40
        'gbp': 0, // skipped
        // sar missing → skipped
        'jpy': 0.5, // inverted = 2
      },
    );

    test('invertedMap skips null/zero and inverts valid rates', () {
      final inverted = mapper.invertedMap(today);

      expect(inverted, {
        'USD': 50.0,
        'EUR': 40.0,
        'JPY': 2.0,
      });
      expect(inverted.containsKey('GBP'), isFalse);
      expect(inverted.containsKey('SAR'), isFalse);
    });

    test('invertedRateFor returns null for missing or zero', () {
      expect(mapper.invertedRateFor(today, 'USD'), 50.0);
      expect(mapper.invertedRateFor(today, 'GBP'), isNull);
      expect(mapper.invertedRateFor(today, 'SAR'), isNull);
    });

    test('toCurrencyRates leaves change null when yesterday is null', () {
      final rates = mapper.toCurrencyRates(
        today,
        yesterdayInverted: null,
        isFromCache: false,
      );

      expect(rates, isNotEmpty);
      for (final rate in rates) {
        expect(rate.change, isNull);
        expect(rate.changePercentage, isNull);
        expect(rate.hasChange, isFalse);
      }
    });

    test('toCurrencyRates computes change from yesterday inverted map', () {
      final rates = mapper.toCurrencyRates(
        today,
        yesterdayInverted: const {
          'USD': 40.0,
          'EUR': 40.0,
        },
        isFromCache: false,
      );

      final usd = rates.firstWhere((r) => r.code == 'USD');
      expect(usd.rate, 50.0);
      expect(usd.change, 10.0);
      expect(usd.changePercentage, 25.0);
      expect(usd.isEgpWeakening, isTrue);

      final eur = rates.firstWhere((r) => r.code == 'EUR');
      expect(eur.change, 0.0);
      expect(eur.changePercentage, 0.0);

      final jpy = rates.firstWhere((r) => r.code == 'JPY');
      expect(jpy.change, isNull);
      expect(jpy.changePercentage, isNull);
    });

    test('fromCached recomputes change from stored maps', () {
      final cached = CachedRates(
        rates: const {'USD': 50.0, 'EUR': 40.0},
        yesterdayRates: const {'USD': 40.0},
        timestamp: DateTime.utc(2024, 1, 15),
        apiDate: '2024-01-15',
      );

      final rates = mapper.fromCached(cached, isFromCache: true);

      expect(rates.length, 2);
      final usd = rates.firstWhere((r) => r.code == 'USD');
      expect(usd.isFromCache, isTrue);
      expect(usd.change, 10.0);
      expect(usd.changePercentage, 25.0);

      final eur = rates.firstWhere((r) => r.code == 'EUR');
      expect(eur.change, isNull);
    });
  });
}
