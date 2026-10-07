
part of 'codepay_account.dart';

_CodepayAccount _$CodepayAccountFromJson(Map<String, dynamic> json) =>
    _CodepayAccount(
      bankId: json['bankId'] as String,
      accountName: json['accountName'] as String,
      bankBranch: const BankBranchConverter().fromJson(
        json['bankBranch'] as String,
      ),
      publicRss: (json['publicRss'] as num).toInt(),
      id: json['id'] as String,
      accountNumber: json['accountNumber'] as String,
      type: (json['type'] as num).toInt(),
    );

Map<String, dynamic> _$CodepayAccountToJson(_CodepayAccount instance) =>
    <String, dynamic>{
      'bankId': instance.bankId,
      'accountName': instance.accountName,
      'bankBranch': const BankBranchConverter().toJson(instance.bankBranch),
      'publicRss': instance.publicRss,
      'id': instance.id,
      'accountNumber': instance.accountNumber,
      'type': instance.type,
    };
