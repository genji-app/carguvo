import 'package:betting_domain/betting_domain.dart' as betting_domain;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';
import 'package:sun_sports/shared/widgets/sport/enums/event_status.dart';

part 'league_model.freezed.dart';
part 'league_model.g.dart';

@freezed
sealed class LeagueData with _$LeagueData {
  const factory LeagueData({
    @JsonKey(name: 'li') @Default(0) int leagueId,

    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(1)
    int sportId,

    @JsonKey(name: 'ln') @Default('') String leagueName,

    @JsonKey(name: 'lg') @Default('') String leagueLogo,

    @JsonKey(name: 'lpo') int? priorityOrder,

    @JsonKey(name: 'e') @Default([]) List<LeagueEventData> events,

    @JsonKey(name: 'eo') List<OutrightData>? outrightEvents,
  }) = _LeagueData;

  factory LeagueData.fromJson(Map<String, dynamic> json) =>
      _$LeagueDataFromJson(json);
}

@freezed
sealed class LeagueEventData with _$LeagueEventData {
  const factory LeagueEventData({
    @JsonKey(name: 'ei') @Default(0) int eventId,

    @JsonKey(name: 'en') String? eventName,

    @JsonKey(name: 'hi') @Default(0) int homeId,

    @JsonKey(name: 'hn') @Default('') String homeName,

    @JsonKey(name: 'ai') @Default(0) int awayId,

    @JsonKey(name: 'an') @Default('') String awayName,

    @JsonKey(name: 'hf') String? homeLogoFirst,

    @JsonKey(name: 'hl') String? homeLogoLast,

    @JsonKey(name: 'af') String? awayLogoFirst,

    @JsonKey(name: 'al') String? awayLogoLast,

    @JsonKey(name: 'st', fromJson: _parseStartTime, readValue: _readStartTime)
    @Default(0)
    int startTime,

    @JsonKey(name: 'hs') @Default(0) int homeScore,

    @JsonKey(name: 'as') @Default(0) int awayScore,

    @JsonKey(name: 'l') @Default(false) bool isLive,

    @JsonKey(name: 'gl') @Default(false) bool isGoingLive,

    @JsonKey(name: 'ls') @Default(false) bool isLivestream,

    @JsonKey(name: 's') @Default(false) bool isSuspended,

    @JsonKey(name: 'es') String? eventStatus,

    @JsonKey(name: 'esi') @Default(0) int eventStatsId,

    @JsonKey(name: 'gt') @Default(0) int gameTime,

    @JsonKey(name: 'gp') @Default(0) int gamePart,

    @JsonKey(name: 'stm') @Default(0) int stoppageTime,

    @JsonKey(name: 'hc') @Default(0) int cornersHome,

    @JsonKey(name: 'ac') @Default(0) int cornersAway,

    @JsonKey(name: 'hso') @Default(0) int homeScoreOT,

    @JsonKey(name: 'aso') @Default(0) int awayScoreOT,

    @JsonKey(name: 'rch') @Default(0) int redCardsHome,

    @JsonKey(name: 'rca') @Default(0) int redCardsAway,

    @JsonKey(name: 'ych') @Default(0) int yellowCardsHome,

    @JsonKey(name: 'yca') @Default(0) int yellowCardsAway,

    @JsonKey(name: 'mc') @Default(0) int totalMarketsCount,

    @JsonKey(name: 'ip') @Default(false) bool isParlay,

    @JsonKey(name: 'min') int? minute,

    @JsonKey(name: 'm') @Default([]) List<LeagueMarketData> markets,
  }) = _LeagueEventData;

  factory LeagueEventData.fromJson(Map<String, dynamic> json) =>
      _$LeagueEventDataFromJson(json);
}

Object? _readStartTime(Map<dynamic, dynamic> json, String key) {
  return json['st'] ?? json['et'];
}

int _parseStartTime(dynamic value) {
  if (value == null) return 0;

  if (value is int) return value;

  if (value is num) return value.toInt();

  if (value is String) {
    final asInt = int.tryParse(value);
    if (asInt != null) return asInt;

    final dateTime = DateTime.tryParse(value);
    if (dateTime != null) return dateTime.millisecondsSinceEpoch;
  }

  return 0;
}

@freezed
sealed class LeagueMarketData with _$LeagueMarketData {
  const factory LeagueMarketData({
    @JsonKey(name: 'mi') @Default(0) int marketId,

    @JsonKey(name: 'mn') @Default('') String marketName,

    @JsonKey(name: 'mt') String? marketType,

    @JsonKey(name: 'ip') @Default(false) bool isParlay,

    @JsonKey(name: 'o') @Default([]) List<LeagueOddsData> odds,
  }) = _LeagueMarketData;

  factory LeagueMarketData.fromJson(Map<String, dynamic> json) =>
      _$LeagueMarketDataFromJson(json);
}

