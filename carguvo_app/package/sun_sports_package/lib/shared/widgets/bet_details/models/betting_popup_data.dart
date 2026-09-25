import 'package:betting_domain/betting_domain.dart' show OutrightKind, outrightKindFromName;
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/features/bet_detail/domain/helpers/market_layout_helper.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';

export 'package:betting_domain/betting_domain.dart' show OutrightKind, outrightKindFromName;

class BettingPopupData {
  final int? _sportId;

  int get sportId {
    if (_sportId != null && _sportId > 0) return _sportId;
    final fromLeague = leagueData?.sportId ?? 0;
    return fromLeague > 0 ? fromLeague : 1;
  }

  bool get isSpecialOutright =>
      marketData.marketId == 0 && eventData.awayName.isEmpty;

  OutrightKind get outrightKind =>
      outrightKindFromName(eventData.eventName ?? '');

  final LeagueOddsData oddsData;

  final LeagueMarketData marketData;

  final LeagueEventData eventData;

  final OddsType oddsType;

  final LeagueData? leagueData;

  final OddsStyle oddsStyle;

  final String outrightMatchName;

  BettingPopupData({
    int? sportId,
    required this.oddsData,
    required this.marketData,
    required this.eventData,
    required this.oddsType,
    this.leagueData,
    this.oddsStyle = OddsStyle.decimal,
    this.outrightMatchName = '',
    this.minStake = 0,
    this.maxStake = 0,
    this.maxPayout = 0,
  }) : _sportId = sportId;

  OddsStyle get sendOddsStyle {
    final effective = MarketLayoutHelper.getEffectiveOddsStyle(
      marketData.marketId,
      oddsStyle,
    );
    final resolved = MarketLayoutHelper.resolveOddsWithStyle(
      _getOddsValueByType(),
      effective,
    );
    return resolved?.style ?? OddsStyle.decimal;
  }

  double getSelectedOddsValue() {
    final oddsValue = _getOddsValueByType();
    return oddsValue.getByStyle(sendOddsStyle);
  }

  double getSelectedOddsValueByStyle(OddsStyle style) {
    final oddsValue = _getOddsValueByType();
    return oddsValue.getByStyle(style);
  }

  String getDisplayOdds() {
    final oddsValue = getSelectedOddsValue();
    if (oddsValue == 0 || oddsValue == -100) return '-';
    return oddsValue.toStringAsFixed(2);
  }

