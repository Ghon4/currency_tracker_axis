import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:currency_tracker_axis/app/theme/app_theme.dart';

/// Shows day-over-day absolute + percent change with EGP-aware colors.
///
/// GREEN when [change] &lt; 0 (EGP strengthening), RED when [change] &gt; 0
/// (EGP weakening). Null change renders an em dash.
class RateChangeIndicator extends StatelessWidget {
  const RateChangeIndicator({
    super.key,
    required this.change,
    required this.changePercentage,
  });

  final double? change;
  final double? changePercentage;

  @override
  Widget build(BuildContext context) {
    if (change == null || changePercentage == null) {
      return Text(
        '—',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
      );
    }

    final colors = AppTheme.rateColors(context);
    final isStrengthening = change! < 0;
    final isWeakening = change! > 0;
    final color = isStrengthening
        ? colors.egpStrengthening
        : isWeakening
            ? colors.egpWeakening
            : Theme.of(context).colorScheme.outline;

    final absStr = NumberFormat('+0.00#;-0.00#', 'en_US').format(change);
    final pctStr =
        NumberFormat('0.00#', 'en_US').format(changePercentage!.abs());
    final arrow = isWeakening
        ? '▲'
        : isStrengthening
            ? '▼'
            : '•';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(arrow, style: TextStyle(color: color, fontSize: 16)),
        Text(
          '$absStr ($pctStr%)',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
        ),
      ],
    );
  }
}
