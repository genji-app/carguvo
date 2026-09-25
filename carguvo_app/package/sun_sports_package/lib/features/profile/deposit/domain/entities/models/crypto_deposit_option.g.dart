
part of 'crypto_deposit_option.dart';

_CryptoDepositOption _$CryptoDepositOptionFromJson(Map<String, dynamic> json) =>
    _CryptoDepositOption(
      depositNetworks:
          (json['depositNetworks'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      bankId: json['bankId'] as String,
      currencyName: json['currencyName'] as String,
      exchangeRateString: json['exchangeRateString'] as String,
      exchangeRate: (json['exchangeRate'] as num).toInt(),
      fee: (json['fee'] as num).toInt(),
      network: json['network'] as String,
    );

Map<String, dynamic> _$CryptoDepositOptionToJson(
  _CryptoDepositOption instance,
) => <String, dynamic>{
  'depositNetworks': instance.depositNetworks,
  'bankId': instance.bankId,
  'currencyName': instance.currencyName,
  'exchangeRateString': instance.exchangeRateString,
  'exchangeRate': instance.exchangeRate,
  'fee': instance.fee,
  'network': instance.network,
};
