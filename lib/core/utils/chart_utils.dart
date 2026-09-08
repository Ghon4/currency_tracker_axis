import 'package:intl/intl.dart';

/// Formatting helpers for historical chart axes and tooltips.
class ChartUtils {
  ChartUtils._();

  static final DateFormat _axisDate = DateFormat('MMM d', 'en_US');
  static final DateFormat _tooltipDate = DateFormat('MMM d, yyyy', 'en_US');
  static final NumberFormat _rate = NumberFormat('0.00##', 'en_US');

  /// Short date for the X-axis (e.g. `Sep 3`).
  static String formatAxisDate(DateTime d) => _axisDate.format(d.toLocal());

  /// Rate label for the Y-axis (e.g. `52.01`).
  static String formatAxisRate(double v) => _rate.format(v);

  /// Multi-line tooltip: date + rate in EGP.
  static String formatTooltip(DateTime d, double rate) =>
      '${_tooltipDate.format(d.toLocal())}\n${formatAxisRate(rate)} EGP';
}
