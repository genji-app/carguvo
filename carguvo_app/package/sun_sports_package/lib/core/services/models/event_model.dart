import 'package:freezed_annotation/freezed_annotation.dart';
import 'market_model.dart';

part 'event_model.freezed.dart';
part 'event_model.g.dart';

@freezed
sealed class EventModel with _$EventModel {
  const factory EventModel({
    required int id,
    required String name,
    @JsonKey(name: 'leagueId') required int leagueId,
    @JsonKey(name: 'leagueName') String? leagueName,
    @JsonKey(name: 'startDate') required String startDate,
    @JsonKey(name: 'isLive') @Default(false) bool isLive,
    @JsonKey(name: 'homeTeam') TeamModel? homeTeam,
    @JsonKey(name: 'awayTeam') TeamModel? awayTeam,
    @JsonKey(name: 'score') ScoreModel? score,
    @JsonKey(name: 'minute') int? minute,
    @JsonKey(name: 'markets') @Default([]) List<MarketModel> markets,
    @JsonKey(name: 'featured') @Default(false) bool featured,
    @JsonKey(name: 'popularityScore') double? popularityScore,
  }) = _EventModel;

  factory EventModel.fromJson(Map<String, dynamic> json) =>
      _$EventModelFromJson(json);
}

@freezed
sealed class TeamModel with _$TeamModel {
  const factory TeamModel({
    required int id,
    required String name,
    String? logo,
    String? shortName,
  }) = _TeamModel;

  factory TeamModel.fromJson(Map<String, dynamic> json) =>
      _$TeamModelFromJson(json);
}

@freezed
sealed class ScoreModel with _$ScoreModel {
  const factory ScoreModel({@Default(0) int home, @Default(0) int away}) =
      _ScoreModel;

  factory ScoreModel.fromJson(Map<String, dynamic> json) =>
      _$ScoreModelFromJson(json);
}

@freezed
sealed class EventsResponse with _$EventsResponse {
  const factory EventsResponse({
    @Default([]) List<EventModel> events,
    @Default(0) int total,
  }) = _EventsResponse;

  factory EventsResponse.fromJson(Map<String, dynamic> json) =>
      _$EventsResponseFromJson(json);
}

extension EventModelX on EventModel {
  String get homeTeamName => homeTeam?.name ?? 'Home';

  String get awayTeamName => awayTeam?.name ?? 'Away';

  String get scoreString {
    if (score == null) return '-';
    return '${score!.home} - ${score!.away}';
  }

  String get timeString {
    if (!isLive) return '';
    if (minute == null) return 'LIVE';
    return "$minute'";
  }

  bool get hasStarted {
    final start = DateTime.tryParse(startDate);
    if (start == null) return false;
    return DateTime.now().isAfter(start);
  }

  MarketModel? getMarketByClass(String cls) {
    try {
      return markets.firstWhere((m) => m.cls == cls);
    } catch (e) {
      return null;
    }
  }
}
