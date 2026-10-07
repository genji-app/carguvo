class CodepayCreateQrRequest {
  final String bankId;
  final int amount;
  final String bankAccountId;

  const CodepayCreateQrRequest({
    required this.bankId,
    required this.amount,
    required this.bankAccountId,
  });
}
