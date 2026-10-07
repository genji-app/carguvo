abstract class MessageType {
  static const String leagueInsert = 'league_ins';
  static const String eventInsert = 'event_ins';
  static const String eventUpdate = 'event_up';
  static const String eventRemove = 'event_rm';
  static const String marketUpdate = 'market_up';
  static const String oddsUpdate = 'odds_up';
  static const String oddsInsert = 'odds_ins';
  static const String oddsRemove = 'odds_rmv';
  static const String scoreUpdate = 'score_up';
  static const String balanceUpdate = 'balance_up';
  static const String userBalance = 'user_bal';
}

abstract class MessagePriority {
  static const Map<String, int> priorities = {
    MessageType.leagueInsert: 1,
    MessageType.eventInsert: 2,
    MessageType.eventUpdate: 3,
    MessageType.scoreUpdate: 3,
    MessageType.marketUpdate: 4,
    MessageType.oddsUpdate: 5,
    MessageType.oddsInsert: 5,
    MessageType.oddsRemove: 5,
    MessageType.eventRemove: 6,
    MessageType.balanceUpdate: 7,
    MessageType.userBalance: 7,
  };

  static int getPriority(String type) => priorities[type] ?? 99;
}

abstract class TimeRange {
  static const String live = 'LIVE';
  static const String early = 'EARLY';
  static const String today = 'TODAY';

  static const String todayEarly = 'TODAY_EARLY';
}

abstract class DefaultConfig {
  static const int sampleIntervalMs = 200;

  static const int maxParsePerSample = 500;

  static const int maxPendingQueueSize = 5000;

  static const int pendingExpirationSec = 10;

  static const int metricsIntervalSec = 30;

  static const int cleanupIntervalSec = 30;

  static const int reconnectDelaySec = 3;

  static const int maxReconnectAttempts = 5;

  static const int pingIntervalSec = 30;
}

abstract class JsonField {
  static const String type = '"t":"';
  static const String sportId = '"s":';
  static const String data = '"d":';

  static const String leagueId = '"leagueId":';
  static const String eventId = '"eventId":';
  static const String marketId = '"marketId":';
  static const String domainEventId = '"domainEventId":';
  static const String domainMarketId = '"domainMarketId":';

  static const String timeRange = '"timeRange":"';
  static const String kafkaOddsList = '"kafkaOddsList":[';
  static const String strOfferId = '"strOfferId":"';
  static const String offerId = '"offerId":';
}
