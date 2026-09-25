import 'package:betting_domain/betting_domain.dart' show deriveSelectionPeriod;

import '../league_model.dart';
import 'event_detail_response_v2.dart';
import 'event_model_v2.dart';
import 'league_model_v2.dart';
import 'market_model_v2.dart';
import 'odds_model_v2.dart';
import 'odds_style_model_v2.dart';
import 'score_model_v2.dart';

extension LeagueModelV2Adapter on LeagueModelV2 {
  LeagueData toLegacy() {
    return LeagueData(
      leagueId: leagueId,
      leagueName: leagueName,
      leagueLogo: leagueLogo,
      priorityOrder: priorityOrder,
      sportId: sportId,
      events: events.map((e) => e.toLegacy()).toList(),
    );
  }
}

extension LeagueModelV2ListAdapter on List<LeagueModelV2> {
  List<LeagueData> toLegacy() {
    return map((league) => league.toLegacy()).toList();
  }
}

extension EventModelV2Adapter on EventModelV2 {
  LeagueEventData toLegacy() {
    int homeScoreInt = 0;
    int awayScoreInt = 0;
    int cornersHome = 0;
    int cornersAway = 0;
    int redCardsHome = 0;
    int redCardsAway = 0;
    int yellowCardsHome = 0;
    int yellowCardsAway = 0;
    int homeScoreOT = 0;
    int awayScoreOT = 0;

    if (score != null) {
      homeScoreInt = int.tryParse(score!.homeScore) ?? 0;
      awayScoreInt = int.tryParse(score!.awayScore) ?? 0;

      if (score is SoccerScoreModelV2) {
        final soccerScore = score! as SoccerScoreModelV2;
        cornersHome = soccerScore.homeCorner;
        cornersAway = soccerScore.awayCorner;
        redCardsHome = soccerScore.redCardsHome;
        redCardsAway = soccerScore.redCardsAway;
        yellowCardsHome = soccerScore.yellowCardsHome;
        yellowCardsAway = soccerScore.yellowCardsAway;
        homeScoreOT = soccerScore.homeScoreOT;
        awayScoreOT = soccerScore.awayScoreOT;
      }
    }

    return LeagueEventData(
      eventId: eventId,
      homeId: homeId,
      awayId: awayId,
      homeName: homeName,
      awayName: awayName,
      homeLogoFirst: homeLogo,
      awayLogoFirst: awayLogo,
      startTime: startTime,
      isLive: isLive,
      isGoingLive: isGoingLive,
      isLivestream: isLiveStream,
      isSuspended: isSuspended,
      eventStatsId: eventStatsId,
      gamePart: gamePart,
      gameTime: gameTime,
      homeScore: homeScoreInt,
      awayScore: awayScoreInt,
      cornersHome: cornersHome,
      cornersAway: cornersAway,
      homeScoreOT: homeScoreOT,
      awayScoreOT: awayScoreOT,
      redCardsHome: redCardsHome,
      redCardsAway: redCardsAway,
      yellowCardsHome: yellowCardsHome,
      yellowCardsAway: yellowCardsAway,
      totalMarketsCount: marketCount,
      markets: markets.map((m) => m.toLegacy()).toList(),
    );
  }
}

extension EventModelV2ListAdapter on List<EventModelV2> {
  List<LeagueEventData> toLegacy() {
    return map((event) => event.toLegacy()).toList();
  }
}

extension MarketModelV2Adapter on MarketModelV2 {
  LeagueMarketData toLegacy() {
    return LeagueMarketData(
      marketId: marketId,
      marketName: marketType.displayName,
      isParlay: isParlay,
      odds: oddsList.map((o) => o.toLegacy()).toList(),
    );
  }
}

extension MarketModelV2ListAdapter on List<MarketModelV2> {
  List<LeagueMarketData> toLegacy() {
    return map((market) => market.toLegacy()).toList();
  }
}

extension OddsModelV2Adapter on OddsModelV2 {
  LeagueOddsData toLegacy() {
    return LeagueOddsData(
      points: points,
      isMainLine: isMainLine,
      selectionHomeId: selectionHomeId,
      selectionAwayId: selectionAwayId,
      selectionDrawId: selectionDrawId,
      offerId: strOfferId,
      isSuspended: isSuspended,
      oddsHome: homeOdds?.toLegacyOddsValue() ?? const OddsValue(),
      oddsAway: awayOdds?.toLegacyOddsValue() ?? const OddsValue(),
      oddsDraw: drawOdds?.toLegacyOddsValue() ?? const OddsValue(),
      playerName: playerName,
      playerId: playerId,
      period: period,
    );
  }
}

extension OddsModelV2ListAdapter on List<OddsModelV2> {
  List<LeagueOddsData> toLegacy() {
    return map((odds) => odds.toLegacy()).toList();
  }
}

extension OddsStyleModelV2Adapter on OddsStyleModelV2 {
  OddsValue toLegacyOddsValue() {
    return OddsValue(
      malay: _toLegacyOdds(malay),
      indo: _toLegacyOdds(indo),
      decimal: _toLegacyOdds(decimal),
      hongKong: _toLegacyOdds(hk),
    );
  }
}

double _toLegacyOdds(String raw) =>
    raw.isEmpty ? -100 : (double.tryParse(raw) ?? -100);

extension EventDetailResponseV2Adapter on EventDetailResponseV2 {
  LeagueEventData toLeagueEventData() {
    final mainMarkets = markets.map((m) => m.toLegacy()).toList();

    final childMarkets = <LeagueMarketData>[];
    for (final child in children) {
      final forceSuspend = child.childType != null && child.isSuspended;
      childMarkets.addAll(
        child.markets.map((m) {
          final legacy = m.toLegacy();
          if (!forceSuspend) return legacy;
          return legacy.copyWith(
            odds: [
              for (final o in legacy.odds) o.copyWith(isSuspended: true),
            ],
          );
        }),
      );
    }

    return deriveRestPeriod(
      LeagueEventData(
        eventId: eventId,
        homeId: homeId,
        awayId: awayId,
        homeName: homeName,
        awayName: awayName,
        homeLogoFirst: homeLogo,
        awayLogoFirst: awayLogo,
        startTime: startTime,
        isLive: isLive,
        isGoingLive: isGoingLive,
        isLivestream: isLiveStream,
        isSuspended: isEffectivelySuspended,
        eventStatsId: eventStatsId,
        gamePart: gamePart,
        gameTime: gameTime,
        stoppageTime: stoppageTime,
        totalMarketsCount: marketCount,
        markets: [...mainMarkets, ...childMarkets],
      ),
    );
  }

  LeagueEventData deriveRestPeriod(LeagueEventData e) => e.copyWith(
        markets: [
          for (final m in e.markets)
            m.copyWith(
              odds: [
                for (final o in m.odds)
                  o.period == 0
                      ? o.copyWith(
                          period: deriveSelectionPeriod(
                            (o.selectionHomeId?.isNotEmpty ?? false)
                                ? o.selectionHomeId!
                                : (o.selectionAwayId?.isNotEmpty ?? false)
                                    ? o.selectionAwayId!
                                    : (o.selectionDrawId ?? ''),
                            e.eventId,
                          ),
                        )
                      : o,
              ],
            ),
        ],
      );
}
