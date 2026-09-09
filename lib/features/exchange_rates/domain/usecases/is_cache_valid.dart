import 'package:currency_tracker_axis/features/exchange_rates/data/datasources/local/cache_operations.dart';

/// Whether the local rates cache is within the 24-hour TTL.
class IsCacheValid {
  const IsCacheValid(this._cache);

  final CacheOperations _cache;

  Future<bool> call() => _cache.isCacheValid();
}
