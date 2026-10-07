class BankDepositRequest {
  final String bankId;
  final String accountNumber;
  final String accountName;
  final String amount;

  const BankDepositRequest({
    required this.bankId,
    required this.accountNumber,
    required this.accountName,
    required this.amount,
  });
}
