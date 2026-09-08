import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:currency_tracker_axis/core/utils/date_utils.dart';
import 'package:currency_tracker_axis/features/currency_detail/presentation/bloc/currency_detail_bloc.dart';
import 'package:currency_tracker_axis/features/exchange_rates/presentation/widgets/rate_change_indicator.dart';

/// Header card: name, rate, daily change, last update, offline chip.
class CurrencyHeader extends StatelessWidget {
  const CurrencyHeader({super.key, required this.data});

  final CurrencyDetailHeaderData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rate = data.rate;
    final formatted = NumberFormat('#,##0.00', 'en_US').format(rate.rate);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(rate.name, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(rate.code, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                RateChangeIndicator(
                  change: rate.change,
                  changePercentage: rate.changePercentage,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '1 ${rate.code} = $formatted EGP',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              'Last updated: ${AppDateUtils.toDisplayDateTime(data.lastUpdated)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (data.isFromCache) ...[
              const SizedBox(height: 12),
              _OfflineChip(lastUpdated: data.lastUpdated),
            ],
          ],
        ),
      ),
    );
  }
}

class _OfflineChip extends StatelessWidget {
  const _OfflineChip({required this.lastUpdated});

  final DateTime lastUpdated;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFBBF24).withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off,
            size: 16,
            color: theme.colorScheme.onSurface,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'Cached · ${AppDateUtils.toDisplayDateTime(lastUpdated)}',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
