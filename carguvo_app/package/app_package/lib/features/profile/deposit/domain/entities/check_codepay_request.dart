class CheckCodePayRequest {
  final String bankAccountId;
  final String bankId;
  final String type;

  const CheckCodePayRequest({
    required this.bankAccountId,
    required this.bankId,
    required this.type,
  });
}
