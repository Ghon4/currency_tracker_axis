import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:currency_tracker_axis/app/router.dart';
import 'package:currency_tracker_axis/core/cache/hive_service.dart';
import 'package:currency_tracker_axis/core/connectivity/connectivity_service.dart';
import 'package:currency_tracker_axis/core/network/dio_client.dart';
import 'package:currency_tracker_axis/features/exchange_rates/data/datasources/exchange_rates_local_datasource.dart';
import 'package:currency_tracker_axis/features/exchange_rates/data/datasources/exchange_rates_local_datasource_impl.dart';
import 'package:currency_tracker_axis/features/exchange_rates/data/datasources/exchange_rates_remote_datasource.dart';
import 'package:currency_tracker_axis/features/exchange_rates/data/datasources/exchange_rates_remote_datasource_stub.dart';
import 'package:currency_tracker_axis/features/exchange_rates/data/repositories/exchange_rates_repository_impl.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/repositories/exchange_rates_repository.dart';

/// Global service locator.
final GetIt sl = GetIt.instance;

/// Registers core services and foundation data-layer stubs.
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

  sl.registerLazySingleton<DioClient>(
    () => DioClient(connectivity: sl()),
  );

  // Data layer (remote stub + local Hive impl for foundation)
  sl.registerLazySingleton<ExchangeRatesRemoteDataSource>(
    ExchangeRatesRemoteDataSourceStub.new,
  );
  sl.registerLazySingleton<ExchangeRatesLocalDataSource>(
    () => ExchangeRatesLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ExchangeRatesRepository>(
    () => ExchangeRatesRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Navigation
  sl.registerSingleton<GoRouter>(AppRouter.router);

  // Use cases / BLoCs registered when feature modules are implemented:
  // sl.registerFactory(() => ExchangeRatesBloc(sl()));
}
