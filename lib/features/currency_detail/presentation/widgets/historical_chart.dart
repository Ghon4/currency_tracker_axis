import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:currency_tracker_axis/core/theme/chart_theme.dart';
import 'package:currency_tracker_axis/core/utils/chart_utils.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/historical_point.dart';

/// 7-day (or partial) inverted rate line chart.
class HistoricalChart extends StatelessWidget {
  const HistoricalChart({super.key, required this.points});

  final List<HistoricalPoint> points;

  @override
  Widget build(BuildContext context) {
    final theme = ChartTheme.of(context);
    final sorted = [...points]..sort((a, b) => a.date.compareTo(b.date));

    if (sorted.isEmpty) {
      return const SizedBox.shrink();
    }

    final minY = sorted.map((p) => p.rate).reduce(math.min);
    final maxY = sorted.map((p) => p.rate).reduce(math.max);
    final pad = (maxY - minY) == 0 ? math.max(maxY * 0.01, 0.01) : (maxY - minY) * 0.1;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (sorted.length - 1).toDouble(),
        minY: minY - pad,
        maxY: maxY + pad,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: theme.gridColor,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final i = value.round();
                if (i < 0 || i >= sorted.length) {
                  return const SizedBox.shrink();
                }
                // Avoid crowding when many points: show endpoints + middle.
                if (sorted.length > 4 &&
                    i != 0 &&
                    i != sorted.length - 1 &&
                    i != sorted.length ~/ 2) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    ChartUtils.formatAxisDate(sorted[i].date),
                    style: theme.labelStyle,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              getTitlesWidget: (value, meta) {
                if (value == meta.min || value == meta.max) {
                  return const SizedBox.shrink();
                }
                return Text(
                  ChartUtils.formatAxisRate(value),
                  style: theme.labelStyle,
                  textAlign: TextAlign.right,
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) =>
                Theme.of(context).colorScheme.inverseSurface,
            getTooltipItems: (spots) => spots.map((s) {
              final index = s.x.round().clamp(0, sorted.length - 1);
              final p = sorted[index];
              return LineTooltipItem(
                ChartUtils.formatTooltip(p.date, p.rate),
                theme.tooltipStyle,
              );
            }).toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            curveSmoothness: 0.25,
            color: theme.lineColor,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: 3.5,
                color: theme.pointColor,
                strokeWidth: 0,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.lineColor.withValues(alpha: 0.25),
                  theme.lineColor.withValues(alpha: 0.0),
                ],
              ),
            ),
            spots: [
              for (var i = 0; i < sorted.length; i++)
                FlSpot(i.toDouble(), sorted[i].rate),
            ],
          ),
        ],
      ),
    );
  }
}
