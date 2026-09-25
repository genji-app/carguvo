import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/event_model_v2.dart';

enum FlatItemTypeV2 {
  leagueHeader,

  eventRow,
}

class FlatItemV2 {
  final FlatItemTypeV2 type;
  final LeagueModelV2 league;
  final EventModelV2? event;
  final int leagueIndex;
  final bool isLastEventInLeague;

  final int leagueOccurrence;

  const FlatItemV2._({
    required this.type,
    required this.league,
    this.event,
    required this.leagueIndex,
    required this.isLastEventInLeague,
    this.leagueOccurrence = 0,
  });

  factory FlatItemV2.header(
    LeagueModelV2 league, {
    required int leagueIndex,
    int leagueOccurrence = 0,
  }) =>
      FlatItemV2._(
        type: FlatItemTypeV2.leagueHeader,
        league: league,
        leagueIndex: leagueIndex,
        isLastEventInLeague: false,
        leagueOccurrence: leagueOccurrence,
      );

  factory FlatItemV2.event(
    EventModelV2 event,
    LeagueModelV2 league, {
    required int leagueIndex,
    required bool isLastEventInLeague,
  }) => FlatItemV2._(
    type: FlatItemTypeV2.eventRow,
    league: league,
    event: event,
    leagueIndex: leagueIndex,
    isLastEventInLeague: isLastEventInLeague,
  );

  String get key {
    switch (type) {
      case FlatItemTypeV2.leagueHeader:
        return leagueOccurrence == 0
            ? 'league_${league.leagueId}'
            : 'league_${league.leagueId}#$leagueOccurrence';
      case FlatItemTypeV2.eventRow:
        return 'event_${event!.eventId}';
    }
  }

  double getHeight({required bool isDesktop}) {
    switch (type) {
      case FlatItemTypeV2.leagueHeader:
        return isDesktop ? 52.0 : 42.0;
      case FlatItemTypeV2.eventRow:
        final isSoccer = event?.sportId == 1 || event?.sportId == null;
        return isSoccer
            ? (isDesktop ? 205.0 : 160.0)
            : (isDesktop ? 250.0 : 270.0);
    }
  }
}

List<FlatItemV2> buildFlatItemsV2(
  List<LeagueModelV2> leagues, {
  Set<int>? collapsedLeagueIds,
  bool includeEmptyLeagues = false,
}) {
  final items = <FlatItemV2>[];
  var visibleLeagueIndex = 0;
  final headerOccurrences = <int, int>{};

  for (final league in leagues) {
    if (league.events.isEmpty && !includeEmptyLeagues) continue;
    final leagueIndex = visibleLeagueIndex;

    final occurrence = headerOccurrences[league.leagueId] ?? 0;
    headerOccurrences[league.leagueId] = occurrence + 1;

    items.add(
      FlatItemV2.header(
        league,
        leagueIndex: leagueIndex,
        leagueOccurrence: occurrence,
      ),
    );

    final isCollapsed = collapsedLeagueIds?.contains(league.leagueId) ?? false;
    if (!isCollapsed && league.events.isNotEmpty) {
      for (var i = 0; i < league.events.length; i++) {
        final event = league.events[i];
        final isLastEventInLeague = i == league.events.length - 1;
        items.add(
          FlatItemV2.event(
            event,
            league,
            leagueIndex: leagueIndex,
            isLastEventInLeague: isLastEventInLeague,
          ),
        );
      }
    }

    visibleLeagueIndex++;
  }

  return items;
}
