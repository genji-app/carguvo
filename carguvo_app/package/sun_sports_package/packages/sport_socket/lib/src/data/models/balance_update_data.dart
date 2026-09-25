class BalanceUpdateData {
  final double balance;

  final String? currency;

  final String raw;

  final DateTime timestamp;

  const BalanceUpdateData({
    required this.balance,
    this.currency,
    required this.raw,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'BalanceUpdateData(balance: $balance, currency: $currency)';
  }
}
