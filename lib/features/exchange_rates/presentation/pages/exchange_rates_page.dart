import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:currency_tracker_axis/core/widgets/empty_widget.dart';
import 'package:currency_tracker_axis/core/widgets/error_view.dart';
import 'package:currency_tracker_axis/core/widgets/loading_widget.dart';
import 'package:currency_tracker_axis/core/widgets/offline_banner.dart';
import 'package:currency_tracker_axis/features/exchange_rates/presentation/bloc/exchange_rates_bloc.dart';
import 'package:currency_tracker_axis/features/exchange_rates/presentation/widgets/exchange_rates_list.dart';

/// Home screen: exchange rates list with cache-first loading and offline banner.
class ExchangeRatesPage extends StatelessWidget {
  const ExchangeRatesPage({super.key});

  Future<void> _onRefresh(BuildContext context) async {
    final bloc = context.read<ExchangeRatesBloc>();
    bloc.add(const RefreshRates());
    await bloc.stream.firstWhere((s) => s is! ExchangeRatesLoading);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Exchange Rates'),
      ),
      body: BlocConsumer<ExchangeRatesBloc, ExchangeRatesState>(
        listener: (context, state) {
          // Reserved for snackbars on silent refresh failure.
        },
        builder: (context, state) {
          return switch (state) {
            ExchangeRatesInitial() => const RatesShimmerList(),
            ExchangeRatesLoading(:final previousRates)
                when previousRates == null || previousRates.isEmpty =>
              const RatesShimmerList(),
            ExchangeRatesLoading(:final previousRates) => RefreshIndicator(
                onRefresh: () => _onRefresh(context),
                child: ExchangeRatesList(rates: previousRates!),
              ),
            ExchangeRatesSuccess(
              :final rates,
              :final isFromCache,
              :final lastUpdated,
            ) =>
              Column(
                children: [
                  if (isFromCache) OfflineBanner(lastUpdated: lastUpdated),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => _onRefresh(context),
                      child: ExchangeRatesList(rates: rates),
                    ),
                  ),
                ],
              ),
            ExchangeRatesError(:final message, :final retryable) => AppErrorView(
                message: message,
                onRetry: retryable
                    ? () => context
                        .read<ExchangeRatesBloc>()
                        .add(const LoadRates())
                    : null,
              ),
            ExchangeRatesEmpty(:final message) => AppEmptyView(
                message: message,
                onRefresh: () => context
                    .read<ExchangeRatesBloc>()
                    .add(const RefreshRates()),
              ),
          };
        },
      ),
    );
  }
}
