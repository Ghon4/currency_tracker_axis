import 'package:equatable/equatable.dart';

/// Absolute and percentage day-over-day change for a currency rate.
class DailyChange extends Equatable {
  const DailyChange({
    required this.absolute,
    required this.percentage,
  });

  /// Change in EGP-per-unit (`today - yesterday`).
  final double absolute;

  /// Percentage change relative to yesterday's inverted rate.
  final double percentage;

  @override
  List<Object?> get props => [absolute, percentage];
}
