import 'package:freezed_annotation/freezed_annotation.dart';

part 'bet_statistics_entity.freezed.dart';
part 'bet_statistics_entity.g.dart';

@freezed
sealed class BetStatisticsSimple with _$BetStatisticsSimple {
  const factory BetStatisticsSimple({
    @JsonKey(name: '0') int? eventId,

    @JsonKey(name: '1')
    Map<String, List<BetStatisticsSelection>>? marketStatistics,
  }) = _BetStatisticsSimple;

  factory BetStatisticsSimple.fromJson(Map<String, dynamic> json) =>
      _$BetStatisticsSimpleFromJson(json);
}

@freezed
sealed class BetStatisticsSelection with _$BetStatisticsSelection {
  const factory BetStatisticsSelection({
    @JsonKey(name: '1') int? marketId,

    @JsonKey(name: '2', fromJson: _parsePoints) String? points,

    @JsonKey(name: '3') String? selectionName,

    @JsonKey(name: '4') double? percentage,
  }) = _BetStatisticsSelection;

  factory BetStatisticsSelection.fromJson(Map<String, dynamic> json) =>
      _$BetStatisticsSelectionFromJson(json);
}

String? _parsePoints(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is num) return value.toString();
  return value.toString();
}

@freezed
sealed class BetStatisticsUserDetails with _$BetStatisticsUserDetails {
  const factory BetStatisticsUserDetails({
    @JsonKey(name: '0') @Default([]) List<BetStatisticsUserBetDetail> userBets,

    @JsonKey(name: '1') int? totalCount,

    @JsonKey(name: '2') @Default([]) List<String> marketTypes,
  }) = _BetStatisticsUserDetails;

  factory BetStatisticsUserDetails.fromJson(Map<String, dynamic> json) =>
      _$BetStatisticsUserDetailsFromJson(json);
}

@freezed
sealed class BetStatisticsUserBetDetail with _$BetStatisticsUserBetDetail {
  const factory BetStatisticsUserBetDetail({
    @JsonKey(name: '1') String? userName,

    @JsonKey(name: '2') String? selectionName,

    @JsonKey(name: '3') String? opponentName,

    @JsonKey(name: '4') int? eventId,

    @JsonKey(name: '5') String? leagueName,

    @JsonKey(name: '6') int? leagueId,

    @JsonKey(name: '7') bool? flag,

    @JsonKey(name: '8') String? marketName,

    @JsonKey(name: '9') String? idOrTimestamp,

    @JsonKey(name: '10') String? oddsStyle,

    @JsonKey(name: '11') String? oddsValueString,

    @JsonKey(name: '12') String? score,

    @JsonKey(name: '13') String? selectionId,

    @JsonKey(name: '14') String? selectionName2,

    @JsonKey(name: '15') String? betTimestamp,

    @JsonKey(name: '16') double? oddsValue,

    @JsonKey(name: '17') String? points,

    @JsonKey(name: '18') int? number,

    @JsonKey(name: '19') int? marketId,

    @JsonKey(name: '20') Map<String, String>? oddsValues,

    @JsonKey(name: '21') String? id,

    @JsonKey(name: '22') String? matchTime,
  }) = _BetStatisticsUserBetDetail;

  factory BetStatisticsUserBetDetail.fromJson(Map<String, dynamic> json) =>
      _$BetStatisticsUserBetDetailFromJson(json);
}
