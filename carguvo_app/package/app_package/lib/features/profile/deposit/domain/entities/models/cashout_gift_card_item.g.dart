
part of 'cashout_gift_card_item.dart';

_CashoutGiftCardItem _$CashoutGiftCardItemFromJson(Map<String, dynamic> json) =>
    _CashoutGiftCardItem(
      image: json['image'] as String,
      amount: (json['amount'] as num).toInt(),
      displayName: json['displayName'] as String,
      price: (json['price'] as num).toInt(),
      name: json['name'] as String,
      active: json['active'] as bool,
      id: json['id'] as String,
      type: (json['type'] as num).toInt(),
      brand: json['brand'] as String,
      telcoId: (json['telcoId'] as num).toInt(),
    );

Map<String, dynamic> _$CashoutGiftCardItemToJson(
  _CashoutGiftCardItem instance,
) => <String, dynamic>{
  'image': instance.image,
  'amount': instance.amount,
  'displayName': instance.displayName,
  'price': instance.price,
  'name': instance.name,
  'active': instance.active,
  'id': instance.id,
  'type': instance.type,
  'brand': instance.brand,
  'telcoId': instance.telcoId,
};
