part of 'currency_detail_bloc.dart';

/// States for the currency detail screen.
sealed class CurrencyDetailState extends Equatable {
  const CurrencyDetailState();

  @override
  List<Object?> get props => [];
}

final class CurrencyDetailInitial extends CurrencyDetailState {
  const CurrencyDetailInitial();
}

/// Full-page shimmer (header + chart) before header is known.
final class CurrencyDetailLoading extends CurrencyDetailState {
  const CurrencyDetailLoading({required this.currencyCode});

  final String currencyCode;

  @override
  List<Object?> get props => [currencyCode];
}

/// Header visible; chart area shows [ChartShimmer].
final class CurrencyDetailHeaderLoaded extends CurrencyDetailState {
  const CurrencyDetailHeaderLoaded({required this.header});

  final CurrencyDetailHeaderData header;

  @override
  List<Object?> get props => [header];
}

final class CurrencyDetailSuccess extends CurrencyDetailState {
  const CurrencyDetailSuccess({
    required this.header,
    required this.points,
  });

  final CurrencyDetailHeaderData header;
  final List<HistoricalPoint> points;

  @override
  List<Object?> get props => [header, points];
}

/// Header still shown; chart section error + retry.
final class CurrencyDetailChartError extends CurrencyDetailState {
  const CurrencyDetailChartError({
    required this.header,
    required this.message,
  });

  final CurrencyDetailHeaderData header;
  final String message;

  @override
  List<Object?> get props => [header, message];
}

final class CurrencyDetailFullError extends CurrencyDetailState {
  const CurrencyDetailFullError({
    required this.currencyCode,
    required this.message,
  });

  final String currencyCode;
  final String message;

  @override
  List<Object?> get props => [currencyCode, message];
}

/// Header payload shared across header-ready states.
class CurrencyDetailHeaderData extends Equatable {
  const CurrencyDetailHeaderData({
    required this.rate,
    required this.isFromCache,
    required this.lastUpdated,
  });

  final CurrencyRate rate;
  final bool isFromCache;
  final DateTime lastUpdated;

  @override
  List<Object?> get props => [rate, isFromCache, lastUpdated];
}
