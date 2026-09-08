import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:currency_tracker_axis/core/constants/app_constants.dart';

/// Amber banner shown when the list is served from local cache.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, required this.lastUpdated});

  final DateTime lastUpdated;

  @override
  Widget build(BuildContext context) {
    final formatted = DateFormat(AppConstants.displayDateTimeFormat)
        .format(lastUpdated.toLocal());

    return Material(
      color: const Color(0xFFFBBF24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(
              Icons.cloud_off,
              size: 18,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Offline — Showing cached data from $formatted',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
