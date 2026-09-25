import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/codepay_create_qr_response.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/payment_method.dart';

class DepositStorage {
  static const String _boxName = 'deposit_qr_responses';
  static Box<String>? _box;

  static Future<void> init() async {
    if (_box != null) return;
    await Hive.initFlutter();
    _box = await Hive.openBox<String>(_boxName);
  }

  static Box<String> get box {
    if (_box == null) {
      throw Exception('DepositStorage not initialized. Call init() first.');
    }
    return _box!;
  }

  static Future<void> saveCodepayResponse(
    CodepayCreateQrResponse response, {
    required String userId,
    PaymentMethod paymentMethod = PaymentMethod.codepay,
    String? walletName,
  }) async {
    if (userId.isEmpty) {
      debugPrint('Warning: saveCodepayResponse called with empty userId');
      return;
    }

    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final adjustedRemainingTime = response.remainingTime + currentTime;

    final String storageKey;
    if (paymentMethod == PaymentMethod.eWallet && walletName != null) {
      storageKey = '${userId}_ewallet_$walletName';
    } else {
      final prefix = paymentMethod == PaymentMethod.eWallet
          ? 'ewallet'
          : 'codepay';
      storageKey = '${userId}_${prefix}_${response.bankName}';
    }

    final responseMap = {
      'bankAccount': response.bankAccount,
      'amount': response.amount,
      'statusId': response.statusId,
      'accountName': response.accountName,
      'bankBranch': response.bankBranch,
      'qrcode': response.qrcode,
      'codepay': response.codepay,
      'bankName': response.bankName,
      'message': response.message,
      'remainingTime': adjustedRemainingTime,
    };
    debugPrint(
      'save codepay: key=$storageKey, bankName=${response.bankName}, walletName=$walletName',
    );
    await box.put(storageKey, jsonEncode(responseMap));
  }

  static CodepayCreateQrResponse? getCodepayResponse(
    String bankName, {
    required String userId,
    PaymentMethod paymentMethod = PaymentMethod.codepay,
    String? walletName,
  }) {
    if (userId.isEmpty) {
      debugPrint('Warning: getCodepayResponse called with empty userId');
      return null;
    }

    final String storageKey;
    if (paymentMethod == PaymentMethod.eWallet && walletName != null) {
      storageKey = '${userId}_ewallet_$walletName';
    } else {
      final prefix = paymentMethod == PaymentMethod.eWallet
          ? 'ewallet'
          : 'codepay';
      storageKey = '${userId}_${prefix}_$bankName';
    }

    final jsonString = box.get(storageKey);
    if (jsonString == null) return null;

    try {
      final responseMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final savedRemainingTime = responseMap['remainingTime'] as int;

      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final remainingTimeMs = savedRemainingTime - currentTime;

      if (remainingTimeMs <= 0) {
        _removeByStorageKey(storageKey);
        return null;
      }

      return CodepayCreateQrResponse(
        bankAccount: responseMap['bankAccount']?.toString() ?? '',
        amount: responseMap['amount'] as int? ?? 0,
        statusId: responseMap['statusId'] as int? ?? 0,
        accountName: responseMap['accountName']?.toString() ?? '',
        bankBranch: responseMap['bankBranch']?.toString() ?? '',
        qrcode: responseMap['qrcode']?.toString() ?? '',
        codepay: responseMap['codepay']?.toString() ?? '',
        bankName: responseMap['bankName']?.toString() ?? '',
        message: responseMap['message']?.toString() ?? '',
        remainingTime: remainingTimeMs,
      );
    } catch (e) {
      _removeByStorageKey(storageKey);
      return null;
    }
  }

  static Future<void> _removeByStorageKey(String storageKey) async {
    await box.delete(storageKey);
  }

  static Future<void> removeCodepayResponse(
    String bankName, {
    required String userId,
    PaymentMethod paymentMethod = PaymentMethod.codepay,
    String? walletName,
  }) async {
    if (userId.isEmpty) {
      debugPrint('Warning: removeCodepayResponse called with empty userId');
      return;
    }

    final String storageKey;
    if (paymentMethod == PaymentMethod.eWallet && walletName != null) {
      storageKey = '${userId}_ewallet_$walletName';
    } else {
      final prefix = paymentMethod == PaymentMethod.eWallet
          ? 'ewallet'
          : 'codepay';
      storageKey = '${userId}_${prefix}_$bankName';
    }
    await _removeByStorageKey(storageKey);
  }

  static bool hasValidResponse(
    String bankName, {
    required String userId,
    PaymentMethod paymentMethod = PaymentMethod.codepay,
    String? walletName,
  }) {
    return getCodepayResponse(
          bankName,
          userId: userId,
          paymentMethod: paymentMethod,
          walletName: walletName,
        ) !=
        null;
  }

  static Future<void> clearAll() async {
    await box.clear();
  }
}
