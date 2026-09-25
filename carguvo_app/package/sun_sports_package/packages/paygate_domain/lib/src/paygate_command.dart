library;

const int kPaygateCardProcessingStatus = 1099;

enum PaygateCommand {
  fetchBankAccounts,
  createCodePay,
  checkCodePay,
  createDepositSlip,
  chargeCard,
  useGiftCode,
  getCryptoAddress,
  createUserBankAccount,
  createWithdrawSlip,
  withdrawCardCashout,
  createCryptoWithdrawSlip,

  requestOtp,
  activePhone;

  bool get missingStatusIsError => switch (this) {
    PaygateCommand.useGiftCode || PaygateCommand.createUserBankAccount => true,
    _ => false,
  };

  bool get hasSoftProcessingState => this == PaygateCommand.chargeCard;

  bool isSuccess(int? status) => switch (this) {
    PaygateCommand.chargeCard =>
      status == null || status == 0 || status == kPaygateCardProcessingStatus,
    _ => missingStatusIsError ? status == 0 : (status == null || status == 0),
  };

  bool isSoftProcessing(int? status) =>
      hasSoftProcessingState && status == kPaygateCardProcessingStatus;
}

int? paygateStatusOf(Map<String, dynamic> json) =>
    (json['status'] as num?)?.toInt();
