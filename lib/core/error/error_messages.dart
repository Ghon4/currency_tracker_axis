/// Centralized user-facing error copy for Failures and UI.
class ErrorMessages {
  ErrorMessages._();

  static const network =
      'No internet connection. Please check your network.';
  static const server =
      'Server is currently unavailable. Please try again later.';
  static const cache =
      'Unable to load cached data. Please try refreshing.';
  static const parse = 'Data format error. Please try again.';
  static const rateUnavailable =
      'Rate for this currency is currently unavailable.';
  static const empty = 'No data available for this currency.';
  static const timeout = 'Request timed out. Please try again.';
  static const unexpected = 'Something went wrong. Please try again.';
  static const offlineSoft = "You're offline.";
}
