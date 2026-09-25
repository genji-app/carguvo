class CryptoAddressRequest {
  final String network;
  final String currencyName;
  final String fiatCurrency;

  const CryptoAddressRequest({
    required this.network,
    required this.currencyName,
    required this.fiatCurrency,
  });

  Map<String, dynamic> toJson() => {
    'command': 'getCryptoAddress',
    'network': network,
    'currencyName': currencyName,
    'fiatCurrency': fiatCurrency,
  };
}
