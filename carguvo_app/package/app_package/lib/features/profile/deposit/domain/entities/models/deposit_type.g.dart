
part of 'deposit_type.dart';

_DepositType _$DepositTypeFromJson(Map<String, dynamic> json) => _DepositType(
  description: json['description'] as String,
  id: (json['id'] as num).toInt(),
);

Map<String, dynamic> _$DepositTypeToJson(_DepositType instance) =>
    <String, dynamic>{'description': instance.description, 'id': instance.id};
