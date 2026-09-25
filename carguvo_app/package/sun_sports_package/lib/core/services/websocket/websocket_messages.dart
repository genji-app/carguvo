
import 'dart:convert';
import 'package:sun_sports/shared/domain/enums/websocket_enums.dart';

import 'package:sport_socket/src/data/models/market_data.dart'
    show MarketStatus;
import 'package:sport_socket/src/data/models/event_data.dart' show EventStatus;

export 'package:sun_sports/shared/domain/enums/websocket_enums.dart'
    show WsMessageType;
export 'package:sport_socket/src/data/models/market_data.dart'
    show MarketStatus;
export 'package:sport_socket/src/data/models/event_data.dart' show EventStatus;

class WsMessage {
  final WsMessageType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  const WsMessage({required this.type, required this.data, DateTime? timestamp})
    : timestamp = timestamp ?? const _DefaultDateTime();

  factory WsMessage.parse(String raw) {
    try {
      if (raw.startsWith('{')) {
        return _parseJsonMessage(raw);
      }

      final parts = raw.split(':');
      if (parts.isEmpty) {
        return WsMessage(type: WsMessageType.unknown, data: {'raw': raw});
      }

      final prefix = parts[0].toUpperCase();

      switch (prefix) {
        case 'ODDS':
          return _parseOddsMessage(parts);
        case 'BAL':
        case 'USERBAL':
          return _parseBalanceMessage(parts);
        case 'STATUS':
          return _parseEventStatusMessage(parts);
        case 'SCORE':
          return _parseScoreMessage(parts);
        case 'MARKET':
          return _parseMarketStatusMessage(parts);
        case 'PONG':
          return WsMessage(type: WsMessageType.heartbeat, data: {});
        case 'CONNECTED':
          return WsMessage(
            type: WsMessageType.connection,
            data: {'connected': true},
          );
        default:
          return WsMessage(type: WsMessageType.unknown, data: {'raw': raw});
      }
    } catch (e) {
      return WsMessage(
        type: WsMessageType.unknown,
        data: {'raw': raw, 'error': e.toString()},
      );
    }
  }

  static WsMessage _parseJsonMessage(String json) {
    final data = _tryParseJson(json);
    if (data == null) {
      return WsMessage(type: WsMessageType.unknown, data: {'raw': json});
    }

    final messageType = data['t'] as String?;
    if (messageType != null) {
      switch (messageType) {
        case 'odds_up':
          return WsMessage(type: WsMessageType.oddsUpdate, data: data);
        case 'odds_ins':
          return WsMessage(type: WsMessageType.oddsInsert, data: data);
        case 'odds_rmv':
          return WsMessage(type: WsMessageType.oddsRemove, data: data);

        case 'market_up':
          return WsMessage(type: WsMessageType.marketStatus, data: data);

        case 'event_up':
          return WsMessage(type: WsMessageType.eventStatus, data: data);
        case 'event_ins':
          return WsMessage(type: WsMessageType.eventInsert, data: data);
        case 'event_rm':
          return WsMessage(type: WsMessageType.eventRemove, data: data);

        case 'league_ins':
          return WsMessage(type: WsMessageType.leagueInsert, data: data);

        case 'balance_up':
        case 'user_bal':
          return WsMessage(type: WsMessageType.balanceUpdate, data: data);

        case 'score_up':
          return WsMessage(type: WsMessageType.scoreUpdate, data: data);
      }
    }

    if (data.containsKey('odds') || data.containsKey('displayOdds')) {
      return WsMessage(type: WsMessageType.oddsUpdate, data: data);
    }
    if (data.containsKey('balance')) {
      return WsMessage(type: WsMessageType.balanceUpdate, data: data);
    }
    if (data.containsKey('score') || data.containsKey('homeScore')) {
      return WsMessage(type: WsMessageType.scoreUpdate, data: data);
    }
    if (data.containsKey('status')) {
      return WsMessage(type: WsMessageType.eventStatus, data: data);
    }

    return WsMessage(type: WsMessageType.unknown, data: data);
  }

