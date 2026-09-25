import 'package:freezed_annotation/freezed_annotation.dart';

part 'verified_bank_account.freezed.dart';
part 'verified_bank_account.g.dart';

@freezed
sealed class VerifiedBankAccount with _$VerifiedBankAccount {
  const factory VerifiedBankAccount({
    @JsonKey(name: 'accountHolder') required String accountHolder,
    @JsonKey(name: 'bankId') required String bankId,
    @JsonKey(name: 'accountNo') required String accountNo,
  }) = _VerifiedBankAccount;

  factory VerifiedBankAccount.fromJson(Map<String, dynamic> json) =>
      _$VerifiedBankAccountFromJson(json);
}
