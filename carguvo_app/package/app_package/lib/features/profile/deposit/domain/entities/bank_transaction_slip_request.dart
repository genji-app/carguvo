class BankTransactionSlipRequest {
  final String bankAccountId;
  final int amount;
  final String accountName;
  final String transactionCode;
  final int type;

  const BankTransactionSlipRequest({
    required this.bankAccountId,
    required this.amount,
    required this.accountName,
    required this.transactionCode,
    required this.type,
  });
}
