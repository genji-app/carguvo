
part of 'bank_account_item.dart';

_BankAccountItem _$BankAccountItemFromJson(Map<String, dynamic> json) =>
    _BankAccountItem(
      supportQrCode: json['supportQRCode'] as bool,
      supportWithdraw: json['supportWithdraw'] as bool,
      bankType: (json['bankType'] as num).toInt(),
      name: json['name'] as String,
      fullName: json['fullName'] as String,
      id: json['id'] as String,
      accounts:
          (json['accounts'] as List<dynamic>?)
              ?.map((e) => ItemAccount.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      suggestedTransCode:
          (json['suggestedTransCode'] as List<dynamic>?)
              ?.map(
                (e) => SuggestedTransCode.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      shortName: json['shortName'] as String,
      url: json['url'] as String,
    );

Map<String, dynamic> _$BankAccountItemToJson(_BankAccountItem instance) =>
    <String, dynamic>{
      'supportQRCode': instance.supportQrCode,
      'supportWithdraw': instance.supportWithdraw,
      'bankType': instance.bankType,
      'name': instance.name,
      'fullName': instance.fullName,
      'id': instance.id,
      'accounts': instance.accounts.map((e) => e.toJson()).toList(),
      'suggestedTransCode': instance.suggestedTransCode
          .map((e) => e.toJson())
          .toList(),
      'shortName': instance.shortName,
      'url': instance.url,
    };
