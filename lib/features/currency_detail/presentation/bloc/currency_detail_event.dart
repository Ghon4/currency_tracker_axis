part of 'currency_detail_bloc.dart';

/// Public events for the currency detail screen.
sealed class CurrencyDetailEvent extends Equatable {
  const CurrencyDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Loads header + chart for [currencyCode].
final class LoadDetail extends CurrencyDetailEvent {
  const LoadDetail({required this.currencyCode, this.seedRate});

  final String currencyCode;

  /// Optional rate from list navigation for an instant header.
  final CurrencyRate? seedRate;

  @override
  List<Object?> get props => [currencyCode, seedRate];
}

/// Pull-to-refresh / retry — refreshes header and chart.
final class RefreshDetail extends CurrencyDetailEvent {
  const RefreshDetail();
}
