
part of 'telco.dart';

_Telco _$TelcoFromJson(Map<String, dynamic> json) => _Telco(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  url: json['url'] as String?,
  exchangeRates: (json['exchangeRates'] as List<dynamic>?)
      ?.map((e) => ExchangeRate.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TelcoToJson(_Telco instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'url': instance.url,
  'exchangeRates': instance.exchangeRates?.map((e) => e.toJson()).toList(),
};

_ExchangeRate _$ExchangeRateFromJson(Map<String, dynamic> json) =>
    _ExchangeRate(
      gold: (json['gold'] as num).toInt(),
      amount: (json['amount'] as num).toInt(),
      promotionPercent: (json['promotionPercent'] as num?)?.toInt(),
      brand: json['brand'] as String?,
    );

Map<String, dynamic> _$ExchangeRateToJson(_ExchangeRate instance) =>
    <String, dynamic>{
      'gold': instance.gold,
      'amount': instance.amount,
      'promotionPercent': instance.promotionPercent,
      'brand': instance.brand,
    };