@freezed
sealed class LeagueOddsData with _$LeagueOddsData {
  const factory LeagueOddsData({
    @JsonKey(name: 'p') @Default('') String points,

    @JsonKey(name: 'ml') @Default(false) bool isMainLine,

    @JsonKey(name: 'shi') String? selectionHomeId,

    @JsonKey(name: 'sai') String? selectionAwayId,

    @JsonKey(name: 'sdi') String? selectionDrawId,

    @JsonKey(name: 'soi') String? offerId,

    @Default(false) bool isSuspended,

    @JsonKey(
      name: 'oh',
      fromJson: OddsValue.fromJson,
      toJson: OddsValue.toJsonStatic,
    )
    @Default(OddsValue())
    OddsValue oddsHome,

    @JsonKey(
      name: 'oa',
      fromJson: OddsValue.fromJson,
      toJson: OddsValue.toJsonStatic,
    )
    @Default(OddsValue())
    OddsValue oddsAway,

    @JsonKey(
      name: 'od',
      fromJson: OddsValue.fromJson,
      toJson: OddsValue.toJsonStatic,
    )
    @Default(OddsValue())
    OddsValue oddsDraw,

    @JsonKey(name: 'ho') double? homeOddsLegacy,

    @JsonKey(name: 'ao') double? awayOddsLegacy,

    @JsonKey(name: 'do') double? drawOddsLegacy,

    @JsonKey(name: 'oi') String? offerIdLegacy,

    @JsonKey(name: 'si') String? selectionIdLegacy,

    @Default('') String playerName,

    @Default('') String playerId,

    @Default(0) int period,
  }) = _LeagueOddsData;

  factory LeagueOddsData.fromJson(Map<String, dynamic> json) =>
      _$LeagueOddsDataFromJson(json);
}

class OddsValue {
  final double malay;
  final double indo;
  final double decimal;
  final double hongKong;

  const OddsValue({
    this.malay = -100,
    this.indo = -100,
    this.decimal = -100,
    this.hongKong = -100,
  });

  factory OddsValue.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const OddsValue();
    return OddsValue(
      malay: _parseOdds(json['ma']),
      indo: _parseOdds(json['in']),
      decimal: _parseOdds(json['de']),
      hongKong: _parseOdds(json['hk']),
    );
  }

  Map<String, dynamic> toJson() => {
    'ma': malay.toString(),
    'in': indo.toString(),
    'de': decimal.toString(),
    'hk': hongKong.toString(),
  };

  static Map<String, dynamic>? toJsonStatic(OddsValue value) => value.toJson();

  static double _parseOdds(dynamic value) {
    if (value == null) return -100;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? -100;
    return -100;
  }

  double getByStyle(OddsStyle style) {
    switch (style) {
      case OddsStyle.malay:
        return malay;
      case OddsStyle.indo:
        return indo;
      case OddsStyle.decimal:
        return decimal;
      case OddsStyle.hongKong:
        return hongKong;
    }
  }

  bool get isValid => decimal > 0 && decimal != -100;

  String format({int decimals = 2}) {
    if (!isValid) return '-';
    return decimal.toStringAsFixed(decimals);
  }

  @override
  String toString() =>
      'OddsValue(ma: $malay, in: $indo, de: $decimal, hk: $hongKong)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OddsValue &&
          runtimeType == other.runtimeType &&
          malay == other.malay &&
          indo == other.indo &&
          decimal == other.decimal &&
          hongKong == other.hongKong;

  @override
  int get hashCode => Object.hash(malay, indo, decimal, hongKong);
}

@freezed
sealed class OutrightData with _$OutrightData {
  const factory OutrightData({
    @JsonKey(name: 'oi') @Default(0) int outrightId,

    @JsonKey(name: 'on') @Default('') String outrightName,

    @JsonKey(name: 'os') @Default([]) List<OutrightSelection> selections,
  }) = _OutrightData;

  factory OutrightData.fromJson(Map<String, dynamic> json) =>
      _$OutrightDataFromJson(json);
}

@freezed
sealed class OutrightSelection with _$OutrightSelection {
  const factory OutrightSelection({
    @JsonKey(name: 'si') @Default('') String selectionId,

    @JsonKey(name: 'sn') @Default('') String selectionName,

    @JsonKey(name: 'od') @Default(0.0) double odds,

    @JsonKey(name: 'oi') String? offerId,
  }) = _OutrightSelection;

  factory OutrightSelection.fromJson(Map<String, dynamic> json) =>
      _$OutrightSelectionFromJson(json);
}

extension LeagueDataX on LeagueData {
  bool get isOutrightOnly =>
      outrightEvents != null && outrightEvents!.isNotEmpty && events.isEmpty;

  int get totalEvents => events.length;

  List<LeagueEventData> get liveEvents =>
      events.where((e) => e.isLive).toList();

