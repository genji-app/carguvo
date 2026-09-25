import 'package:freezed_annotation/freezed_annotation.dart';

part 'score_model_v2.freezed.dart';

sealed class ScoreModelV2 {
  int get sportId;
  String get homeScore;
  String get awayScore;

  static ScoreModelV2? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;

    final sportId = _parseInt(json['0']);

    switch (sportId) {
      case 1:
        return SoccerScoreModelV2.fromJson(json);
      case 2:
        return BasketballScoreModelV2.fromJson(json);
      case 4:
        return TennisScoreModelV2.fromJson(json);
      case 5:
        return VolleyballScoreModelV2.fromJson(json);
      case 6:
        return TableTennisScoreModelV2.fromJson(json);
      case 7:
        return BadmintonScoreModelV2.fromJson(json);
      default:
        return GenericScoreModelV2.fromJson(json);
    }
  }
}

@freezed
sealed class SoccerScoreModelV2
    with _$SoccerScoreModelV2
    implements ScoreModelV2 {
  const factory SoccerScoreModelV2({
    @Default(1) int sportId,

    @Default(0) int homeScoreFT,

    @Default(0) int awayScoreFT,

    @Default(0) int homeScoreH2,

    @Default(0) int awayScoreH2,

    @Default(0) int homeCorner,

    @Default(0) int awayCorner,

    @Default(0) int homeScoreOT,

    @Default(0) int awayScoreOT,

    @Default(0) int homeScorePen,

    @Default(0) int awayScorePen,

    @Default(0) int yellowCardsHome,

    @Default(0) int yellowCardsAway,

    @Default(0) int redCardsHome,

    @Default(0) int redCardsAway,
  }) = _SoccerScoreModelV2;

  const SoccerScoreModelV2._();

  factory SoccerScoreModelV2.fromJson(Map<String, dynamic> json) {
    return SoccerScoreModelV2(
      sportId: _parseInt(json['0']),
      homeScoreFT: _parseInt(json['100']),
      awayScoreFT: _parseInt(json['101']),
      homeScoreH2: _parseInt(json['102']),
      awayScoreH2: _parseInt(json['103']),
      homeCorner: _parseInt(json['104']),
      awayCorner: _parseInt(json['105']),
      homeScoreOT: _parseInt(json['106']),
      awayScoreOT: _parseInt(json['107']),
      homeScorePen: _parseInt(json['108']),
      awayScorePen: _parseInt(json['109']),
      yellowCardsHome: _parseInt(json['110']),
      yellowCardsAway: _parseInt(json['111']),
      redCardsHome: _parseInt(json['112']),
      redCardsAway: _parseInt(json['113']),
    );
  }

  @override
  String get homeScore => homeScoreFT.toString();

  @override
  String get awayScore => awayScoreFT.toString();

  int get homeScoreH1 => homeScoreFT - homeScoreH2;

  int get awayScoreH1 => awayScoreFT - awayScoreH2;

  int get totalCorners => homeCorner + awayCorner;

  int get totalGoals => homeScoreFT + awayScoreFT;

  bool get hasOvertime => homeScoreOT > 0 || awayScoreOT > 0;

  bool get hasPenalty => homeScorePen > 0 || awayScorePen > 0;

  String get displayScore => '$homeScoreFT - $awayScoreFT';

  String get firstHalfScore => '$homeScoreH1 - $awayScoreH1';

  String get cornerScore => '$homeCorner - $awayCorner';

  int get totalYellowCards => yellowCardsHome + yellowCardsAway;

  int get totalRedCards => redCardsHome + redCardsAway;
}

