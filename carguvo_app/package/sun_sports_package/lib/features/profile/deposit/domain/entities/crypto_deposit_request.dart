class CryptoDepositRequest {
  final String cryptoType;
  final String amount;
  final String depositAddress;

  const CryptoDepositRequest({
    required this.cryptoType,
    required this.amount,
    required this.depositAddress,
  });
}
