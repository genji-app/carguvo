
part of 'fetch_bank_account_data.dart';

_FetchBankAccountsData _$FetchBankAccountsDataFromJson(
  Map<String, dynamic> json,
) => _FetchBankAccountsData(
  minTranfer: (json['minTranfer'] as num?)?.toInt() ?? 0,
  cashoutGiftCards:
      (json['cashoutGiftCards'] as List<dynamic>?)
          ?.map((e) => CashoutGiftCard.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  digitalWallets: json['digitalWallets'] as List<dynamic>? ?? const [],
  smartOtpRegistered: json['smartOTPRegistered'] as bool? ?? false,
  crypto:
      (json['crypto'] as List<dynamic>?)
          ?.map((e) => CryptoDepositOption.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  batCk: json['batCK'] as bool? ?? false,
  tranferTax: (json['tranferTax'] as num?)?.toInt() ?? 0,
  sSportUrl: json['sSportUrl'] as String? ?? '',
  depositTypes:
      (json['depositTypes'] as List<dynamic>?)
          ?.map((e) => DepositType.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  telcos:
      (json['telcos'] as List<dynamic>?)
          ?.map((e) => CashoutGiftCard.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  codepay:
      (json['codepay'] as List<dynamic>?)
          ?.map((e) => CodepayBank.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  needVerifyBankAccount: json['needVerifyBankAccount'] as bool? ?? false,
  verifiedAccountHolder:
      json['verifiedAccountHolder'] as List<dynamic>? ?? const [],
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => BankAccountItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  verifiedBankAccounts:
      (json['verifiedBankAccounts'] as List<dynamic>?)
          ?.map((e) => VerifiedBankAccount.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$FetchBankAccountsDataToJson(
  _FetchBankAccountsData instance,
) => <String, dynamic>{
  'minTranfer': instance.minTranfer,
  'cashoutGiftCards': instance.cashoutGiftCards.map((e) => e.toJson()).toList(),
  'digitalWallets': instance.digitalWallets,
  'smartOTPRegistered': instance.smartOtpRegistered,
  'crypto': instance.crypto.map((e) => e.toJson()).toList(),
  'batCK': instance.batCk,
  'tranferTax': instance.tranferTax,
  'sSportUrl': instance.sSportUrl,
  'depositTypes': instance.depositTypes.map((e) => e.toJson()).toList(),
  'telcos': instance.telcos.map((e) => e.toJson()).toList(),
  'codepay': instance.codepay.map((e) => e.toJson()).toList(),
  'needVerifyBankAccount': instance.needVerifyBankAccount,
  'verifiedAccountHolder': instance.verifiedAccountHolder,
  'items': instance.items.map((e) => e.toJson()).toList(),
  'verifiedBankAccounts': instance.verifiedBankAccounts
      .map((e) => e.toJson())
      .toList(),
};
