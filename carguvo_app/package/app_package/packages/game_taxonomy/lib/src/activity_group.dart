enum ActivityGroup {
  deposit,
  withdraw,
  cancel,
  promotion,
  sport,
  casino,
}

extension ActivityGroupClassifier on String {
  static const _depositPatterns = ['nạp', 'deposit'];

  static const _cancelPatterns = ['hủy'];

  static const _withdrawPatterns = ['rút', 'withdraw'];

  static const _sportPatterns = [
    'k-sport',
    'saba',
    'bti',
    'sport',
    'thể thao',
  ];

  static const _promotionPatterns = [
    'khuyến mãi',
    'hoàn trả',
    'giftcode',
    'lì xì',
  ];

  ActivityGroup get classifyActivityGroup {
    final lower = trim().toLowerCase();
    if (lower.isEmpty) return ActivityGroup.casino;

    if (_depositPatterns.any(lower.contains)) return ActivityGroup.deposit;
    if (_cancelPatterns.any(lower.contains)) return ActivityGroup.cancel;
    if (_withdrawPatterns.any(lower.contains)) return ActivityGroup.withdraw;
    if (_promotionPatterns.any(lower.contains)) return ActivityGroup.promotion;
    if (_sportPatterns.any(lower.contains)) return ActivityGroup.sport;

    return ActivityGroup.casino;
  }
}
