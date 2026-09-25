import 'package:sun_sports/core/services/models/league_model.dart';

enum FlatItemType {
  leagueHeader,

  eventRow,
}

class FlatItem {
  final FlatItemType type;
  final LeagueData league;
  final LeagueEventData? event;
  final int leagueIndex;
  final bool isLastEventInLeague;

  const FlatItem._({
    required this.type,
    required this.league,
    this.event,
    required this.leagueIndex,
    required this.isLastEventInLeague,
  });

  factory FlatItem.header(LeagueData league, {required int leagueIndex}) =>
      FlatItem._(
        type: FlatItemType.leagueHeader,
        league: league,
        leagueIndex: leagueIndex,
        isLastEventInLeague: false,
      );

  factory FlatItem.event(
    LeagueEventData event,
    LeagueData league, {
    required int leagueIndex,
    required bool isLastEventInLeague,
  }) => FlatItem._(
    type: FlatItemType.eventRow,
    league: league,
    event: event,
    leagueIndex: leagueIndex,
    isLastEventInLeague: isLastEventInLeague,
  );

  String get key {
    switch (type) {
      case FlatItemType.leagueHeader:
        return 'league_${league.leagueId}';
      case FlatItemType.eventRow:
        return 'event_${event!.eventId}';
    }
  }

  double getHeight({required bool isDesktop}) {
    switch (type) {
      case FlatItemType.leagueHeader:
        return isDesktop ? 52.0 : 42.0;
      case FlatItemType.eventRow:
        return isDesktop ? 205.0 : 220.0;
    }
  }
}

List<FlatItem> buildFlatItems(
  List<LeagueData> leagues, {
  Set<int>? collapsedLeagueIds,
}) {
  final items = <FlatItem>[];
  var visibleLeagueIndex = 0;

  for (final league in leagues) {
    if (league.events.isEmpty) continue;
    final leagueIndex = visibleLeagueIndex;

    items.add(FlatItem.header(league, leagueIndex: leagueIndex));

    final isCollapsed = collapsedLeagueIds?.contains(league.leagueId) ?? false;
    if (!isCollapsed) {
      for (var i = 0; i < league.events.length; i++) {
        final event = league.events[i];
        final isLastEventInLeague = i == league.events.length - 1;
        items.add(
          FlatItem.event(
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
