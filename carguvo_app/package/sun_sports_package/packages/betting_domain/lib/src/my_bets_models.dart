library;

enum BetSlipStatus {
  active,
  running,
  pending,
  settled,
  declined,
  cashout,
  unknown;

  static BetSlipStatus fromString(String? value) {
    if (value == null || value.isEmpty) return BetSlipStatus.settled;
    return switch (value.toLowerCase().trim()) {
      'active' || 'running' => BetSlipStatus.active,
      'pending' => BetSlipStatus.pending,
      'settled' => BetSlipStatus.settled,
      'declined' => BetSlipStatus.declined,
      'cashout' => BetSlipStatus.cashout,
      _ => BetSlipStatus.unknown,
    };
  }

  String toApiString() => switch (this) {
    BetSlipStatus.active || BetSlipStatus.running => 'Active',
    BetSlipStatus.pending => 'Pending',
    BetSlipStatus.settled => 'Settled',
    BetSlipStatus.declined => 'Declined',
    BetSlipStatus.cashout => 'Cashout',
    BetSlipStatus.unknown => 'Unknown',
  };

  bool get isActiveStatus =>
      this == BetSlipStatus.active || this == BetSlipStatus.running;

  bool get isPendingStatus => this == BetSlipStatus.pending;
}

enum SettlementStatusEnum {
  won,
  lost,
  halfWon,
  halfLost,
  draw,
  cashout,
  pending,
  running,
  refunded,
  voided,
  declined,
  processing,
  unknown;

  bool get isSettled => switch (this) {
    SettlementStatusEnum.won ||
    SettlementStatusEnum.lost ||
    SettlementStatusEnum.halfWon ||
    SettlementStatusEnum.halfLost ||
    SettlementStatusEnum.draw ||
    SettlementStatusEnum.cashout ||
    SettlementStatusEnum.refunded ||
    SettlementStatusEnum.voided ||
    SettlementStatusEnum.declined => true,
    _ => false,
  };

  static SettlementStatusEnum fromString(String? value) {
    if (value == null || value.isEmpty) return SettlementStatusEnum.unknown;
    final s = value.toLowerCase().replaceAll(' ', '').trim();
    return switch (s) {
      'won' => SettlementStatusEnum.won,
      'lost' => SettlementStatusEnum.lost,
      'wonhalf' || 'halfwon' => SettlementStatusEnum.halfWon,
      'losthalf' || 'halflost' => SettlementStatusEnum.halfLost,
      'draw' || 'tie' => SettlementStatusEnum.draw,
      'void' || 'voided' => SettlementStatusEnum.voided,
      'refund' || 'refunded' => SettlementStatusEnum.refunded,
      'cashout' => SettlementStatusEnum.cashout,
      'declined' => SettlementStatusEnum.declined,
      'pending' => SettlementStatusEnum.pending,
      'running' || 'active' => SettlementStatusEnum.running,
      'processing' => SettlementStatusEnum.processing,
      _ => SettlementStatusEnum.unknown,
    };
  }

  String toApiString() => switch (this) {
    SettlementStatusEnum.won => 'Won',
    SettlementStatusEnum.lost => 'Lost',
    SettlementStatusEnum.halfWon => 'Half Won',
    SettlementStatusEnum.halfLost => 'Half Lost',
    SettlementStatusEnum.draw => 'Draw',
    SettlementStatusEnum.voided => 'Voided',
    SettlementStatusEnum.refunded => 'Refunded',
    SettlementStatusEnum.cashout => 'Cashout',
    SettlementStatusEnum.declined => 'Declined',
    SettlementStatusEnum.pending => 'Pending',
    SettlementStatusEnum.running => 'Running',
    SettlementStatusEnum.processing => 'Processing',
    SettlementStatusEnum.unknown => 'Unknown',
  };
}

enum MatchType {
  normal,
  leagueBetting,
  unknown;

  static MatchType fromString(String? value) {
    if (value == null || value.isEmpty) return MatchType.unknown;
    final normalized = value.toLowerCase().trim();
    if (normalized == 'normal') return MatchType.normal;
    if (normalized == 'league betting') return MatchType.leagueBetting;
    return MatchType.unknown;
  }

