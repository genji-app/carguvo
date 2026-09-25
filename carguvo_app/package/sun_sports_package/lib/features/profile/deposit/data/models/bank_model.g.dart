
part of 'bank_model.dart';

_BankModel _$BankModelFromJson(Map<String, dynamic> json) => _BankModel(
  id: json['id'] as String,
  name: json['name'] as String,
  iconUrl: json['icon_url'] as String?,
);

Map<String, dynamic> _$BankModelToJson(_BankModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon_url': instance.iconUrl,
    };
