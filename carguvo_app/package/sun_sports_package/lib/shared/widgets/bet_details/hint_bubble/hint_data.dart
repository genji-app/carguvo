export 'package:betting_domain/betting_domain.dart' show HintData;

import 'package:betting_domain/betting_domain.dart';
import 'package:sun_sports/core/services/models/api_v2/score_model_v2.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';
import 'package:sun_sports/shared/widgets/bet_details/models/betting_popup_data.dart';

class HintDataFactory {
  HintDataFactory._();

  static HintData fromBettingPopup({
    required BettingPopupData popupData,
    required double currentOdds,
    double stake = 100000.0,
    ScoreModelV2? scoreV2,
    OddsStyle? styleOverride,
  }) {
    final marketId = popupData.marketData.marketId;

    final isOutright = marketId == 0 &&
        popupData.eventData.awayName.isEmpty &&
        popupData.eventData.homeName.isNotEmpty;

    final market = isOutright
        ? MarketCategory.outright
        : HintData.getMarketCategory(marketId);

    String eventDate = '';
    if (isOutright && popupData.eventData.startTime > 0) {
      final dt = DateTime.fromMillisecondsSinceEpoch(
        popupData.eventData.startTime,
      );
      eventDate =
          '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    }

    final teamName = HintData.hintSelectionName(
      market: market,
      teamName: popupData.getTeamName(),
      playerName: popupData.oddsData.playerName,
      points: popupData.oddsData.points,
      marketId: marketId,
      homeName: popupData.eventData.homeName,
      awayName: popupData.eventData.awayName,
    );

    final liveScore = (popupData.sportId != 1 && scoreV2 != null)
        ? scoreV2.hintScore(marketId)
        : null;

    return HintData(
      marketId: marketId,
      sportId: popupData.sportId,
      market: market,
      period: HintData.getPeriod(marketId),
      periodLabel: HintData.keoRungPeriodLabel(
        marketId: marketId,
        period: popupData.oddsData.period,
        continuousMinute: popupData.eventData.continuousMatchMinute,
      ),
      handicap: HintData.selectedHandicap(
        rawPoints: popupData.oddsData.points,
        market: market,
        oddsType: popupData.oddsType,
      ),
      ratio: currentOdds,
      style: styleOverride ?? popupData.oddsStyle,
      team: HintData.mapOddsTypeToTeam(popupData.oddsType),
      homeName: popupData.eventData.homeName,
      awayName: popupData.eventData.awayName,
      teamName: teamName,
      homeScore: liveScore?.$1 ?? popupData.eventData.homeScore,
      awayScore: liveScore?.$2 ?? popupData.eventData.awayScore,
      homeCorner: popupData.eventData.cornersHome,
      awayCorner: popupData.eventData.cornersAway,
      homeBookings:
          popupData.eventData.redCardsHome * 2 +
          popupData.eventData.yellowCardsHome,
      awayBookings:
          popupData.eventData.redCardsAway * 2 +
          popupData.eventData.yellowCardsAway,
      stake: stake,
      isLive: popupData.isLive,
      eventName: popupData.eventData.eventName ?? '',
      eventDate: eventDate,
      outrightKind: popupData.outrightKind,
    );
  }
}
