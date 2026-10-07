
part of 'deposit_type.dart';

_DepositType _$DepositTypeFromJson(Map<String, dynamic> json) => _DepositType(
  id: (json['id'] as num).toInt(),
  description: json['description'] as String,
);

Map<String, dynamic> _$DepositTypeToJson(_DepositType instance) =>
    <String, dynamic>{'id': instance.id, 'description': instance.description};