  List<LeagueEventData> get upcomingEvents =>
      events.where((e) => !e.isLive).toList();

  List<LeagueEventData> get eventsSortedByTime =>
      List.from(events)..sort((a, b) => a.startTime.compareTo(b.startTime));
}

extension LeagueEventDataX on LeagueEventData {
  String get fullName => '$homeName vs $awayName';

  String get displayName => eventName ?? fullName;

  String get scoreString => '$homeScore - $awayScore';

  DateTime get startDateTime => DateTime.fromMillisecondsSinceEpoch(startTime);

  String get formattedTime {
    final dt = startDateTime;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year;
    return '$day/$month/$year | $hour:$minute';
  }

  String get formattedDate {
    final dt = startDateTime;
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
  }

  String get formattedDateTime => '$formattedDate $formattedTime';

  bool get hasStarted => DateTime.now().millisecondsSinceEpoch > startTime;

  String get minuteString {
    if (!isLive) return '';

    final minutes = gameTime > 0 ? (gameTime / 1000 / 60).ceil() : 0;
    final stoppageMinutes = stoppageTime > 0
        ? (stoppageTime / 1000 / 60).ceil()
        : 0;

    if (minutes > 0) {
      if (stoppageMinutes > 0) {
        final part = gamePartEnum;
        if (part == GamePart.firstHalf) {
          return "45+$stoppageMinutes'";
        } else if (part == GamePart.secondHalf) {
          return "90+$stoppageMinutes'";
        }
        return "$minutes+$stoppageMinutes'";
      }
      return "$minutes'";
    }

    if (minute != null && minute! > 0) return "$minute'";
    return 'LIVE';
  }

  GamePart get gamePartEnum => GamePart.fromInt(gamePart);

  int get continuousMatchMinute {
    final minutes = gameTime > 0 ? gameTime ~/ 60000 : 0;
    if (minutes <= 0) return 0;
    switch (GamePart.resolveLive(gamePart, gameTimeMinutes: minutes)) {
      case GamePart.secondHalf:
        return 45 + minutes;
      case GamePart.firstHalfExtraTime:
        return 90 + minutes;
      case GamePart.secondHalfExtraTime:
        return 105 + minutes;
      default:
        return minutes;
    }
  }

  String get liveStatusDisplay {
    if (!isLive) return '';
    final min = minuteString;
    final part = gamePartEnum.displayName;
    if (min.isNotEmpty && part != 'Not Started') {
      return '$min | $part';
    }
    return min.isNotEmpty ? min : 'LIVE';
  }

  EventStatus get status => EventStatusX.fromString(eventStatus);

  bool get canBet => !isSuspended && status == EventStatus.active;

  bool get isOvertimePhase => gamePart > GamePart.regulaTimeFinished.value;

  int get displayHomeScore => homeScore + homeScoreOT;

  int get displayAwayScore => awayScore + awayScoreOT;

  String get homeLogo {
    if (homeLogoFirst != null && homeLogoFirst!.isNotEmpty) {
      return homeLogoFirst!;
    }
    if (homeLogoLast != null && homeLogoLast!.isNotEmpty) {
      return homeLogoLast!;
    }
    return '';
  }

  String get awayLogo {
    if (awayLogoFirst != null && awayLogoFirst!.isNotEmpty) {
      return awayLogoFirst!;
    }
    if (awayLogoLast != null && awayLogoLast!.isNotEmpty) {
      return awayLogoLast!;
    }
    return '';
  }

  LeagueMarketData? getMarketById(int marketId) {
    try {
      return markets.firstWhere((m) => m.marketId == marketId);
    } catch (e) {
      return null;
    }
  }

  List<LeagueMarketData> getMainMarkets(int sportId) {
    final mainIds = MarketHelper.getMainMarketIds(sportId);
    return markets.where((m) => mainIds.contains(m.marketId)).toList();
  }

  bool get hasMarkets => markets.isNotEmpty;

  int get totalCardsHome => redCardsHome + yellowCardsHome;
  int get totalCardsAway => redCardsAway + yellowCardsAway;
}

extension LeagueMarketDataX on LeagueMarketData {
  String get displayName =>
      marketName.isNotEmpty ? marketName : MarketHelper.getMarketName(marketId);

  bool get isHandicap => MarketHelper.isHandicap(marketId);
  bool get isOverUnder => MarketHelper.isOverUnder(marketId);
  bool get is1X2 => MarketHelper.is1X2(marketId);
  bool get isMoneyLine => MarketHelper.isMoneyLine(marketId);
  bool get isOddEven => MarketHelper.isOddEven(marketId);
  bool get isCorrectScore => MarketHelper.isCorrectScore(marketId);

  List<OddsType> get oddsTypes => MarketHelper.getOddsTypes(marketId);

