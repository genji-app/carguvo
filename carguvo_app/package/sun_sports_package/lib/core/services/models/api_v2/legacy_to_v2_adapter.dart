import 'package:sun_sports/core/services/models/api_v2/event_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/market_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/odds_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/odds_style_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/score_model_v2.dart';
import 'package:sun_sports/core/services/models/league_model.dart';

extension OddsValueToV2 on OddsValue {
  OddsStyleModelV2 toOddsStyleModelV2() {
    return OddsStyleModelV2(
      decimal: decimal.toString(),
      malay: malay.toString(),
      indo: indo.toString(),
      hk: hongKong.toString(),
    );
  }
}

extension LeagueOddsDataToV2 on LeagueOddsData {
  OddsModelV2 toOddsModelV2() {
    return OddsModelV2(
      selectionHomeId: effectiveHomeSelectionId ?? '',
      selectionAwayId: effectiveAwaySelectionId ?? '',
      selectionDrawId: effectiveDrawSelectionId ?? '',
      points: points,
      homeOdds: oddsHome.isValid ? oddsHome.toOddsStyleModelV2() : null,
      awayOdds: oddsAway.isValid ? oddsAway.toOddsStyleModelV2() : null,
      drawOdds: oddsDraw.isValid ? oddsDraw.toOddsStyleModelV2() : null,
      strOfferId: effectiveOfferId ?? '',
      isMainLine: isMainLine,
      isSuspended: false,
      isHidden: false,
    );
  }
}

extension LeagueMarketDataToV2 on LeagueMarketData {
  MarketModelV2 toMarketModelV2({
    required int eventId,
    required int leagueId,
    required int sportId,
  }) {
    return MarketModelV2(
      oddsList: odds.map((o) => o.toOddsModelV2()).toList(),
      sportId: sportId,
      leagueId: leagueId,
      eventId: eventId,
      marketId: marketId,
      isSuspended: false,
      isParlay: isParlay,
      isCashOut: false,
      promotionType: 0,
      groupId: 0,
    );
  }
}

extension LeagueEventDataToV2 on LeagueEventData {
  EventModelV2 toEventModelV2({required int leagueId, required int sportId}) {
    final score = GenericScoreModelV2(
      sportId: sportId,
      homeScoreValue: homeScore.toString(),
      awayScoreValue: awayScore.toString(),
    );
    final startDt = DateTime.fromMillisecondsSinceEpoch(startTime);
    final startDateStr = startTime > 0
        ? '${startDt.toIso8601String().split('.').first}Z'
        : '';

    return EventModelV2(
      markets: markets
          .map(
            (m) => m.toMarketModelV2(
              eventId: eventId,
              leagueId: leagueId,
              sportId: sportId,
            ),
          )
          .toList(),
      sportId: sportId,
      leagueId: leagueId,
      eventId: eventId,
      startDate: startDateStr,
      startTime: startTime,
      isSuspended: isSuspended,
      isParlay: isParlay,
      isCashOut: false,
      type: isLive ? 3 : 2,
      eventStatsId: eventStatsId,
      homeId: homeId,
      awayId: awayId,
      homeName: homeName,
      awayName: awayName,
      homeLogo: homeLogo,
      awayLogo: awayLogo,
      marketCount: totalMarketsCount,
      isGoingLive: isGoingLive,
      isLive: isLive,
      isLiveStream: isLivestream,
      gamePart: gamePart,
      gameTime: gameTime,
      score: score,
      isFavorited: false,
    );
  }
}

extension LeagueDataToV2 on LeagueData {
  LeagueModelV2 toLeagueModelV2({required int sportId}) {
    return LeagueModelV2(
      events: events
          .map((e) => e.toEventModelV2(leagueId: leagueId, sportId: sportId))
          .toList(),
      sportId: sportId,
      leagueId: leagueId,
      leagueName: leagueName,
      leagueNameEn: leagueName,
      leagueLogo: leagueLogo,
      priorityOrder: priorityOrder ?? 0,
      isFavorited: false,
    );
  }
}
