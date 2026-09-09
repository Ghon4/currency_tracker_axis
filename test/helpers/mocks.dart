import 'package:mocktail/mocktail.dart';

import 'package:currency_tracker_axis/core/cache/hive_service.dart';
import 'package:currency_tracker_axis/core/connectivity/connectivity_service.dart';
import 'package:currency_tracker_axis/core/connectivity/usecases/watch_connectivity.dart';
import 'package:currency_tracker_axis/features/currency_detail/domain/usecases/get_seven_day_history.dart';
import 'package:currency_tracker_axis/features/exchange_rates/data/datasources/local/exchange_rates_local_datasource.dart';
import 'package:currency_tracker_axis/features/exchange_rates/data/datasources/remote/exchange_rates_remote_datasource.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/usecases/get_cached_historical.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/usecases/get_cached_rates.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/usecases/get_latest_rates_with_change.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/usecases/is_cache_valid.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/usecases/save_rates_to_cache.dart';

class MockExchangeRatesRemoteDataSource extends Mock
    implements ExchangeRatesRemoteDataSource {}

class MockExchangeRatesLocalDataSource extends Mock
    implements ExchangeRatesLocalDataSource {}

class MockGetLatestRatesWithChange extends Mock
    implements GetLatestRatesWithChange {}

class MockGetCachedRates extends Mock implements GetCachedRates {}

class MockGetCachedHistorical extends Mock implements GetCachedHistorical {}

class MockSaveRatesToCache extends Mock implements SaveRatesToCache {}

class MockIsCacheValid extends Mock implements IsCacheValid {}

class MockWatchConnectivity extends Mock implements WatchConnectivity {}

class MockGetSevenDayHistory extends Mock implements GetSevenDayHistory {}

class MockHiveService extends Mock implements HiveService {}

class MockConnectivityService extends Mock implements ConnectivityService {}
