import 'package:freezed_annotation/freezed_annotation.dart';

part 'verified_bank_account.freezed.dart';
part 'verified_bank_account.g.dart';

@freezed
sealed class VerifiedBankAccount with _$VerifiedBankAccount {
  const factory VerifiedBankAccount({
    @JsonKey(name: 'accountHolder') String? accountHolder,
    @JsonKey(name: 'bankId') String? bankId,
    @JsonKey(name: 'accountNo') String? accountNo,
  }) = _VerifiedBankAccount;

  factory VerifiedBankAccount.fromJson(Map<String, Object?> json) =>
      _$VerifiedBankAccountFromJson(json);
}
