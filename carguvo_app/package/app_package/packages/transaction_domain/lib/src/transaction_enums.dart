library;

export 'package:game_taxonomy/game_taxonomy.dart' show ActivityGroup;

enum TransactionSource {
  paymentSlip,

  cardDeposit,

  cardWithdraw,

  activityLog,
}

enum TransactionPaymentMethod {
  ibanking,
  atm,
  office,
  digitalWallets,
  smartPay,
  codePay,
  card,
  crypto,
  qrPay,
  iap,
  other,
}

enum TransactionSlipType { deposit, withdraw, other }

enum TransactionStatus {
  pending,
  success,
  rejected,
  transfered,
  processing,
  newRequest,
  other,
}
