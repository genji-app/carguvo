import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';

import 'market_model_v2.dart';

part 'event_detail_response_v2.freezed.dart';

@freezed
sealed class EventDetailResponseV2 with _$EventDetailResponseV2 {
  const factory EventDetailResponseV2({
    @Default([]) List<EventDetailResponseV2> children,

    @Default([]) List<MarketModelV2> markets,

    @Default(0) int sportId,

    @Default(0) int leagueId,

    @Default(0) int eventId,

    @Default('') String startDate,

    @Default(0) int startTime,

    @Default(false) bool isSuspended,

    @Default(false) bool isHidden,

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

    List<int>? marketGroups,

    @Default(false) bool isHot,

    @Default(false) bool isGoingLive,

    @Default(false) bool isLive,

    @Default(false) bool isLiveStream,

    @Default(0) int gamePart,

    @Default(0) int gameTime,

    @Default(0) int stoppageTime,

    Map<String, dynamic>? scoreRaw,

    int? childType,
  }) = _EventDetailResponseV2;

  const EventDetailResponseV2._();

  factory EventDetailResponseV2.fromJson(Map<String, dynamic> json) {
    final children = <EventDetailResponseV2>[];
    final rawChildren = json['0'];
    if (rawChildren is List) {
      for (final item in rawChildren) {
        if (item is Map) {
          children.add(
            EventDetailResponseV2.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    final markets = <MarketModelV2>[];
    final rawMarkets = json['1'];
    if (rawMarkets is List) {
      for (final item in rawMarkets) {
        if (item is Map) {
          markets.add(MarketModelV2.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    List<int>? marketGroups;
    final rawGroups = json['24'];
    if (rawGroups is List) {
      marketGroups = rawGroups.whereType<int>().toList();
    }

    Map<String, dynamic>? scoreRaw;
    final rawScore = json['33'];
    if (rawScore is Map) {
      scoreRaw = Map<String, dynamic>.from(rawScore);
    }

    return EventDetailResponseV2(
      children: children,
      markets: markets,
      sportId: _parseInt(json['2']),
      leagueId: _parseInt(json['3']),
      eventId: _parseInt(json['4']),
      startDate: json['5']?.toString() ?? '',
      startTime: _parseInt(json['6']),
      isSuspended: json['7'] == true,
      isHidden: json['8'] == true,
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
      marketGroups: marketGroups,
      isHot: json['26'] == true,
      isGoingLive: json['27'] == true,
      isLive: json['28'] == true,
      isLiveStream: json['29'] == true,
      gamePart: _parseInt(json['30']),
      gameTime: _parseInt(json['31']),
      stoppageTime: _parseInt(json['32']),
      scoreRaw: scoreRaw,
      childType: json['34'] as int?,
    );
  }

  List<MarketModelV2> get allMarkets {
    final all = <MarketModelV2>[...markets];
    for (final child in children) {
      all.addAll(child.markets);
    }
    return all;
  }

  List<EventDetailResponseV2> getChildrenByType(int type) {
    return children.where((c) => c.childType == type).toList();
  }

  List<EventDetailResponseV2> get cornerChildren => getChildrenByType(2);

  List<EventDetailResponseV2> get extraTimeChildren => getChildrenByType(1);

  List<EventDetailResponseV2> get penaltyChildren => getChildrenByType(3);

  List<MarketModelV2> get cornerMarkets =>
      cornerChildren.expand((c) => c.markets).toList();

  List<MarketModelV2> get extraTimeMarkets =>
      extraTimeChildren.expand((c) => c.markets).toList();

  List<MarketModelV2> get penaltyMarkets =>
      penaltyChildren.expand((c) => c.markets).toList();

  String get fullName => '$homeName vs $awayName';

  bool get isAvailable => !isSuspended && !isHidden;

  bool get isEffectivelySuspended {
    if (!isSuspended) return false;
    if (gamePart < GamePart.finished.value) return true;
    final hasOpenMarket = markets.any((m) => m.isAvailable) ||
        children.any(
          (c) => !c.isSuspended && c.markets.any((m) => m.isAvailable),
        );
    return !hasOpenMarket;
  }
}

enum ChildEventType {
  extraTime(1),
  corner(2),
  penalty(3);

  final int value;
  const ChildEventType(this.value);

  static ChildEventType? fromValue(int? value) {
    if (value == null) return null;
    return ChildEventType.values.cast<ChildEventType?>().firstWhere(
      (e) => e?.value == value,
      orElse: () => null,
    );
  }
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  if (value is num) return value.toInt();
  return 0;
}
