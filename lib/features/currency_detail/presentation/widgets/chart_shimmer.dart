import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Animated shimmer placeholder matching the chart area (not a spinner).
class ChartShimmer extends StatelessWidget {
  const ChartShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    final highlight = Theme.of(context).colorScheme.surfaceContainerLowest;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const CustomPaint(painter: _FakeChartSkeletonPainter()),
      ),
    );
  }
}

/// Draws a baseline + horizontal rules so the shimmer reads as a chart.
class _FakeChartSkeletonPainter extends CustomPainter {
  const _FakeChartSkeletonPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const inset = 16.0;
    final left = inset;
    final right = size.width - inset;
    final top = inset;
    final bottom = size.height - inset;

    // Baseline
    canvas.drawLine(Offset(left, bottom), Offset(right, bottom), paint);

    // Horizontal grid rules
    for (var i = 1; i <= 3; i++) {
      final y = bottom - (bottom - top) * (i / 4);
      canvas.drawLine(Offset(left, y), Offset(right, y), paint);
    }

    // Soft “line series” polyline
    final path = Path()
      ..moveTo(left, bottom - (bottom - top) * 0.35)
      ..lineTo(left + (right - left) * 0.25, bottom - (bottom - top) * 0.55)
      ..lineTo(left + (right - left) * 0.5, bottom - (bottom - top) * 0.4)
      ..lineTo(left + (right - left) * 0.75, bottom - (bottom - top) * 0.7)
      ..lineTo(right, bottom - (bottom - top) * 0.6);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
