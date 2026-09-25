
part of 'bank.dart';

_CodePayBank _$CodePayBankFromJson(Map<String, dynamic> json) => _CodePayBank(
  id: json['id'] as String,
  name: json['name'] as String,
  fullName: json['fullName'] as String?,
  shortName: json['shortName'] as String?,
  url: json['url'] as String?,
  bankType: (json['bankType'] as num?)?.toInt(),
  supportQRCode: json['supportQRCode'] as bool?,
  supportWithdraw: json['supportWithdraw'] as bool?,
  codePayDisplayOrder: (json['codePayDisplayOrder'] as num?)?.toInt(),
  accounts: (json['accounts'] as List<dynamic>?)
      ?.map((e) => BankAccount.fromJson(e as Map<String, dynamic>))
      .toList(),
  suggestedTransCode: (json['suggestedTransCode'] as List<dynamic>?)
      ?.map((e) => SuggestedTransCode.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CodePayBankToJson(_CodePayBank instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'fullName': instance.fullName,
      'shortName': instance.shortName,
      'url': instance.url,
      'bankType': instance.bankType,
      'supportQRCode': instance.supportQRCode,
      'supportWithdraw': instance.supportWithdraw,
      'codePayDisplayOrder': instance.codePayDisplayOrder,
      'accounts': instance.accounts?.map((e) => e.toJson()).toList(),
      'suggestedTransCode': instance.suggestedTransCode
          ?.map((e) => e.toJson())
          .toList(),
    };

_BankItem _$BankItemFromJson(Map<String, dynamic> json) => _BankItem(
  id: json['id'] as String,
  name: json['name'] as String,
  fullName: json['fullName'] as String?,
  shortName: json['shortName'] as String?,
  url: json['url'] as String?,
  bankType: (json['bankType'] as num?)?.toInt(),
  supportQRCode: json['supportQRCode'] as bool?,
  supportWithdraw: json['supportWithdraw'] as bool?,
  codePayDisplayOrder: (json['codePayDisplayOrder'] as num?)?.toInt(),
  accounts: (json['accounts'] as List<dynamic>?)
      ?.map((e) => BankAccount.fromJson(e as Map<String, dynamic>))
      .toList(),
  suggestedTransCode: (json['suggestedTransCode'] as List<dynamic>?)
      ?.map((e) => SuggestedTransCode.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$BankItemToJson(_BankItem instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'fullName': instance.fullName,
  'shortName': instance.shortName,
  'url': instance.url,
  'bankType': instance.bankType,
  'supportQRCode': instance.supportQRCode,
  'supportWithdraw': instance.supportWithdraw,
  'codePayDisplayOrder': instance.codePayDisplayOrder,
  'accounts': instance.accounts?.map((e) => e.toJson()).toList(),
  'suggestedTransCode': instance.suggestedTransCode
      ?.map((e) => e.toJson())
      .toList(),
};

_BankAccount _$BankAccountFromJson(Map<String, dynamic> json) => _BankAccount(
  id: json['id'] as String?,
  bankId: json['bankId'] as String?,
  accountName: json['accountName'] as String?,
  accountNumber: json['accountNumber'] as String?,
  accountNumberOrigin: json['accountNumberOrigin'] as String?,
  bankBranch: json['bankBranch'] as String?,
  bankNote: json['bankNote'] as String?,
  publicRss: (json['publicRss'] as num?)?.toInt(),
  type: (json['type'] as num?)?.toInt(),
  qrCodeImage: json['qrCodeImage'] as String?,
);

Map<String, dynamic> _$BankAccountToJson(_BankAccount instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bankId': instance.bankId,
      'accountName': instance.accountName,
      'accountNumber': instance.accountNumber,
      'accountNumberOrigin': instance.accountNumberOrigin,
      'bankBranch': instance.bankBranch,
      'bankNote': instance.bankNote,
      'publicRss': instance.publicRss,
      'type': instance.type,
      'qrCodeImage': instance.qrCodeImage,
    };

_SuggestedTransCode _$SuggestedTransCodeFromJson(Map<String, dynamic> json) =>
    _SuggestedTransCode(
      text: json['text'] as String?,
      type: (json['type'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SuggestedTransCodeToJson(_SuggestedTransCode instance) =>
    <String, dynamic>{'text': instance.text, 'type': instance.type};
