import 'package:freezed_annotation/freezed_annotation.dart';

import 'event_model_v2.dart';

part 'league_model_v2.freezed.dart';

@freezed
sealed class LeagueModelV2 with _$LeagueModelV2 {
  const factory LeagueModelV2({
    @Default([]) List<EventModelV2> events,

    @Default(0) int sportId,

    @Default(0) int leagueId,

    @Default('') String leagueName,

    @Default('') String leagueNameEn,

    @Default('') String leagueLogo,

    @Default(0) int priorityOrder,

    int? leagueOrder,

    @Default(false) bool isFavorited,
  }) = _LeagueModelV2;

  const LeagueModelV2._();

  factory LeagueModelV2.fromJson(Map<String, dynamic> json) {
    final events = <EventModelV2>[];
    final rawEvents = json['0'];
    if (rawEvents is List) {
      for (final item in rawEvents) {
        if (item is Map) {
          events.add(EventModelV2.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    } else if (rawEvents is Map) {
      events.add(EventModelV2.fromJson(Map<String, dynamic>.from(rawEvents)));
    }

    final key2 = json['2'];
    final key4 = json['4'];
    final hasAlternateLeagueKeys = key2 is String && key4 is num;

    int sportId;
    int leagueId;
    String leagueName;
    String leagueNameEn;
    String leagueLogo;
    int priorityOrder;
    int? leagueOrder;

    if (hasAlternateLeagueKeys) {
      sportId = events.isNotEmpty
          ? events.first.sportId
          : _parseInt(json['1']);
      leagueId = _parseInt(json['1']);
      leagueName = key2.trim();
      final key5 = json['5']?.toString() ?? '';
      if (key5.startsWith('http')) {
        leagueLogo = key5;
        leagueNameEn = leagueName;
      } else {
        leagueLogo = json['3']?.toString() ?? '';
        leagueNameEn = key5.isEmpty ? leagueName : key5;
      }
      priorityOrder = key4.toInt();
      leagueOrder = null;
    } else {
      sportId = _parseInt(json['1']);
      leagueId = _parseInt(json['3']);
      leagueName = key4?.toString() ?? '';
      leagueNameEn = json['5']?.toString() ?? '';
      leagueLogo = json['6']?.toString() ?? '';
      priorityOrder = _parseInt(json['8']);
      leagueOrder = json.containsKey('7') ? _parseInt(json['7']) : null;
    }

    return LeagueModelV2(
      events: events,
      sportId: sportId,
      leagueId: leagueId,
      leagueName: leagueName,
      leagueNameEn: leagueNameEn,
      leagueLogo: leagueLogo,
      priorityOrder: priorityOrder,
      leagueOrder: leagueOrder,
    );
  }

  String get displayName => leagueName.isNotEmpty ? leagueName : leagueNameEn;

  int get eventCount => events.length;

  List<EventModelV2> get liveEvents => events.where((e) => e.isLive).toList();

  List<EventModelV2> get upcomingEvents =>
      events.where((e) => !e.isLive && !e.isSuspended).toList();

  bool get hasLiveEvents => events.any((e) => e.isLive);

  int get liveEventCount => liveEvents.length;

  List<EventModelV2> get eventsSortedByTime {
    final sorted = List<EventModelV2>.from(events);
    sorted.sort((a, b) => a.startTime.compareTo(b.startTime));
    return sorted;
  }

  List<EventModelV2> get availableEvents =>
      events.where((e) => e.isAvailable).toList();
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  if (value is num) return value.toInt();
  return 0;
}

extension LeagueListParserV2 on List<dynamic> {
  List<LeagueModelV2> toLeagueModelsV2() {
    return map((item) {
      if (item is Map<String, dynamic>) {
        return LeagueModelV2.fromJson(item);
      } else if (item is Map) {
        return LeagueModelV2.fromJson(Map<String, dynamic>.from(item));
      }
      throw const FormatException('Invalid league data format');
    }).toList();
  }
}

extension MergeDuplicateLeaguesX on List<LeagueModelV2> {
  List<LeagueModelV2> mergeDuplicateLeagues() {
    final indexById = <int, int>{};
    List<LeagueModelV2>? merged;

    for (var i = 0; i < length; i++) {
      final league = this[i];
      final existingIndex = indexById[league.leagueId];
      if (existingIndex == null) {
        indexById[league.leagueId] = merged?.length ?? i;
        merged?.add(league);
      } else {
        merged ??= sublist(0, i);
        final existing = merged[existingIndex];
        merged[existingIndex] = existing.copyWith(
          events: [...existing.events, ...league.events],
        );
      }
    }

    return merged ?? this;
  }
}
