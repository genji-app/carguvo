
part of 'card_deposit_dto.dart';

_CardDepositResponseDto _$CardDepositResponseDtoFromJson(
  Map<String, dynamic> json,
) => _CardDepositResponseDto(
  amount: json['amount'] as num?,
  code: json['code'] as String?,
  serial: json['serial'] as String?,
  network: json['network'] as String?,
  createdTime: (json['createdTime'] as num?)?.toInt(),
  statusMessage: json['statusMessage'] as String?,
  receivedAmount: json['receivedAmount'] as num?,
  slipId: json['slipId'],
);

Map<String, dynamic> _$CardDepositResponseDtoToJson(
  _CardDepositResponseDto instance,
) => <String, dynamic>{
  'amount': instance.amount,
  'code': instance.code,
  'serial': instance.serial,
  'network': instance.network,
  'createdTime': instance.createdTime,
  'statusMessage': instance.statusMessage,
  'receivedAmount': instance.receivedAmount,
  'slipId': instance.slipId,
};
