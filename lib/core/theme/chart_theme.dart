import 'package:flutter/material.dart';

/// Chart colors and typography derived from the ambient [ThemeData].
class ChartTheme {
  const ChartTheme({
    required this.lineColor,
    required this.pointColor,
    required this.gridColor,
    required this.labelStyle,
    required this.tooltipStyle,
  });

  final Color lineColor;
  final Color pointColor;
  final Color gridColor;
  final TextStyle labelStyle;
  final TextStyle tooltipStyle;

  /// Builds chart styling from [context]'s color scheme and text theme.
  static ChartTheme of(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return ChartTheme(
      lineColor: scheme.primary,
      pointColor: scheme.primary,
      gridColor: scheme.outlineVariant.withValues(alpha: 0.5),
      labelStyle: text.bodySmall!.copyWith(color: scheme.onSurfaceVariant),
      tooltipStyle: text.bodySmall!.copyWith(color: scheme.onInverseSurface),
    );
  }
}
