import 'package:freezed_annotation/freezed_annotation.dart';

part 'market_model.freezed.dart';
part 'market_model.g.dart';

@freezed
sealed class MarketModel with _$MarketModel {
  const factory MarketModel({
    required String id,
    required String name,
    @JsonKey(name: 'cls') required String cls,
    @Default([]) List<SelectionModel> odds,
    @Default(true) bool isActive,
    String? description,
  }) = _MarketModel;

  factory MarketModel.fromJson(Map<String, dynamic> json) =>
      _$MarketModelFromJson(json);
}

@freezed
sealed class SelectionModel with _$SelectionModel {
  const factory SelectionModel({
    @JsonKey(name: 'selectionId') required String selectionId,
    required String name,
    @JsonKey(name: 'displayOdds') required String displayOdds,
    @JsonKey(name: 'offerId') required String offerId,
    @JsonKey(name: 'trueOdds') double? trueOdds,
    @Default(true) bool isActive,
    @JsonKey(name: 'handicap') double? handicap,
    @JsonKey(name: 'line') double? line,
  }) = _SelectionModel;

  factory SelectionModel.fromJson(Map<String, dynamic> json) =>
      _$SelectionModelFromJson(json);
}

abstract class MarketClasses {
  static const String matchWinner = '1x2';
  static const String asianHandicap = 'asian_handicap';
  static const String overUnder = 'over_under';
  static const String bothTeamsToScore = 'both_teams_to_score';
  static const String correctScore = 'correct_score';
  static const String doubleChance = 'double_chance';
  static const String drawNoBet = 'draw_no_bet';
  static const String halfTimeFullTime = 'half_time_full_time';
  static const String firstHalf = 'first_half';
  static const String secondHalf = 'second_half';
}

extension SelectionModelX on SelectionModel {
  double get oddsValue {
    return double.tryParse(displayOdds) ?? 0.0;
  }

  double calculateWinnings(double stake) {
    return stake * oddsValue;
  }

  String get formattedOdds {
    final value = oddsValue;
    if (value == 0) return '-';
    return value.toStringAsFixed(2);
  }
}

extension MarketModelX on MarketModel {
  SelectionModel? get homeSelection {
    try {
      return odds.firstWhere(
        (o) => o.selectionId == '1' || o.name.toLowerCase().contains('home'),
      );
    } catch (e) {
      return odds.isNotEmpty ? odds.first : null;
    }
  }

  SelectionModel? get drawSelection {
    try {
      return odds.firstWhere(
        (o) => o.selectionId == 'X' || o.name.toLowerCase().contains('draw'),
      );
    } catch (e) {
      return null;
    }
  }

  SelectionModel? get awaySelection {
    try {
      return odds.firstWhere(
        (o) => o.selectionId == '2' || o.name.toLowerCase().contains('away'),
      );
    } catch (e) {
      return odds.length > 1 ? odds.last : null;
    }
  }

  bool get isAsianHandicap => cls == MarketClasses.asianHandicap;

  bool get isOverUnder => cls == MarketClasses.overUnder;

  bool get isMatchWinner => cls == MarketClasses.matchWinner;
}
