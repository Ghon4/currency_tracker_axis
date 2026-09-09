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
    this.isCacheStale = false,
    this.userMessage,
  });

  final List<CurrencyRate> rates;
  final bool isFromCache;
  final DateTime lastUpdated;

  /// True when serving cache older than the 24-hour TTL.
  final bool isCacheStale;

  /// One-shot snackbar message (e.g. soft offline refresh failure).
  final String? userMessage;

  ExchangeRatesSuccess copyWith({
    List<CurrencyRate>? rates,
    bool? isFromCache,
    DateTime? lastUpdated,
    bool? isCacheStale,
    String? userMessage,
    bool clearUserMessage = false,
  }) {
    return ExchangeRatesSuccess(
      rates: rates ?? this.rates,
      isFromCache: isFromCache ?? this.isFromCache,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isCacheStale: isCacheStale ?? this.isCacheStale,
      userMessage: clearUserMessage ? null : (userMessage ?? this.userMessage),
    );
  }

  @override
  List<Object?> get props =>
      [rates, isFromCache, lastUpdated, isCacheStale, userMessage];
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
  const ExchangeRatesEmpty({this.message = ErrorMessages.empty});

  final String message;

  @override
  List<Object?> get props => [message];
}
