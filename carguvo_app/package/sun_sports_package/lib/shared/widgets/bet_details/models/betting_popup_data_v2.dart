import 'package:sun_sports/core/services/models/api_v2/event_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/event_model_v2_extensions.dart';
import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/market_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/odds_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/odds_style_model_v2.dart';
import 'package:sun_sports/core/services/models/league_model.dart'
    show MarketHelper;
import 'package:sun_sports/shared/domain/enums/league_enums.dart';

class BettingPopupDataV2 {
  final int sportId;

  final OddsModelV2 oddsData;

  final MarketModelV2 marketData;

  final EventModelV2 eventData;

  final OddsType oddsType;

  final LeagueModelV2? leagueData;

  final OddsFormatV2 oddsFormat;

  final int minStake;

  final int maxStake;

  final int maxPayout;

  BettingPopupDataV2({
    this.sportId = 1,
    required this.oddsData,
    required this.marketData,
    required this.eventData,
    required this.oddsType,
    this.leagueData,
    this.oddsFormat = OddsFormatV2.decimal,
    this.minStake = 0,
    this.maxStake = 0,
    this.maxPayout = 0,
  });

  BettingPopupDataV2 copyWith({OddsFormatV2? oddsFormat}) => BettingPopupDataV2(
    sportId: sportId,
    oddsData: oddsData,
    marketData: marketData,
    eventData: eventData,
    oddsType: oddsType,
    leagueData: leagueData,
    oddsFormat: oddsFormat ?? this.oddsFormat,
    minStake: minStake,
    maxStake: maxStake,
    maxPayout: maxPayout,
  );

  double getSelectedOddsValue() {
    switch (oddsType) {
      case OddsType.home:
        return oddsData.getHomeOdds(oddsFormat);
      case OddsType.away:
        return oddsData.getAwayOdds(oddsFormat);
      case OddsType.draw:
        return oddsData.getDrawOdds(oddsFormat) ?? 0.0;
      default:
        return 0.0;
    }
  }

  String getDisplayOdds() {
    final oddsValue = getSelectedOddsValue();
    if (oddsValue <= 0) return '-';
    return oddsValue.toStringAsFixed(2);
  }

  String? getSelectionId() {
    final base = switch (oddsType) {
      OddsType.home => oddsData.selectionHomeId,
      OddsType.away => oddsData.selectionAwayId,
      OddsType.draw => oddsData.selectionDrawId,
      _ => null,
    };
    if (oddsData.period > 0 && (base?.isNotEmpty ?? false)) {
      return '${oddsData.period}-$base';
    }
    return base;
  }

  String? getOfferId() => oddsData.strOfferId;

  String getTeamName() {
    switch (oddsType) {
      case OddsType.home:
        return eventData.homeName;
      case OddsType.away:
        return eventData.awayName;
      case OddsType.draw:
        return 'Hòa';
      default:
        return '';
    }
  }

  String getSelectionName() {
    final marketId = marketData.marketId;

    if (marketId == 0 &&
        eventData.awayName.isEmpty &&
        eventData.homeName.isNotEmpty) {
      return eventData.homeName;
    }

    if (MarketHelper.isHandicap(marketId)) {
      switch (oddsType) {
        case OddsType.home:
          return eventData.homeName;
        case OddsType.away:
          return eventData.awayName;
        case OddsType.draw:
          return 'Draw';
        default:
          return eventData.homeName;
      }
    }

    if (MarketHelper.isOverUnder(marketId)) {
      return oddsType == OddsType.home ? 'Over' : 'Under';
    }

    if (_isDoubleChanceMarket(marketId)) {
      switch (oddsType) {
        case OddsType.home:
          return '1X';
        case OddsType.away:
          return 'X2';
        case OddsType.draw:
          return '12';
        default:
          return '1X';
      }
    }

    if (MarketHelper.isOddEven(marketId)) {
      return oddsType == OddsType.home ? 'Odd' : 'Even';
    }

    if (MarketHelper.isCorrectScore(marketId)) {
      final points = oddsData.points;
      final scores = points.split(RegExp(r'[:\-]'));
      if (scores.length >= 2) {
        final score1 = int.tryParse(scores[0]) ?? 0;
        final score2 = int.tryParse(scores[1]) ?? 0;
        if (score1 > score2) return 'Home';
        if (score1 < score2) return 'Away';
        return 'Draw';
      }
      return points;
    }

    switch (oddsType) {
      case OddsType.home:
        return 'Home';
      case OddsType.away:
        return 'Away';
      case OddsType.draw:
        return 'Draw';
      default:
        return 'Home';
    }
  }

  bool _isDoubleChanceMarket(int marketId) => [7, 8].contains(marketId);

  String getPointDisplay() {
    final points = oddsData.points;
    final score = '[${eventData.homeScoreInt}-${eventData.awayScoreInt}]';

    if (_isCornerMarket()) {
      return '$points@';
    }

    return '$points$score@';
  }

  String getMarketName() => marketData.marketType.displayName;

  String getMarketNameViDisplay() =>
      MarketHelper.getMarketNameViDisplay(marketData.marketId);

  String getLeagueName() => leagueData?.displayName ?? '';

  String getHomeName() => eventData.homeName;

  String getAwayName() => eventData.awayName;

  String getScore() => '[${eventData.homeScoreInt}-${eventData.awayScoreInt}]';

  bool get isLive => eventData.isLive;

  int get gameTime => eventData.gameTime ~/ 60000;

  int get gamePart => eventData.gamePart;

  int get cornersHome => eventData.cornersHome;

  int get cornersAway => eventData.cornersAway;

  int get yellowCardsHome => eventData.yellowCardsHome;

  int get yellowCardsAway => eventData.yellowCardsAway;

  int get redCardsHome => eventData.redCardsHome;

  int get redCardsAway => eventData.redCardsAway;

  String? get homeLogo =>
      eventData.homeLogo.isNotEmpty ? eventData.homeLogo : null;

  String? get awayLogo =>
      eventData.awayLogo.isNotEmpty ? eventData.awayLogo : null;

  bool get isParlay => marketData.isParlay;

  String getMatchTimeISO() {
    if (eventData.startTime == 0) return '';
    final dateTime = DateTime.fromMillisecondsSinceEpoch(eventData.startTime);
    return dateTime.toIso8601String();
  }

  String getLeagueIdString() {
    return leagueData?.leagueId.toString() ?? eventData.eventId.toString();
  }

  bool _isCornerMarket() {
    return MarketHelper.isCornerMarket(marketData.marketId);
  }
}