  String toApiString() => switch (this) {
    MatchType.normal => 'Normal',
    MatchType.leagueBetting => 'League Betting',
    MatchType.unknown => 'Unknown',
  };
}

class BettingHistoryConstants {
  BettingHistoryConstants._();

  static const String apiStatusActive = 'Active';
  static const String apiStatusPending = 'Pending';
  static const String apiStatusSettled = 'Settled';
  static const String apiStatusDeclined = 'Declined';
  static const String apiStatusAll = 'All';

  static const String defaultCurrency = 'VND';
  static const String defaultMatchType = 'Normal';

  static const String defaultScore = '[0-0]';
  static const String scoreSeparatorApi = ':';
  static const String scoreBracketStart = '[';
  static const String scoreBracketEnd = ']';
  static const String scoreDash = '-';
}

class CashoutInfo {
  const CashoutInfo({
    required this.id,
    required this.time,
    this.stakeAmount = 0,
    this.cashoutAmount = 0,
    this.fee = 0.0,
    this.isSuccess = false,
  });

  final String id;
  final DateTime time;
  final num stakeAmount;
  final num cashoutAmount;
  final double fee;
  final bool isSuccess;

  factory CashoutInfo.fromJson(Map<String, dynamic> json) => CashoutInfo(
        id: json['0']?.toString() ?? '',
        time: _localDateTime(json['6']) ?? DateTime.now(),
        stakeAmount: (json['1'] as num?) ?? 0,
        cashoutAmount: (json['3'] as num?) ?? 0,
        fee: (json['4'] as num?)?.toDouble() ?? 0.0,
        isSuccess: json['5'] == true,
      );
}

class CashoutResponse {
  const CashoutResponse({
    required this.ticketId,
    this.isSuccess = false,
    required this.settlementStatus,
    this.cashoutAmount,
    this.odds,
    this.originalStake,
  });

  final String ticketId;
  final bool isSuccess;
  final String settlementStatus;
  final num? cashoutAmount;
  final num? odds;
  final num? originalStake;

  factory CashoutResponse.fromJson(Map<String, dynamic> json) =>
      CashoutResponse(
        ticketId: json['0']?.toString() ?? '',
        isSuccess: _parseBool(json['1']),
        settlementStatus: json['2']?.toString() ?? '',
        cashoutAmount: (json['3'] as num?) ?? 0,
        odds: (json['4'] as num?) ?? 0,
        originalStake: (json['6'] as num?) ?? 0,
      );

  static bool _parseBool(Object? value) {
    if (value is bool) return value;
    if (value is num) return value == 1;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    return false;
  }
}

class GetCashoutResponse {
  const GetCashoutResponse({
    required this.ticketId,
    required this.isCashoutAvailable,
    this.cashoutAmount,
    this.odds,
    this.feeOrAdjustment,
    this.originalStake,
  });

  final String ticketId;
  final bool isCashoutAvailable;
  final num? cashoutAmount;
  final num? odds;
  final num? feeOrAdjustment;
  final num? originalStake;

  factory GetCashoutResponse.fromJson(Map<String, dynamic> json) =>
      GetCashoutResponse(
        ticketId: json['0']?.toString() ?? '',
        isCashoutAvailable: json['1'] == true,
        cashoutAmount: json['3'] as num?,
        odds: json['4'] as num?,
        feeOrAdjustment: json['5'] as num?,
        originalStake: json['6'] as num?,
      );
}

DateTime? _localDateTime(Object? raw) {
  if (raw is! String || raw.isEmpty) return null;
  return DateTime.tryParse(raw)?.toLocal();
}

int _idOf(dynamic raw) {
  if (raw is num) return raw.toInt();
  return int.tryParse(raw?.toString() ?? '') ?? 0;
}

class ChildBet {
  const ChildBet({
    this.homeName,
    this.awayName,
    required this.id,
    required this.stake,
    required this.winning,
    required this.status,
    required this.displayOdds,
    required this.score,
    required this.cls,
    required this.oddsName,
    required this.ticketId,
    required this.marketName,
    required this.sportId,
    required this.marketId,
    required this.selectionId,
    required this.currency,
    required this.matchId,
    required this.homeId,
    required this.awayId,
    required this.leagueName,
    required this.oddsStyle,
    required this.startDate,
    this.settlementStatus,
    this.matchType,
    this.htScore,
    this.summaryEventId,
  });

