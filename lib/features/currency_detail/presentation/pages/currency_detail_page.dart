import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:currency_tracker_axis/core/widgets/error_view.dart';
import 'package:currency_tracker_axis/features/currency_detail/presentation/bloc/currency_detail_bloc.dart';
import 'package:currency_tracker_axis/features/currency_detail/presentation/widgets/chart_error_widget.dart';
import 'package:currency_tracker_axis/features/currency_detail/presentation/widgets/chart_shimmer.dart';
import 'package:currency_tracker_axis/features/currency_detail/presentation/widgets/currency_header.dart';
import 'package:currency_tracker_axis/features/currency_detail/presentation/widgets/detail_loading_widget.dart';
import 'package:currency_tracker_axis/features/currency_detail/presentation/widgets/historical_chart.dart';

/// Currency detail screen: header + 7-day historical chart.
class CurrencyDetailPage extends StatelessWidget {
  const CurrencyDetailPage({
    super.key,
    required this.currencyCode,
  });

  /// ISO currency code from the route (`USD`, `EUR`, …).
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currencyCode.toUpperCase()),
      ),
      body: BlocBuilder<CurrencyDetailBloc, CurrencyDetailState>(
        builder: (context, state) {
          return switch (state) {
            CurrencyDetailInitial() || CurrencyDetailLoading() =>
              const DetailLoadingWidget(),
            CurrencyDetailFullError(:final message) => AppErrorView(
                message: message,
                onRetry: () => context.read<CurrencyDetailBloc>().add(
                      LoadDetail(currencyCode: currencyCode),
                    ),
              ),
            CurrencyDetailHeaderLoaded(:final header) => _DetailBody(
                header: header,
                chart: const ChartShimmer(),
              ),
            CurrencyDetailSuccess(:final header, :final points) => _DetailBody(
                header: header,
                chart: HistoricalChart(points: points),
              ),
            CurrencyDetailChartError(:final header, :final message) =>
              _DetailBody(
                header: header,
                chart: ChartErrorView(
                  message: message,
                  onRetry: () => context
                      .read<CurrencyDetailBloc>()
                      .add(const RefreshDetail()),
                ),
              ),
          };
        },
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.header, required this.chart});

  final CurrencyDetailHeaderData header;
  final Widget chart;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        final bloc = context.read<CurrencyDetailBloc>();
        bloc.add(const RefreshDetail());
        await bloc.stream.firstWhere(
          (s) =>
              s is CurrencyDetailSuccess ||
              s is CurrencyDetailChartError ||
              s is CurrencyDetailFullError,
        );
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          CurrencyHeader(data: header),
          const SizedBox(height: 24),
          Text(
            'Last 7 days',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 240,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: KeyedSubtree(
                key: ValueKey(chart.runtimeType),
                child: chart,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
