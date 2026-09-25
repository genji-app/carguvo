import 'package:sport_socket/sport_socket.dart' as socket;
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/shared/domain/enums/betting_enums.dart';

class LeagueAdapter {
  const LeagueAdapter._();

  static LeagueData toFreezed(socket.LeagueData source) {
    return LeagueData(
      leagueId: source.leagueId,
      leagueName: source.name,
      leagueLogo: source.logoUrl ?? '',
      priorityOrder: source.priorityOrder,
      events: [],
    );
  }

  static List<LeagueData> toFreezedList(Iterable<socket.LeagueData> sources) {
    return sources.map(toFreezed).toList();
  }

  static LeagueData toFreezedWithEvents(
    socket.LeagueData league,
    List<socket.EventData> events,
    Map<int, List<socket.MarketData>> marketsPerEvent,
    Map<String, List<socket.OddsData>> oddsPerMarket,
  ) {
    return LeagueData(
      leagueId: league.leagueId,
      leagueName: league.name,
      leagueLogo: league.logoUrl ?? '',
      priorityOrder: league.priorityOrder,
      events: events.map((e) {
        final eventMarkets = marketsPerEvent[e.eventId] ?? [];
        return EventAdapter.toFreezedWithMarkets(
          e,
          eventMarkets,
          oddsPerMarket,
        );
      }).toList(),
    );
  }

  static LeagueData updateFreezed(
    LeagueData existing,
    socket.LeagueData source,
  ) {
    return existing.copyWith(
      leagueName: source.name,
      leagueLogo: source.logoUrl ?? existing.leagueLogo,
      priorityOrder: source.priorityOrder ?? existing.priorityOrder,
    );
  }
}

class EventAdapter {
  const EventAdapter._();

  static LeagueEventData toFreezed(socket.EventData source) {
    return LeagueEventData(
      eventId: source.eventId,
      homeId: source.homeId,
      homeName: source.homeName,
      awayId: source.awayId,
      awayName: source.awayName,
      homeLogoFirst: source.homeLogo,
      awayLogoFirst: source.awayLogo,
      startTime: source.startDate?.millisecondsSinceEpoch ?? 0,
      homeScore: source.homeScore ?? 0,
      awayScore: source.awayScore ?? 0,
      isLive: source.isLive,
      isGoingLive: source.isGoingLive,
      isLivestream: source.isLiveStream,
      isSuspended: source.status != 'ACTIVE',
      eventStatus: source.status,
      gameTime: source.gameTime ?? 0,
      gamePart: source.gamePart ?? 0,
      stoppageTime: source.stoppageTime ?? 0,
      cornersHome: source.cornersHome ?? 0,
      cornersAway: source.cornersAway ?? 0,
      redCardsHome: source.redCardsHome ?? 0,
      redCardsAway: source.redCardsAway ?? 0,
      yellowCardsHome: source.yellowCardsHome ?? 0,
      yellowCardsAway: source.yellowCardsAway ?? 0,
      markets: [],
    );
  }

  static LeagueEventData toFreezedWithMarkets(
    socket.EventData source,
    List<socket.MarketData> markets,
    Map<String, List<socket.OddsData>> oddsPerMarket,
  ) {
    return LeagueEventData(
      eventId: source.eventId,
      homeId: source.homeId,
      homeName: source.homeName,
      awayId: source.awayId,
      awayName: source.awayName,
      homeLogoFirst: source.homeLogo,
      awayLogoFirst: source.awayLogo,
      startTime: source.startDate?.millisecondsSinceEpoch ?? 0,
      homeScore: source.homeScore ?? 0,
      awayScore: source.awayScore ?? 0,
      isLive: source.isLive,
      isGoingLive: source.isGoingLive,
      isLivestream: source.isLiveStream,
      isSuspended: source.status != 'ACTIVE',
      eventStatus: source.status,
      gameTime: source.gameTime ?? 0,
      gamePart: source.gamePart ?? 0,
      stoppageTime: source.stoppageTime ?? 0,
      cornersHome: source.cornersHome ?? 0,
      cornersAway: source.cornersAway ?? 0,
      redCardsHome: source.redCardsHome ?? 0,
      redCardsAway: source.redCardsAway ?? 0,
      yellowCardsHome: source.yellowCardsHome ?? 0,
      yellowCardsAway: source.yellowCardsAway ?? 0,
      totalMarketsCount: markets.length,
      markets: markets.map((m) {
        final marketKey = '${source.eventId}_${m.marketId}';
        final odds = oddsPerMarket[marketKey] ?? [];
        return MarketAdapter.toFreezed(m, odds);
      }).toList(),
    );
  }

