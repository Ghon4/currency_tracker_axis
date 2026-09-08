import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/currency_rate.dart';
import 'package:currency_tracker_axis/features/exchange_rates/presentation/widgets/rate_change_indicator.dart';

/// Card row for a single foreign currency vs EGP.
class CurrencyListItem extends StatelessWidget {
  const CurrencyListItem({
    super.key,
    required this.rate,
    this.onTap,
  });

  final CurrencyRate rate;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatted = NumberFormat('#,##0.00##', 'en_US').format(rate.rate);

    return Card(
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rate.name, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(rate.code, style: theme.textTheme.bodySmall),
                    const SizedBox(height: 8),
                    Text(
                      '1 ${rate.code} = $formatted EGP',
                      style: theme.textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              RateChangeIndicator(
                change: rate.change,
                changePercentage: rate.changePercentage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
