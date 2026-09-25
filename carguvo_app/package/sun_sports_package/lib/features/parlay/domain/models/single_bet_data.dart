import 'package:betting_domain/betting_domain.dart' as bd;
import 'package:sun_sports/core/services/models/api_v2/score_model_v2.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/features/bet_detail/domain/helpers/market_layout_helper.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';
import 'package:sun_sports/shared/widgets/bet_details/models/betting_popup_data.dart';

class SingleBetData {
  final int sportId;

  final LeagueOddsData oddsData;

  final LeagueMarketData marketData;

  final LeagueEventData eventData;

  final OddsType oddsType;

  final LeagueData? leagueData;

  final OddsStyle oddsStyle;

  final int stake;

  final int minStake;

  final int maxStake;

  final int maxPayout;

  final bool isCalculating;

  final String? errorMessage;

  final double? updatedOdds;

  final bool isDisabled;

  final ScoreModelV2? scoreV2;

  const SingleBetData({
    required this.sportId,
    required this.oddsData,
    required this.marketData,
    required this.eventData,
    required this.oddsType,
    this.leagueData,
    this.oddsStyle = OddsStyle.decimal,
    this.stake = 0,
    this.minStake = 50,
    this.maxStake = 10000,
    this.maxPayout = 0,
    this.isCalculating = false,
    this.errorMessage,
    this.updatedOdds,
    this.isDisabled = false,
    this.scoreV2,
  });

  factory SingleBetData.fromBettingPopupData(BettingPopupData popupData) {
    return SingleBetData(
      sportId: popupData.sportId,
      oddsData: popupData.oddsData,
      marketData: popupData.marketData,
      eventData: popupData.eventData,
      oddsType: popupData.oddsType,
      leagueData: popupData.leagueData,
      oddsStyle: popupData.oddsStyle,
      minStake: popupData.minStake > 0 ? popupData.minStake : 50,
      maxStake: popupData.maxStake > 0 ? popupData.maxStake : 10000,
      maxPayout: popupData.maxPayout,
    );
  }

  BettingPopupData toBettingPopupData() {
    return BettingPopupData(
      sportId: sportId,
      oddsData: oddsData,
      marketData: marketData,
      eventData: eventData,
      oddsType: oddsType,
      leagueData: leagueData,
      oddsStyle: oddsStyle,
      minStake: minStake,
      maxStake: maxStake,
      maxPayout: maxPayout,
    );
  }

  SingleBetData copyWith({
    int? sportId,
    LeagueOddsData? oddsData,
    LeagueMarketData? marketData,
    LeagueEventData? eventData,
    OddsType? oddsType,
    LeagueData? leagueData,
    OddsStyle? oddsStyle,
    int? stake,
    int? minStake,
    int? maxStake,
    int? maxPayout,
    bool? isCalculating,
    String? errorMessage,
    double? updatedOdds,
    bool? isDisabled,
    ScoreModelV2? scoreV2,
  }) {
    return SingleBetData(
      sportId: sportId ?? this.sportId,
      oddsData: oddsData ?? this.oddsData,
      marketData: marketData ?? this.marketData,
      eventData: eventData ?? this.eventData,
      oddsType: oddsType ?? this.oddsType,
      leagueData: leagueData ?? this.leagueData,
      oddsStyle: oddsStyle ?? this.oddsStyle,
      stake: stake ?? this.stake,
      minStake: minStake ?? this.minStake,
      maxStake: maxStake ?? this.maxStake,
      maxPayout: maxPayout ?? this.maxPayout,
      isCalculating: isCalculating ?? this.isCalculating,
      errorMessage: errorMessage,
      updatedOdds: updatedOdds ?? this.updatedOdds,
      isDisabled: isDisabled ?? this.isDisabled,
      scoreV2: scoreV2 ?? this.scoreV2,
    );
  }

  Map<String, dynamic> toJson() => {
    'sportId': sportId,
    'oddsData': oddsData.toJson(),
    'marketData': marketData.toJson(),
    'eventData': eventData.toJson(),
    'oddsType': oddsType.value,
    'leagueData': leagueData?.toJson(),
    'oddsStyle': oddsStyle.value,
    'stake': stake,
    'minStake': minStake,
    'maxStake': maxStake,
    'maxPayout': maxPayout,
    'updatedOdds': updatedOdds,
    'isDisabled': isDisabled,
  };

