
part of 'item_account.dart';

_ItemAccount _$ItemAccountFromJson(Map<String, dynamic> json) => _ItemAccount(
  bankId: json['bankId'] as String,
  accountNumberOrigin: json['accountNumberOrigin'] as String,
  bankNote: json['bankNote'] as String,
  accountName: json['accountName'] as String,
  bankBranch: json['bankBranch'] as String,
  publicRss: (json['publicRss'] as num).toInt(),
  id: json['id'] as String,
  accountNumber: json['accountNumber'] as String,
  type: (json['type'] as num).toInt(),
  qrCodeImage: json['qrCodeImage'] as String,
);

Map<String, dynamic> _$ItemAccountToJson(_ItemAccount instance) =>
    <String, dynamic>{
      'bankId': instance.bankId,
      'accountNumberOrigin': instance.accountNumberOrigin,
      'bankNote': instance.bankNote,
      'accountName': instance.accountName,
      'bankBranch': instance.bankBranch,
      'publicRss': instance.publicRss,
      'id': instance.id,
      'accountNumber': instance.accountNumber,
      'type': instance.type,
      'qrCodeImage': instance.qrCodeImage,
    };