  final String? homeName;
  final String? awayName;
  final String id;
  final num stake;
  final num winning;
  final BetSlipStatus status;
  final String displayOdds;
  final String score;
  final String cls;
  final String oddsName;
  final String ticketId;
  final String marketName;
  final int sportId;
  final int marketId;
  final String selectionId;
  final String currency;
  final String matchId;
  final int homeId;
  final int awayId;
  final String leagueName;
  final String oddsStyle;
  final DateTime startDate;
  final String? settlementStatus;
  final String? matchType;
  final String? htScore;

  final int? summaryEventId;

  factory ChildBet.fromJson(Map<String, dynamic> json) => ChildBet(
        homeName: json['homeName']?.toString(),
        awayName: json['awayName']?.toString(),
        id: json['id']?.toString() ?? '',
        stake: (json['stake'] as num?) ?? 0,
        winning: (json['winning'] as num?) ?? 0,
        status: BetSlipStatus.fromString(json['status'] as String?),
        displayOdds: json['displayOdds']?.toString() ?? '',
        score: json['score']?.toString() ?? '',
        cls: json['cls']?.toString() ?? '',
        oddsName: json['oddsName']?.toString() ?? '',
        ticketId: json['ticketId']?.toString() ?? '',
        marketName: json['marketName']?.toString() ?? '',
        sportId: (json['sportId'] as num?)?.toInt() ?? 1,
        marketId: (json['marketId'] as num?)?.toInt() ?? 0,
        selectionId: json['selectionId']?.toString() ?? '',
        currency: json['currency']?.toString() ?? '',
        matchId: json['matchId']?.toString() ?? '',
        homeId: _idOf(json['homeId']),
        awayId: _idOf(json['awayId']),
        leagueName: json['leagueName']?.toString() ?? '',
        oddsStyle: json['oddsStyle']?.toString() ?? 'ma',
        startDate: _localDateTime(json['startDate']) ?? DateTime.now(),
        settlementStatus: json['settlementStatus'] as String?,
        matchType: json['matchType'] as String?,
        htScore: json['htScore']?.toString(),
        summaryEventId: (json['summaryEventId'] as num?)?.toInt(),
      );

  SettlementStatusEnum get settlementStatusEnum =>
      SettlementStatusEnum.fromString(settlementStatus);

  MatchType get matchTypeEnum => MatchType.fromString(matchType);

  bool get isMatchLive =>
      startDate.isBefore(DateTime.now()) && status.isActiveStatus;
}

class BetSlip {
  const BetSlip({
    this.homeName,
    this.awayName,
    required this.id,
    required this.stake,
    required this.winning,
    required this.status,
    required this.displayOdds,
    required this.score,
    required this.cls,
    this.oddsName = '',
    required this.ticketId,
    required this.marketName,
    required this.sportId,
    required this.marketId,
    required this.selectionId,
    required this.currency,
    required this.matchType,
    required this.matchId,
    this.eventStatsId = 0,
    required this.homeId,
    required this.awayId,
    required this.leagueName,
    required this.oddsStyle,
    required this.startDate,
    required this.betTime,
    this.childBets = const [],
    this.settlementStatus,
    this.parlayResult,
    this.parlayOdds,
    this.cashOutAbleAmount,
    this.matchName,
    this.htScore,
    this.cashoutHistory = const [],
    this.summaryEventId,
  });

  final String? homeName;
  final String? awayName;
  final String id;
  final num stake;
  final num winning;
  final BetSlipStatus status;
  final String displayOdds;
  final String score;
  final String cls;

  final String oddsName;
  final String ticketId;
  final String marketName;
  final int sportId;
  final int marketId;
  final String selectionId;
  final String currency;
  final String matchType;
  final String matchId;

  final int eventStatsId;
  final int homeId;
  final int awayId;
  final String leagueName;
  final String oddsStyle;
  final DateTime startDate;
  final DateTime betTime;
  final List<ChildBet> childBets;
  final String? settlementStatus;

  final String? parlayResult;

  final num? parlayOdds;
  final num? cashOutAbleAmount;
  final String? matchName;
  final String? htScore;
  final List<CashoutInfo> cashoutHistory;

  final int? summaryEventId;