  factory SingleBetData.fromJson(Map<String, dynamic> json) {
    return SingleBetData(
      sportId:
          json['sportId'] as int? ??
          1,
      oddsData: LeagueOddsData.fromJson(
        json['oddsData'] as Map<String, dynamic>,
      ),
      marketData: LeagueMarketData.fromJson(
        json['marketData'] as Map<String, dynamic>,
      ),
      eventData: LeagueEventData.fromJson(
        json['eventData'] as Map<String, dynamic>,
      ),
      oddsType: OddsType.values.firstWhere(
        (e) => e.value == (json['oddsType'] as int? ?? 0),
        orElse: () => OddsType.none,
      ),
      leagueData: json['leagueData'] != null
          ? LeagueData.fromJson(json['leagueData'] as Map<String, dynamic>)
          : null,
      oddsStyle: OddsStyle.fromInt(json['oddsStyle'] as int? ?? 2),
      stake: json['stake'] as int? ?? 0,
      minStake: json['minStake'] as int? ?? 50,
      maxStake: json['maxStake'] as int? ?? 10000,
      maxPayout: json['maxPayout'] as int? ?? 0,
      updatedOdds: (json['updatedOdds'] as num?)?.toDouble(),
      isDisabled: json['isDisabled'] as bool? ?? false,
    );
  }

  OddsStyle get sendOddsStyle => resolvedStyleFor(oddsStyle);

  bool get isAlwaysDecimalMarket =>
      MarketLayoutHelper.isAlwaysDecimal(marketData.marketId);

  OddsStyle resolvedStyleFor(OddsStyle userStyle) {
    final effective = MarketLayoutHelper.getEffectiveOddsStyle(
      marketData.marketId,
      userStyle,
    );
    final resolved = MarketLayoutHelper.resolveOddsWithStyle(
      _getOddsValueByType(),
      effective,
    );
    return resolved?.style ?? OddsStyle.decimal;
  }

  double get originalOdds {
    final oddsValue = _getOddsValueByType();
    return oddsValue.getByStyle(sendOddsStyle);
  }

  double get displayOdds {
    if (updatedOdds != null) return updatedOdds!;

    final oddsValue = _getOddsValueByType();
    return oddsValue.getByStyle(sendOddsStyle);
  }

  double getOddsByStyle(OddsStyle style) {
    final oddsValue = _getOddsValueByType();
    return oddsValue.getByStyle(style);
  }

  String get displayOddsString {
    final odds = displayOdds;
    if (odds == 0 || odds == -100) return '-';
    return odds.toStringAsFixed(2);
  }

  String? get selectionId {
    if (const [153, 155, 156, 158, 1026, 1027].contains(marketData.marketId) &&
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

  String? get offerId => oddsData.offerId ?? oddsData.offerIdLegacy;

  String get teamName {
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

  String get selectionName => bd.SelectionLabels.apiSelectionName(
        marketId: marketData.marketId,
        pick: oddsType,
        points: oddsData.points,
        homeName: homeName,
        awayName: awayName,
        playerName: oddsData.playerName,
      );

  String get displayName => bd.SelectionLabels.displayLabel(
        marketId: marketData.marketId,
        pick: oddsType,
        points: oddsData.points,
        homeName: homeName,
        awayName: awayName,
        playerName: oddsData.playerName,
      );

  String get pointDisplay {
    final points = oddsData.points;
    final score = '[${eventData.homeScore}-${eventData.awayScore}]';

    if (MarketHelper.isCornerMarket(marketData.marketId)) {
      return '$points@';
    }

    return '$points$score@';
  }

  String get marketName {
    return MarketHelper.getMarketNameViDisplay(marketData.marketId);
  }

  String get leagueName => leagueData?.leagueName ?? '';

  String get homeName => eventData.homeName;

  String get awayName => eventData.awayName;

  String get score => '[${eventData.homeScore}-${eventData.awayScore}]';

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

  String get matchTimeISO {
    if (eventData.startTime == 0) return '';
    final dateTime = DateTime.fromMillisecondsSinceEpoch(
      eventData.startTime,
      isUtc: true,
    );
    return dateTime.toIso8601String();
  }

  String get leagueIdString {
    return leagueData?.leagueId.toString() ?? eventData.eventId.toString();
  }

  double get potentialWinnings => potentialWinningsWith(displayOdds);

  double potentialWinningsWith(double odds) =>
      bd.betPayoutFor(stake, odds, sendOddsStyle);

  double get totalCost => totalCostWith(displayOdds);

  double totalCostWith(double odds) =>
      bd.betCostFor(stake, odds, sendOddsStyle);

  int get minStakeActual => minStake * 1000;

  int get maxStakeActual => maxStake * 1000;

  bool get isStakeValid => stake >= minStakeActual && stake <= maxStakeActual;

  bool get canPlaceBet =>
      stake > 0 && isStakeValid && !isCalculating && !isDisabled;

  String get cls => bd.SelectionLabels.clsValue(
        marketId: marketData.marketId,
        pick: oddsType,
        points: oddsData.points,
        homeScore: '${eventData.homeScore}',
        awayScore: '${eventData.awayScore}',
      );

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
}
