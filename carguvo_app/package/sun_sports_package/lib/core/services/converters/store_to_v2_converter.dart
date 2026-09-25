import 'package:betting_domain/betting_domain.dart';
import 'package:sport_socket/sport_socket.dart' as socket;
import 'package:sun_sports/shared/domain/enums/league_enums.dart';

import '../models/api_v2/event_model_v2.dart';
import '../models/api_v2/league_model_v2.dart';
import '../models/api_v2/market_model_v2.dart';
import '../models/api_v2/odds_model_v2.dart';
import '../models/api_v2/odds_style_model_v2.dart';
import '../models/api_v2/score_model_v2.dart';

class StoreToV2Converter {
  const StoreToV2Converter._();

  static List<LeagueModelV2> buildLeagues(
    socket.SportDataStore store,
    int sportId,
  ) {
    final leagues = store.getSortedLeaguesBySport(sportId);
    final result = <LeagueModelV2>[];

    for (final league in leagues) {
      final events = store
          .getEventsByLeague(league.leagueId)
          .where((e) =>
              store.isListMember(e.eventId, sportId) &&
              e.statusEnum.isVisible)
          .toList()
        ..sort(socket.EventData.compareByStartThenId);

      if (events.isEmpty) continue;

      result.add(
        LeagueModelV2(
          leagueId: league.leagueId,
          sportId: sportId,
          leagueName: league.name,
          leagueNameEn: league.nameEn ?? '',
          leagueLogo: league.logoUrl ?? '',
          priorityOrder: league.priorityOrder,
          isFavorited: false,
          events: [
            for (final e in events) _eventFromStore(store, e, sportId),
          ],
        ),
      );
    }

    return result;
  }

  static List<LeagueModelV2> buildHotLeagues(
    socket.SportDataStore store,
    int sportId,
  ) {
    final hotEvents = store.getHotEventsBySport(sportId);
    if (hotEvents.isEmpty) return const [];

    final byLeague = <int, List<socket.EventData>>{};
    for (final e in hotEvents) {
      byLeague.putIfAbsent(e.leagueId, () => <socket.EventData>[]).add(e);
    }

    final result = <LeagueModelV2>[];
    for (final entry in byLeague.entries) {
      final league = store.getLeague(entry.key);
      if (league == null) continue;

      final events = entry.value
        ..sort(socket.EventData.compareByStartThenId);

      result.add(
        LeagueModelV2(
          leagueId: league.leagueId,
          sportId: sportId,
          leagueName: league.name,
          leagueNameEn: league.nameEn ?? '',
          leagueLogo: league.logoUrl ?? '',
          priorityOrder: league.priorityOrder,
          isFavorited: false,
          events: [
            for (final e in events) _eventFromStore(store, e, sportId),
          ],
        ),
      );
    }

    result.sort((a, b) => a.priorityOrder.compareTo(b.priorityOrder));
    return result;
  }

  static EventModelV2? buildDetailEvent(
    socket.SportDataStore store,
    int eventId,
  ) {
    final e = store.getEvent(eventId);
    if (e == null) return null;
    return _eventFromStore(store, e, e.sportId);
  }

  static bool _hasAnyLiveStat(socket.EventData e) =>
      e.homeScore != null ||
      e.awayScore != null ||
      e.yellowCardsHome != null ||
      e.yellowCardsAway != null ||
      e.redCardsHome != null ||
      e.redCardsAway != null ||
      e.cornersHome != null ||
      e.cornersAway != null;

  static bool _hasAnySetStat(socket.EventData e) =>
      e.homeScore != null ||
      e.awayScore != null ||
      e.currentSet != null ||
      e.liveScores != null ||
      e.homeTotalPoint != null ||
      e.awayTotalPoint != null;

  static List<HomeAwayScoreV2> _liveScoresFromStore(socket.EventData e) => [
        for (final (home, away) in e.liveScores ?? const <(String, String)>[])
          HomeAwayScoreV2(homeScore: home, awayScore: away),
      ];