  factory BetSlip.fromJson(Map<String, dynamic> json) => BetSlip(
        homeName: json['homeName']?.toString(),
        awayName: json['awayName']?.toString(),
        id: json['id']?.toString() ?? '',
        stake: (json['stake'] as num?) ?? 0,
        winning: (json['winning'] as num?) ?? 0,
        status: BetSlipStatus.fromString(json['status'] as String?),
        displayOdds: json['displayOdds']?.toString() ?? '',
        score: json['score']?.toString() ?? '',
        cls: json['cls']?.toString() ?? '',
        oddsName: json['oddsName']?.toString() ?? '',
        ticketId: json['ticketId']?.toString() ?? '',
        marketName: json['marketName']?.toString() ?? '',
        sportId: (json['sportId'] as num?)?.toInt() ?? 1,
        marketId: (json['marketId'] as num?)?.toInt() ?? 0,
        selectionId: json['selectionId']?.toString() ?? '',
        currency: json['currency']?.toString() ?? '',
        matchType: json['matchType']?.toString() ?? '',
        matchId: json['matchId']?.toString() ?? '',
        eventStatsId: (json['eventStatsId'] as num?)?.toInt() ?? 0,
        homeId: _idOf(json['homeId']),
        awayId: _idOf(json['awayId']),
        leagueName: json['leagueName']?.toString() ?? '',
        oddsStyle: json['oddsStyle']?.toString() ?? 'ma',
        startDate: _localDateTime(json['startDate']) ?? DateTime.now(),
        betTime: _localDateTime(json['betTime']) ?? DateTime.now(),
        childBets: ((json['childBets'] as List?) ?? const [])
            .whereType<Map>()
            .map((c) => ChildBet.fromJson(Map<String, dynamic>.from(c)))
            .toList(),
        settlementStatus: json['settlementStatus'] as String?,
        parlayResult: json['parlayResult'] as String?,
        parlayOdds: json['parlayOdds'] as num?,
        cashOutAbleAmount: json['cashOutAbleAmount'] as num?,
        matchName: json['matchName'] as String?,
        htScore: json['htScore']?.toString(),
        cashoutHistory: ((json['cashoutHistory'] as List?) ?? const [])
            .whereType<Map>()
            .map((c) => CashoutInfo.fromJson(Map<String, dynamic>.from(c)))
            .toList(),
        summaryEventId: (json['summaryEventId'] as num?)?.toInt(),
      );

  BetSlip copyWith({
    String? homeName,
    String? awayName,
    String? id,
    num? stake,
    num? winning,
    BetSlipStatus? status,
    String? displayOdds,
    String? score,
    String? cls,
    String? oddsName,
    String? ticketId,
    String? marketName,
    int? sportId,
    int? marketId,
    String? selectionId,
    String? currency,
    String? matchType,
    String? matchId,
    int? eventStatsId,
    int? homeId,
    int? awayId,
    String? leagueName,
    String? oddsStyle,
    DateTime? startDate,
    DateTime? betTime,
    List<ChildBet>? childBets,
    String? settlementStatus,
    String? parlayResult,
    num? parlayOdds,
    num? cashOutAbleAmount,
    String? matchName,
    String? htScore,
    List<CashoutInfo>? cashoutHistory,
    int? summaryEventId,
  }) =>
      BetSlip(
        homeName: homeName ?? this.homeName,
        awayName: awayName ?? this.awayName,
        id: id ?? this.id,
        stake: stake ?? this.stake,
        winning: winning ?? this.winning,
        status: status ?? this.status,
        displayOdds: displayOdds ?? this.displayOdds,
        score: score ?? this.score,
        cls: cls ?? this.cls,
        oddsName: oddsName ?? this.oddsName,
        ticketId: ticketId ?? this.ticketId,
        marketName: marketName ?? this.marketName,
        sportId: sportId ?? this.sportId,
        marketId: marketId ?? this.marketId,
        selectionId: selectionId ?? this.selectionId,
        currency: currency ?? this.currency,
        matchType: matchType ?? this.matchType,
        matchId: matchId ?? this.matchId,
        eventStatsId: eventStatsId ?? this.eventStatsId,
        homeId: homeId ?? this.homeId,
        awayId: awayId ?? this.awayId,
        leagueName: leagueName ?? this.leagueName,
        oddsStyle: oddsStyle ?? this.oddsStyle,
        startDate: startDate ?? this.startDate,
        betTime: betTime ?? this.betTime,
        childBets: childBets ?? this.childBets,
        settlementStatus: settlementStatus ?? this.settlementStatus,
        parlayResult: parlayResult ?? this.parlayResult,
        parlayOdds: parlayOdds ?? this.parlayOdds,
        cashOutAbleAmount: cashOutAbleAmount ?? this.cashOutAbleAmount,
        matchName: matchName ?? this.matchName,
        htScore: htScore ?? this.htScore,
        cashoutHistory: cashoutHistory ?? this.cashoutHistory,
        summaryEventId: summaryEventId ?? this.summaryEventId,
      );
}

