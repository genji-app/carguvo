
part of 'verified_bank_account.dart';

_VerifiedBankAccount _$VerifiedBankAccountFromJson(Map<String, dynamic> json) =>
    _VerifiedBankAccount(
      accountHolder: json['accountHolder'] as String?,
      bankId: json['bankId'] as String?,
      accountNo: json['accountNo'] as String?,
    );

Map<String, dynamic> _$VerifiedBankAccountToJson(
  _VerifiedBankAccount instance,
) => <String, dynamic>{
  'accountHolder': instance.accountHolder,
  'bankId': instance.bankId,
  'accountNo': instance.accountNo,
};
