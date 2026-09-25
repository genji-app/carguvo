import 'bank.dart';
import 'crypto_config.dart';
import 'payment_config_data.dart';

enum PaymentMethodType {
  bank(1),
  eWallet(2),
  crypto(4);

  const PaymentMethodType(this.value);
  final int value;

  static PaymentMethodType fromValue(int? value) => switch (value) {
    1 => PaymentMethodType.bank,
    2 => PaymentMethodType.eWallet,
    4 => PaymentMethodType.crypto,
    _ => PaymentMethodType.bank,
  };

  String get label => switch (this) {
    PaymentMethodType.bank => 'Ngân hàng',
    PaymentMethodType.eWallet => 'Ví điện tử',
    PaymentMethodType.crypto => 'Tiền mã hóa',
  };
}

class PaymentMethodInfo {
  const PaymentMethodInfo({
    required this.id,
    required this.name,
    this.fullName,
    this.shortName,
    this.imageUrl,
    this.methodType = PaymentMethodType.bank,
    this.supportQRCode = false,
    this.supportWithdraw = false,
  });

  final String id;
  final String name;
  final String? fullName;
  final String? shortName;
  final String? imageUrl;
  final PaymentMethodType methodType;
  final bool supportQRCode;
  final bool supportWithdraw;

  String get displayName => shortName ?? name;

  String get typeLabel => methodType.label;

  bool get isBank => methodType == PaymentMethodType.bank;

  bool get isEWallet => methodType == PaymentMethodType.eWallet;

  bool get isCrypto => methodType == PaymentMethodType.crypto;
}

extension PaymentConfigDataX on PaymentConfigData {
  Map<String, PaymentMethodInfo> buildPaymentMethodMap() {
    final map = <String, PaymentMethodInfo>{};

    for (final item in items ?? <BankItem>[]) {
      if (item.id.isNotEmpty) {
        map[item.id] = PaymentMethodInfo(
          id: item.id,
          name: item.name,
          fullName: item.fullName,
          shortName: item.shortName,
          imageUrl: item.url,
          methodType: PaymentMethodType.fromValue(item.bankType),
          supportQRCode: item.supportQRCode ?? false,
          supportWithdraw: item.supportWithdraw ?? false,
        );
      }
    }

    for (final item in codepay ?? <CodePayBank>[]) {
      if (item.id.isNotEmpty && !map.containsKey(item.id)) {
        map[item.id] = PaymentMethodInfo(
          id: item.id,
          name: item.name,
          fullName: item.fullName,
          shortName: item.shortName,
          imageUrl: item.url,
          methodType: PaymentMethodType.fromValue(item.bankType),
          supportQRCode: item.supportQRCode ?? false,
          supportWithdraw: item.supportWithdraw ?? false,
        );
      }
    }

    for (final item in crypto ?? <CryptoConfig>[]) {
      final id = item.bankId;
      if (id != null && id.isNotEmpty && !map.containsKey(id)) {
        map[id] = PaymentMethodInfo(
          id: id,
          name: item.currencyName ?? 'Crypto',
          fullName: item.currencyName,
          shortName: item.currencyName,
          imageUrl: null,
          methodType: PaymentMethodType.crypto,
          supportQRCode: false,
          supportWithdraw: false,
        );
      }
    }

    return map;
  }

  PaymentMethodInfo? getPaymentMethodById(String id) {
    return buildPaymentMethodMap()[id];
  }

  List<PaymentMethodInfo> get allPaymentMethods {
    return buildPaymentMethodMap().values.toList();
  }
}
