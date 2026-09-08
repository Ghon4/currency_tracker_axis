import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:currency_tracker_axis/features/currency_detail/presentation/pages/currency_detail_page.dart';
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
        builder: (context, state) => const ExchangeRatesPage(),
      ),
      GoRoute(
        path: AppRoutes.currencyDetail,
        name: 'currencyDetail',
        builder: (context, state) {
          final code = state.pathParameters['code'] ?? '';
          return CurrencyDetailPage(code: code);
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
