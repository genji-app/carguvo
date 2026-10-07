
part of 'card_withdraw_dto.dart';

_CardWithdrawResponseDto _$CardWithdrawResponseDtoFromJson(
  Map<String, dynamic> json,
) => _CardWithdrawResponseDto(
  id: json['id'] as String?,
  requestTime: (json['requestTime'] as num?)?.toInt(),
  responseTime: (json['responseTime'] as num?)?.toInt(),
  status: (json['status'] as num?)?.toInt(),
  description: json['description'] as String?,
  displayName: json['displayName'] as String?,
  userId: (json['userId'] as num?)?.toInt(),
  result: json['result'] == null
      ? null
      : CardWithdrawResultDto.fromJson(json['result'] as Map<String, dynamic>),
  item: json['item'] == null
      ? null
      : CardWithdrawItemDto.fromJson(json['item'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CardWithdrawResponseDtoToJson(
  _CardWithdrawResponseDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'requestTime': instance.requestTime,
  'responseTime': instance.responseTime,
  'status': instance.status,
  'description': instance.description,
  'displayName': instance.displayName,
  'userId': instance.userId,
  'result': instance.result?.toJson(),
  'item': instance.item?.toJson(),
};

_CardWithdrawResultDto _$CardWithdrawResultDtoFromJson(
  Map<String, dynamic> json,
) => _CardWithdrawResultDto(code: json['code'], serial: json['serial']);

Map<String, dynamic> _$CardWithdrawResultDtoToJson(
  _CardWithdrawResultDto instance,
) => <String, dynamic>{'code': instance.code, 'serial': instance.serial};

_CardWithdrawItemDto _$CardWithdrawItemDtoFromJson(Map<String, dynamic> json) =>
    _CardWithdrawItemDto(
      amount: json['amount'] as num?,
      price: json['price'] as num?,
      displayName: json['displayName'] as String?,
      name: json['name'] as String?,
      image: json['image'] as String?,
      brand: json['brand'] as String?,
      active: json['active'] as bool?,
      type: (json['type'] as num?)?.toInt(),
      telcoId: (json['telcoId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CardWithdrawItemDtoToJson(
  _CardWithdrawItemDto instance,
) => <String, dynamic>{
  'amount': instance.amount,
  'price': instance.price,
  'displayName': instance.displayName,
  'name': instance.name,
  'image': instance.image,
  'brand': instance.brand,
  'active': instance.active,
  'type': instance.type,
  'telcoId': instance.telcoId,
};