  static WsMessage _parseOddsMessage(List<String> parts) {
    return WsMessage(
      type: WsMessageType.oddsUpdate,
      data: {
        'eventId': parts.length > 1 ? int.tryParse(parts[1]) : null,
        'marketId': parts.length > 2 ? parts[2] : null,
        'selectionId': parts.length > 3 ? parts[3] : null,
        'odds': parts.length > 4 ? parts[4] : null,
      },
    );
  }

  static WsMessage _parseBalanceMessage(List<String> parts) {
    final balanceStr = parts.length > 1 ? parts.last : '0';
    final balance = double.tryParse(balanceStr.replaceAll('.', '')) ?? 0;

    return WsMessage(
      type: WsMessageType.balanceUpdate,
      data: {
        'balance': balance / 1000.0,
        'raw': balanceStr,
      },
    );
  }

  static WsMessage _parseEventStatusMessage(List<String> parts) {
    return WsMessage(
      type: WsMessageType.eventStatus,
      data: {
        'eventId': parts.length > 1 ? int.tryParse(parts[1]) : null,
        'status': parts.length > 2 ? parts[2] : null,
      },
    );
  }

  static WsMessage _parseScoreMessage(List<String> parts) {
    return WsMessage(
      type: WsMessageType.scoreUpdate,
      data: {
        'eventId': parts.length > 1 ? int.tryParse(parts[1]) : null,
        'home': parts.length > 2 ? int.tryParse(parts[2]) : 0,
        'away': parts.length > 3 ? int.tryParse(parts[3]) : 0,
      },
    );
  }

  static WsMessage _parseMarketStatusMessage(List<String> parts) {
    return WsMessage(
      type: WsMessageType.marketStatus,
      data: {
        'eventId': parts.length > 1 ? int.tryParse(parts[1]) : null,
        'marketId': parts.length > 2 ? parts[2] : null,
        'suspended': parts.length > 3 ? parts[3] == 'true' : false,
      },
    );
  }

