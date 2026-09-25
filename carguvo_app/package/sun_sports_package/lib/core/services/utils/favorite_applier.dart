import 'package:flutter/foundation.dart';

import '../models/api_v2/event_model_v2.dart';
import '../models/api_v2/league_model_v2.dart';
import '../models/favorite_data.dart';

class FavoriteApplier {
  static List<LeagueModelV2> applyFavorites(
    List<LeagueModelV2> leagues,
    FavoriteData? favoriteData,
  ) {
    if (favoriteData == null || favoriteData.isEmpty) {
      return leagues;
    }

    final favoriteLeagueIds = favoriteData.leagueIds.toSet();
    final favoriteEventIds = favoriteData.eventIds.toSet();

    return leagues.map((league) {
      final isLeagueFavorite = favoriteLeagueIds.contains(league.leagueId);

      final updatedEvents = league.events.map((event) {
        final isEventFavorite =
            isLeagueFavorite || favoriteEventIds.contains(event.eventId);

        if (event.isFavorited == isEventFavorite) {
          return event;
        }

        return event.copyWith(isFavorited: isEventFavorite);
      }).toList();

      final updatedLeague = league.copyWith(
        isFavorited: isLeagueFavorite,
        events: updatedEvents,
      );

      if (kDebugMode && isLeagueFavorite) {
        final eventsNotFavorite = updatedEvents
            .where((e) => !e.isFavorited)
            .length;
        if (eventsNotFavorite > 0) {
          debugPrint(
            '[FavoriteApplier] WARNING: League ${league.leagueId} is favorite '
            'but $eventsNotFavorite events are not favorite!',
          );
        } else {
          debugPrint(
            '[FavoriteApplier] League ${league.leagueId} is favorite '
            'with ${updatedEvents.length} events (all favorite)',
          );
        }
      }

      return updatedLeague;
    }).toList();
  }

  static LeagueModelV2 applyFavoritesToLeague(
    LeagueModelV2 league,
    FavoriteData? favoriteData,
  ) {
    if (favoriteData == null || favoriteData.isEmpty) {
      return league;
    }

    final favoriteLeagueIds = favoriteData.leagueIds.toSet();
    final favoriteEventIds = favoriteData.eventIds.toSet();

    final isLeagueFavorite = favoriteLeagueIds.contains(league.leagueId);

    final updatedEvents = league.events.map((event) {
      final isEventFavorite =
          isLeagueFavorite || favoriteEventIds.contains(event.eventId);
      return event.copyWith(isFavorited: isEventFavorite);
    }).toList();

    return league.copyWith(
      isFavorited: isLeagueFavorite,
      events: updatedEvents,
    );
  }

  static EventModelV2 applyFavoritesToEvent(
    EventModelV2 event,
    FavoriteData? favoriteData,
  ) {
    if (favoriteData == null || favoriteData.isEmpty) {
      return event;
    }

    final favoriteEventIds = favoriteData.eventIds.toSet();
    final isEventFavorite = favoriteEventIds.contains(event.eventId);

    return event.copyWith(isFavorited: isEventFavorite);
  }
}
