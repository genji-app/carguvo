library;

class TransactionHistoryApi {
  TransactionHistoryApi._();

  static const String paygateSlipHistoryCommand = 'fetchTransactionSlipHistory';

  static const String paygateCardHistoryCommand = 'fetchCardHistory';

  static const String paygateCardWithdrawCommand = 'lichsudt';

  static const String saPlayHistoryCommand = 'fetch-user-transaction2';

  static const String activityAssetName = 'gold';
}

(int, List<Map<String, dynamic>>) transactionCountAndItemsOf(
  Map<String, dynamic> root,
) {
  final dataRaw = root['data'];
  List<dynamic> rawItems;
  Object? countRaw;
  if (dataRaw is List) {
    rawItems = dataRaw;
    countRaw = root['count'];
  } else {
    final data = dataRaw is Map ? Map<String, dynamic>.from(dataRaw) : root;
    rawItems = (data['items'] as List?) ?? const [];
    countRaw = data['count'];
  }
  final items = rawItems
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
  final count = countRaw is num ? countRaw.toInt() : items.length;
  return (count, items);
}

String? transactionBusinessErrorOf(Map<String, dynamic> root) {
  final code = root['code'];
  if (code is num && code != 0) {
    return '${root['message'] ?? 'Lỗi'} (code $code)';
  }
  final status = root['status'];
  if (status is num && status != 200 && status != 0) {
    return '${root['message'] ?? 'Lỗi'} (status $status)';
  }
  return null;
}
