import 'package:equatable/equatable.dart';

/// A single historical inverted rate at a UTC date.
class HistoricalPoint extends Equatable {
  const HistoricalPoint({
    required this.date,
    required this.rate,
  });

  /// UTC date for this sample.
  final DateTime date;

  /// EGP per 1 foreign unit (inverted).
  final double rate;

  @override
  List<Object?> get props => [date, rate];
}