  List<LeagueOddsData> get visibleOdds =>
      odds.where((o) => o.points.isNotEmpty || is1X2).toList();

  LeagueOddsData? get mainLineOdds {
    try {
      return odds.firstWhere((o) => o.isMainLine);
    } catch (e) {
      return odds.isNotEmpty ? odds.first : null;
    }
  }
}

extension LeagueOddsDataX on LeagueOddsData {
  double get pointsValue => double.tryParse(points) ?? 0.0;

  double getHomeOdds(OddsStyle style) {
    if (oddsHome.isValid) {
      return oddsHome.getByStyle(style);
    }
    return homeOddsLegacy ?? -100;
  }

  double getAwayOdds(OddsStyle style) {
    if (oddsAway.isValid) {
      return oddsAway.getByStyle(style);
    }
    return awayOddsLegacy ?? -100;
  }

  double? getDrawOdds(OddsStyle style) {
    if (oddsDraw.isValid) {
      return oddsDraw.getByStyle(style);
    }
    return drawOddsLegacy;
  }

  String formattedHomeOdds(OddsStyle style, {int decimals = 2}) {
    final value = getHomeOdds(style);
    if (!_isValidOddsValue(value, style)) return '-';
    return value.toStringAsFixed(decimals);
  }

  String formattedAwayOdds(OddsStyle style, {int decimals = 2}) {
    final value = getAwayOdds(style);
    if (!_isValidOddsValue(value, style)) return '-';
    return value.toStringAsFixed(decimals);
  }

  String? formattedDrawOdds(OddsStyle style, {int decimals = 2}) {
    final value = getDrawOdds(style);
    if (value == null || !_isValidOddsValue(value, style)) return null;
    return value.toStringAsFixed(decimals);
  }

  bool _isValidOddsValue(double value, OddsStyle style) {
    if (value == -100 || value == 0) return false;
    if (style == OddsStyle.decimal && value < 1.0) return false;
    if (style == OddsStyle.hongKong && value <= 0) return false;
    return true;
  }

  bool get hasDrawOdds =>
      oddsDraw.isValid || (drawOddsLegacy != null && drawOddsLegacy! > 0);

  String? get effectiveOfferId => offerId ?? offerIdLegacy;

  String? get effectiveHomeSelectionId => selectionHomeId ?? selectionIdLegacy;

  String? get effectiveAwaySelectionId => selectionAwayId;

  String? get effectiveDrawSelectionId => selectionDrawId;

  bool get isValid => oddsHome.isValid || homeOddsLegacy != null;
}

class MarketHelper {
  MarketHelper._();

  static const footballMainMarkets = [5, 3, 1];

  static const basketballMainMarkets = [200, 201, 202];

  static const tennisMainMarkets = [400, 402, 401];

  static const volleyballMainMarkets = [500, 509, 510];

  static List<int> getMainMarketIds(int sportId) {
    switch (sportId) {
      case 1:
        return footballMainMarkets;
      case 2:
        return basketballMainMarkets;
      case 4:
        return tennisMainMarkets;
      case 5:
        return volleyballMainMarkets;
      default:
        return footballMainMarkets;
    }
  }

  static bool isHandicap(int marketId) =>
      betting_domain.MarketOddsRules.isHandicap(marketId);

  static bool isOverUnder(int marketId) =>
      betting_domain.MarketOddsRules.isOverUnder(marketId);

  static bool is1X2(int marketId) {
    return [
      1, 2, 89,
      23, 24,
      17, 18,
      29, 30,
      50, 51, 52, 53, 54, 55,
      138,
    ].contains(marketId);
  }

  static bool isMoneyLine(int marketId) {
    return [
      200, 205, 206, 207, 208, 209,
      400, 403, 404, 405, 406, 407,
      500, 504, 505, 506, 507, 508,
      700, 704, 705,
    ].contains(marketId);
  }

  static bool isOddEven(int marketId) {
    return [8, 9, 86, 56, 57, 76, 77, 164, 179, 1013, 1015, 1016].contains(marketId);
  }

  static bool isCorrectScore(int marketId) {
    return [10, 11, 1006, 1012].contains(marketId);
  }

  static bool isCornerMarket(int marketId) {
    return [
      17, 18, 19, 20, 21, 22,
      56, 57,
      61, 62, 63, 64,
      66, 67,
      92, 93, 94, 95, 96,
      104, 105, 106, 107, 108, 109, 110, 111,
      112,
      113,
      114,
      115,
      116,
      117,
      118,
      119,
      120,
      121,
      122,
      123,
      124,
      125,
      126,
      127,
      128,
      131, 134, 135, 136,
      137,
      140, 141, 142, 144,
      145,
      197, 198,
      199, 1005,
      90, 91,
    ].contains(marketId);
  }

  static bool isYellowCardMarket(int marketId) {
    return [138, 139, 143].contains(marketId);
  }

