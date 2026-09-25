
part of 'deposit_complains_dto.dart';

_DepositComplainResponseDto _$DepositComplainResponseDtoFromJson(
  Map<String, dynamic> json,
) => _DepositComplainResponseDto(
  id: json['id'],
  objectId: json['_id'],
  amount: json['amount'] as num?,
  value: json['value'] as num?,
  status: (json['status'] as num?)?.toInt(),
  type: (json['type'] as num?)?.toInt(),
  method: (json['method'] as num?)?.toInt(),
  statusDescription: json['statusDescription'] as String?,
  reason: json['reason'] as String?,
  note: json['note'] as String?,
  transactionCode: json['transactionCode'] as String?,
  code: json['code'] as String?,
  ref: json['ref'] as String?,
  responseTime: (json['responseTime'] as num?)?.toInt(),
  requestTime: (json['requestTime'] as num?)?.toInt(),
  createdTime: (json['createdTime'] as num?)?.toInt(),
  createdAt: (json['createdAt'] as num?)?.toInt(),
  time: (json['time'] as num?)?.toInt(),
);

Map<String, dynamic> _$DepositComplainResponseDtoToJson(
  _DepositComplainResponseDto instance,
) => <String, dynamic>{
  'id': instance.id,
  '_id': instance.objectId,
  'amount': instance.amount,
  'value': instance.value,
  'status': instance.status,
  'type': instance.type,
  'method': instance.method,
  'statusDescription': instance.statusDescription,
  'reason': instance.reason,
  'note': instance.note,
  'transactionCode': instance.transactionCode,
  'code': instance.code,
  'ref': instance.ref,
  'responseTime': instance.responseTime,
  'requestTime': instance.requestTime,
  'createdTime': instance.createdTime,
  'createdAt': instance.createdAt,
  'time': instance.time,
};