extension BetSlipX on BetSlip {
  SettlementStatusEnum get settlementStatusEnum {
    if (status == BetSlipStatus.declined) return SettlementStatusEnum.declined;
    if (status == BetSlipStatus.cashout) return SettlementStatusEnum.cashout;
    if (isComboBet) return _comboSettlementStatusEnum;
    return SettlementStatusEnum.fromString(settlementStatus);
  }

  SettlementStatusEnum get _comboSettlementStatusEnum {
    if (SettlementStatusEnum.fromString(parlayResult) ==
        SettlementStatusEnum.cashout) {
      return SettlementStatusEnum.cashout;
    }
    if (status.isActiveStatus) return SettlementStatusEnum.running;
    if (status.isPendingStatus) return SettlementStatusEnum.pending;
    if (childBets.any((c) => c.status.isActiveStatus)) {
      return SettlementStatusEnum.running;
    }
    final mainLost = SettlementStatusEnum.fromString(settlementStatus) ==
        SettlementStatusEnum.lost;
    final anyChildLost = childBets.any(
      (c) => c.settlementStatusEnum == SettlementStatusEnum.lost,
    );
    if (mainLost || anyChildLost) return SettlementStatusEnum.lost;
    return SettlementStatusEnum.won;
  }

  MatchType get matchTypeEnum => MatchType.fromString(matchType);

  bool get isComboBet => childBets.isNotEmpty;

  num get totalStake =>
      isComboBet
          ? childBets.fold<num>(stake, (sum, child) => sum + child.stake)
          : stake;

  num get totalWinning => winning;

  double get _comboCombinedOdds {
    double ratio(num w, num s) => s > 0 ? w / s : 0.0;
    var maxRatio = ratio(winning, stake);
    for (final child in childBets) {
      final r = ratio(child.winning, child.stake);
      if (r > maxRatio) maxRatio = r;
    }
    return maxRatio;
  }

  double get comboOddsValue {
    final served = parlayOdds?.toDouble() ?? 0;
    if (served > 0) return served;
    return _comboCombinedOdds;
  }

  BetSlip resolveComboWinning() {
    if (!isComboBet) return this;
    final combinedOdds = _comboCombinedOdds;
    if (combinedOdds <= 0) return this;
    return copyWith(winning: totalStake * combinedOdds);
  }

  bool get isActive => status.isActiveStatus;

  bool get isPending => status.isPendingStatus;

  bool get isSettled => switch (status) {
        BetSlipStatus.cashout ||
        BetSlipStatus.settled ||
        BetSlipStatus.declined => true,
        BetSlipStatus.active ||
        BetSlipStatus.running ||
        BetSlipStatus.pending ||
        BetSlipStatus.unknown => false,
      };

  bool get hasMatchStarted => startDate.isBefore(DateTime.now());

  bool get isMatchLive {
    final now = DateTime.now();
    final hasStarted = startDate.isBefore(now);
    final isLiveEligible = status.isActiveStatus || status.isPendingStatus;
    return hasStarted && isLiveEligible;
  }

  bool get isCashoutAvailable {
    if (isComboBet) return false;
    if (hasMatchStarted) return false;
    return (cashOutAbleAmount ?? 0) > 0;
  }

  num get potentialProfit => winning - stake;

  BetSlip applyCashout(CashoutResponse cashoutResponse) => copyWith(
        status: BetSlipStatus.cashout,
        settlementStatus: cashoutResponse.settlementStatus,
        winning: cashoutResponse.cashoutAmount ?? winning,
        cashOutAbleAmount: 0,
      );
}

