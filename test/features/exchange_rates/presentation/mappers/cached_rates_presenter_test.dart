import 'package:flutter_test/flutter_test.dart';

import 'package:currency_tracker_axis/core/constants/app_constants.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/cached_rates.dart';
import 'package:currency_tracker_axis/features/exchange_rates/presentation/mappers/cached_rates_presenter.dart';

void main() {
  test('maps cached rates with change math', () {
    final cached = CachedRates(
      rates: const {'USD': 50, 'EUR': 54},
      yesterdayRates: const {'USD': 49, 'EUR': 54},
      timestamp: DateTime.utc(2026, 3, 20),
      apiDate: '2026-03-20',
    );

    final rates = CachedRatesPresenter.map(cached);

    expect(rates.length, 2);
    expect(rates.first.code, 'USD');
    expect(rates.first.name, AppConstants.currencyNames['USD']);
    expect(rates.first.change, closeTo(1, 0.0001));
    expect(rates.first.isFromCache, isTrue);

    final eur = rates.firstWhere((r) => r.code == 'EUR');
    expect(eur.change, 0);
  });
}
