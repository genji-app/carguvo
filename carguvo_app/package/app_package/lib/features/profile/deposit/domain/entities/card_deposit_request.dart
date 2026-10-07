class CardDepositRequest {
  final String serial;
  final String code;
  final int telcoId;
  final int amount;

  const CardDepositRequest({
    required this.serial,
    required this.code,
    required this.telcoId,
    required this.amount,
  });
}