  static bool isCardMarket(int marketId) =>
      const [29, 30, 31, 32, 33, 34, 138, 139, 143].contains(marketId);

  static String liveMatchInfoLabel({
    required int marketId,
    required String homeName,
    required String awayName,
    required int homeScore,
    required int awayScore,
    required int cornersHome,
    required int cornersAway,
    required int yellowCardsHome,
    required int yellowCardsAway,
    required int redCardsHome,
    required int redCardsAway,
  }) {
    if (isCornerMarket(marketId)) {
      if (marketId == 61 || marketId == 62 || marketId == 134) {
        return '$homeName: $cornersHome phạt góc';
      }
      if (marketId == 63 || marketId == 64 || marketId == 135) {
        return '$awayName: $cornersAway phạt góc';
      }
      return 'Tổng: ${cornersHome + cornersAway} phạt góc';
    }

    if (isCardMarket(marketId)) {
      final bookings =
          (redCardsHome + redCardsAway) * 2 +
          (yellowCardsHome + yellowCardsAway);
      return 'Tổng: $bookings thẻ phạt';
    }

    return '$homeScore-$awayScore';
  }

  static bool isExtraTime(int marketId) {
    return [23, 24, 25, 26, 27, 28, 1011, 1012, 1019].contains(marketId);
  }

  static List<OddsType> getOddsTypes(int marketId) {
    if (is1X2(marketId) || [12, 13].contains(marketId)) {
      return [OddsType.home, OddsType.draw, OddsType.away];
    }
    if (isCorrectScore(marketId) || [14, 15].contains(marketId)) {
      return [OddsType.home];
    }
    return [OddsType.home, OddsType.away];
  }

  static String getMarketName(int marketId) {
    switch (marketId) {
      case 1:
        return '1X2 FT';
      case 2:
        return '1X2 HT';
      case 3:
        return 'Over/Under FT';
      case 4:
        return 'Over/Under HT';
      case 5:
        return 'Handicap FT';
      case 6:
        return 'Handicap HT';
      case 7:
        return 'Next Goal';
      case 8:
        return 'Odd/Even FT';
      case 10:
        return 'Correct Score';
      case 12:
        return 'Double Chance';
      case 14:
        return 'Total Goals';
      case 16:
        return 'Draw No Bet';
      case 200:
        return 'Money Line FT';
      case 201:
        return 'Handicap FT';
      case 202:
        return 'Over/Under FT';
      case 205:
        return 'Money Line H1';
      case 400:
        return 'Match Winner';
      case 401:
        return 'Over/Under Games';
      case 402:
        return 'Handicap Games';
      case 500:
        return 'Match Winner';
      case 509:
        return 'Handicap Points';
      case 510:
        return 'Over/Under Points';
      default:
        return 'Market #$marketId';
    }
  }

