import 'package:freezed_annotation/freezed_annotation.dart';

part 'telco.freezed.dart';
part 'telco.g.dart';

@freezed
sealed class Telco with _$Telco {
  const factory Telco({
    @JsonKey(name: 'id') required int id,
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'url') String? url,
    @JsonKey(name: 'exchangeRates') List<ExchangeRate>? exchangeRates,
  }) = _Telco;

  factory Telco.fromJson(Map<String, Object?> json) => _$TelcoFromJson(json);
}

@freezed
sealed class ExchangeRate with _$ExchangeRate {
  const factory ExchangeRate({
    @JsonKey(name: 'gold') required int gold,
    @JsonKey(name: 'amount') required int amount,
    @JsonKey(name: 'promotionPercent') int? promotionPercent,
    @JsonKey(name: 'brand') String? brand,
  }) = _ExchangeRate;

  factory ExchangeRate.fromJson(Map<String, Object?> json) =>
      _$ExchangeRateFromJson(json);
}
