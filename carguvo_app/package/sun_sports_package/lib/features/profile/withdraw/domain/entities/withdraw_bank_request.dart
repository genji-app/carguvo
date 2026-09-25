class WithdrawBankRequest {
  final String bankId;
  final String accountNumber;
  final String accountName;
  final int amount;
  final int slipType;

  const WithdrawBankRequest({
    required this.bankId,
    required this.accountNumber,
    required this.accountName,
    required this.amount,
    this.slipType = 2,
  });
}
