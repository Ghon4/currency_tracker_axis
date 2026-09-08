import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:currency_tracker_axis/app/router.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/currency_rate.dart';
import 'package:currency_tracker_axis/features/exchange_rates/presentation/widgets/currency_list_item.dart';

/// Scrollable list of [CurrencyRate] rows with pull-to-refresh friendly physics.
class ExchangeRatesList extends StatelessWidget {
  const ExchangeRatesList({super.key, required this.rates});

  final List<CurrencyRate> rates;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      itemCount: rates.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final rate = rates[index];
        return CurrencyListItem(
          key: ValueKey(rate.code),
          rate: rate,
          onTap: () => context.push(
            AppRoutes.currencyDetailLocation(rate.code),
          ),
        );
      },
    );
  }
}
