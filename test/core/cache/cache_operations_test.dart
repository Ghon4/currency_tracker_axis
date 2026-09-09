import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:currency_tracker_axis/core/cache/memory_rates_cache.dart';
import 'package:currency_tracker_axis/core/constants/app_constants.dart';
import 'package:currency_tracker_axis/features/exchange_rates/data/datasources/local/cache_operations.dart';

import '../../helpers/mock_cache_data.dart';
import '../../helpers/mocks.dart';

void main() {
  late MockHiveService hive;
  late MemoryRatesCache memory;
  late CacheOperations cache;

  setUp(() {
    hive = MockHiveService();
    memory = MemoryRatesCache();
    cache = CacheOperations(hive: hive, memory: memory);
  });

  group('MemoryRatesCache', () {
    test('stores and clears rates + historical', () {
      final rates = freshCachedRates();
      memory.saveRates(rates);
      expect(memory.getRates(), rates);

      final points = sampleHistoryPoints(count: 3);
      memory.saveHistorical('usd', points);
      expect(memory.getHistorical('USD'), points);

      memory.clear();
      expect(memory.getRates(), isNull);
      expect(memory.getHistorical('USD'), isNull);
    });
  });

  group('CacheOperations TTL', () {
    test('isCacheValid is true within 24h', () async {
      final fresh = freshCachedRates(
        timestamp: DateTime.now().toUtc().subtract(const Duration(hours: 2)),
      );
      memory.saveRates(fresh);

      expect(await cache.isCacheValid(), isTrue);
      expect(await cache.getCacheTimestamp(), fresh.timestamp);
    });

    test('isCacheValid is false after TTL', () async {
      memory.saveRates(staleCachedRates());
      expect(await cache.isCacheValid(), isFalse);
    });

    test('isCacheValid is false when empty', () async {
      expect(await cache.isCacheValid(), isFalse);
      expect(await cache.getCacheTimestamp(), isNull);
    });

    test('clearCache clears memory and hive', () async {
      memory.saveRates(freshCachedRates());
      memory.saveHistorical('USD', sampleHistoryPoints(count: 2));
      when(() => hive.clearAll()).thenAnswer((_) async {});

      await cache.clearCache();

      expect(memory.getRates(), isNull);
      expect(memory.getHistorical('USD'), isNull);
      verify(() => hive.clearAll()).called(1);
    });

    test('TTL constant matches AppConstants', () {
      expect(CacheOperations.ttl, AppConstants.cacheTtl);
      expect(AppConstants.cacheTtl, const Duration(hours: 24));
    });
  });
}
