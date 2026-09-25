
part of 'cashout_gift_card.dart';

_CashoutGiftCard _$CashoutGiftCardFromJson(Map<String, dynamic> json) =>
    _CashoutGiftCard(
      name: json['name'] as String,
      id: (json['id'] as num).toInt(),
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (e) => CashoutGiftCardItem.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      url: json['url'] as String,
      exchangeRates:
          (json['exchangeRates'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
      bankType: (json['bankType'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$CashoutGiftCardToJson(_CashoutGiftCard instance) =>
    <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'url': instance.url,
      'exchangeRates': instance.exchangeRates,
      'bankType': instance.bankType,
    };
