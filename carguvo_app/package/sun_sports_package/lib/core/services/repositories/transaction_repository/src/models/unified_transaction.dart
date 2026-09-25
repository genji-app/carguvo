// ignore_for_file: avoid_dynamic_calls

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sun_sports/core/services/models/transaction/transaction.dart';

import 'transaction_filter.dart';

part 'unified_transaction.freezed.dart';

@freezed
sealed class UnifiedTransaction with _$UnifiedTransaction {
  const factory UnifiedTransaction.slip({
    required String id,

    required num amount,

    required TransactionSource source,

    required TransactionSlipType slipType,

    required TransactionStatus status,

    required TransactionPaymentMethod paymentMethod,

    required String statusDescription,

    required String transactionCode,

    required DateTime sortTime,

    String? bankName,

    String? accountName,

    String? accountNumber,

    String? notes,

    @JsonKey(includeFromJson: false, includeToJson: false)
    Map<String, dynamic>? debugRawJson,
  }) = SlipTransaction;

  const factory UnifiedTransaction.cardDeposit({
    required String id,

    required num amount,

    required TransactionSource source,

    required TransactionStatus status,

    required String statusDescription,

    required String serial,

    required String code,

    required String network,

    required DateTime sortTime,

    num? receivedAmount,

    @JsonKey(includeFromJson: false, includeToJson: false)
    Map<String, dynamic>? debugRawJson,
  }) = CardDepositTransaction;

  const factory UnifiedTransaction.cardWithdraw({
    required String id,

    required num amount,

    required TransactionSource source,

    required TransactionStatus status,

    required String statusDescription,

    required String telcoName,

    required DateTime sortTime,

    String? serial,

    String? code,

    @JsonKey(includeFromJson: false, includeToJson: false)
    Map<String, dynamic>? debugRawJson,
  }) = CardWithdrawTransaction;

  const factory UnifiedTransaction.activity({
    required String id,

    required num amount,

    required TransactionSource source,

    required TransactionSlipType slipType,

    required TransactionStatus status,

    required String statusDescription,

    required num closingBalance,

    required ActivityGroup group,

    required String rawServiceName,

    required DateTime sortTime,

    @JsonKey(includeFromJson: false, includeToJson: false)
    Map<String, dynamic>? debugRawJson,
  }) = ActivityTransaction;
}

extension UnifiedTransactionX on UnifiedTransaction {
  bool get isPositive => slipType == TransactionSlipType.deposit;

  String get amountPrefix => isPositive ? '+' : '-';

  DateTime get date => sortTime;

  TransactionPaymentMethod get paymentMethod => map(
    slip: (s) => s.paymentMethod,
    cardDeposit: (_) => TransactionPaymentMethod.card,
    cardWithdraw: (_) => TransactionPaymentMethod.card,
    activity: (_) => TransactionPaymentMethod.other,
  );

  String get transactionCode => map(
    slip: (s) => s.transactionCode,
    cardDeposit: (c) => c.code,
    cardWithdraw: (c) => c.code ?? '',
    activity: (_) => '',
  );

  String? get notes => map(
    slip: (s) => s.notes,
    cardDeposit: (_) => null,
    cardWithdraw: (_) => null,
    activity: (_) => null,
  );

  String get bankId => map(
    slip: (s) => s.bankName ?? '',
    cardDeposit: (_) => '',
    cardWithdraw: (_) => '',
    activity: (_) => '',
  );

  String? get accountName => map(
    slip: (s) => s.accountName,
    cardDeposit: (_) => null,
    cardWithdraw: (_) => null,
    activity: (_) => null,
  );

  String? get accountNumber => map(
    slip: (s) => s.accountNumber,
    cardDeposit: (_) => null,
    cardWithdraw: (_) => null,
    activity: (_) => null,
  );

  String? get cardSerial => map(
    slip: (_) => null,
    cardDeposit: (c) => c.serial,
    cardWithdraw: (c) => c.serial,
    activity: (_) => null,
  );

  String? get cardCode => map(
    slip: (_) => null,
    cardDeposit: (c) => c.code,
    cardWithdraw: (c) => c.code,
    activity: (_) => null,
  );

  String? get cardTelcoName => map(
    slip: (_) => null,
    cardDeposit: (c) => c.network,
    cardWithdraw: (c) => c.telcoName,
    activity: (_) => null,
  );

  TransactionSlipType get slipType => map(
    slip: (s) => s.slipType,
    cardDeposit: (_) => TransactionSlipType.deposit,
    cardWithdraw: (_) => TransactionSlipType.withdraw,
    activity: (a) => a.slipType,
  );

  num get actualAmount => map(
    slip: (s) => s.amount,
    cardDeposit: (c) {
      final received = c.receivedAmount;
      if (received == null || received <= 0 || received > c.amount) {
        return c.amount;
      }
      return received;
    },
    cardWithdraw: (c) => c.amount,
    activity: (a) => a.amount,
  );

  num? get cardFaceValue => map(
    slip: (_) => null,
    cardDeposit: (c) => c.amount,
    cardWithdraw: (c) => c.amount,
    activity: (_) => null,
  );

  double? get discountPercentage => mapOrNull(
    cardDeposit: (c) {
      final received = c.receivedAmount;
      if (received == null) return null;
      if (c.amount <= 0 || received <= 0) return null;
      if (received >= c.amount) return null;
      final pct = (c.amount - received) / c.amount * 100;
      if (pct > 100) return null;
      return pct;
    },
  );

  num? get discountAmount => mapOrNull(
    cardDeposit: (c) {
      final received = c.receivedAmount;
      if (received == null || received <= 0 || received >= c.amount) {
        return null;
      }
      return c.amount - received;
    },
  );
}

extension ActivityTransactionX on ActivityTransaction {
  bool get isRefund {
    if (group == ActivityGroup.cancel) return true;
    if (group == ActivityGroup.withdraw &&
        slipType == TransactionSlipType.deposit) {
      return true;
    }
    return false;
  }
}
