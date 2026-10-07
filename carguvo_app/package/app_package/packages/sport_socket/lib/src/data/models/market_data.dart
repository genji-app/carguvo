enum MarketStatus {
  active(0),

  suspended(1),

  hidden(2),

  autoSuspended(3),

  autoHidden(4);

  final int code;

  const MarketStatus(this.code);

  static MarketStatus fromCode(dynamic code) {
    final intCode =
        code is String ? int.tryParse(code) ?? 0 : (code as int?) ?? 0;
    return MarketStatus.values.firstWhere(
      (s) => s.code == intCode,
      orElse: () => MarketStatus.active,
    );
  }

  bool get canBet => this == MarketStatus.active;

  bool get isVisible =>
      this != MarketStatus.hidden && this != MarketStatus.autoHidden;

  bool get isSuspended =>
      this == MarketStatus.suspended || this == MarketStatus.autoSuspended;
}

class MarketData {
  final int marketId;

  final int eventId;

  String? name;

  String? marketType;

  MarketStatus status;

  bool isParlay;

  bool isCashOut;

  int promotionType;

  int groupId;

  bool get isSuspended => status.isSuspended;

  bool get isVisible => status.isVisible;

  bool get canBet => status.canBet;

  int _version = 0;

  int get version => _version;

  MarketData({
    required this.marketId,
    required this.eventId,
    this.name,
    this.marketType,
    this.status = MarketStatus.active,
    this.isParlay = false,
    this.isCashOut = false,
    this.promotionType = 0,
    this.groupId = 0,
  });

  factory MarketData.fromJson(
    Map<String, dynamic> json, {
    required int eventId,
  }) {
    final marketId = json['marketId'] as int? ??
        json['domainMarketId'] as int? ??
        json['mi'] as int? ??
        0;

    final market = MarketData(
      marketId: marketId,
      eventId: eventId,
    );

    market._applyJson(json);
    return market;
  }

  void updateFrom(Map<String, dynamic> data) {
    _applyJson(data);
    _version++;
  }

  void _applyJson(Map<String, dynamic> data) {
    if (data.containsKey('marketName') || data.containsKey('mn')) {
      name = data['marketName']?.toString() ?? data['mn']?.toString();
    }

    if (data.containsKey('marketType') || data.containsKey('mt')) {
      marketType = data['marketType']?.toString() ?? data['mt']?.toString();
    }

    if (data.containsKey('status')) {
      status = MarketStatus.fromCode(data['status']);
    }
    if (data.containsKey('isSuspended')) {
      status = data['isSuspended'] == true
          ? MarketStatus.suspended
          : MarketStatus.active;
    }

    if (data.containsKey('isParlay')) {
      isParlay = data['isParlay'] == true;
    }
    if (data.containsKey('isCashOut')) {
      isCashOut = data['isCashOut'] == true;
    }
    if (data.containsKey('promotionType')) {
      promotionType = _parseInt(data['promotionType']) ?? promotionType;
    }
    if (data.containsKey('groupId')) {
      groupId = _parseInt(data['groupId']) ?? groupId;
    }
  }

  String get marketKey => '${eventId}_$marketId';

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  @override
  String toString() {
    return 'MarketData(marketId: $marketId, eventId: $eventId, '
        'status: $status, name: $name)';
  }
}
