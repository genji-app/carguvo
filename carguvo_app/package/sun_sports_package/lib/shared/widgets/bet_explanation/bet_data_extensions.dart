import 'package:sun_sports/core/services/models/api_v2/score_model_v2.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/core/services/repositories/repositories.dart';
import 'package:sun_sports/features/bet_detail/domain/helpers/market_layout_helper.dart';
import 'package:sun_sports/features/parlay/domain/models/single_bet_data.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';
import 'package:sun_sports/shared/widgets/bet_details/hint_bubble/hint_bubble.dart';

extension SingleBetDataToHintData on SingleBetData {
  HintData toHintData({OddsStyle? oddsStyleOverride, double? liveRatio}) {
    final market = HintData.getMarketCategory(marketData.marketId);
    final hintTeamName = HintData.hintSelectionName(
      market: market,
      teamName: teamName,
      playerName: oddsData.playerName,
      points: oddsData.points,
    );
    final v2 = scoreV2;
    final liveScore = (sportId != 1 && v2 != null)
        ? v2.hintScore(marketData.marketId)
        : null;

    final preferredStyle = oddsStyleOverride ?? oddsStyle;
    final OddsValue oddsValueForType = switch (oddsType) {
      OddsType.home => oddsData.oddsHome,
      OddsType.away => oddsData.oddsAway,
      OddsType.draw => oddsData.oddsDraw,
      _ => const OddsValue(),
    };
    final resolved = MarketLayoutHelper.resolveOddsWithStyle(
      oddsValueForType,
      preferredStyle,
    );
    final bool useRealtime =
        preferredStyle == oddsStyle && resolved?.style == preferredStyle;
    final bool hasLive =
        liveRatio != null && liveRatio != 0 && liveRatio != -100;
    final double effectiveRatio = hasLive
        ? liveRatio
        : useRealtime
        ? displayOdds
        : (resolved?.value ?? -100);
    final OddsStyle effectiveStyle = resolved?.style ?? preferredStyle;

    return HintData(
      marketId: marketData.marketId,
      sportId: sportId,
      market: market,
      period: HintData.getPeriod(marketData.marketId),
      periodLabel: HintData.keoRungPeriodLabel(
        marketId: marketData.marketId,
        period: oddsData.period,
        continuousMinute: eventData.continuousMatchMinute,
      ),
      handicap: HintData.selectedHandicap(
        rawPoints: oddsData.points,
        market: market,
        oddsType: oddsType,
      ),
      ratio: effectiveRatio,
      style: effectiveStyle,
      team: HintData.mapOddsTypeToTeam(oddsType),
      homeName: eventData.homeName,
      awayName: eventData.awayName,
      teamName: hintTeamName,
      homeScore: liveScore?.$1 ?? eventData.homeScore,
      awayScore: liveScore?.$2 ?? eventData.awayScore,
      homeCorner: eventData.cornersHome,
      awayCorner: eventData.cornersAway,
      homeBookings: eventData.redCardsHome * 2 + eventData.yellowCardsHome,
      awayBookings: eventData.redCardsAway * 2 + eventData.yellowCardsAway,
      stake: stake > 0 ? stake.toDouble() : 100000.0,
      isLive: eventData.isLive,
    );
  }
}

extension BetSlipToHintData on BetSlip {
  HintData toHintData() {
    final handicap = _extractHandicap(cls, oddsName);

    return HintData(
      marketId: marketId,
      sportId: sportId,
      market: HintData.getMarketCategory(marketId),
      period: HintData.getPeriod(marketId),
      handicap: handicap,
      ratio: double.tryParse(displayOdds) ?? 0.0,
      style: _parseOddsStyle(oddsStyle),
      team: _parseTeamFromOddsName(oddsName),
      homeName: homeName ?? '',
      awayName: awayName ?? '',
      teamName: homeName ?? '',
      homeScore: _parseScore(score).home,
      awayScore: _parseScore(score).away,
      homeCorner: 0,
      awayCorner: 0,
      homeBookings: 0,
      awayBookings: 0,
      stake: stake > 0 ? stake.toDouble() : 100000.0,
      isLive: isMatchLive,
    );
  }
}

extension ChildBetToHintData on ChildBet {
  HintData toHintData() {
    final handicap = _extractHandicap(cls, oddsName);

    return HintData(
      marketId: marketId,
      sportId: sportId,
      market: HintData.getMarketCategory(marketId),
      period: HintData.getPeriod(marketId),
      handicap: handicap,
      ratio: double.tryParse(displayOdds) ?? 0.0,
      style: _parseOddsStyle(oddsStyle),
      team: _parseTeamFromOddsName(oddsName),
      homeName: homeName ?? '',
      awayName: awayName ?? '',
      teamName: homeName ?? '',
      homeScore: _parseScore(score).home,
      awayScore: _parseScore(score).away,
      homeCorner: 0,
      awayCorner: 0,
      homeBookings: 0,
      awayBookings: 0,
      stake: stake > 0 ? stake.toDouble() : 100000.0,
      isLive: isMatchLive,
    );
  }
}

OddsStyle _parseOddsStyle(String style) {
  return switch (style.toLowerCase()) {
    'ma' || 'malay' || 'my' => OddsStyle.malay,
    'indo' || 'id' => OddsStyle.indo,
    'hk' || 'hongkong' => OddsStyle.hongKong,
    'de' || 'decimal' => OddsStyle.decimal,
    _ => OddsStyle.decimal,
  };
}

double _extractHandicap(String cls, String oddsName) {
  final clsMatch = RegExp(r'[-+]?\d+\.?\d*').firstMatch(cls);
  if (clsMatch != null) {
    return double.tryParse(clsMatch.group(0) ?? '0') ?? 0.0;
  }

  final oddsMatch = RegExp(r'\d+\.?\d*').firstMatch(oddsName);
  if (oddsMatch != null) {
    return double.tryParse(oddsMatch.group(0) ?? '0') ?? 0.0;
  }

  return 0.0;
}

HintTeamType _parseTeamFromOddsName(String oddsName) {
  final name = oddsName.toLowerCase();

  if (name.contains('home') || name.contains('over') || name.contains('odd')) {
    return HintTeamType.home;
  }

  if (name.contains('away') ||
      name.contains('under') ||
      name.contains('even')) {
    return HintTeamType.away;
  }

  if (name.contains('draw')) {
    return HintTeamType.draw;
  }

  return HintTeamType.none;
}

({int home, int away}) _parseScore(String score) {
  if (score.isEmpty) return (home: 0, away: 0);

  final cleaned = score.replaceAll('[', '').replaceAll(']', '');

  final parts = cleaned.split('-');
  if (parts.length != 2) return (home: 0, away: 0);

  final home = int.tryParse(parts[0].trim()) ?? 0;
  final away = int.tryParse(parts[1].trim()) ?? 0;

  return (home: home, away: away);
}