  static String getMarketNameVi(int marketId) {
    switch (marketId) {
      case 1:
        return '1X2';
      case 2:
        return '1X2 H1';
      case 3:
        return 'Tài xỉu';
      case 4:
        return 'Tài xỉu H1';
      case 5:
        return 'Kèo chấp';
      case 6:
        return 'Kèo chấp H1';
      case 7:
        return 'Bàn tiếp theo';
      case 8:
        return 'Lẻ/Chẵn';
      case 9:
        return 'Lẻ/Chẵn H1';
      case 10:
        return 'Tỷ số chính xác';
      case 11:
        return 'Tỷ số chính xác H1';
      case 12:
        return 'Cơ hội kép';
      case 13:
        return 'Cơ hội kép H1';
      case 14:
        return 'Tổng bàn thắng';
      case 15:
        return 'Tổng bàn thắng H1';
      case 16:
        return 'Hòa hoàn tiền';
      case 75:
        return 'Hòa hoàn tiền H1';

      case 17:
        return '1X2 Phạt góc';
      case 18:
        return '1X2 Phạt góc H1';
      case 19:
        return 'Kèo chấp Phạt góc';
      case 20:
        return 'Kèo chấp Phạt góc H1';
      case 21:
        return 'Tài xỉu Phạt góc';
      case 22:
        return 'Tài xỉu Phạt góc H1';
      case 56:
        return 'Lẻ/Chẵn Phạt góc';
      case 57:
        return 'Lẻ/Chẵn Phạt góc H1';
      case 66:
        return 'Phạt góc cuối';
      case 67:
        return 'Phạt góc cuối H1';

      case 23:
        return '1X2 Hiệp phụ';
      case 24:
        return '1X2 Hiệp phụ H1';
      case 25:
        return 'Tài xỉu Hiệp phụ';
      case 26:
        return 'Tài xỉu Hiệp phụ H1';
      case 27:
        return 'Kèo chấp Hiệp phụ';
      case 28:
        return 'Kèo chấp Hiệp phụ H1';

      case 29:
        return '1X2 Thẻ phạt';
      case 30:
        return '1X2 Thẻ phạt H1';
      case 31:
        return 'Tài xỉu Thẻ phạt';
      case 32:
        return 'Tài xỉu Thẻ phạt H1';
      case 33:
        return 'Kèo chấp Thẻ phạt';
      case 34:
        return 'Kèo chấp Thẻ phạt H1';

      case 38:
        return 'Tài xỉu 0-15\'';
      case 39:
        return 'Tài xỉu 15-30\'';
      case 40:
        return 'Tài xỉu 30-45\'';
      case 41:
        return 'Tài xỉu 45-60\'';
      case 42:
        return 'Tài xỉu 60-75\'';
      case 43:
        return 'Tài xỉu 75-90\'';
      case 44:
        return 'Kèo chấp 0-15\'';
      case 45:
        return 'Kèo chấp 15-30\'';
      case 46:
        return 'Kèo chấp 30-45\'';
      case 47:
        return 'Kèo chấp 45-60\'';
      case 48:
        return 'Kèo chấp 60-75\'';
      case 49:
        return 'Kèo chấp 75-90\'';
      case 50:
        return '1X2 0-15\'';
      case 51:
        return '1X2 15-30\'';
      case 52:
        return '1X2 30-45\'';
      case 53:
        return '1X2 45-60\'';
      case 54:
        return '1X2 60-75\'';
      case 55:
        return '1X2 75-90\'';

      case 58:
        return 'Đội đi tiếp';
      case 59:
        return 'Đội giao bóng';
      case 76:
        return 'Lẻ/Chẵn Đội nhà';
      case 77:
        return 'Lẻ/Chẵn Đội khách';
      case 80:
        return 'Tài xỉu Hiệp 2';
      case 83:
        return 'Giữ sạch lưới Đội nhà';
      case 84:
        return 'Giữ sạch lưới Đội khách';
      case 85:
        return 'Kèo chấp Hiệp 2';
      case 86:
        return 'Lẻ/Chẵn Hiệp 2';
      case 89:
        return '1X2 Hiệp 2';
      case 97:
        return 'Bàn cuối cùng';
      case 101:
        return 'Tài xỉu Đội nhà';
      case 102:
        return 'Tài xỉu Đội khách';
      case 103:
        return 'Đội ghi bàn';
      case 129:
        return 'Thắng Penalty';
      case 130:
        return 'Tài xỉu Penalty';

      case 200:
        return 'Thắng/Thua';
      case 201:
        return 'Kèo chấp';
      case 202:
        return 'Tài xỉu';
      case 203:
        return 'Kèo chấp H1';
      case 204:
        return 'Tài xỉu H1';
      case 205:
        return 'Thắng/Thua H1';

      case 400:
        return 'Thắng trận';
      case 401:
        return 'Tài xỉu Game';
      case 402:
        return 'Kèo chấp Game';

      case 500:
        return 'Thắng trận';
      case 509:
        return 'Kèo chấp Điểm';
      case 510:
        return 'Tài xỉu Điểm';

      case 137:
        return 'Phạt góc tiếp theo';
      case 138:
        return '1X2 Thẻ vàng';
      case 139:
        return 'Tài xỉu Thẻ vàng';
      case 140:
        return 'Phạt góc H1 T/CX/X';
      case 141:
        return 'Phạt góc HP T/CX/X';
      case 142:
        return 'Tài xỉu Phạt góc HP';
      case 143:
        return 'Cơ hội kép Thẻ vàng';
      case 144:
        return 'Chấp Phạt góc Châu Âu';
      case 145:
        return 'Phạt góc T/CX/X';
      case 152:
        return 'Chấp Châu Âu';
      case 195:
        return 'Chấp Châu Âu H1';

      case 61:
        return 'Tài xỉu PG Đội nhà';
      case 62:
        return 'Tài xỉu PG Đội nhà H1';
      case 63:
        return 'Tài xỉu PG Đội khách';
      case 64:
        return 'Tài xỉu PG Đội khách H1';

      case 131:
        return 'Tổng phạt góc';
      case 134:
        return 'Tổng PG Đội nhà';
      case 135:
        return 'Tổng PG Đội khách';
      case 136:
        return 'Tổng phạt góc H1';

      case 92:
        return 'PG Tài xỉu 0-15\'';
      case 93:
        return 'PG Tài xỉu 15-30\'';
      case 94:
        return 'PG Tài xỉu 30-45\'';
      case 95:
        return 'PG Tài xỉu 45-60\'';
      case 96:
        return 'PG Tài xỉu 60-75\'';

      default:
        final englishName = getMarketName(marketId);
        return _convertToVietnamese(englishName);
    }
  }

