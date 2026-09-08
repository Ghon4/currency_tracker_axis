import 'package:intl/intl.dart';

import 'package:currency_tracker_axis/core/constants/app_constants.dart';

/// UTC-centric date helpers for API requests and local display formatting.
class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _apiFormat =
      DateFormat(AppConstants.apiDateFormat, 'en_US');
  static final DateFormat _displayDateFormat =
      DateFormat(AppConstants.displayDateFormat);
  static final DateFormat _displayDateTimeFormat =
      DateFormat(AppConstants.displayDateTimeFormat);

  /// Today's date at UTC midnight (date-only).
  static DateTime utcToday() {
    final now = DateTime.now().toUtc();
    return DateTime.utc(now.year, now.month, now.day);
  }

  /// Yesterday's date at UTC midnight.
  static DateTime utcYesterday() =>
      utcToday().subtract(const Duration(days: 1));

  /// Last [n] UTC calendar days ending at [utcToday], oldest first.
  ///
  /// Chart window for [AppConstants.historicalDays]:
  /// `[today-(n-1) … today]` (includes today).
  static List<DateTime> lastNUtcDays(int n) {
    assert(n > 0, 'n must be positive');
    final today = utcToday();
    return List.generate(
      n,
      (index) => today.subtract(Duration(days: n - 1 - index)),
    );
  }

  /// Formats [date] as `yyyy-MM-dd` in UTC for API hosts/paths.
  static String toApiDate(DateTime date) =>
      _apiFormat.format(date.toUtc());

  /// Formats [date] for UI using the device local timezone.
  static String toDisplayDate(DateTime date) =>
      _displayDateFormat.format(date.toLocal());

  /// Formats [date] with time for UI using the device local timezone.
  static String toDisplayDateTime(DateTime date) =>
      _displayDateTimeFormat.format(date.toLocal());

  /// Parses an API `yyyy-MM-dd` string as a UTC date-only [DateTime].
  static DateTime parseApiDate(String yyyyMmDd) {
    final parsed = _apiFormat.parseStrict(yyyyMmDd, true);
    return DateTime.utc(parsed.year, parsed.month, parsed.day);
  }
}