  static List<LeagueEventData> toFreezedList(
    Iterable<socket.EventData> sources,
  ) {
    return sources.map(toFreezed).toList();
  }

  static LeagueEventData updateFreezed(
    LeagueEventData existing,
    socket.EventData source,
  ) {
    return existing.copyWith(
      homeScore: source.homeScore ?? existing.homeScore,
      awayScore: source.awayScore ?? existing.awayScore,
      isLive: source.isLive,
      isSuspended: source.status != 'ACTIVE',
      eventStatus: source.status ?? existing.eventStatus,
      gameTime: source.gameTime ?? existing.gameTime,
      gamePart: source.gamePart ?? existing.gamePart,
      stoppageTime: source.stoppageTime ?? existing.stoppageTime,
      cornersHome: source.cornersHome ?? existing.cornersHome,
      cornersAway: source.cornersAway ?? existing.cornersAway,
      redCardsHome: source.redCardsHome ?? existing.redCardsHome,
      redCardsAway: source.redCardsAway ?? existing.redCardsAway,
      yellowCardsHome: source.yellowCardsHome ?? existing.yellowCardsHome,
      yellowCardsAway: source.yellowCardsAway ?? existing.yellowCardsAway,
    );
  }
}

class MarketAdapter {
  const MarketAdapter._();

  static LeagueMarketData toFreezed(
    socket.MarketData source,
    List<socket.OddsData> odds,
  ) {
    return LeagueMarketData(
      marketId: source.marketId,
      marketName: MarketHelper.getMarketName(source.marketId),
      isParlay: false,
      odds: odds.map(OddsAdapter.toFreezed).toList(),
    );
  }

  static List<LeagueMarketData> toFreezedList(
    Iterable<socket.MarketData> sources,
    Map<String, List<socket.OddsData>> oddsPerMarket,
  ) {
    return sources.map((m) {
      final marketKey = '${m.eventId}_${m.marketId}';
      final odds = oddsPerMarket[marketKey] ?? [];
      return toFreezed(m, odds);
    }).toList();
  }
}

class OddsAdapter {
  const OddsAdapter._();

  static LeagueOddsData toFreezed(socket.OddsData source) {
    return LeagueOddsData(
      points: source.points ?? '',
      isMainLine: source.isMainLine,
      isSuspended: source.isSuspended,
      offerId: source.offerId,
      selectionHomeId: source.selectionIdHome,
      selectionAwayId: source.selectionIdAway,
      selectionDrawId: source.selectionIdDraw,
      oddsHome: OddsValue(
        malay: _parseDouble(source.malayHome),
        indo: _parseDouble(source.indoHome),
        decimal: source.oddsHome ?? -100,
        hongKong: _parseDouble(source.hkHome),
      ),
      oddsAway: OddsValue(
        malay: _parseDouble(source.malayAway),
        indo: _parseDouble(source.indoAway),
        decimal: source.oddsAway ?? -100,
        hongKong: _parseDouble(source.hkAway),
      ),
      oddsDraw: source.oddsDraw != null
          ? OddsValue(
              malay: -100,
              indo: -100,
              decimal: source.oddsDraw!,
              hongKong: -100,
            )
          : const OddsValue(),
    );
  }

  static List<LeagueOddsData> toFreezedList(Iterable<socket.OddsData> sources) {
    return sources.map(toFreezed).toList();
  }

  static OddsChangeDirection getHomeDirection(socket.OddsData source) {
    return _mapDirection(source.homeDirection);
  }

  static OddsChangeDirection getAwayDirection(socket.OddsData source) {
    return _mapDirection(source.awayDirection);
  }

  static OddsChangeDirection getDrawDirection(socket.OddsData source) {
    return _mapDirection(source.drawDirection);
  }

  static OddsChangeDirection _mapDirection(socket.OddsDirection direction) {
    switch (direction) {
      case socket.OddsDirection.up:
        return OddsChangeDirection.up;
      case socket.OddsDirection.down:
        return OddsChangeDirection.down;
      case socket.OddsDirection.none:
        return OddsChangeDirection.none;
    }
  }

  static double _parseDouble(String? value) {
    if (value == null || value.isEmpty) return -100;
    return double.tryParse(value) ?? -100;
  }
}
