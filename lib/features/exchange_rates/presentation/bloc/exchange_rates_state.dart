part of 'exchange_rates_bloc.dart';

sealed class ExchangeRatesState extends Equatable {
  const ExchangeRatesState();

  @override
  List<Object?> get props => [];
}

final class ExchangeRatesInitial extends ExchangeRatesState {
  const ExchangeRatesInitial();
}

final class ExchangeRatesLoading extends ExchangeRatesState {
  const ExchangeRatesLoading({this.previousRates});

  /// Optional prior list kept visible under a refresh overlay.
  final List<CurrencyRate>? previousRates;

  @override
  List<Object?> get props => [previousRates];
}

final class ExchangeRatesSuccess extends ExchangeRatesState {
  const ExchangeRatesSuccess({
    required this.rates,
    required this.isFromCache,
    required this.lastUpdated,
  });

  final List<CurrencyRate> rates;
  final bool isFromCache;
  final DateTime lastUpdated;

  @override
  List<Object?> get props => [rates, isFromCache, lastUpdated];
}

final class ExchangeRatesError extends ExchangeRatesState {
  const ExchangeRatesError({
    required this.message,
    this.retryable = true,
  });

  final String message;
  final bool retryable;

  @override
  List<Object?> get props => [message, retryable];
}

final class ExchangeRatesEmpty extends ExchangeRatesState {
  const ExchangeRatesEmpty({this.message = 'No exchange rates available.'});

  final String message;

  @override
  List<Object?> get props => [message];
}
