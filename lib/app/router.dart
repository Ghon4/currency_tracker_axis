import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:currency_tracker_axis/app/di/dependency_injection.dart';
import 'package:currency_tracker_axis/features/currency_detail/presentation/bloc/currency_detail_bloc.dart';
import 'package:currency_tracker_axis/features/currency_detail/presentation/pages/currency_detail_page.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/currency_rate.dart';
import 'package:currency_tracker_axis/features/exchange_rates/presentation/bloc/exchange_rates_bloc.dart';
import 'package:currency_tracker_axis/features/exchange_rates/presentation/pages/exchange_rates_page.dart';

/// Application route paths.
abstract final class AppRoutes {
  static const String home = '/';
  static const String currencyDetail = '/currency/:code';

  static String currencyDetailLocation(String code) =>
      '/currency/${code.toUpperCase()}';
}

/// GoRouter configuration for the currency tracker shell.
abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        name: 'exchangeRates',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<ExchangeRatesBloc>()..add(const LoadRates()),
          child: const ExchangeRatesPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.currencyDetail,
        name: 'currencyDetail',
        builder: (context, state) {
          final code = state.pathParameters['code'] ?? '';
          final seed =
              state.extra is CurrencyRate ? state.extra as CurrencyRate : null;
          return BlocProvider(
            create: (_) => sl<CurrencyDetailBloc>()
              ..add(LoadDetail(currencyCode: code, seedRate: seed)),
            child: CurrencyDetailPage(currencyCode: code),
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.error?.toString() ?? 'Page not found'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go home'),
            ),
          ],
        ),
      ),
    ),
  );
}
