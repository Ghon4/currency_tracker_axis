/// Application-wide constants for API hosts, currencies, cache, and timeouts.
class AppConstants {
  AppConstants._();

  /// Base currency for all rate comparisons (Egyptian Pound).
  static const String baseCurrency = 'EGP';

  /// Foreign currencies tracked against [baseCurrency].
  static const List<String> targetCurrencies = [
    'USD',
    'EUR',
    'GBP',
    'SAR',
    'JPY',
  ];

  /// Human-readable names keyed by ISO currency code.
  static const Map<String, String> currencyNames = {
    'USD': 'US Dollar',
    'EUR': 'Euro',
    'GBP': 'British Pound',
    'SAR': 'Saudi Riyal',
    'JPY': 'Japanese Yen',
  };

  /// Latest rates host (no trailing slash).
  static const String latestHost = 'https://latest.currency-api.pages.dev';

  /// Historical host for a UTC date subdomain (`yyyy-MM-dd`).
  static String historicalHost(String yyyyMmDd) =>
      'https://$yyyyMmDd.currency-api.pages.dev';

  /// API path for rates of [base] (lowercase currency code in path).
  static String ratesPath(String base) =>
      '/v1/currencies/${base.toLowerCase()}.json';

  /// Full URL for the latest rates snapshot.
  static String latestRatesUrl({String base = baseCurrency}) =>
      '$latestHost${ratesPath(base)}';

  /// Full URL for historical rates on [yyyyMmDd].
  static String historicalRatesUrl(
    String yyyyMmDd, {
    String base = baseCurrency,
  }) =>
      '${historicalHost(yyyyMmDd)}${ratesPath(base)}';

  static const String apiDateFormat = 'yyyy-MM-dd';
  static const String displayDateFormat = 'MMM d, yyyy';
  static const String displayDateTimeFormat = 'MMM d, yyyy · HH:mm';

  static const String ratesBoxName = 'rates_box';
  static const String historicalBoxName = 'historical_box';
  static const String metaBoxName = 'meta_box';
  static const String cachedRatesKey = 'cached_rates';
  static const String cacheSchemaVersionKey = 'schema_version';
  static const int cacheSchemaVersion = 1;

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);
  static const Duration connectivityDebounce = Duration(milliseconds: 800);

  /// Number of calendar days for historical chart windows.
  static const int historicalDays = 7;

  /// Maximum retries for transient network/server failures.
  static const int maxRetries = 2;

  /// Base delay for exponential backoff (`300ms * attempt`).
  static const Duration retryBaseDelay = Duration(milliseconds: 300);
}
