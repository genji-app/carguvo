import 'package:flutter/foundation.dart';
import 'package:provider_game_manager/provider_game_manager.dart';
import 'package:sun_sports/core/services/models/transaction/transaction.dart';
import 'package:transaction_domain/transaction_domain.dart' as td;

import 'models/models.dart';

abstract final class TransactionMapper {
  static UnifiedTransaction fromCardSlip(
    Map<String, dynamic> raw,
    TransactionSource source,
    TransactionSlipType slipType,
  ) {
    final statusMsg = raw['statusMessage'] as String?;

    return standardLegacy(raw, source, slipType, statusMsg);
  }

  static UnifiedTransaction standardLegacy(
    Map<String, dynamic> raw,
    TransactionSource source,
    TransactionSlipType slipType,
    String? statusMsg,
  ) {
    final codeVal = raw['code']?.toString() ?? raw['serial']?.toString() ?? '';
    final amountVal = raw['amount'] as num? ?? 0;

    if (source == TransactionSource.cardDeposit) {
      return UnifiedTransaction.cardDeposit(
        id: raw['serial']?.toString() ?? codeVal,
        amount: amountVal,
        source: source,
        status: parseStatusFromMessage(statusMsg),
        statusDescription: statusMsg ?? '',
        serial: raw['serial']?.toString() ?? '',
        code: raw['code']?.toString() ?? '',
        network: raw['network']?.toString() ?? '',
        sortTime: parseSortTime(raw),
        receivedAmount: raw['receivedAmount'] as num?,
        debugRawJson: raw,
      );
    } else {
      final item = raw['item'] as Map<String, dynamic>?;
      final telcoNameVal =
          item?['displayName']?.toString() ??
          raw['displayName']?.toString() ??
          '';
      final result = raw['result'] as Map<String, dynamic>?;
      return UnifiedTransaction.cardWithdraw(
        id:
            raw['id']?.toString() ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        amount: amountVal,
        source: source,
        status: resolveCardWithdrawStatus(
          raw['status'] as int?,
          raw['description'] as String?,
        ),
        statusDescription: raw['description']?.toString() ?? '',
        serial: result?['serial']?.toString(),
        code: result?['code']?.toString(),
        telcoName: telcoNameVal,
        sortTime: parseSortTime(raw),
        debugRawJson: raw,
      );
    }
  }

  static UnifiedTransaction mapRaw(
    Map<String, dynamic> raw,
    TransactionSource source,
    TransactionSlipType slipType,
  ) {
    final amountVal = (raw['amount'] as num?) ?? (raw['value'] as num?) ?? 0;
    final bankReceiveMap = raw['bankReceive'] as Map<String, dynamic>?;

    return UnifiedTransaction.slip(
      id:
          (raw['id'] as Object?)?.toString() ??
          (raw['_id'] as Object?)?.toString() ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      amount: amountVal,
      source: source,
      slipType: slipType,
      status: parseStatus(raw['status'] as int?),
      paymentMethod: parsePaymentMethod(
        raw['type'] as int? ?? raw['method'] as int?,
      ),
      statusDescription:
          (raw['statusDescription'] as String?) ??
          (raw['reason'] as String?) ??
          (raw['note'] as String?) ??
          '',
      transactionCode:
          (raw['transactionCode'] as String?) ??
          (raw['code'] as String?) ??
          (raw['ref'] as String?) ??
          '',
      sortTime: parseSortTime(raw),
      bankName: bankReceiveMap?['bankId']?.toString(),
      accountName: bankReceiveMap?['accountName']?.toString(),
      accountNumber: bankReceiveMap?['accountNumber']?.toString(),
      notes: (raw['notes'] as String?) ?? (raw['note'] as String?),
      debugRawJson: raw,
    );
  }

  static DateTime parseSortTime(Map<String, dynamic> raw) =>
      td.parseSortTime(raw, log: debugPrint);

  static TransactionStatus resolveCardWithdrawStatus(
    int? statusCode,
    String? description,
  ) => td.resolveCardWithdrawStatus(statusCode, description);

  static TransactionStatus parseStatus(int? code) => td.parseStatus(code);

  static TransactionStatus parseStatusFromMessage(String? msg) =>
      td.parseStatusFromMessage(msg);

  static TransactionPaymentMethod parsePaymentMethod(int? code) =>
      td.parsePaymentMethod(code);

  static TransactionSlipType parseSlipType(int? code) =>
      td.parseSlipType(code);

