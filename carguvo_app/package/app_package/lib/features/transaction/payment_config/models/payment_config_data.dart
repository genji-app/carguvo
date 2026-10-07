import 'package:freezed_annotation/freezed_annotation.dart';

import 'bank.dart';
import 'crypto_config.dart';
import 'deposit_type.dart';
import 'gift_card.dart';
import 'telco.dart';
import 'verified_bank_account.dart';

part 'payment_config_data.freezed.dart';
part 'payment_config_data.g.dart';

@freezed
sealed class PaymentConfigResponse with _$PaymentConfigResponse {
  const factory PaymentConfigResponse({
    @JsonKey(name: 'codePayHelpUrl') String? codePayHelpUrl,
    @JsonKey(name: 'bankHelpUrl') String? bankHelpUrl,
    @JsonKey(name: 'eWalletHelpUrl') String? eWalletHelpUrl,
    @JsonKey(name: 'data') PaymentConfigData? data,
    @JsonKey(name: 'status') int? status,
  }) = _PaymentConfigResponse;

  factory PaymentConfigResponse.fromJson(Map<String, Object?> json) =>
      _$PaymentConfigResponseFromJson(json);
}

@freezed
sealed class PaymentConfigData with _$PaymentConfigData {
  const factory PaymentConfigData({
    @JsonKey(name: 'minTranfer') int? minTransfer,
    @JsonKey(name: 'needVerifyBankAccount') bool? needVerifyBankAccount,
    @JsonKey(name: 'smartOTPRegistered') bool? smartOTPRegistered,
    @JsonKey(name: 'batCK') bool? batCK,
    @JsonKey(name: 'tranferTax') double? transferTax,
    @JsonKey(name: 'sSportUrl') String? sSportUrl,
    @JsonKey(name: 'depositTypes') List<DepositType>? depositTypes,
    @JsonKey(name: 'telcos') List<Telco>? telcos,
    @JsonKey(name: 'codepay') List<CodePayBank>? codepay,
    @JsonKey(name: 'items') List<BankItem>? items,
    @JsonKey(name: 'crypto') List<CryptoConfig>? crypto,
    @JsonKey(name: 'digitalWallets') List<dynamic>? digitalWallets,
    @JsonKey(name: 'verifiedAccountHolder') List<String>? verifiedAccountHolder,
    @JsonKey(name: 'verifiedBankAccounts')
    List<VerifiedBankAccount>? verifiedBankAccounts,
    @JsonKey(name: 'cashoutGiftCards') List<CashoutGiftCard>? cashoutGiftCards,
  }) = _PaymentConfigData;

  factory PaymentConfigData.fromJson(Map<String, Object?> json) =>
      _$PaymentConfigDataFromJson(json);
}
