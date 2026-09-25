class WithdrawCryptoRequest {
  final String network;
  final String cryptoCurrency;
  final int amount;
  final String address;
  final String fiatCurrency;

  const WithdrawCryptoRequest({
    required this.network,
    required this.cryptoCurrency,
    required this.amount,
    required this.address,
    this.fiatCurrency = 'VND',
  });
}
