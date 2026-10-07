library;

class CashoutQuote {
  const CashoutQuote({
    required this.ticketId,
    required this.isAvailable,
    this.amount,
    this.odds,
  });

  final String ticketId;
  final bool isAvailable;
  final num? amount;
  final num? odds;

  bool get isSellable =>
      isAvailable && amount != null && amount! > 0;

  static CashoutQuote fromJson(Map<String, dynamic> json) => CashoutQuote(
        ticketId: json['0']?.toString() ?? '',
        isAvailable: _truthy(json['1']),
        amount: json['3'] as num?,
        odds: json['4'] as num?,
      );
}

class CashoutResult {
  const CashoutResult({
    required this.ticketId,
    required this.isSuccess,
    required this.settlementStatus,
    this.amount,
  });

  final String ticketId;
  final bool isSuccess;
  final String settlementStatus;
  final num? amount;

  static CashoutResult fromJson(Map<String, dynamic> json) => CashoutResult(
        ticketId: json['0']?.toString() ?? '',
        isSuccess: _truthy(json['1']),
        settlementStatus: json['2']?.toString() ?? '',
        amount: json['3'] as num?,
      );
}

bool _truthy(Object? v) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) {
    final s = v.trim().toLowerCase();
    return s == '1' || s == 'true' || s == 'yes';
  }
  return false;
}
