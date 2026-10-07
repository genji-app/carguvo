import 'package:freezed_annotation/freezed_annotation.dart';
import 'codepay_account.dart';

part 'codepay_bank.freezed.dart';
part 'codepay_bank.g.dart';

@freezed
sealed class CodepayBank with _$CodepayBank {
  const factory CodepayBank({
    @JsonKey(name: 'supportQRCode') required bool supportQrCode,
    required bool supportWithdraw,
    required int bankType,
    required String name,
    required String fullName,
    required String id,
    @Default([]) List<CodepayAccount> accounts,
    required String shortName,
    required String url,
  }) = _CodepayBank;

  factory CodepayBank.fromJson(Map<String, dynamic> json) =>
      _$CodepayBankFromJson(json);
}
