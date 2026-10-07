import 'package:freezed_annotation/freezed_annotation.dart';

part 'bank.freezed.dart';
part 'bank.g.dart';

@freezed
sealed class CodePayBank with _$CodePayBank {
  const factory CodePayBank({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'fullName') String? fullName,
    @JsonKey(name: 'shortName') String? shortName,
    @JsonKey(name: 'url') String? url,
    @JsonKey(name: 'bankType') int? bankType,
    @JsonKey(name: 'supportQRCode') bool? supportQRCode,
    @JsonKey(name: 'supportWithdraw') bool? supportWithdraw,
    @JsonKey(name: 'codePayDisplayOrder') int? codePayDisplayOrder,
    @JsonKey(name: 'accounts') List<BankAccount>? accounts,
    @JsonKey(name: 'suggestedTransCode')
    List<SuggestedTransCode>? suggestedTransCode,
  }) = _CodePayBank;

  factory CodePayBank.fromJson(Map<String, Object?> json) =>
      _$CodePayBankFromJson(json);
}

@freezed
sealed class BankItem with _$BankItem {
  const factory BankItem({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'fullName') String? fullName,
    @JsonKey(name: 'shortName') String? shortName,
    @JsonKey(name: 'url') String? url,
    @JsonKey(name: 'bankType') int? bankType,
    @JsonKey(name: 'supportQRCode') bool? supportQRCode,
    @JsonKey(name: 'supportWithdraw') bool? supportWithdraw,
    @JsonKey(name: 'codePayDisplayOrder') int? codePayDisplayOrder,
    @JsonKey(name: 'accounts') List<BankAccount>? accounts,
    @JsonKey(name: 'suggestedTransCode')
    List<SuggestedTransCode>? suggestedTransCode,
  }) = _BankItem;

  factory BankItem.fromJson(Map<String, Object?> json) =>
      _$BankItemFromJson(json);
}

@freezed
sealed class BankAccount with _$BankAccount {
  const factory BankAccount({
    @JsonKey(name: 'id') String? id,
    @JsonKey(name: 'bankId') String? bankId,
    @JsonKey(name: 'accountName') String? accountName,
    @JsonKey(name: 'accountNumber') String? accountNumber,
    @JsonKey(name: 'accountNumberOrigin') String? accountNumberOrigin,
    @JsonKey(name: 'bankBranch') String? bankBranch,
    @JsonKey(name: 'bankNote') String? bankNote,
    @JsonKey(name: 'publicRss') int? publicRss,
    @JsonKey(name: 'type') int? type,
    @JsonKey(name: 'qrCodeImage') String? qrCodeImage,
  }) = _BankAccount;

  factory BankAccount.fromJson(Map<String, Object?> json) =>
      _$BankAccountFromJson(json);
}

@freezed
sealed class SuggestedTransCode with _$SuggestedTransCode {
  const factory SuggestedTransCode({
    @JsonKey(name: 'text') String? text,
    @JsonKey(name: 'type') int? type,
  }) = _SuggestedTransCode;

  factory SuggestedTransCode.fromJson(Map<String, Object?> json) =>
      _$SuggestedTransCodeFromJson(json);
}
