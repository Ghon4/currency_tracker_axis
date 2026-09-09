import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:currency_tracker_axis/core/constants/app_constants.dart';

/// Amber banner shown when the list is served from local cache.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({
    super.key,
    required this.lastUpdated,
    this.isStale = false,
  });

  final DateTime lastUpdated;

  /// When true, highlights that the cache is older than 24 hours.
  final bool isStale;

  @override
  Widget build(BuildContext context) {
    final formatted = DateFormat(AppConstants.displayDateTimeFormat)
        .format(lastUpdated.toLocal());
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Material(
      color: isStale ? const Color(0xFFF59E0B) : const Color(0xFFFBBF24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(
              isStale ? Icons.warning_amber_rounded : Icons.cloud_off,
              size: 18,
              color: onSurface,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isStale
                    ? 'Offline — Stale data. Last updated: $formatted'
                    : 'Offline — Last updated: $formatted',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: onSurface,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