  static ActivityGroup mapServiceNameToGroup(String serviceName) =>
      td.mapServiceNameToGroup(serviceName);
}

extension PaymentSlipDtoMapper on PaymentSlipDto {
  UnifiedTransaction toUnified() {
    return UnifiedTransaction.slip(
      id: id.toString(),
      amount: amount,
      source: TransactionSource.paymentSlip,
      slipType: TransactionMapper.parseSlipType(slipType),
      status: TransactionMapper.parseStatus(status),
      paymentMethod: TransactionMapper.parsePaymentMethod(type),
      statusDescription: statusDescription,
      transactionCode: transactionCode,
      sortTime: DateTime.fromMillisecondsSinceEpoch(responseTime),
      bankName: bankReceive.bankId,
      accountName: bankReceive.accountName,
      accountNumber: bankReceive.accountNumber,
      notes: notes,
      debugRawJson: toJson(),
    );
  }
}

extension DepositComplainDtoMapper on DepositComplainResponseDto {
  UnifiedTransaction toUnified() {
    final amountVal = amount ?? value ?? 0;

    final ms = responseTime ?? requestTime ?? createdTime ?? createdAt ?? time;
    final parsedTime = ms != null ? td.epochToLocal(ms) : DateTime.now();

    return UnifiedTransaction.slip(
      id:
          id?.toString() ??
          objectId?.toString() ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      amount: amountVal,
      source: TransactionSource.paymentSlip,
      slipType: TransactionSlipType.deposit,
      status: TransactionMapper.parseStatus(status),
      paymentMethod: TransactionMapper.parsePaymentMethod(type ?? method),
      statusDescription: statusDescription ?? reason ?? note ?? '',
      transactionCode: transactionCode ?? code ?? ref ?? '',
      sortTime: parsedTime,
      bankName: null,
      accountName: null,
      accountNumber: null,
      notes: note ?? reason ?? '',
      debugRawJson: toJson(),
    );
  }
}

extension CardDepositDtoMapper on CardDepositResponseDto {
  UnifiedTransaction toUnified() {
    final statusMsg = statusMessage ?? '';
    return UnifiedTransaction.cardDeposit(
      id: serial ?? code ?? DateTime.now().microsecondsSinceEpoch.toString(),
      amount: amount ?? 0,
      source: TransactionSource.cardDeposit,
      status: TransactionMapper.parseStatusFromMessage(statusMessage),
      statusDescription: statusMsg,
      serial: serial ?? '',
      code: code ?? '',
      network: network ?? '',
      sortTime: createdTime != null
          ? td.epochToLocal(createdTime!)
          : DateTime.now(),
      receivedAmount: receivedAmount,
      debugRawJson: toJson(),
    );
  }
}

extension CardWithdrawDtoMapper on CardWithdrawResponseDto {
  UnifiedTransaction toUnified() {
    final resolvedStatus = TransactionMapper.resolveCardWithdrawStatus(
      status,
      description,
    );

    final effectiveMs = (responseTime != null && responseTime! > 0)
        ? responseTime
        : requestTime;
    final parsedTime = effectiveMs != null
        ? td.epochToLocal(effectiveMs)
        : DateTime.now();

    return UnifiedTransaction.cardWithdraw(
      id: id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      amount: item?.amount ?? 0,
      source: TransactionSource.cardWithdraw,
      status: resolvedStatus,
      statusDescription: description ?? '',
      serial: result?.serial?.toString(),
      code: result?.code?.toString(),
      telcoName: item?.displayName ?? '',
      sortTime: parsedTime,
      debugRawJson: toJson(),
    );
  }
}

extension PlayHistoryItemDtoMapper on PlayHistoryItemDto {
  UnifiedTransaction toUnified() {
    final isDeposit = exchangeValue >= 0;

    return UnifiedTransaction.activity(
      id: '${createdTime}_${exchangeValue.abs()}_${serviceName.hashCode}',
      amount: exchangeValue.abs(),
      source: TransactionSource.activityLog,
      slipType: isDeposit
          ? TransactionSlipType.deposit
          : TransactionSlipType.withdraw,
      status: TransactionStatus.success,
      statusDescription: description,
      closingBalance: closingValue,
      group: TransactionMapper.mapServiceNameToGroup(serviceName),
      rawServiceName: serviceName,
      sortTime: td.epochToLocal(createdTime),
      debugRawJson: toJson(),
    );
  }
}
