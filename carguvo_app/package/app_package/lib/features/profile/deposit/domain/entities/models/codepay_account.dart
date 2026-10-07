import 'package:freezed_annotation/freezed_annotation.dart';

part 'codepay_account.freezed.dart';
part 'codepay_account.g.dart';

enum BankBranch {
  @JsonValue('AUTOMOMO')
  automomo,
  @JsonValue('Codepay')
  Codepay,
  @JsonValue('SUNPAY')
  sunpay,
  @JsonValue('UNKNOWN')
  unknown,
}

class BankBranchConverter implements JsonConverter<BankBranch, String> {
  const BankBranchConverter();

  @override
  BankBranch fromJson(String json) {
    switch (json) {
      case 'AUTOMOMO':
        return BankBranch.automomo;
      case 'Codepay':
        return BankBranch.Codepay;
      case 'SUNPAY':
        return BankBranch.sunpay;
      default:
        return BankBranch.unknown;
    }
  }

  @override
  String toJson(BankBranch object) {
    switch (object) {
      case BankBranch.automomo:
        return 'AUTOMOMO';
      case BankBranch.Codepay:
        return 'Codepay';
      case BankBranch.sunpay:
        return 'SUNPAY';
      case BankBranch.unknown:
        return 'UNKNOWN';
    }
  }
}

@freezed
sealed class CodepayAccount with _$CodepayAccount {
  const factory CodepayAccount({
    required String bankId,
    required String accountName,
    @BankBranchConverter() required BankBranch bankBranch,
    required int publicRss,
    required String id,
    required String accountNumber,
    required int type,
  }) = _CodepayAccount;

  factory CodepayAccount.fromJson(Map<String, dynamic> json) =>
      _$CodepayAccountFromJson(json);
}
