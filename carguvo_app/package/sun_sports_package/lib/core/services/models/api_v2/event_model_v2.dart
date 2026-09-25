import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';

import 'market_model_v2.dart';
import 'score_model_v2.dart';

part 'event_model_v2.freezed.dart';

@freezed
sealed class EventModelV2 with _$EventModelV2 {
  const factory EventModelV2({
    @Default([]) List<MarketModelV2> markets,

    @Default(0) int sportId,

    @Default(0) int leagueId,

    @Default(0) int eventId,

    @Default('') String startDate,

    @Default(0) int startTime,

    @Default(false) bool isSuspended,

    @Default(false) bool isParlay,

    @Default(false) bool isCashOut,

    @Default(0) int type,

    @Default(0) int eventStatsId,

    @Default(0) int homeId,

    @Default(0) int awayId,

    @Default('') String homeName,

    @Default('') String awayName,

    @Default('') String homeLogo,

    @Default('') String awayLogo,

    @Default(0) int marketCount,

    @Default(false) bool isGoingLive,

    @Default(false) bool isLive,

    @Default(false) bool isLiveStream,

    @Default(0) int gamePart,

    @Default(0) int gameTime,

    @Default(0) int stoppageTime,

    ScoreModelV2? score,

    @Default(false) bool isFavorited,
  }) = _EventModelV2;

  const EventModelV2._();

  factory EventModelV2.fromJson(Map<String, dynamic> json) {
    final markets = <MarketModelV2>[];
    final rawMarkets = json['1'];
    if (rawMarkets is List) {
      for (final item in rawMarkets) {
        if (item is Map) {
          markets.add(MarketModelV2.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    final rawChildren = json['0'];
    if (rawChildren is List) {
      for (final item in rawChildren) {
        if (item is! Map) continue;
        final childJson = Map<String, dynamic>.from(item);
        if (childJson['34'] == null) continue;
        final child = EventModelV2.fromJson(childJson);
        final childSuspended = childJson['7'] == true;
        markets.addAll(
          childSuspended
              ? child.markets.map((m) => m.copyWith(isSuspended: true))
              : child.markets,
        );
      }
    }

    ScoreModelV2? score;
    final rawScore = json['33'];
    if (rawScore is Map) {
      score = ScoreModelV2.fromJson(Map<String, dynamic>.from(rawScore));
    }

    final rawSuspended = json['7'] == true;
    final gamePart = _parseInt(json['30']);
    final afterRegularTime = gamePart >= GamePart.finished.value;
    final isSuspended = rawSuspended &&
        (!afterRegularTime || !markets.any((m) => m.isAvailable));

    return EventModelV2(
      markets: markets,
      sportId: _parseInt(json['2']),
      leagueId: _parseInt(json['3']),
      eventId: _parseInt(json['4']),
      startDate: json['5']?.toString() ?? '',
      startTime: _parseInt(json['6']),
      isSuspended: isSuspended,
      isParlay: json['9'] == true,
      isCashOut: json['10'] == true,
      type: _parseInt(json['11']),
      eventStatsId: _parseInt(json['14']),
      homeId: _parseInt(json['17']),
      awayId: _parseInt(json['18']),
      homeName: json['19']?.toString() ?? '',
      awayName: json['20']?.toString() ?? '',
      homeLogo: json['21']?.toString() ?? '',
      awayLogo: json['22']?.toString() ?? '',
      marketCount: _parseInt(json['23']),
      isGoingLive: json['27'] == true,
      isLive: json['28'] == true,
      isLiveStream: json['29'] == true,
      gamePart: gamePart,
      gameTime: _parseInt(json['31']),
      stoppageTime: _parseInt(json['32']),
      score: score,
    );
  }

  DateTime get startDateTime {
    if (startDate.isNotEmpty) {
      final parsed = DateTime.tryParse(startDate);
      if (parsed != null) return parsed.toLocal();
    }
    if (startTime > 0) {
      return DateTime.fromMillisecondsSinceEpoch(startTime, isUtc: true)
          .toLocal();
    }
    return DateTime.now();
  }

  int get gameTimeMinutes => (gameTime / 60000).floor();

  String get gameTimeDisplay {
    if (!isLive || gameTime == 0) return '';
    final minutes = gameTimeMinutes;
    return "$minutes'";
  }

  bool get isAvailable => !isSuspended;

  EventStatusV2 get status {
    if (isSuspended) return EventStatusV2.suspended;
    if (isLive) return EventStatusV2.live;
    if (isGoingLive) return EventStatusV2.goingLive;
    return EventStatusV2.prematch;
  }

  String get gamePartDisplay =>
      GamePart.resolveLive(gamePart, gameTimeMinutes: gameTimeMinutes).shortCode;

  MarketModelV2? getMarketById(int marketId) {
    try {
      return markets.firstWhere((m) => m.marketId == marketId);
    } catch (_) {
      return null;
    }
  }

  MarketModelV2? get fullTime1X2Market => getMarketById(1);

  MarketModelV2? get handicapMarket => getMarketById(3);

  MarketModelV2? get overUnderMarket => getMarketById(4);

  MarketModelV2? get firstHalf1X2Market => getMarketById(2);

  MarketModelV2? get handicapFirstHalfMarket => getMarketById(5);

  MarketModelV2? get overUnderFirstHalfMarket => getMarketById(6);

  String get scoreDisplay {
    final s = score;
    if (s == null) return '- : -';
    return '${s.homeScore} - ${s.awayScore}';
  }

  bool get hasStarted => isLive || gameTime > 0;

  String get fullName => '$homeName vs $awayName';

  String get liveStatusDisplay {
    if (!isLive) return '';
    final time = gameTimeDisplay;
    final part = gamePartDisplay;
    if (time.isNotEmpty && part.isNotEmpty) {
      return '$time | $part';
    }
    return time.isNotEmpty ? time : 'LIVE';
  }
}

enum EventStatusV2 {
  prematch,
  goingLive,
  live,
  suspended;

  String get displayName {
    switch (this) {
      case EventStatusV2.prematch:
        return 'Pre-match';
      case EventStatusV2.goingLive:
        return 'Going Live';
      case EventStatusV2.live:
        return 'Live';
      case EventStatusV2.suspended:
        return 'Suspended';
    }
  }
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  if (value is num) return value.toInt();
  return 0;
}
