
part of 'crypto_config.dart';

_CryptoConfig _$CryptoConfigFromJson(Map<String, dynamic> json) =>
    _CryptoConfig(
      bankId: json['bankId'] as String?,
      currencyName: json['currencyName'] as String?,
      exchangeRate: json['exchangeRate'] as num?,
      exchangeRateString: json['exchangeRateString'] as String?,
      fee: json['fee'] as num?,
      network: json['network'] as String?,
      depositNetworks: (json['depositNetworks'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$CryptoConfigToJson(_CryptoConfig instance) =>
    <String, dynamic>{
      'bankId': instance.bankId,
      'currencyName': instance.currencyName,
      'exchangeRate': instance.exchangeRate,
      'exchangeRateString': instance.exchangeRateString,
      'fee': instance.fee,
      'network': instance.network,
      'depositNetworks': instance.depositNetworks,
    };