class BetSlipParser {
  BetSlipParser._();

  static BetSlip parse(Map<String, dynamic> json) {
    final ticketId = json['0']?.toString() ?? '';
    final betTimeStr = json['1'] as String? ?? DateTime.now().toIso8601String();
    final startDateStr = json['18'] as String? ?? betTimeStr;

    final childBets = _parseChildBets(json);
    final isCombo = childBets.isNotEmpty;

    num? cashOutAmount;
    num? parlayStake;
    num? parlayRefund;
    num? parlayOdds;
    String? parlayResult;
    if (json['20'] is Map<String, dynamic>) {
      final summary = json['20'] as Map<String, dynamic>;
      cashOutAmount = (summary['0'] as num?)?.toDouble();
      parlayOdds = (summary['1'] as num?)?.toDouble();
      parlayStake = (summary['3'] as num?)?.toDouble();
      parlayRefund = (summary['4'] as num?)?.toDouble();
      parlayResult = summary['5'] as String?;
    }

    final mainWinning = (json['10'] as num?)?.toDouble() ?? 0.0;
    final mainStake = (json['9'] as num?)?.toDouble() ?? 0.0;
    final resolvedWinning = isCombo ? (parlayRefund ?? mainWinning) : mainWinning;
    final resolvedStake = isCombo ? (parlayStake ?? mainStake) : mainStake;

    final cashoutHistory = _parseCashoutHistory(json['24'] as List? ?? []);

    return BetSlip(
      homeName: json['33'] as String? ?? '',
      awayName: json['34'] as String? ?? '',
      id: ticketId,
      stake: resolvedStake,
      winning: resolvedWinning,
      status: BetSlipStatus.fromString(json['12'] as String?),
      settlementStatus: json['11'] as String?,
      parlayResult: parlayResult,
      parlayOdds: parlayOdds,
      displayOdds: json['8']?.toString() ?? '0.00',
      score: _formatScore(json['14'] as String?),
      htScore: _formatScore(json['16'] as String?),
      cls: json['7']?.toString() ?? '',
      oddsName: json['5'] as String? ?? '',
      ticketId: ticketId,
      marketName: json['6'] as String? ?? '',
      sportId: (json['2'] as num?)?.toInt() ?? 1,
      marketId: (json['15'] as num?)?.toInt() ?? 0,
      selectionId: json['27']?.toString() ?? '',
      currency: json['19'] as String? ?? BettingHistoryConstants.defaultCurrency,
      matchType: json['13'] as String? ?? BettingHistoryConstants.defaultMatchType,
      matchId: json['26']?.toString() ?? '',
      homeId: (json['26'] as num?)?.toInt() ?? 0,
      awayId: (json['27'] as num?)?.toInt() ?? 0,
      leagueName: json['3'] as String? ?? '',
      oddsStyle: json['25'] as String? ?? 'ma',
      startDate: _localDateTime(startDateStr) ?? DateTime.now(),
      betTime: _localDateTime(betTimeStr) ?? DateTime.now(),
      childBets: childBets,
      cashOutAbleAmount: cashOutAmount?.toInt(),
      matchName: json['4'] as String?,
      cashoutHistory: cashoutHistory,
      summaryEventId: (json['36'] as num?)?.toInt(),
    );
  }