  static String _convertToVietnamese(String name) {
    return name
        .replaceAll(RegExp(r'Over/Under', caseSensitive: false), 'Tài xỉu')
        .replaceAll(RegExp(r'Handicap', caseSensitive: false), 'Kèo chấp')
        .replaceAll(RegExp(r'Odd/Even', caseSensitive: false), 'Lẻ/Chẵn')
        .replaceAll(
          RegExp(r'Correct Score', caseSensitive: false),
          'Tỷ số chính xác',
        )
        .replaceAll(
          RegExp(r'Double Chance', caseSensitive: false),
          'Cơ hội kép',
        )
        .replaceAll(
          RegExp(r'Draw No Bet', caseSensitive: false),
          'Hòa hoàn tiền',
        )
        .replaceAll(
          RegExp(r'Total Goals', caseSensitive: false),
          'Tổng bàn thắng',
        )
        .replaceAll(RegExp(r'Next Goal', caseSensitive: false), 'Bàn tiếp theo')
        .replaceAll(RegExp(r'Last Goal', caseSensitive: false), 'Bàn cuối cùng')
        .replaceAll(RegExp(r'Corner', caseSensitive: false), 'Phạt góc')
        .replaceAll(RegExp(r'Booking', caseSensitive: false), 'Thẻ phạt')
        .replaceAll(RegExp(r'Money Line', caseSensitive: false), 'Thắng/Thua')
        .replaceAll(RegExp(r'Match Winner', caseSensitive: false), 'Thắng trận')
        .replaceAll(
          RegExp(r'Clean Sheet', caseSensitive: false),
          'Giữ sạch lưới',
        )
        .replaceAll(RegExp(r'\bFT\b'), '')
        .replaceAll(RegExp(r'\bHT\b'), 'H1')
        .trim();
  }

  static String getMarketNameViDisplay(int marketId) {
    final mapped = betting_domain.marketDisplayNames[marketId];
    if (mapped != null) {
      return mapped;
    }

    final period = _getPeriodName(marketId);
    final marketType = _getBaseMarketTypeVi(marketId);

    if (period.isEmpty) {
      return marketType;
    }
    return '$period - $marketType';
  }

  static String resolveTeamNamesInMarketName(
    String name, {
    String? homeName,
    String? awayName,
  }) {
    var result = name;
    if (homeName != null && homeName.isNotEmpty) {
      result = result
          .replaceAll('Đội nhà', homeName)
          .replaceAll('đội nhà', homeName);
    }
    if (awayName != null && awayName.isNotEmpty) {
      result = result
          .replaceAll('Đội khách', awayName)
          .replaceAll('đội khách', awayName);
    }
    return result;
  }

  static String _getPeriodName(int marketId) {
    const firstHalfMarkets = [
      2,
      4,
      6,
      9,
      11,
      13,
      15,
      18,
      20,
      22,
      24,
      26,
      28,
      30,
      32,
      34,
      57,
      67,
      75,
      203,
      204,
      205,
    ];
    if (firstHalfMarkets.contains(marketId)) {
      return 'Hiệp 1';
    }

    const secondHalfMarkets = [80, 85, 86, 89];
    if (secondHalfMarkets.contains(marketId)) {
      return 'Hiệp 2';
    }

    const extraTimeMarkets = [23, 25, 27];
    if (extraTimeMarkets.contains(marketId)) {
      return 'Hiệp phụ';
    }

    const extraTimeH1Markets = [24, 26, 28];
    if (extraTimeH1Markets.contains(marketId)) {
      return 'Hiệp phụ H1';
    }

    const timeRangeMarkets = [
      38,
      39,
      40,
      41,
      42,
      43,
      44,
      45,
      46,
      47,
      48,
      49,
      50,
      51,
      52,
      53,
      54,
      55,
    ];
    if (timeRangeMarkets.contains(marketId)) {
      return '';
    }

    const cornerMarkets = [17, 19, 21, 56, 66];
    if (cornerMarkets.contains(marketId)) {
      return 'Toàn trận';
    }

    const bookingMarkets = [29, 31, 33];
    if (bookingMarkets.contains(marketId)) {
      return 'Toàn trận';
    }

    const fullTimeMarkets = [
      1,
      3,
      5,
      7,
      8,
      10,
      12,
      14,
      16,
      58,
      59,
      76,
      77,
      83,
      84,
      97,
      101,
      102,
      103,
      129,
      130,
      200,
      201,
      202,
      400,
      401,
      402,
      500,
      509,
      510,
    ];
    if (fullTimeMarkets.contains(marketId)) {
      return 'Toàn trận';
    }

    return 'Toàn trận';
  }

