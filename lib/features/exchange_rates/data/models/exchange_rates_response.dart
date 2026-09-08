import 'package:json_annotation/json_annotation.dart';

part 'exchange_rates_response.g.dart';

/// Raw API response: `{ "date": "…", "egp": { "usd": 0.019, … } }`.
@JsonSerializable()
class ExchangeRatesResponse {
  const ExchangeRatesResponse({
    required this.date,
    required this.egp,
  });

  /// API date string (`yyyy-MM-dd`).
  final String date;

  /// Raw rates: units of foreign currency per 1 EGP (before inversion).
  @JsonKey(fromJson: ratesMapFromJson)
  final Map<String, double> egp;

  factory ExchangeRatesResponse.fromJson(Map<String, dynamic> json) =>
      _$ExchangeRatesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ExchangeRatesResponseToJson(this);
}

/// Coerces nested rate map values from `num` to `double`.
Map<String, double> ratesMapFromJson(Object? json) {
  if (json is! Map) {
    throw FormatException('Expected rates map, got ${json.runtimeType}');
  }
  return json.map(
    (key, value) => MapEntry(
      key.toString(),
      (value as num).toDouble(),
    ),
  );
}

/// Thin DTO helper around a single raw (from-EGP) rate.
class RateDto {
  const RateDto({
    required this.code,
    required this.rawFromEgp,
  });

  final String code;
  final double rawFromEgp;

  /// EGP per 1 foreign unit. Returns `0` when [rawFromEgp] is zero.
  double get inverted => rawFromEgp == 0 ? 0 : 1 / rawFromEgp;
}