  static List<ChildBet> _parseChildBets(Map<String, dynamic> json) {
    final childBetsData = json['21'] as List<dynamic>? ?? [];
    return childBetsData
        .map((child) {
          if (child is! Map<String, dynamic>) return null;
          final id = child['0']?.toString() ?? '';
          final startDateStr = child['18'] as String? ??
              child['1'] as String? ??
              DateTime.now().toIso8601String();
          return ChildBet(
            homeName: child['33'] as String? ?? '',
            awayName: child['34'] as String? ?? '',
            id: id,
            stake: (child['9'] as num?)?.toDouble() ?? 0.0,
            winning: (child['10'] as num?)?.toDouble() ?? 0.0,
            status: BetSlipStatus.fromString(child['12'] as String?),
            displayOdds: child['8']?.toString() ?? '0.00',
            score: _formatScore(child['14'] as String?),
            htScore: _formatScore(child['16'] as String?),
            cls: child['7']?.toString() ?? '',
            oddsName: child['5'] as String? ?? '',
            ticketId: id,
            marketName: child['6'] as String? ?? '',
            sportId: (child['2'] as num?)?.toInt() ?? 1,
            marketId: (child['15'] as num?)?.toInt() ?? 0,
            selectionId: child['27']?.toString() ?? '',
            currency: child['19'] as String? ??
                BettingHistoryConstants.defaultCurrency,
            matchId: child['26']?.toString() ?? '',
            homeId: (child['26'] as num?)?.toInt() ?? 0,
            awayId: (child['27'] as num?)?.toInt() ?? 0,
            leagueName: child['3'] as String? ?? '',
            oddsStyle: child['25'] as String? ?? 'ma',
            startDate: _localDateTime(startDateStr) ?? DateTime.now(),
            settlementStatus: child['11'] as String? ??
                BettingHistoryConstants.apiStatusSettled,
            summaryEventId: (child['36'] as num?)?.toInt(),
          );
        })
        .whereType<ChildBet>()
        .toList();
  }

  static List<CashoutInfo> _parseCashoutHistory(List<dynamic> data) => data
      .map((item) {
        if (item is! Map<String, dynamic>) return null;
        return CashoutInfo.fromJson(item);
      })
      .whereType<CashoutInfo>()
      .toList();

  static String _formatScore(String? scoreStr) {
    if (scoreStr == null || scoreStr.isEmpty) {
      return BettingHistoryConstants.defaultScore;
    }
    if (scoreStr.contains(BettingHistoryConstants.scoreSeparatorApi)) {
      final parts = scoreStr.split(BettingHistoryConstants.scoreSeparatorApi);
      return '${BettingHistoryConstants.scoreBracketStart}${parts[0]}'
          '${BettingHistoryConstants.scoreDash}${parts[1]}'
          '${BettingHistoryConstants.scoreBracketEnd}';
    }
    return scoreStr;
  }
}

class SettlementStatusParser {
  SettlementStatusParser._();

  static SettlementStatusEnum parseStatus(BetSlip bet) {
    if (bet.status == BetSlipStatus.cashout) {
      return SettlementStatusEnum.cashout;
    }

    final ticketStatus = bet.status;
    final settlementStatus = bet.settlementStatus?.toLowerCase();

    if (ticketStatus == BetSlipStatus.unknown && settlementStatus != null) {
      return _parseFromSettlementStatus(settlementStatus, bet);
    }

    return _parseFromStatus(ticketStatus, settlementStatus, bet);
  }

  static SettlementStatusEnum _parseFromSettlementStatus(
    String settlementStatus,
    BetSlip bet,
  ) {
    switch (settlementStatus) {
      case 'active':
        return SettlementStatusEnum.running;
      case 'settled':
        if (bet.winning > 0) return SettlementStatusEnum.won;
        if (bet.stake > 0 && bet.winning == 0) return SettlementStatusEnum.lost;
        return SettlementStatusEnum.draw;
      case 'cashout':
        return SettlementStatusEnum.cashout;
      case 'pending':
        return SettlementStatusEnum.pending;
      default:
        return SettlementStatusEnum.pending;
    }
  }

  static SettlementStatusEnum _parseFromStatus(
    BetSlipStatus ticketStatus,
    String? settlementStatus,
    BetSlip bet,
  ) {
    switch (ticketStatus) {
      case BetSlipStatus.cashout:
        return SettlementStatusEnum.cashout;
      case BetSlipStatus.pending:
        return SettlementStatusEnum.pending;
      case BetSlipStatus.active:
      case BetSlipStatus.running:
        return SettlementStatusEnum.running;
      case BetSlipStatus.declined:
        return SettlementStatusEnum.declined;
      case BetSlipStatus.settled:
        if (settlementStatus != null) {
          return _parseFromSettlementStatus(settlementStatus, bet);
        }
        if (bet.winning > 0) return SettlementStatusEnum.won;
        if (bet.stake > 0 && bet.winning == 0) return SettlementStatusEnum.lost;
        return SettlementStatusEnum.draw;
      case BetSlipStatus.unknown:
        if (settlementStatus != null) {
          return _parseFromSettlementStatus(settlementStatus, bet);
        }
        return SettlementStatusEnum.pending;
    }
  }
}
