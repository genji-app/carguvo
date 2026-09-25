// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unlock_command_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UnlockCommandResponseImpl _$$UnlockCommandResponseImplFromJson(
  Map<String, dynamic> json,
) => _$UnlockCommandResponseImpl(
  data: UnlockCommandData.fromJson(json['data'] as Map<String, dynamic>),
  status: (json['status'] as num).toInt(),
);

Map<String, dynamic> _$$UnlockCommandResponseImplToJson(
  _$UnlockCommandResponseImpl instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'status': instance.status,
};

_$UnlockCommandDataImpl _$$UnlockCommandDataImplFromJson(
  Map<String, dynamic> json,
) => _$UnlockCommandDataImpl(
  ip: json['ip'] as String,
  message: json['message'] as String,
);

Map<String, dynamic> _$$UnlockCommandDataImplToJson(
  _$UnlockCommandDataImpl instance,
) => <String, dynamic>{'ip': instance.ip, 'message': instance.message};