@freezed
sealed class BasketballScoreModelV2
    with _$BasketballScoreModelV2
    implements ScoreModelV2 {
  const factory BasketballScoreModelV2({
    @Default(2) int sportId,

    @Default([]) List<HomeAwayScoreV2> liveScores,

    @Default(0) int homeScoreFT,

    @Default(0) int awayScoreFT,

    @Default(0) int homeScoreOT,

    @Default(0) int awayScoreOT,
  }) = _BasketballScoreModelV2;

  const BasketballScoreModelV2._();

  factory BasketballScoreModelV2.fromJson(Map<String, dynamic> json) {
    final liveScores = <HomeAwayScoreV2>[];
    final rawScores = json['200'];
    if (rawScores is List) {
      for (final item in rawScores) {
        if (item is Map) {
          liveScores.add(
            HomeAwayScoreV2.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return BasketballScoreModelV2(
      sportId: _parseInt(json['0']),
      liveScores: liveScores,
      homeScoreFT: _parseInt(json['201']),
      awayScoreFT: _parseInt(json['202']),
      homeScoreOT: _parseInt(json['203']),
      awayScoreOT: _parseInt(json['204']),
    );
  }

  @override
  String get homeScore => homeScoreFT.toString();

  @override
  String get awayScore => awayScoreFT.toString();

  int get currentQuarter => liveScores.length;

  bool get isOvertime => homeScoreOT > 0 || awayScoreOT > 0;

  String get displayScore => '$homeScoreFT - $awayScoreFT';
}

@freezed
sealed class TennisScoreModelV2
    with _$TennisScoreModelV2
    implements ScoreModelV2 {
  const factory TennisScoreModelV2({
    @Default(4) int sportId,

    @Default([]) List<HomeAwayScoreV2> liveScores,

    @Default(0) int homeSetScore,
    @Default(0) int awaySetScore,

    String? homeCurrentPoint,
    String? awayCurrentPoint,

    String? servingSide,

    @Default(0) int currentSet,

  }) = _TennisScoreModelV2;

  const TennisScoreModelV2._();

  factory TennisScoreModelV2.fromJson(Map<String, dynamic> json) {
    final rawList = json['400'] as List? ?? [];
    final liveScores = rawList
        .whereType<Map<String, dynamic>>()
        .map((e) => HomeAwayScoreV2.fromJson(e))
        .toList();

    return TennisScoreModelV2(
      sportId: _parseInt(json['0']),
      liveScores: liveScores,
      homeSetScore: _parseInt(json['401']),
      awaySetScore: _parseInt(json['402']),
      homeCurrentPoint: json['405']?.toString(),
      awayCurrentPoint: json['406']?.toString(),
      servingSide: json['407']?.toString(),
      currentSet: _parseInt(json['408']),
    );
  }

  @override
  String get homeScore => homeSetScore.toString();

  @override
  String get awayScore => awaySetScore.toString();

  bool? get isHomeServing => switch (servingSide) {
    '1' => true,
    '2' => false,
    _ => null,
  };

  (String, String)? get currentPointDisplay {
    final h = homeCurrentPoint;
    final a = awayCurrentPoint;
    if (h == null || a == null) return null;
    return (h, a);
  }
}

@freezed
sealed class VolleyballScoreModelV2
    with _$VolleyballScoreModelV2
    implements ScoreModelV2 {
  const factory VolleyballScoreModelV2({
    @Default(5) int sportId,

    @Default([]) List<HomeAwayScoreV2> liveScores,

    @Default(0) int homeSetScore,

    @Default(0) int awaySetScore,

    @Default(0) int homeTotalPoint,

    @Default(0) int awayTotalPoint,

    @Default('') String servingSide,

    @Default(0) int currentSet,

    @Default('') String numOfSets,
  }) = _VolleyballScoreModelV2;

  const VolleyballScoreModelV2._();

  factory VolleyballScoreModelV2.fromJson(Map<String, dynamic> json) {
    final liveScores = <HomeAwayScoreV2>[];
    final rawScores = json['500'];
    if (rawScores is List) {
      for (final item in rawScores) {
        if (item is Map) {
          liveScores.add(
            HomeAwayScoreV2.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return VolleyballScoreModelV2(
      sportId: _parseInt(json['0']),
      liveScores: liveScores,
      homeSetScore: _parseInt(json['501']),
      awaySetScore: _parseInt(json['502']),
      homeTotalPoint: _parseInt(json['503']),
      awayTotalPoint: _parseInt(json['504']),
      servingSide: json['505']?.toString() ?? '',
      currentSet: _parseInt(json['506']),
      numOfSets: json['507']?.toString() ?? '',
    );
  }

  @override
  String get homeScore => homeSetScore.toString();

  @override
  String get awayScore => awaySetScore.toString();

  String get displayScore => '$homeSetScore - $awaySetScore';
}

@freezed
sealed class BadmintonScoreModelV2
    with _$BadmintonScoreModelV2
    implements ScoreModelV2 {
  const factory BadmintonScoreModelV2({
    @Default(7) int sportId,

    @Default([]) List<HomeAwayScoreV2> liveScores,

    @Default(0) int homeGameScore,
    @Default(0) int awayGameScore,

    @Default(0) int homeTotalPoint,
    @Default(0) int awayTotalPoint,

    String? servingSide,

    @Default(0) int currentSet,

    @Default('3') String numOfSets,
  }) = _BadmintonScoreModelV2;

  const BadmintonScoreModelV2._();

  factory BadmintonScoreModelV2.fromJson(Map<String, dynamic> json) {
    final rawList = json['700'] as List? ?? [];
    final liveScores = rawList
        .whereType<Map<String, dynamic>>()
        .map((e) => HomeAwayScoreV2.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return BadmintonScoreModelV2(
      sportId: _parseInt(json['0']),
      liveScores: liveScores,
      homeGameScore: _parseInt(json['701']),
      awayGameScore: _parseInt(json['702']),
      homeTotalPoint: _parseInt(json['703']),
      awayTotalPoint: _parseInt(json['704']),
      servingSide: json['705']?.toString(),
      currentSet: _parseInt(json['706']),
      numOfSets: json['707']?.toString() ?? '3',
    );
  }

  @override
  String get homeScore => homeGameScore.toString();

  @override
  String get awayScore => awayGameScore.toString();
}

@freezed
sealed class TableTennisScoreModelV2
    with _$TableTennisScoreModelV2
    implements ScoreModelV2 {
  const factory TableTennisScoreModelV2({
    @Default(6) int sportId,

    @Default([]) List<HomeAwayScoreV2> liveScores,

    @Default(0) int homeSetScore,
    @Default(0) int awaySetScore,

    @Default(0) int homeTotalPoint,
    @Default(0) int awayTotalPoint,

    String? servingSide,

    @Default(0) int currentSet,

    @Default('7') String numOfSets,
  }) = _TableTennisScoreModelV2;

  const TableTennisScoreModelV2._();

  factory TableTennisScoreModelV2.fromJson(Map<String, dynamic> json) {
    final rawList = json['600'] as List? ?? [];
    final liveScores = rawList
        .whereType<Map<String, dynamic>>()
        .map((e) => HomeAwayScoreV2.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return TableTennisScoreModelV2(
      sportId: _parseInt(json['0']),
      liveScores: liveScores,
      homeSetScore: _parseInt(json['601']),
      awaySetScore: _parseInt(json['602']),
      homeTotalPoint: _parseInt(json['603']),
      awayTotalPoint: _parseInt(json['604']),
      servingSide: json['605']?.toString(),
      currentSet: _parseInt(json['606']),
      numOfSets: json['607']?.toString() ?? '7',
    );
  }

  @override
  String get homeScore => homeSetScore.toString();

  @override
  String get awayScore => awaySetScore.toString();
}

@freezed
sealed class GenericScoreModelV2
    with _$GenericScoreModelV2
    implements ScoreModelV2 {
  const factory GenericScoreModelV2({
    @Default(0) int sportId,
    @Default('0') String homeScoreValue,
    @Default('0') String awayScoreValue,
  }) = _GenericScoreModelV2;

  const GenericScoreModelV2._();

  factory GenericScoreModelV2.fromJson(Map<String, dynamic> json) {
    return GenericScoreModelV2(
      sportId: _parseInt(json['0']),
      homeScoreValue: json['100']?.toString() ?? '0',
      awayScoreValue: json['101']?.toString() ?? '0',
    );
  }

  @override
  String get homeScore => homeScoreValue;

  @override
  String get awayScore => awayScoreValue;
}

@freezed
sealed class HomeAwayScoreV2 with _$HomeAwayScoreV2 {
  const factory HomeAwayScoreV2({
    @Default('') String homeScore,
    @Default('') String awayScore,
  }) = _HomeAwayScoreV2;

  const HomeAwayScoreV2._();

  factory HomeAwayScoreV2.fromJson(Map<String, dynamic> json) {
    return HomeAwayScoreV2(
      homeScore: json['0']?.toString() ?? '',
      awayScore: json['1']?.toString() ?? '',
    );
  }

  int get homeScoreInt => int.tryParse(homeScore) ?? 0;
  int get awayScoreInt => int.tryParse(awayScore) ?? 0;
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  if (value is num) return value.toInt();
  return 0;
}

extension HintLiveScoreV2 on ScoreModelV2 {
  (int home, int away) hintScore(int marketId) {
    final self = this;

    if (self is TennisScoreModelV2) {
      if (marketId == 401 || marketId == 402) {
        return (
          self.liveScores.fold(0, (t, e) => t + e.homeScoreInt),
          self.liveScores.fold(0, (t, e) => t + e.awayScoreInt),
        );
      }
      return (self.homeSetScore, self.awaySetScore);
    }

    if (self is BasketballScoreModelV2) {
      final quarter = _basketballQuarterIndex(marketId);
      if (quarter != null && quarter < self.liveScores.length) {
        return (
          self.liveScores[quarter].homeScoreInt,
          self.liveScores[quarter].awayScoreInt,
        );
      }
      return (self.homeScoreFT, self.awayScoreFT);
    }

    if (self is VolleyballScoreModelV2) {
      if (marketId == 509 || marketId == 510) {
        return (self.homeTotalPoint, self.awayTotalPoint);
      }
      return (self.homeSetScore, self.awaySetScore);
    }

    if (self is BadmintonScoreModelV2) {
      if (marketId == 709 || marketId == 710) {
        return (self.homeTotalPoint, self.awayTotalPoint);
      }
      if (const [701, 702, 711, 712].contains(marketId)) {
        final index = self.currentSet - 1;
        if (index >= 0 && index < self.liveScores.length) {
          return (
            self.liveScores[index].homeScoreInt,
            self.liveScores[index].awayScoreInt,
          );
        }
      }
      return (self.homeGameScore, self.awayGameScore);
    }

    if (self is SoccerScoreModelV2) {
      return (self.homeScoreFT, self.awayScoreFT);
    }

    return (int.tryParse(homeScore) ?? 0, int.tryParse(awayScore) ?? 0);
  }
}

int? _basketballQuarterIndex(int marketId) {
  if (marketId >= 210 && marketId <= 213) return marketId - 210;
  if (marketId >= 214 && marketId <= 217) return marketId - 214;
  return null;
}
