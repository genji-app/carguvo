
part of 'codepay_bank.dart';

_CodepayBank _$CodepayBankFromJson(Map<String, dynamic> json) => _CodepayBank(
  supportQrCode: json['supportQRCode'] as bool,
  supportWithdraw: json['supportWithdraw'] as bool,
  bankType: (json['bankType'] as num).toInt(),
  name: json['name'] as String,
  fullName: json['fullName'] as String,
  id: json['id'] as String,
  accounts:
      (json['accounts'] as List<dynamic>?)
          ?.map((e) => CodepayAccount.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  shortName: json['shortName'] as String,
  url: json['url'] as String,
);

Map<String, dynamic> _$CodepayBankToJson(_CodepayBank instance) =>
    <String, dynamic>{
      'supportQRCode': instance.supportQrCode,
      'supportWithdraw': instance.supportWithdraw,
      'bankType': instance.bankType,
      'name': instance.name,
      'fullName': instance.fullName,
      'id': instance.id,
      'accounts': instance.accounts.map((e) => e.toJson()).toList(),
      'shortName': instance.shortName,
      'url': instance.url,
    };
