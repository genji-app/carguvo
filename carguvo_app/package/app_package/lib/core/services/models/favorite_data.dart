library;

import 'package:sport_events/sport_events.dart';

class FavoriteData {
  final int sportId;
  final List<int> leagueIds;
  final List<int> eventIds;

  const FavoriteData({
    required this.sportId,
    required this.leagueIds,
    required this.eventIds,
  });

  factory FavoriteData.fromJson(Map<String, dynamic> json, int sportId) {
    final ids = FavoriteIds.parseResponse(json, sportId);
    return FavoriteData(
      sportId: sportId,
      leagueIds: ids.leagueIds,
      eventIds: ids.eventIds,
    );
  }

  bool isLeagueFavorite(int leagueId) => leagueIds.contains(leagueId);

  bool isEventFavorite(int eventId) => eventIds.contains(eventId);

  bool get isEmpty => leagueIds.isEmpty && eventIds.isEmpty;

  int get totalCount => leagueIds.length + eventIds.length;
}
