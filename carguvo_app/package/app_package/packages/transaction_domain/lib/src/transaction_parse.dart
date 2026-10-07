library;

import 'package:game_taxonomy/game_taxonomy.dart';

import 'transaction_enums.dart';
const int kTransactionSecondsCeiling = 10000000000;

DateTime epochToLocal(num raw) {
  final v = raw.toInt();
  return DateTime.fromMillisecondsSinceEpoch(
    v < kTransactionSecondsCeiling ? v * 1000 : v,
  );
}

int? _positive(dynamic raw) {
  final value = transactionIntFrom(raw);
  return (value == null || value <= 0) ? null : value;
}

DateTime parseSortTime(
  Map<String, dynamic> raw, {
  void Function(String message)? log,
  DateTime Function()? now,
}) {
  final ms =
      _positive(raw['responseTime']) ??
      _positive(raw['requestTime']) ??
      _positive(raw['createdTime']) ??
      _positive(raw['createdAt']) ??
      _positive(raw['time']);
  if (ms == null) {
    log?.call(
      '[TransactionMapper] Warning: Could not parse sortTime, using DateTime.now()',
    );
    return (now ?? DateTime.now)();
  }
  return epochToLocal(ms);
}

TransactionStatus parseStatus(int? code) {
  if (code == null) return TransactionStatus.pending;
  return switch (code) {
    1 || 11 => TransactionStatus.pending,
    2 || 12 => TransactionStatus.success,
    3 => TransactionStatus.rejected,
    4 => TransactionStatus.transfered,
    5 || 9 || 10 => TransactionStatus.processing,
    6 => TransactionStatus.newRequest,
    _ => TransactionStatus.other,
  };
}
TransactionStatus parseStatusFromMessage(String? msg) {
  if (msg == null) return TransactionStatus.pending;
  final m = msg.toLowerCase().trim();
  if (m.contains('thành công') ||
      m.contains('success') ||
      m.contains('hoàn thành') ||
      m.contains('complete')) {
    return TransactionStatus.success;
  }
  if (m.contains('từ chối') ||
      m.contains('thất bại') ||
      m.contains('fail') ||
      m.contains('lỗi') ||
      m.contains('error')) {
    return TransactionStatus.rejected;
  }
  if (m.contains('đang xử lý') || m.contains('processing')) {
    return TransactionStatus.processing;
  }
  return TransactionStatus.pending;
}

TransactionStatus resolveCardWithdrawStatus(
  int? statusCode,
  String? description,
) {
  if (description != null && description.isNotEmpty) {
    final m = description.toLowerCase().trim();
    if (m.contains('từ chối') ||
        m.contains('thất bại') ||
        m.contains('fail') ||
        m.contains('lỗi') ||
        m.contains('error')) {
      return TransactionStatus.rejected;
    }
    if (m.contains('thành công') ||
        m.contains('success') ||
        m.contains('hoàn thành') ||
        m.contains('đã trả thưởng') ||
        m.contains('complete')) {
      return TransactionStatus.success;
    }
    if (m.contains('đang xử lý') || m.contains('processing')) {
      return TransactionStatus.processing;
    }
  }
  return parseStatus(statusCode);
}

TransactionPaymentMethod parsePaymentMethod(int? code) => switch (code) {
  1 => TransactionPaymentMethod.ibanking,
  2 => TransactionPaymentMethod.atm,
  3 => TransactionPaymentMethod.office,
  4 => TransactionPaymentMethod.digitalWallets,
  5 => TransactionPaymentMethod.smartPay,
  6 => TransactionPaymentMethod.codePay,
  7 => TransactionPaymentMethod.card,
  8 => TransactionPaymentMethod.crypto,
  9 => TransactionPaymentMethod.qrPay,
  11 => TransactionPaymentMethod.iap,
  _ => TransactionPaymentMethod.other,
};

TransactionSlipType parseSlipType(int? code) => switch (code) {
  1 => TransactionSlipType.deposit,
  2 => TransactionSlipType.withdraw,
  _ => TransactionSlipType.other,
};

ActivityGroup mapServiceNameToGroup(String serviceName) =>
    serviceName.classifyActivityGroup;

int? transactionIntFrom(Object? v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

num? transactionNumFrom(Object? v) {
  if (v is num) return v;
  if (v is String) return num.tryParse(v);
  return null;
}

String formatHistoryTime(DateTime dt) {
  final local = dt.isUtc ? dt.toLocal() : dt;
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(local.hour)}:${two(local.minute)} - '
      '${two(local.day)}/${two(local.month)}/${local.year}';
}

String refundServiceName({
  required bool isRefund,
  required String rawServiceName,
}) =>
    isRefund && rawServiceName == 'Rút' ? 'Hoàn tiền' : rawServiceName;