  static Map<String, dynamic>? _tryParseJson(String json) {
    try {
      final decoded = jsonDecode(json);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

class _DefaultDateTime implements DateTime {
  const _DefaultDateTime();

  @override
  dynamic noSuchMethod(Invocation invocation) => DateTime.now();
}

class OddsUpdateData {
  final int eventId;
  final String marketId;
  final String selectionId;

  final OddsStyleValues oddsValues;

  final String odds;
  final double? trueOdds;

  const OddsUpdateData({
    required this.eventId,
    required this.marketId,
    required this.selectionId,
    required this.odds,
    this.trueOdds,
    this.oddsValues = const OddsStyleValues(),
  });

  factory OddsUpdateData.fromMessage(WsMessage message) {
    final data = message.data;
    return OddsUpdateData(
      eventId: data['eventId'] as int? ?? 0,
      marketId: data['marketId'] as String? ?? '',
      selectionId: data['selectionId'] as String? ?? '',
      odds: data['odds'] as String? ?? '0',
      trueOdds: data['trueOdds'] as double?,
    );
  }
}

class OddsStyleValues {
  final double malay;
  final double indo;
  final double decimal;
  final double hk;

  const OddsStyleValues({
    this.malay = 0,
    this.indo = 0,
    this.decimal = 0,
    this.hk = 0,
  });

  factory OddsStyleValues.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const OddsStyleValues();

    final malay = _parseDouble(json['malay']);
    final indo = _parseDouble(json['indo']);
    final decimal = _parseDouble(json['decimal']);
    final hk = _parseDouble(json['hk']);

    return OddsStyleValues(malay: malay, indo: indo, decimal: decimal, hk: hk);
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  double getByStyleIndex(int styleIndex) {
    switch (styleIndex) {
      case 0:
        return malay;
      case 1:
        return indo;
      case 2:
        return decimal;
      case 3:
        return hk;
      default:
        return decimal;
    }
  }

  bool get isValid => decimal > 0;

  @override
  String toString() =>
      'OddsStyleValues(malay: $malay, indo: $indo, decimal: $decimal, hk: $hk)';
}

class OddsFullListData {
  final int eventId;
  final int marketId;
  final Set<String> validPoints;

  const OddsFullListData({
    required this.eventId,
    required this.marketId,
    required this.validPoints,
  });

  String get marketKey => '${eventId}_$marketId';

  @override
  String toString() =>
      'OddsFullListData(eventId: $eventId, marketId: $marketId, validPoints: $validPoints)';
}

class OddsRemoveData {
  final int eventId;
  final int leagueId;
  final String marketId;
  final String points;
  final String? selectionHomeId;
  final String? selectionAwayId;
  final String? selectionDrawId;

  const OddsRemoveData({
    required this.eventId,
    required this.leagueId,
    required this.marketId,
    required this.points,
    this.selectionHomeId,
    this.selectionAwayId,
    this.selectionDrawId,
  });

  factory OddsRemoveData.fromKafkaItem(Map<String, dynamic> item) {
    final eventId = item['eventId'] as int? ?? 0;
    final leagueId = item['leagueId'] as int? ?? 0;
    final marketIdInt = item['domainMarketId'] ?? item['marketId'];
    final marketId = marketIdInt?.toString() ?? '';
    final odds = item['odds'] as Map<String, dynamic>?;

    return OddsRemoveData(
      eventId: eventId,
      leagueId: leagueId,
      marketId: marketId,
      points: odds?['points'] as String? ?? '',
      selectionHomeId: odds?['selectionHomeId'] as String?,
      selectionAwayId: odds?['selectionAwayId'] as String?,
      selectionDrawId: odds?['selectionDrawId'] as String?,
    );
  }

  @override
  String toString() =>
      'OddsRemoveData(eventId: $eventId, marketId: $marketId, points: $points)';
}

class BalanceUpdateData {
  final double balance;
  final String raw;

  const BalanceUpdateData({required this.balance, required this.raw});

  factory BalanceUpdateData.fromMessage(WsMessage message) {
    final data = message.data;
    return BalanceUpdateData(
      balance: data['balance'] as double? ?? 0.0,
      raw: data['raw'] as String? ?? '0',
    );
  }

  double get balanceK => balance;

  double get balanceVND => balance * 1000;
}

class ScoreUpdateData {
  final int eventId;
  final int home;
  final int away;

  final int? gameTime;

  final int? gamePart;

  final int? yellowCardsHome;

  final int? yellowCardsAway;

  final int? redCardsHome;

  final int? redCardsAway;

  const ScoreUpdateData({
    required this.eventId,
    required this.home,
    required this.away,
    this.gameTime,
    this.gamePart,
    this.yellowCardsHome,
    this.yellowCardsAway,
    this.redCardsHome,
    this.redCardsAway,
  });

  factory ScoreUpdateData.fromMessage(WsMessage message) {
    final data = message.data;
    final d = data['d'] as Map<String, dynamic>? ?? data;
    return ScoreUpdateData(
      eventId: d['eventId'] as int? ?? data['eventId'] as int? ?? 0,
      home:
          d['homeScore'] as int? ??
          d['home'] as int? ??
          data['home'] as int? ??
          0,
      away:
          d['awayScore'] as int? ??
          d['away'] as int? ??
          data['away'] as int? ??
          0,
      gameTime: _parseGameTime(d['gameTime']),
      gamePart: _parseGamePart(d['gamePart']),
      yellowCardsHome: d['yellowCardsHome'] as int?,
      yellowCardsAway: d['yellowCardsAway'] as int?,
      redCardsHome: d['redCardsHome'] as int?,
      redCardsAway: d['redCardsAway'] as int?,
    );
  }

  static int? _parseGameTime(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static int? _parseGamePart(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  String get scoreString => '$home - $away';
}

class EventInsertData {
  final int eventId;
  final int leagueId;
  final int sportId;
  final String homeName;
  final String awayName;
  final int homeScore;
  final int awayScore;
  final bool isLive;
  final int startTime;
  final String? eventStatus;
  final int gameTime;
  final int gamePart;
  final String? homeLogo;
  final String? awayLogo;

  const EventInsertData({
    required this.eventId,
    required this.leagueId,
    required this.sportId,
    required this.homeName,
    required this.awayName,
    this.homeScore = 0,
    this.awayScore = 0,
    this.isLive = false,
    this.startTime = 0,
    this.eventStatus,
    this.gameTime = 0,
    this.gamePart = 0,
    this.homeLogo,
    this.awayLogo,
  });

  factory EventInsertData.fromMessage(WsMessage message) {
    final data = message.data;
    final d = data['d'] as Map<String, dynamic>? ?? data;

    return EventInsertData(
      eventId: d['eventId'] as int? ?? d['ei'] as int? ?? 0,
      leagueId: d['leagueId'] as int? ?? d['li'] as int? ?? 0,
      sportId: data['s'] as int? ?? d['sportId'] as int? ?? 1,
      homeName: d['homeTeam'] as String? ?? d['hn'] as String? ?? '',
      awayName: d['awayTeam'] as String? ?? d['an'] as String? ?? '',
      homeScore: d['homeScore'] as int? ?? d['hs'] as int? ?? 0,
      awayScore: d['awayScore'] as int? ?? d['as'] as int? ?? 0,
      isLive: d['isLive'] as bool? ?? d['l'] as bool? ?? false,
      startTime: d['startTime'] as int? ?? d['st'] as int? ?? 0,
      eventStatus: d['status'] as String? ?? d['es'] as String?,
      gameTime: d['gameTime'] as int? ?? d['gt'] as int? ?? 0,
      gamePart: d['gamePart'] as int? ?? d['gp'] as int? ?? 0,
      homeLogo: d['homeLogo'] as String? ?? d['hf'] as String?,
      awayLogo: d['awayLogo'] as String? ?? d['af'] as String?,
    );
  }

  @override
  String toString() =>
      'EventInsertData(eventId: $eventId, leagueId: $leagueId, $homeName vs $awayName)';
}

class EventRemoveData {
  final int eventId;
  final int leagueId;

  const EventRemoveData({required this.eventId, required this.leagueId});

  factory EventRemoveData.fromMessage(WsMessage message) {
    final data = message.data;
    final d = data['d'] as Map<String, dynamic>? ?? data;

    return EventRemoveData(
      eventId: d['eventId'] as int? ?? d['ei'] as int? ?? 0,
      leagueId: d['leagueId'] as int? ?? d['li'] as int? ?? 0,
    );
  }

  @override
  String toString() =>
      'EventRemoveData(eventId: $eventId, leagueId: $leagueId)';
}

class LeagueInsertData {
  final int leagueId;
  final String leagueName;
  final int sportId;
  final String? logoUrl;

  const LeagueInsertData({
    required this.leagueId,
    required this.leagueName,
    required this.sportId,
    this.logoUrl,
  });

  factory LeagueInsertData.fromMessage(WsMessage message) {
    final data = message.data;
    final d = data['d'] as Map<String, dynamic>? ?? data;

    return LeagueInsertData(
      leagueId: d['leagueId'] as int? ?? d['li'] as int? ?? 0,
      leagueName: d['leagueName'] as String? ?? d['ln'] as String? ?? '',
      sportId: data['s'] as int? ?? d['sportId'] as int? ?? 1,
      logoUrl: d['logoUrl'] as String? ?? d['lg'] as String?,
    );
  }

  @override
  String toString() =>
      'LeagueInsertData(leagueId: $leagueId, name: $leagueName)';
}

class MarketStatusData {
  final int eventId;
  final int leagueId;
  final int marketId;

  final MarketStatus status;

  const MarketStatusData({
    required this.eventId,
    required this.leagueId,
    required this.marketId,
    this.status = MarketStatus.active,
  });

  factory MarketStatusData.fromMessage(WsMessage message) {
    final data = message.data;
    final d = data['d'] as Map<String, dynamic>? ?? data;

    final status = MarketStatus.fromCode(d['status']);

    return MarketStatusData(
      eventId:
          d['domainEventId'] as int? ??
          d['eventId'] as int? ??
          d['ei'] as int? ??
          0,
      leagueId:
          d['domainLeagueId'] as int? ??
          d['leagueId'] as int? ??
          d['li'] as int? ??
          0,
      marketId:
          d['domainMarketId'] as int? ??
          d['marketId'] as int? ??
          d['mi'] as int? ??
          0,
      status: status,
    );
  }

  int get statusCode => status.code;

  bool get isSuspended => status.isSuspended;

  bool get isActive => status == MarketStatus.active;

  bool get isHidden => !status.isVisible;

  bool get canBet => status.canBet;

  @override
  String toString() =>
      'MarketStatusData(eventId: $eventId, marketId: $marketId, status: ${status.name})';
}

class EventStatusData {
  final int eventId;
  final int leagueId;
  final int sportId;

  final EventStatus status;

  final bool isLive;
  final bool isGoingLive;
  final int? homeScore;
  final int? awayScore;
  final int? gameTime;
  final int? gamePart;
  final int? stoppageTime;
  final int? redCardsHome;
  final int? redCardsAway;
  final int? yellowCardsHome;
  final int? yellowCardsAway;
  final int? cornersHome;
  final int? cornersAway;

  const EventStatusData({
    required this.eventId,
    required this.leagueId,
    required this.sportId,
    this.status = EventStatus.active,
    this.isLive = false,
    this.isGoingLive = false,
    this.homeScore,
    this.awayScore,
    this.gameTime,
    this.gamePart,
    this.stoppageTime,
    this.redCardsHome,
    this.redCardsAway,
    this.yellowCardsHome,
    this.yellowCardsAway,
    this.cornersHome,
    this.cornersAway,
  });

  factory EventStatusData.fromMessage(WsMessage message) {
    final data = message.data;
    final d = data['d'] as Map<String, dynamic>? ?? data;

    return EventStatusData(
      eventId: d['eventId'] as int? ?? d['ei'] as int? ?? 0,
      leagueId: d['leagueId'] as int? ?? d['li'] as int? ?? 0,
      sportId: data['s'] as int? ?? d['sportId'] as int? ?? 1,
      status: EventStatus.fromString(d['status'] as String?),
      isLive: d['isLive'] as bool? ?? d['l'] as bool? ?? false,
      isGoingLive: d['isGoingLive'] as bool? ?? d['gl'] as bool? ?? false,
      homeScore: d['homeScore'] as int? ?? d['hs'] as int?,
      awayScore: d['awayScore'] as int? ?? d['as'] as int?,
      gameTime: d['gameTime'] as int? ?? d['gt'] as int?,
      gamePart: d['gamePart'] as int? ?? d['gp'] as int?,
      stoppageTime: d['stoppageTime'] as int? ?? d['stm'] as int?,
      redCardsHome: d['redCardsHome'] as int? ?? d['rch'] as int?,
      redCardsAway: d['redCardsAway'] as int? ?? d['rca'] as int?,
      yellowCardsHome: d['yellowCardsHome'] as int? ?? d['ych'] as int?,
      yellowCardsAway: d['yellowCardsAway'] as int? ?? d['yca'] as int?,
      cornersHome: d['cornersHome'] as int? ?? d['hc'] as int?,
      cornersAway: d['cornersAway'] as int? ?? d['ac'] as int?,
    );
  }

  bool get isLocked => status.isLocked;

  bool get isSuspended => status.isSuspendedStatus;

  bool get isHidden => status.isHiddenStatus;

  bool get canBet => status.canBet;

  @override
  String toString() =>
      'EventStatusData(eventId: $eventId, status: ${status.name}, live: $isLive, score: $homeScore-$awayScore)';
}
