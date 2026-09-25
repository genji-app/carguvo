import 'package:freezed_annotation/freezed_annotation.dart';

part 'crypto_config.freezed.dart';
part 'crypto_config.g.dart';

@freezed
sealed class CryptoConfig with _$CryptoConfig {
  const factory CryptoConfig({
    @JsonKey(name: 'bankId') String? bankId,
    @JsonKey(name: 'currencyName') String? currencyName,
    @JsonKey(name: 'exchangeRate') num? exchangeRate,
    @JsonKey(name: 'exchangeRateString') String? exchangeRateString,
    @JsonKey(name: 'fee') num? fee,
    @JsonKey(name: 'network') String? network,
    @JsonKey(name: 'depositNetworks') List<String>? depositNetworks,
  }) = _CryptoConfig;

  factory CryptoConfig.fromJson(Map<String, Object?> json) =>
      _$CryptoConfigFromJson(json);
}
