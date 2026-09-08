part of 'exchange_rates_bloc.dart';

sealed class ExchangeRatesEvent extends Equatable {
  const ExchangeRatesEvent();

  @override
  List<Object?> get props => [];
}

/// Initial load (cache-first, then network).
final class LoadRates extends ExchangeRatesEvent {
  const LoadRates();
}

/// Force network refresh (pull-to-refresh).
final class RefreshRates extends ExchangeRatesEvent {
  const RefreshRates();
}

/// Connectivity returned online — refresh if showing cache/error/empty.
final class ConnectivityRestored extends ExchangeRatesEvent {
  const ConnectivityRestored();
}
