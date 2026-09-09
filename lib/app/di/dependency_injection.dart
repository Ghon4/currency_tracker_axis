import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:currency_tracker_axis/app/router.dart';
import 'package:currency_tracker_axis/core/cache/hive_service.dart';
import 'package:currency_tracker_axis/core/cache/memory_rates_cache.dart';
import 'package:currency_tracker_axis/core/connectivity/connectivity_service.dart';
import 'package:currency_tracker_axis/core/connectivity/usecases/watch_connectivity.dart';
import 'package:currency_tracker_axis/core/error/error_mapper.dart';
import 'package:currency_tracker_axis/core/error/retry_policy.dart';
import 'package:currency_tracker_axis/core/network/dio_client.dart';
import 'package:currency_tracker_axis/features/currency_detail/data/datasources/local/currency_detail_local_datasource.dart';
import 'package:currency_tracker_axis/features/currency_detail/data/datasources/remote/historical_rates_remote_datasource.dart';
import 'package:currency_tracker_axis/features/currency_detail/data/repositories/historical_rates_repository_impl.dart';
import 'package:currency_tracker_axis/features/currency_detail/domain/repositories/historical_rates_repository.dart';
import 'package:currency_tracker_axis/features/currency_detail/domain/usecases/get_seven_day_history.dart';
import 'package:currency_tracker_axis/features/currency_detail/presentation/bloc/currency_detail_bloc.dart';
import 'package:currency_tracker_axis/features/exchange_rates/data/datasources/local/cache_operations.dart';
import 'package:currency_tracker_axis/features/exchange_rates/data/datasources/local/exchange_rates_local_datasource.dart';
import 'package:currency_tracker_axis/features/exchange_rates/data/datasources/remote/exchange_rates_remote_datasource.dart';
import 'package:currency_tracker_axis/features/exchange_rates/data/mappers/rate_mapper.dart';
import 'package:currency_tracker_axis/features/exchange_rates/data/repositories/exchange_rates_repository_impl.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/repositories/exchange_rates_repository.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/usecases/get_cached_historical.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/usecases/get_cached_rates.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/usecases/get_latest_rates_with_change.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/usecases/is_cache_valid.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/usecases/save_rates_to_cache.dart';
import 'package:currency_tracker_axis/features/exchange_rates/presentation/bloc/exchange_rates_bloc.dart';
import 'package:currency_tracker_axis/features/exchange_rates/presentation/mappers/cached_rates_presenter.dart';

/// Global service locator.
final GetIt sl = GetIt.instance;

/// Registers core services, data layer, domain use cases, and presentation BLoCs.
///
/// Call after [WidgetsFlutterBinding.ensureInitialized]. Hive and
/// connectivity are initialized here before the UI starts.
Future<void> configureDependencies() async {
  // Core
  final connectivity = ConnectivityService();
  await connectivity.init();
  sl.registerSingleton<ConnectivityService>(connectivity);

  final hive = HiveService();
  await hive.init();
  sl.registerSingleton<HiveService>(hive);

  sl.registerSingleton<MemoryRatesCache>(MemoryRatesCache());
  sl.registerLazySingleton<CacheOperations>(
    () => CacheOperations(hive: sl(), memory: sl()),
  );
  sl.registerLazySingleton<RetryPolicy>(() => const RetryPolicy());

  sl.registerLazySingleton<DioClient>(
    () => DioClient(connectivity: sl()),
  );

  sl.registerLazySingleton<ErrorMapper>(() => const ErrorMapper());
  sl.registerLazySingleton<RateMapper>(() => const RateMapper());

  // Data layer
  sl.registerLazySingleton<ExchangeRatesRemoteDataSource>(
    () => ExchangeRatesRemoteDataSourceImpl(sl(), retryPolicy: sl()),
  );
  sl.registerLazySingleton<ExchangeRatesLocalDataSource>(
    () => ExchangeRatesLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<HistoricalRatesRemoteDataSource>(
    () => HistoricalRatesRemoteDataSourceImpl(
      ratesRemote: sl(),
      mapper: sl(),
    ),
  );
  sl.registerLazySingleton<CurrencyDetailLocalDataSource>(
    () => CurrencyDetailLocalDataSourceImpl(
      ratesLocal: sl(),
      mapCachedRates: CachedRatesPresenter.map,
    ),
  );
  sl.registerLazySingleton<ExchangeRatesRepository>(
    () => ExchangeRatesRepositoryImpl(
      remote: sl(),
      local: sl(),
      errorMapper: sl(),
      rateMapper: sl(),
      historicalRemote: sl(),
    ),
  );
  sl.registerLazySingleton<HistoricalRatesRepository>(
    () => HistoricalRatesRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetLatestRatesWithChange(sl()));
  sl.registerLazySingleton(() => GetCachedRates(sl()));
  sl.registerLazySingleton(() => GetCachedHistorical(sl()));
  sl.registerLazySingleton(() => SaveRatesToCache(sl()));
  sl.registerLazySingleton(() => IsCacheValid(sl()));
  sl.registerLazySingleton(() => GetSevenDayHistory(sl()));
  sl.registerLazySingleton(() => WatchConnectivity(sl()));

  // Presentation
  sl.registerFactory(
    () => ExchangeRatesBloc(
      getLatestRatesWithChange: sl(),
      getCachedRates: sl(),
      saveRatesToCache: sl(),
      watchConnectivity: sl(),
      isCacheValid: sl(),
      mapCachedRates: CachedRatesPresenter.map,
    ),
  );
  sl.registerFactory(
    () => CurrencyDetailBloc(
      getSevenDayHistory: sl(),
      getCachedRates: sl(),
      getCachedHistorical: sl(),
      getLatestRatesWithChange: sl(),
      mapCachedRates: CachedRatesPresenter.map,
    ),
  );

  // Navigation
  sl.registerSingleton<GoRouter>(AppRouter.router);
}
