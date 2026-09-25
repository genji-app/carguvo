import 'package:freezed_annotation/freezed_annotation.dart';
import 'cashout_gift_card.dart';
import 'crypto_deposit_option.dart';
import 'deposit_type.dart';
import 'codepay_bank.dart';
import 'bank_account_item.dart';
import 'verified_bank_account.dart';

part 'fetch_bank_account_data.freezed.dart';
part 'fetch_bank_account_data.g.dart';

@freezed
sealed class FetchBankAccountsData with _$FetchBankAccountsData {
  const factory FetchBankAccountsData({
    @Default(0) int minTranfer,
    @Default([]) List<CashoutGiftCard> cashoutGiftCards,
    @Default([]) List<dynamic> digitalWallets,
    @JsonKey(name: 'smartOTPRegistered')
    @Default(false)
    bool smartOtpRegistered,
    @Default([]) List<CryptoDepositOption> crypto,
    @JsonKey(name: 'batCK') @Default(false) bool batCk,
    @Default(0) int tranferTax,
    @Default('') String sSportUrl,
    @Default([]) List<DepositType> depositTypes,
    @Default([]) List<CashoutGiftCard> telcos,
    @Default([]) List<CodepayBank> codepay,
    @Default(false) bool needVerifyBankAccount,
    @Default([]) List<dynamic> verifiedAccountHolder,
    @Default([]) List<BankAccountItem> items,
    @Default([]) List<VerifiedBankAccount> verifiedBankAccounts,
  }) = _FetchBankAccountsData;

  factory FetchBankAccountsData.fromJson(Map<String, dynamic> json) =>
      _$FetchBankAccountsDataFromJson(json);
}