  static ScoreModelV2? _scoreFromStore(socket.EventData e, int sportId) {
    switch (sportId) {
      case 1:
        if (!_hasAnyLiveStat(e)) return null;
        return SoccerScoreModelV2(
          homeScoreFT: e.homeScore ?? 0,
          awayScoreFT: e.awayScore ?? 0,
          homeCorner: e.cornersHome ?? 0,
          awayCorner: e.cornersAway ?? 0,
          yellowCardsHome: e.yellowCardsHome ?? 0,
          yellowCardsAway: e.yellowCardsAway ?? 0,
          redCardsHome: e.redCardsHome ?? 0,
          redCardsAway: e.redCardsAway ?? 0,
          homeScoreOT: e.homeScoreOT ?? 0,
          awayScoreOT: e.awayScoreOT ?? 0,
        );
      case 2:
        if (e.homeScore == null && e.awayScore == null && e.liveScores == null) {
          return null;
        }
        return BasketballScoreModelV2(
          homeScoreFT: e.homeScore ?? 0,
          awayScoreFT: e.awayScore ?? 0,
          liveScores: _liveScoresFromStore(e),
        );
      case 4:
        if (!_hasAnySetStat(e) &&
            e.homeCurrentPoint == null &&
            e.awayCurrentPoint == null) {
          return null;
        }
        return TennisScoreModelV2(
          homeSetScore: e.homeScore ?? 0,
          awaySetScore: e.awayScore ?? 0,
          currentSet: e.currentSet ?? 0,
          homeCurrentPoint: e.homeCurrentPoint,
          awayCurrentPoint: e.awayCurrentPoint,
          liveScores: _liveScoresFromStore(e),
        );
      case 5:
        if (!_hasAnySetStat(e)) return null;
        return VolleyballScoreModelV2(
          homeSetScore: e.homeScore ?? 0,
          awaySetScore: e.awayScore ?? 0,
          homeTotalPoint: e.homeTotalPoint ?? 0,
          awayTotalPoint: e.awayTotalPoint ?? 0,
          currentSet: e.currentSet ?? 0,
          liveScores: _liveScoresFromStore(e),
        );
      case 6:
        if (!_hasAnySetStat(e)) return null;
        return TableTennisScoreModelV2(
          homeSetScore: e.homeScore ?? 0,
          awaySetScore: e.awayScore ?? 0,
          homeTotalPoint: e.homeTotalPoint ?? 0,
          awayTotalPoint: e.awayTotalPoint ?? 0,
          currentSet: e.currentSet ?? 0,
          liveScores: _liveScoresFromStore(e),
        );
      case 7:
        if (!_hasAnySetStat(e)) return null;
        return BadmintonScoreModelV2(
          homeGameScore: e.homeScore ?? 0,
          awayGameScore: e.awayScore ?? 0,
          homeTotalPoint: e.homeTotalPoint ?? 0,
          awayTotalPoint: e.awayTotalPoint ?? 0,
          currentSet: e.currentSet ?? 0,
          liveScores: _liveScoresFromStore(e),
        );
      default:
        return null;
    }
  }

  static EventModelV2 _eventFromStore(
    socket.SportDataStore store,
    socket.EventData e,
    int sportId,
  ) {
    final markets = store.getMarketsByEvent(e.eventId);
    final marketModels = [
      for (final m in markets)
        _marketFromStore(
          m,
          sportId,
          e.leagueId,
          [
            for (final o in store.getOddsByMarket(e.eventId, m.marketId))
              _oddsFromStore(o),
          ],
        ),
    ];

    final gamePart = e.gamePart ?? 0;
    final effectiveSuspended = e.isSuspended &&
        (gamePart < GamePart.finished.value ||
            !marketModels.any((m) => m.isAvailable));

    return EventModelV2(
      eventId: e.eventId,
      leagueId: e.leagueId,
      sportId: sportId,
      homeName: e.homeName,
      awayName: e.awayName,
      homeId: e.homeId,
      awayId: e.awayId,
      homeLogo: e.homeLogo ?? '',
      awayLogo: e.awayLogo ?? '',
      isLive: e.isLive,
      isGoingLive: e.isGoingLive,
      isLiveStream: e.isLiveStream,
      isSuspended: effectiveSuspended,
      startDate: e.startDate?.toIso8601String() ?? '',
      startTime: e.startDate?.millisecondsSinceEpoch ?? 0,
      marketCount: e.totalMarketsCount,
      isParlay: e.isParlay,
      isCashOut: e.isCashOut,
      type: e.type,
      eventStatsId: e.eventStatsId ?? 0,
      gamePart: gamePart,
      gameTime: e.gameTime ?? 0,
      score: _scoreFromStore(e, sportId),
      isFavorited: false,
      markets: marketModels,
    );
  }

  static MarketModelV2 _marketFromStore(
    socket.MarketData market,
    int sportId,
    int leagueId,
    List<OddsModelV2> oddsList,
  ) =>
      MarketModelV2(
        marketId: market.marketId,
        eventId: market.eventId,
        sportId: sportId,
        leagueId: leagueId,
        isSuspended: market.isSuspended,
        isParlay: market.isParlay,
        isCashOut: market.isCashOut,
        promotionType: market.promotionType,
        groupId: market.groupId,
        oddsList: oddsList,
      );

  static OddsModelV2 _oddsFromStore(socket.OddsData o) => OddsModelV2(
        selectionHomeId: o.selectionIdHome ?? '',
        selectionAwayId: o.selectionIdAway ?? '',
        selectionDrawId: o.selectionIdDraw ?? '',
        points: o.points ?? '',
        strOfferId: o.offerId,
        isMainLine: o.isMainLine,
        isSuspended: o.isSuspended,
        homeOdds: _style(o.oddsHome, o.malayHome, o.indoHome, o.hkHome),
        awayOdds: _style(o.oddsAway, o.malayAway, o.indoAway, o.hkAway),
        drawOdds: _style(o.oddsDraw, o.malayDraw, o.indoDraw, o.hkDraw),
        playerName: o.playerName ?? '',
        playerId: o.playerId ?? '',
        period: _derivePeriod(
          o.selectionIdHome ?? o.selectionIdAway ?? o.selectionIdDraw ?? '',
          o.eventId,
        ),
      );

  static int _derivePeriod(String selectionId, int eventId) =>
      deriveSelectionPeriod(selectionId, eventId);

  static OddsStyleModelV2? _style(
    double? decimal,
    String? malay,
    String? indo,
    String? hk,
  ) {
    if (decimal == null) return null;
    return OddsStyleModelV2(
      decimal: decimal.toString(),
      malay: malay ?? '',
      indo: indo ?? '',
      hk: hk ?? '',
    );
  }
}