  String? getSelectionId() {
    if (_isPlayerGoalscorerMarket(marketData.marketId) &&
        oddsData.playerId.isNotEmpty &&
        (oddsData.selectionHomeId?.isNotEmpty ?? false)) {
      return '${oddsData.playerId}-${oddsData.selectionHomeId}';
    }
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

  String? getOfferId() => oddsData.offerId ?? oddsData.offerIdLegacy;

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

  String getDisplaySelectionLabel() {
    final marketId = marketData.marketId;

    if (_isPlayerGoalscorerMarket(marketId) &&
        oddsData.playerName.isNotEmpty) {
      return oddsData.playerName;
    }

    if (MarketHelper.isCorrectScore(marketId)) {
      return CorrectScoreHelper.getDisplayText(oddsData.points);
    }

    if (CorrectScoreHelper.isWinningMargin(marketId)) {
      final team = CorrectScoreHelper.marginIsHome(oddsData.points)
          ? eventData.homeName
          : eventData.awayName;
      return '$team ${CorrectScoreHelper.marginDisplayText(oddsData.points)}';
    }
    if (MarketLayoutHelper.isTotalScore(marketId) ||
        MarketLayoutHelper.isExactGoals(marketId)) {
      return MarketLayoutHelper.totalScoreLabel(oddsData.points);
    }
    if (MarketLayoutHelper.isCornerRange(marketId)) {
      return oddsData.points;
    }
    if (MarketLayoutHelper.isHalfTimeFullTime(marketId)) {
      return MarketLayoutHelper.htFtLabel(
        oddsData.points,
        homeName: eventData.homeName,
        awayName: eventData.awayName,
      );
    }
    if (MarketLayoutHelper.isCombo(marketId)) {
      return MarketLayoutHelper.comboCellLabel(
            marketId,
            oddsData.points,
            homeName: eventData.homeName,
            awayName: eventData.awayName,
          ) ??
          oddsData.points;
    }
    if (MarketLayoutHelper.isOverExactlyUnder(marketId)) {
      return switch (oddsType) {
        OddsType.home => 'Tài',
        OddsType.away => 'Xỉu',
        _ => 'Chính xác',
      };
    }
    if (marketId == 65 || marketId == 87 || marketId == 88) {
      return switch (oddsType) {
        OddsType.home => 'Hiệp 1',
        OddsType.away => 'Hiệp 2',
        _ => 'Hòa',
      };
    }
    if (oddsType == OddsType.draw) {
      if (marketId == 177 || marketId == 190 || marketId == 199 || marketId == 1005) {
        return 'Không có phạt góc';
      }
      if (marketId == 178 || marketId == 191) {
        return 'Không có bàn thắng';
      }
    }
    if (MarketLayoutHelper.isYesNo(marketId)) {
      return oddsType == OddsType.home ? 'Có' : 'Không';
    }
    if (marketId == 130) {
      return oddsType == OddsType.home ? 'Tài' : 'Xỉu';
    }
    if (marketId == 150) {
      return oddsType == OddsType.home ? 'Hòa' : eventData.awayName;
    }
    if (marketId == 151) {
      return oddsType == OddsType.home ? eventData.homeName : 'Hòa';
    }
    if (MarketHelper.isOverUnder(marketId)) {
      return oddsType == OddsType.home ? 'Tài' : 'Xỉu';
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
      return oddsType == OddsType.home ? 'Lẻ' : 'Chẵn';
    }
    return getTeamName();
  }

  String getSelectionName() {
    final marketId = marketData.marketId;

    if (marketId == 0 &&
        eventData.awayName.isEmpty &&
        eventData.homeName.isNotEmpty) {
      return eventData.homeName;
    }

    if (MarketLayoutHelper.isEuropeanHandicap(marketId)) {
      return switch (oddsType) {
        OddsType.home => 'Home',
        OddsType.away => 'Away',
        _ => 'Draw',
      };
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

    if (marketId == 83 ||
        marketId == 84 ||
        marketId == 1001 ||
        marketId == 1002) {
      return oddsType == OddsType.home ? 'Yes' : 'No';
    }

    if (MarketLayoutHelper.isHalfTimeFullTime(marketId)) {
      return MarketLayoutHelper.htFtSelectionCode(oddsData.points);
    }

    if (MarketLayoutHelper.isCombo(marketId)) {
      return MarketLayoutHelper.comboSelectionName(marketId, oddsData.points);
    }

    if (MarketLayoutHelper.isOverExactlyUnder(marketId)) {
      return switch (oddsType) {
        OddsType.home => 'Over',
        OddsType.away => 'Under',
        _ => 'Exact',
      };
    }

    if (marketId == 130) {
      return oddsType == OddsType.home ? 'Over' : 'Under';
    }

    if (marketId == 131 ||
        marketId == 134 ||
        marketId == 135 ||
        marketId == 136) {
      return oddsData.points;
    }

    if (marketId == 14 || marketId == 15) {
      final p = oddsData.points;
      if (p.length >= 3) {
        final from = p[0];
        final to = p[2];
        return from == to ? from : '$from-$to';
      }
      return p;
    }

    if (marketId == 36 ||
        marketId == 37 ||
        marketId == 60 ||
        marketId == 148 ||
        marketId == 149 ||
        marketId == 154 ||
        marketId == 69 ||
        marketId == 70 ||
        marketId == 71 ||
        marketId == 72 ||
        marketId == 73 ||
        marketId == 74 ||
        marketId == 99 ||
        marketId == 100 ||
        marketId == 1008 ||
        marketId == 78 ||
        marketId == 79 ||
        marketId == 1018) {
      return oddsType == OddsType.home ? 'Yes' : 'No';
    }

    if (marketId == 65 || marketId == 87 || marketId == 88) {
      if (oddsType == OddsType.home) return '1st Half';
      if (oddsType == OddsType.away) return '2nd Half';
      return 'Draw';
    }

    if ((marketId == 177 ||
            marketId == 178 ||
            marketId == 190 ||
            marketId == 191 ||
            marketId == 199 ||
            marketId == 1005) &&
        oddsType == OddsType.draw) {
      return 'None';
    }

    if (CorrectScoreHelper.isWinningMargin(marketId)) {
      return CorrectScoreHelper.marginIsHome(oddsData.points) ? 'Home' : 'Away';
    }

    if (marketId == 150) {
      return oddsType == OddsType.home ? 'Draw' : 'Away';
    }
    if (marketId == 151) {
      return oddsType == OddsType.home ? 'Home' : 'Draw';
    }

    if (MarketLayoutHelper.isExactGoals(marketId)) {
      final p = oddsData.points;
      if (p.length >= 3 && p[1] == ':') {
        final from = p[0];
        final to = p[2];
        return from == to ? from : '$from-$to';
      }
      return p;
    }

    if (_isPlayerGoalscorerMarket(marketId) && oddsData.playerName.isNotEmpty) {
      return oddsData.playerName;
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

  bool _isDoubleChanceMarket(int marketId) => [12, 13, 143].contains(marketId);

  bool _isPlayerGoalscorerMarket(int marketId) =>
      const [153, 155, 156, 158, 1026, 1027].contains(marketId);

  String getPointDisplay() {
    final points = oddsData.points;
    final score = '[${eventData.homeScore}-${eventData.awayScore}]';

    if (_isCornerMarket()) {
      return '$points@';
    }

    return '$points$score@';
  }

  String getSelectedPointsDisplay() {
    final raw = oddsData.points;
    if (!MarketHelper.isHandicap(marketData.marketId) ||
        oddsType != OddsType.away) {
      return raw;
    }
    final value = double.tryParse(raw);
    if (value == null) return raw;
    if (value == 0) return raw.replaceFirst('-', '');
    return raw.startsWith('-') ? raw.substring(1) : '-$raw';
  }

  String getMarketName() {
    return marketData.marketName.isNotEmpty
        ? marketData.marketName
        : MarketHelper.getMarketName(marketData.marketId);
  }

  String getMarketNameViDisplay() =>
      MarketHelper.getMarketNameViDisplay(marketData.marketId);

  String getLeagueName() {
    return leagueData?.leagueName ?? '';
  }

  String getHomeName() => eventData.homeName;

  String getAwayName() => eventData.awayName;

  String getScore() => '[${eventData.homeScore}-${eventData.awayScore}]';

  String liveMatchInfoLabel({
    required int homeScore,
    required int awayScore,
    required int cornersHome,
    required int cornersAway,
    required int yellowCardsHome,
    required int yellowCardsAway,
    required int redCardsHome,
    required int redCardsAway,
  }) => MarketHelper.liveMatchInfoLabel(
    marketId: marketData.marketId,
    homeName: eventData.homeName,
    awayName: eventData.awayName,
    homeScore: homeScore,
    awayScore: awayScore,
    cornersHome: cornersHome,
    cornersAway: cornersAway,
    yellowCardsHome: yellowCardsHome,
    yellowCardsAway: yellowCardsAway,
    redCardsHome: redCardsHome,
    redCardsAway: redCardsAway,
  );

  bool get isLive => eventData.isLive;

  int get gameTime => eventData.gameTime ~/ 60000;

  int get gamePart => eventData.gamePart;

  int get cornersHome => eventData.cornersHome;

  int get cornersAway => eventData.cornersAway;

  int get yellowCardsHome => eventData.yellowCardsHome;

  int get yellowCardsAway => eventData.yellowCardsAway;

  int get redCardsHome => eventData.redCardsHome;

  int get redCardsAway => eventData.redCardsAway;

  String? get homeLogo => eventData.homeLogoFirst ?? eventData.homeLogoLast;

  String? get awayLogo => eventData.awayLogoFirst ?? eventData.awayLogoLast;

  bool get isParlay => eventData.isParlay && marketData.isParlay;

  final int minStake;

  final int maxStake;

  final int maxPayout;

  String getMatchTimeISO() {
    if (eventData.startTime == 0) return '';
    final dateTime = DateTime.fromMillisecondsSinceEpoch(
      eventData.startTime,
      isUtc: true,
    );
    return dateTime.toIso8601String();
  }

  String getLeagueIdString() {
    return leagueData?.leagueId.toString() ?? eventData.eventId.toString();
  }

  OddsValue _getOddsValueByType() {
    switch (oddsType) {
      case OddsType.home:
        return oddsData.oddsHome;
      case OddsType.away:
        return oddsData.oddsAway;
      case OddsType.draw:
        return oddsData.oddsDraw;
      default:
        return const OddsValue();
    }
  }

  bool _isCornerMarket() {
    return MarketHelper.isCornerMarket(marketData.marketId);
  }
}
