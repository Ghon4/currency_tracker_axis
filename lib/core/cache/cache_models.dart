import 'package:hive/hive.dart';

/// Hive-persisted latest + yesterday inverted rates snapshot.
///
/// Rates are stored already inverted (EGP per 1 foreign unit).
class HiveCachedRates extends HiveObject {
  HiveCachedRates({
    required this.rates,
    required this.yesterdayRates,
    required this.timestamp,
    this.apiDate,
  });

  /// Inverted EGP rates keyed by uppercase currency code.
  Map<String, double> rates;

  /// Previous-day inverted rates for change calculations.
  Map<String, double> yesterdayRates;

  /// When this snapshot was written locally.
  DateTime timestamp;

  /// API-reported date (`yyyy-MM-dd`), when available.
  String? apiDate;
}

/// Hive-persisted historical series for a single currency.
class HiveCachedHistorical extends HiveObject {
  HiveCachedHistorical({
    required this.currencyCode,
    required this.points,
    required this.timestamp,
  });

  String currencyCode;
  List<HiveCachedHistoricalPoint> points;
  DateTime timestamp;
}

/// A single historical rate point stored in Hive.
class HiveCachedHistoricalPoint {
  HiveCachedHistoricalPoint({
    required this.date,
    required this.rate,
  });

  DateTime date;

  /// Inverted rate (EGP per 1 foreign unit).
  double rate;
}

/// Hive typeId for [HiveCachedRates].
const int cachedRatesTypeId = 1;

/// Hive typeId for [HiveCachedHistorical].
const int cachedHistoricalTypeId = 2;

/// Hive typeId for [HiveCachedHistoricalPoint].
const int cachedHistoricalPointTypeId = 3;

/// Hand-written adapters (hive_generator conflicts with freezed ^3 source_gen).
class CachedRatesAdapter extends TypeAdapter<HiveCachedRates> {
  @override
  final int typeId = cachedRatesTypeId;

  @override
  HiveCachedRates read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveCachedRates(
      rates: (fields[0] as Map).map(
        (key, value) => MapEntry(key as String, (value as num).toDouble()),
      ),
      yesterdayRates: (fields[1] as Map).map(
        (key, value) => MapEntry(key as String, (value as num).toDouble()),
      ),
      timestamp: fields[2] as DateTime,
      apiDate: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HiveCachedRates obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.rates)
      ..writeByte(1)
      ..write(obj.yesterdayRates)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.apiDate);
  }
}

class CachedHistoricalAdapter extends TypeAdapter<HiveCachedHistorical> {
  @override
  final int typeId = cachedHistoricalTypeId;

  @override
  HiveCachedHistorical read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveCachedHistorical(
      currencyCode: fields[0] as String,
      points: (fields[1] as List).cast<HiveCachedHistoricalPoint>(),
      timestamp: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, HiveCachedHistorical obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.currencyCode)
      ..writeByte(1)
      ..write(obj.points)
      ..writeByte(2)
      ..write(obj.timestamp);
  }
}

class CachedHistoricalPointAdapter
    extends TypeAdapter<HiveCachedHistoricalPoint> {
  @override
  final int typeId = cachedHistoricalPointTypeId;

  @override
  HiveCachedHistoricalPoint read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveCachedHistoricalPoint(
      date: fields[0] as DateTime,
      rate: (fields[1] as num).toDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, HiveCachedHistoricalPoint obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.rate);
  }
}

/// Registers all cache TypeAdapters if they are not already registered.
void registerCacheAdapters() {
  if (!Hive.isAdapterRegistered(cachedRatesTypeId)) {
    Hive.registerAdapter(CachedRatesAdapter());
  }
  if (!Hive.isAdapterRegistered(cachedHistoricalTypeId)) {
    Hive.registerAdapter(CachedHistoricalAdapter());
  }
  if (!Hive.isAdapterRegistered(cachedHistoricalPointTypeId)) {
    Hive.registerAdapter(CachedHistoricalPointAdapter());
  }
}
