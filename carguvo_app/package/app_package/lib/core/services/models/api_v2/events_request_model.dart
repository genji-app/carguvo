import 'package:freezed_annotation/freezed_annotation.dart';

part 'events_request_model.freezed.dart';

@freezed
sealed class EventsRequestModel with _$EventsRequestModel {
  const factory EventsRequestModel({
    required int sportId,

    @Default(0) int timeRange,

    int? sportTypeId,

    int? teamId,

    List<int>? leagueIds,

    String? date,

    @Default(-420) int tzOffset,

    @Default(true) bool isMobile,

    @Default(false) bool sortByTime,

    @Default(false) bool onlyPinLeague,

    @Default(false) bool onlyParlay,

    @Default(false) bool onlyGs,

    @Default(false) bool isLiveStream,

    @Default(false) bool isLiveTracker,

    @Default(false) bool isSportRadar,

    @Default(false) bool isCashOut,
  }) = _EventsRequestModel;

  const EventsRequestModel._();

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{
      'sportId': sportId,
      'timeRange': timeRange,
      'tzOffset': tzOffset,
      'isMobile': isMobile,
    };

    if (sortByTime) params['sortByTime'] = sortByTime;
    if (onlyPinLeague) params['onlyPinLeague'] = onlyPinLeague;
    if (onlyParlay) params['onlyParlay'] = onlyParlay;
    if (onlyGs) params['onlyGs'] = onlyGs;
    if (isLiveStream) params['isLiveStream'] = isLiveStream;
    if (isLiveTracker) params['isLiveTracker'] = isLiveTracker;
    if (isSportRadar) params['isSportRadar'] = isSportRadar;
    if (isCashOut) params['isCashOut'] = isCashOut;

    if (sportTypeId != null) params['sportTypeId'] = sportTypeId;
    if (teamId != null) params['teamId'] = teamId;
    if (leagueIds != null && leagueIds!.isNotEmpty) {
      params['leagueIds'] = leagueIds!.join(',');
    }
    if (date != null) params['date'] = date;

    return params;
  }

  factory EventsRequestModel.live(int sportId, {int? sportTypeId}) =>
      EventsRequestModel(
        sportId: sportId,
        timeRange: 0,
        sportTypeId: sportTypeId,
      );

  factory EventsRequestModel.today(int sportId, {int? sportTypeId}) =>
      EventsRequestModel(
        sportId: sportId,
        timeRange: 1,
        sportTypeId: sportTypeId,
      );

  factory EventsRequestModel.early(int sportId, {int? sportTypeId}) =>
      EventsRequestModel(
        sportId: sportId,
        timeRange: 2,
        sportTypeId: sportTypeId,
      );

  factory EventsRequestModel.all(int sportId, {int? sportTypeId}) =>
      EventsRequestModel(
        sportId: sportId,
        timeRange: 3,
        sportTypeId: sportTypeId,
        sortByTime: true,
      );
}
