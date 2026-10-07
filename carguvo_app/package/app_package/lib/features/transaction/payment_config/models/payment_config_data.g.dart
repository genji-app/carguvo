
part of 'payment_config_data.dart';

_PaymentConfigResponse _$PaymentConfigResponseFromJson(
  Map<String, dynamic> json,
) => _PaymentConfigResponse(
  codePayHelpUrl: json['codePayHelpUrl'] as String?,
  bankHelpUrl: json['bankHelpUrl'] as String?,
  eWalletHelpUrl: json['eWalletHelpUrl'] as String?,
  data: json['data'] == null
      ? null
      : PaymentConfigData.fromJson(json['data'] as Map<String, dynamic>),
  status: (json['status'] as num?)?.toInt(),
);

Map<String, dynamic> _$PaymentConfigResponseToJson(
  _PaymentConfigResponse instance,
) => <String, dynamic>{
  'codePayHelpUrl': instance.codePayHelpUrl,
  'bankHelpUrl': instance.bankHelpUrl,
  'eWalletHelpUrl': instance.eWalletHelpUrl,
  'data': instance.data?.toJson(),
  'status': instance.status,
};

_PaymentConfigData _$PaymentConfigDataFromJson(Map<String, dynamic> json) =>
    _PaymentConfigData(
      minTransfer: (json['minTranfer'] as num?)?.toInt(),
      needVerifyBankAccount: json['needVerifyBankAccount'] as bool?,
      smartOTPRegistered: json['smartOTPRegistered'] as bool?,
      batCK: json['batCK'] as bool?,
      transferTax: (json['tranferTax'] as num?)?.toDouble(),
      sSportUrl: json['sSportUrl'] as String?,
      depositTypes: (json['depositTypes'] as List<dynamic>?)
          ?.map((e) => DepositType.fromJson(e as Map<String, dynamic>))
          .toList(),
      telcos: (json['telcos'] as List<dynamic>?)
          ?.map((e) => Telco.fromJson(e as Map<String, dynamic>))
          .toList(),
      codepay: (json['codepay'] as List<dynamic>?)
          ?.map((e) => CodePayBank.fromJson(e as Map<String, dynamic>))
          .toList(),
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => BankItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      crypto: (json['crypto'] as List<dynamic>?)
          ?.map((e) => CryptoConfig.fromJson(e as Map<String, dynamic>))
          .toList(),
      digitalWallets: json['digitalWallets'] as List<dynamic>?,
      verifiedAccountHolder: (json['verifiedAccountHolder'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      verifiedBankAccounts: (json['verifiedBankAccounts'] as List<dynamic>?)
          ?.map((e) => VerifiedBankAccount.fromJson(e as Map<String, dynamic>))
          .toList(),
      cashoutGiftCards: (json['cashoutGiftCards'] as List<dynamic>?)
          ?.map((e) => CashoutGiftCard.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PaymentConfigDataToJson(_PaymentConfigData instance) =>
    <String, dynamic>{
      'minTranfer': instance.minTransfer,
      'needVerifyBankAccount': instance.needVerifyBankAccount,
      'smartOTPRegistered': instance.smartOTPRegistered,
      'batCK': instance.batCK,
      'tranferTax': instance.transferTax,
      'sSportUrl': instance.sSportUrl,
      'depositTypes': instance.depositTypes?.map((e) => e.toJson()).toList(),
      'telcos': instance.telcos?.map((e) => e.toJson()).toList(),
      'codepay': instance.codepay?.map((e) => e.toJson()).toList(),
      'items': instance.items?.map((e) => e.toJson()).toList(),
      'crypto': instance.crypto?.map((e) => e.toJson()).toList(),
      'digitalWallets': instance.digitalWallets,
      'verifiedAccountHolder': instance.verifiedAccountHolder,
      'verifiedBankAccounts': instance.verifiedBankAccounts
          ?.map((e) => e.toJson())
          .toList(),
      'cashoutGiftCards': instance.cashoutGiftCards
          ?.map((e) => e.toJson())
          .toList(),
    };
