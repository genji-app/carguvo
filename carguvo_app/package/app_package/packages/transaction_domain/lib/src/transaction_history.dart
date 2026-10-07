import 'transaction_enums.dart';

class TransactionHistoryConfig {
  const TransactionHistoryConfig({
    this.pageSize = 20,
    this.maxPages = 100,
  });

  final int pageSize;
  final int maxPages;
}

class TransactionHistoryState {
  const TransactionHistoryState({
    this.items = const [],
    this.currentPage = 0,
    this.hasNextPage = true,
    this.isLoading = false,
    this.error,
  });

  final List<Map<String, dynamic>> items;
  final int currentPage;
  final bool hasNextPage;
  final bool isLoading;
  final String? error;

  TransactionHistoryState copyWith({
    List<Map<String, dynamic>>? items,
    int? currentPage,
    bool? hasNextPage,
    bool? isLoading,
    String? error,
  }) {
    return TransactionHistoryState(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionHistoryState &&
          runtimeType == other.runtimeType &&
          currentPage == other.currentPage &&
          hasNextPage == other.hasNextPage &&
          isLoading == other.isLoading;

  @override
  int get hashCode =>
      currentPage.hashCode ^ hasNextPage.hashCode ^ isLoading.hashCode;
}

class TransactionHistoryPager {
  TransactionHistoryPager({TransactionHistoryConfig? config})
      : _config = config ?? const TransactionHistoryConfig();

  final TransactionHistoryConfig _config;
  final List<Map<String, dynamic>> _allItems = [];

  int get pageSize => _config.pageSize;

  int get maxPages => _config.maxPages;

  List<Map<String, dynamic>> get allItems => List.unmodifiable(_allItems);

  int get currentPage => (_allItems.length / _config.pageSize).floor();

  bool get hasNextPage => currentPage < _config.maxPages;

  void addPage(List<Map<String, dynamic>> items) {
    _allItems.addAll(items);
  }

  List<Map<String, dynamic>> getPage(int pageNumber) {
    final start = pageNumber * _config.pageSize;
    final end = start + _config.pageSize;
    if (start >= _allItems.length) return [];
    return _allItems.sublist(start, end > _allItems.length ? _allItems.length : end);
  }

  void clear() {
    _allItems.clear();
  }

  int get count => _allItems.length;
}

class TransactionFormatter {
  const TransactionFormatter();

  String formatAmount(num value) {
    final rounded = value.round();
    final str = rounded.abs().toString();
    final buffer = StringBuffer(rounded < 0 ? '-' : '');

    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }

    return buffer.toString();
  }

  String formatAmountWithCurrency(num value, {String currency = 'VND'}) {
    final formatted = formatAmount(value);
    switch (currency.toUpperCase()) {
      case 'VND':
        return '$formatted₫';
      case 'USD':
        return '\$$formatted';
      default:
        return '$formatted $currency';
    }
  }

  String formatCompact(num value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}B';
    } else if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return formatAmount(value);
  }

  String statusLabel(TransactionStatus status) {
    return switch (status) {
      TransactionStatus.pending => 'Chờ xử lý',
      TransactionStatus.success => 'Thành công',
      TransactionStatus.rejected => 'Từ chối',
      TransactionStatus.transfered => 'Đã chuyển',
      TransactionStatus.processing => 'Đang xử lý',
      TransactionStatus.newRequest => 'Yêu cầu mới',
      TransactionStatus.other => 'Khác',
    };
  }

  String paymentMethodLabel(TransactionPaymentMethod method) {
    return switch (method) {
      TransactionPaymentMethod.ibanking => 'iBanking',
      TransactionPaymentMethod.atm => 'ATM',
      TransactionPaymentMethod.office => 'Văn phòng',
      TransactionPaymentMethod.digitalWallets => 'Ví điện tử',
      TransactionPaymentMethod.smartPay => 'SmartPay',
      TransactionPaymentMethod.codePay => 'CodePay',
      TransactionPaymentMethod.card => 'Thẻ cào',
      TransactionPaymentMethod.crypto => 'Crypto',
      TransactionPaymentMethod.qrPay => 'QR Pay',
      TransactionPaymentMethod.iap => 'IAP',
      TransactionPaymentMethod.other => 'Khác',
    };
  }

  String slipTypeLabel(TransactionSlipType type) {
    return switch (type) {
      TransactionSlipType.deposit => 'Nạp tiền',
      TransactionSlipType.withdraw => 'Rút tiền',
      TransactionSlipType.other => 'Khác',
    };
  }
}