  static String _getBaseMarketTypeVi(int marketId) {
    switch (marketId) {
      case 1:
      case 2:
      case 89:
        return '1X2';

      case 3:
      case 4:
      case 80:
      case 38:
      case 39:
      case 40:
      case 41:
      case 42:
      case 43:
        return 'Tài xỉu';

      case 5:
      case 6:
      case 85:
      case 44:
      case 45:
      case 46:
      case 47:
      case 48:
      case 49:
        return 'Kèo chấp';

      case 8:
      case 9:
      case 86:
      case 76:
      case 77:
        return 'Lẻ/Chẵn';

      case 7:
        return 'Bàn tiếp theo';

      case 10:
      case 11:
        return 'Tỷ số chính xác';

      case 12:
      case 13:
        return 'Cơ hội kép';

      case 14:
      case 15:
        return 'Tổng bàn thắng';

      case 16:
      case 75:
        return 'Hòa hoàn tiền';

      case 17:
      case 18:
        return '1X2 Phạt góc';
      case 19:
      case 20:
        return 'Kèo chấp Phạt góc';
      case 21:
      case 22:
        return 'Tài xỉu Phạt góc';
      case 56:
      case 57:
        return 'Lẻ/Chẵn Phạt góc';
      case 66:
      case 67:
        return 'Phạt góc cuối';

      case 23:
      case 24:
        return '1X2';
      case 25:
      case 26:
        return 'Tài xỉu';
      case 27:
      case 28:
        return 'Kèo chấp';

      case 29:
      case 30:
        return '1X2 Thẻ phạt';
      case 31:
      case 32:
        return 'Tài xỉu Thẻ phạt';
      case 33:
      case 34:
        return 'Kèo chấp Thẻ phạt';

      case 50:
      case 51:
      case 52:
      case 53:
      case 54:
      case 55:
        return '1X2';

      case 58:
        return 'Đội đi tiếp';
      case 59:
        return 'Đội giao bóng';
      case 83:
        return 'Giữ sạch lưới Đội nhà';
      case 84:
        return 'Giữ sạch lưới Đội khách';
      case 97:
        return 'Bàn cuối cùng';
      case 101:
        return 'Tài xỉu Đội nhà';
      case 102:
        return 'Tài xỉu Đội khách';
      case 103:
        return 'Đội ghi bàn';
      case 129:
        return 'Thắng Penalty';
      case 130:
        return 'Tài xỉu Penalty';

      case 200:
      case 205:
        return 'Thắng/Thua';
      case 201:
      case 203:
        return 'Kèo chấp';
      case 202:
      case 204:
        return 'Tài xỉu';

      case 400:
        return 'Thắng trận';
      case 401:
        return 'Tài xỉu Game';
      case 402:
        return 'Kèo chấp Game';

      case 500:
        return 'Thắng trận';
      case 509:
        return 'Kèo chấp Điểm';
      case 510:
        return 'Tài xỉu Điểm';

      default:
        return getMarketNameVi(marketId);
    }
  }
}

class OddsDisplay {
  OddsDisplay._();

  static String format(double odds, {int decimals = 2}) {
    if (odds == -100 || odds <= 0) return '-';
    return odds.toStringAsFixed(decimals);
  }

  static String getStyleName(OddsStyle style) => style.shortName;

  static bool isPositive(double odds) => odds > 0 && odds != -100;

  static bool isNegative(double odds) => odds < 0 && odds != -100;
}

class PointsFormatter {
  PointsFormatter._();

  static String format(dynamic pointsValue) {
    if (pointsValue == null || pointsValue.toString().isEmpty) {
      return '';
    }

    final value = double.tryParse(pointsValue.toString()) ?? 0;
    if (value == 0) return '0';

    final absValue = value.abs();
    final decimal = absValue % 1;

    if (_isQuarterBall(decimal)) {
      final low = absValue - 0.25;
      final high = absValue + 0.25;
      return '${_formatNumber(low)}/${_formatNumber(high)}';
    }

    return '${_formatNumber(absValue)}';
  }

  static String formatSigned(dynamic pointsValue) {
    if (pointsValue == null || pointsValue.toString().isEmpty) {
      return '';
    }
    final value = double.tryParse(pointsValue.toString()) ?? 0;
    if (value == 0) return '0';
    final sign = value < 0 ? '-' : '+';
    return '$sign${format(value.abs())}';
  }

  static bool _isQuarterBall(double decimal) {
    const tolerance = 0.001;
    return (decimal - 0.25).abs() < tolerance ||
        (decimal - 0.75).abs() < tolerance;
  }

  static bool isQuarterBall(dynamic pointsValue) {
    if (pointsValue == null || pointsValue.toString().isEmpty) {
      return false;
    }
    final value = double.tryParse(pointsValue.toString()) ?? 0;
    final decimal = value.abs() % 1;
    return _isQuarterBall(decimal);
  }

  static String _formatNumber(double num) {
    if (num == num.toInt()) {
      return num.toInt().toString();
    }
    final str = num.toString();
    if (str.contains('.')) {
      return str.replaceAll(RegExp(r'\.?0+$'), '');
    }
    return str;
  }
}
