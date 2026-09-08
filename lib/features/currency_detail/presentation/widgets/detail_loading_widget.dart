import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:currency_tracker_axis/features/currency_detail/presentation/widgets/chart_shimmer.dart';

/// Full-page shimmer for header + chart while the first load is in progress.
class DetailLoadingWidget extends StatelessWidget {
  const DetailLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    final highlight = Theme.of(context).colorScheme.surfaceContainerLowest;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Shimmer.fromColors(
          baseColor: base,
          highlightColor: highlight,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Shimmer.fromColors(
          baseColor: base,
          highlightColor: highlight,
          child: Container(
            height: 20,
            width: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const SizedBox(height: 240, child: ChartShimmer()),
      ],
    );
  }
}
