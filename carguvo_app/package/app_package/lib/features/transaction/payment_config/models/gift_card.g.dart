
part of 'gift_card.dart';

_CashoutGiftCard _$CashoutGiftCardFromJson(Map<String, dynamic> json) =>
    _CashoutGiftCard(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      url: json['url'] as String?,
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => GiftCardItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CashoutGiftCardToJson(_CashoutGiftCard instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'url': instance.url,
      'items': instance.items?.map((e) => e.toJson()).toList(),
    };

_GiftCardItem _$GiftCardItemFromJson(Map<String, dynamic> json) =>
    _GiftCardItem(
      id: json['id'] as String?,
      name: json['name'] as String?,
      displayName: json['displayName'] as String?,
      image: json['image'] as String?,
      amount: (json['amount'] as num?)?.toInt(),
      price: (json['price'] as num?)?.toInt(),
      active: json['active'] as bool?,
      type: (json['type'] as num?)?.toInt(),
      brand: json['brand'] as String?,
      telcoId: (json['telcoId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$GiftCardItemToJson(_GiftCardItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'displayName': instance.displayName,
      'image': instance.image,
      'amount': instance.amount,
      'price': instance.price,
      'active': instance.active,
      'type': instance.type,
      'brand': instance.brand,
      'telcoId': instance.telcoId,
    };
