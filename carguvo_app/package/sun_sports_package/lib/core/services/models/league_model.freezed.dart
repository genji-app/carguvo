// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'league_model.dart';

// dart format off
T _$identity<T>(T value) => value;

mixin _$LeagueData {

@JsonKey(name: 'li') int get leagueId;
@JsonKey(includeFromJson: false, includeToJson: false) int get sportId;
@JsonKey(name: 'ln') String get leagueName;
@JsonKey(name: 'lg') String get leagueLogo;
@JsonKey(name: 'lpo') int? get priorityOrder;
@JsonKey(name: 'e') List<LeagueEventData> get events;
@JsonKey(name: 'eo') List<OutrightData>? get outrightEvents;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeagueDataCopyWith<LeagueData> get copyWith => _$LeagueDataCopyWithImpl<LeagueData>(this as LeagueData, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeagueData&&(identical(other.leagueId, leagueId) || other.leagueId == leagueId)&&(identical(other.sportId, sportId) || other.sportId == sportId)&&(identical(other.leagueName, leagueName) || other.leagueName == leagueName)&&(identical(other.leagueLogo, leagueLogo) || other.leagueLogo == leagueLogo)&&(identical(other.priorityOrder, priorityOrder) || other.priorityOrder == priorityOrder)&&const DeepCollectionEquality().equals(other.events, events)&&const DeepCollectionEquality().equals(other.outrightEvents, outrightEvents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,leagueId,sportId,leagueName,leagueLogo,priorityOrder,const DeepCollectionEquality().hash(events),const DeepCollectionEquality().hash(outrightEvents));

@override
String toString() {
  return 'LeagueData(leagueId: $leagueId, sportId: $sportId, leagueName: $leagueName, leagueLogo: $leagueLogo, priorityOrder: $priorityOrder, events: $events, outrightEvents: $outrightEvents)';
}

}

abstract mixin class $LeagueDataCopyWith<$Res>  {
  factory $LeagueDataCopyWith(LeagueData value, $Res Function(LeagueData) _then) = _$LeagueDataCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'li') int leagueId,@JsonKey(includeFromJson: false, includeToJson: false) int sportId,@JsonKey(name: 'ln') String leagueName,@JsonKey(name: 'lg') String leagueLogo,@JsonKey(name: 'lpo') int? priorityOrder,@JsonKey(name: 'e') List<LeagueEventData> events,@JsonKey(name: 'eo') List<OutrightData>? outrightEvents
});

}
class _$LeagueDataCopyWithImpl<$Res>
    implements $LeagueDataCopyWith<$Res> {
  _$LeagueDataCopyWithImpl(this._self, this._then);

  final LeagueData _self;
  final $Res Function(LeagueData) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? leagueId = null,Object? sportId = null,Object? leagueName = null,Object? leagueLogo = null,Object? priorityOrder = freezed,Object? events = null,Object? outrightEvents = freezed,}) {
  return _then(_self.copyWith(
leagueId: null == leagueId ? _self.leagueId : leagueId // ignore: cast_nullable_to_non_nullable
as int,sportId: null == sportId ? _self.sportId : sportId // ignore: cast_nullable_to_non_nullable
as int,leagueName: null == leagueName ? _self.leagueName : leagueName // ignore: cast_nullable_to_non_nullable
as String,leagueLogo: null == leagueLogo ? _self.leagueLogo : leagueLogo // ignore: cast_nullable_to_non_nullable
as String,priorityOrder: freezed == priorityOrder ? _self.priorityOrder : priorityOrder // ignore: cast_nullable_to_non_nullable
as int?,events: null == events ? _self.events : events // ignore: cast_nullable_to_non_nullable
as List<LeagueEventData>,outrightEvents: freezed == outrightEvents ? _self.outrightEvents : outrightEvents // ignore: cast_nullable_to_non_nullable
as List<OutrightData>?,
  ));
}

}

extension LeagueDataPatterns on LeagueData {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeagueData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeagueData() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeagueData value)  $default,){
final _that = this;
switch (_that) {
case _LeagueData():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeagueData value)?  $default,){
final _that = this;
switch (_that) {
case _LeagueData() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'li')  int leagueId, @JsonKey(includeFromJson: false, includeToJson: false)  int sportId, @JsonKey(name: 'ln')  String leagueName, @JsonKey(name: 'lg')  String leagueLogo, @JsonKey(name: 'lpo')  int? priorityOrder, @JsonKey(name: 'e')  List<LeagueEventData> events, @JsonKey(name: 'eo')  List<OutrightData>? outrightEvents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeagueData() when $default != null:
return $default(_that.leagueId,_that.sportId,_that.leagueName,_that.leagueLogo,_that.priorityOrder,_that.events,_that.outrightEvents);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'li')  int leagueId, @JsonKey(includeFromJson: false, includeToJson: false)  int sportId, @JsonKey(name: 'ln')  String leagueName, @JsonKey(name: 'lg')  String leagueLogo, @JsonKey(name: 'lpo')  int? priorityOrder, @JsonKey(name: 'e')  List<LeagueEventData> events, @JsonKey(name: 'eo')  List<OutrightData>? outrightEvents)  $default,) {final _that = this;
switch (_that) {
case _LeagueData():
return $default(_that.leagueId,_that.sportId,_that.leagueName,_that.leagueLogo,_that.priorityOrder,_that.events,_that.outrightEvents);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'li')  int leagueId, @JsonKey(includeFromJson: false, includeToJson: false)  int sportId, @JsonKey(name: 'ln')  String leagueName, @JsonKey(name: 'lg')  String leagueLogo, @JsonKey(name: 'lpo')  int? priorityOrder, @JsonKey(name: 'e')  List<LeagueEventData> events, @JsonKey(name: 'eo')  List<OutrightData>? outrightEvents)?  $default,) {final _that = this;
switch (_that) {
case _LeagueData() when $default != null:
return $default(_that.leagueId,_that.sportId,_that.leagueName,_that.leagueLogo,_that.priorityOrder,_that.events,_that.outrightEvents);case _:
  return null;

}
}

}

@JsonSerializable()

class _LeagueData implements LeagueData {
  const _LeagueData({@JsonKey(name: 'li') this.leagueId = 0, @JsonKey(includeFromJson: false, includeToJson: false) this.sportId = 1, @JsonKey(name: 'ln') this.leagueName = '', @JsonKey(name: 'lg') this.leagueLogo = '', @JsonKey(name: 'lpo') this.priorityOrder, @JsonKey(name: 'e') final  List<LeagueEventData> events = const [], @JsonKey(name: 'eo') final  List<OutrightData>? outrightEvents}): _events = events,_outrightEvents = outrightEvents;
  factory _LeagueData.fromJson(Map<String, dynamic> json) => _$LeagueDataFromJson(json);

@override@JsonKey(name: 'li') final  int leagueId;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  int sportId;
@override@JsonKey(name: 'ln') final  String leagueName;
@override@JsonKey(name: 'lg') final  String leagueLogo;
@override@JsonKey(name: 'lpo') final  int? priorityOrder;
 final  List<LeagueEventData> _events;
@override@JsonKey(name: 'e') List<LeagueEventData> get events {
  if (_events is EqualUnmodifiableListView) return _events;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_events);
}

 final  List<OutrightData>? _outrightEvents;
@override@JsonKey(name: 'eo') List<OutrightData>? get outrightEvents {
  final value = _outrightEvents;
  if (value == null) return null;
  if (_outrightEvents is EqualUnmodifiableListView) return _outrightEvents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeagueDataCopyWith<_LeagueData> get copyWith => __$LeagueDataCopyWithImpl<_LeagueData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeagueDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeagueData&&(identical(other.leagueId, leagueId) || other.leagueId == leagueId)&&(identical(other.sportId, sportId) || other.sportId == sportId)&&(identical(other.leagueName, leagueName) || other.leagueName == leagueName)&&(identical(other.leagueLogo, leagueLogo) || other.leagueLogo == leagueLogo)&&(identical(other.priorityOrder, priorityOrder) || other.priorityOrder == priorityOrder)&&const DeepCollectionEquality().equals(other._events, _events)&&const DeepCollectionEquality().equals(other._outrightEvents, _outrightEvents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,leagueId,sportId,leagueName,leagueLogo,priorityOrder,const DeepCollectionEquality().hash(_events),const DeepCollectionEquality().hash(_outrightEvents));

@override
String toString() {
  return 'LeagueData(leagueId: $leagueId, sportId: $sportId, leagueName: $leagueName, leagueLogo: $leagueLogo, priorityOrder: $priorityOrder, events: $events, outrightEvents: $outrightEvents)';
}

}

abstract mixin class _$LeagueDataCopyWith<$Res> implements $LeagueDataCopyWith<$Res> {
  factory _$LeagueDataCopyWith(_LeagueData value, $Res Function(_LeagueData) _then) = __$LeagueDataCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'li') int leagueId,@JsonKey(includeFromJson: false, includeToJson: false) int sportId,@JsonKey(name: 'ln') String leagueName,@JsonKey(name: 'lg') String leagueLogo,@JsonKey(name: 'lpo') int? priorityOrder,@JsonKey(name: 'e') List<LeagueEventData> events,@JsonKey(name: 'eo') List<OutrightData>? outrightEvents
});

}
class __$LeagueDataCopyWithImpl<$Res>
    implements _$LeagueDataCopyWith<$Res> {
  __$LeagueDataCopyWithImpl(this._self, this._then);

  final _LeagueData _self;
  final $Res Function(_LeagueData) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? leagueId = null,Object? sportId = null,Object? leagueName = null,Object? leagueLogo = null,Object? priorityOrder = freezed,Object? events = null,Object? outrightEvents = freezed,}) {
  return _then(_LeagueData(
leagueId: null == leagueId ? _self.leagueId : leagueId // ignore: cast_nullable_to_non_nullable
as int,sportId: null == sportId ? _self.sportId : sportId // ignore: cast_nullable_to_non_nullable
as int,leagueName: null == leagueName ? _self.leagueName : leagueName // ignore: cast_nullable_to_non_nullable
as String,leagueLogo: null == leagueLogo ? _self.leagueLogo : leagueLogo // ignore: cast_nullable_to_non_nullable
as String,priorityOrder: freezed == priorityOrder ? _self.priorityOrder : priorityOrder // ignore: cast_nullable_to_non_nullable
as int?,events: null == events ? _self._events : events // ignore: cast_nullable_to_non_nullable
as List<LeagueEventData>,outrightEvents: freezed == outrightEvents ? _self._outrightEvents : outrightEvents // ignore: cast_nullable_to_non_nullable
as List<OutrightData>?,
  ));
}

}

mixin _$LeagueEventData {

@JsonKey(name: 'ei') int get eventId;
@JsonKey(name: 'en') String? get eventName;
@JsonKey(name: 'hi') int get homeId;
@JsonKey(name: 'hn') String get homeName;
@JsonKey(name: 'ai') int get awayId;
@JsonKey(name: 'an') String get awayName;
@JsonKey(name: 'hf') String? get homeLogoFirst;
@JsonKey(name: 'hl') String? get homeLogoLast;
@JsonKey(name: 'af') String? get awayLogoFirst;
@JsonKey(name: 'al') String? get awayLogoLast;
@JsonKey(name: 'st', fromJson: _parseStartTime, readValue: _readStartTime) int get startTime;
@JsonKey(name: 'hs') int get homeScore;
@JsonKey(name: 'as') int get awayScore;
@JsonKey(name: 'l') bool get isLive;
@JsonKey(name: 'gl') bool get isGoingLive;
@JsonKey(name: 'ls') bool get isLivestream;
@JsonKey(name: 's') bool get isSuspended;
@JsonKey(name: 'es') String? get eventStatus;
@JsonKey(name: 'esi') int get eventStatsId;
@JsonKey(name: 'gt') int get gameTime;
@JsonKey(name: 'gp') int get gamePart;
@JsonKey(name: 'stm') int get stoppageTime;
@JsonKey(name: 'hc') int get cornersHome;
@JsonKey(name: 'ac') int get cornersAway;
@JsonKey(name: 'hso') int get homeScoreOT;
@JsonKey(name: 'aso') int get awayScoreOT;
@JsonKey(name: 'rch') int get redCardsHome;
@JsonKey(name: 'rca') int get redCardsAway;
@JsonKey(name: 'ych') int get yellowCardsHome;
@JsonKey(name: 'yca') int get yellowCardsAway;
@JsonKey(name: 'mc') int get totalMarketsCount;
@JsonKey(name: 'ip') bool get isParlay;
@JsonKey(name: 'min') int? get minute;
@JsonKey(name: 'm') List<LeagueMarketData> get markets;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeagueEventDataCopyWith<LeagueEventData> get copyWith => _$LeagueEventDataCopyWithImpl<LeagueEventData>(this as LeagueEventData, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeagueEventData&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.eventName, eventName) || other.eventName == eventName)&&(identical(other.homeId, homeId) || other.homeId == homeId)&&(identical(other.homeName, homeName) || other.homeName == homeName)&&(identical(other.awayId, awayId) || other.awayId == awayId)&&(identical(other.awayName, awayName) || other.awayName == awayName)&&(identical(other.homeLogoFirst, homeLogoFirst) || other.homeLogoFirst == homeLogoFirst)&&(identical(other.homeLogoLast, homeLogoLast) || other.homeLogoLast == homeLogoLast)&&(identical(other.awayLogoFirst, awayLogoFirst) || other.awayLogoFirst == awayLogoFirst)&&(identical(other.awayLogoLast, awayLogoLast) || other.awayLogoLast == awayLogoLast)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.homeScore, homeScore) || other.homeScore == homeScore)&&(identical(other.awayScore, awayScore) || other.awayScore == awayScore)&&(identical(other.isLive, isLive) || other.isLive == isLive)&&(identical(other.isGoingLive, isGoingLive) || other.isGoingLive == isGoingLive)&&(identical(other.isLivestream, isLivestream) || other.isLivestream == isLivestream)&&(identical(other.isSuspended, isSuspended) || other.isSuspended == isSuspended)&&(identical(other.eventStatus, eventStatus) || other.eventStatus == eventStatus)&&(identical(other.eventStatsId, eventStatsId) || other.eventStatsId == eventStatsId)&&(identical(other.gameTime, gameTime) || other.gameTime == gameTime)&&(identical(other.gamePart, gamePart) || other.gamePart == gamePart)&&(identical(other.stoppageTime, stoppageTime) || other.stoppageTime == stoppageTime)&&(identical(other.cornersHome, cornersHome) || other.cornersHome == cornersHome)&&(identical(other.cornersAway, cornersAway) || other.cornersAway == cornersAway)&&(identical(other.homeScoreOT, homeScoreOT) || other.homeScoreOT == homeScoreOT)&&(identical(other.awayScoreOT, awayScoreOT) || other.awayScoreOT == awayScoreOT)&&(identical(other.redCardsHome, redCardsHome) || other.redCardsHome == redCardsHome)&&(identical(other.redCardsAway, redCardsAway) || other.redCardsAway == redCardsAway)&&(identical(other.yellowCardsHome, yellowCardsHome) || other.yellowCardsHome == yellowCardsHome)&&(identical(other.yellowCardsAway, yellowCardsAway) || other.yellowCardsAway == yellowCardsAway)&&(identical(other.totalMarketsCount, totalMarketsCount) || other.totalMarketsCount == totalMarketsCount)&&(identical(other.isParlay, isParlay) || other.isParlay == isParlay)&&(identical(other.minute, minute) || other.minute == minute)&&const DeepCollectionEquality().equals(other.markets, markets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,eventId,eventName,homeId,homeName,awayId,awayName,homeLogoFirst,homeLogoLast,awayLogoFirst,awayLogoLast,startTime,homeScore,awayScore,isLive,isGoingLive,isLivestream,isSuspended,eventStatus,eventStatsId,gameTime,gamePart,stoppageTime,cornersHome,cornersAway,homeScoreOT,awayScoreOT,redCardsHome,redCardsAway,yellowCardsHome,yellowCardsAway,totalMarketsCount,isParlay,minute,const DeepCollectionEquality().hash(markets)]);

@override
String toString() {
  return 'LeagueEventData(eventId: $eventId, eventName: $eventName, homeId: $homeId, homeName: $homeName, awayId: $awayId, awayName: $awayName, homeLogoFirst: $homeLogoFirst, homeLogoLast: $homeLogoLast, awayLogoFirst: $awayLogoFirst, awayLogoLast: $awayLogoLast, startTime: $startTime, homeScore: $homeScore, awayScore: $awayScore, isLive: $isLive, isGoingLive: $isGoingLive, isLivestream: $isLivestream, isSuspended: $isSuspended, eventStatus: $eventStatus, eventStatsId: $eventStatsId, gameTime: $gameTime, gamePart: $gamePart, stoppageTime: $stoppageTime, cornersHome: $cornersHome, cornersAway: $cornersAway, homeScoreOT: $homeScoreOT, awayScoreOT: $awayScoreOT, redCardsHome: $redCardsHome, redCardsAway: $redCardsAway, yellowCardsHome: $yellowCardsHome, yellowCardsAway: $yellowCardsAway, totalMarketsCount: $totalMarketsCount, isParlay: $isParlay, minute: $minute, markets: $markets)';
}

}

abstract mixin class $LeagueEventDataCopyWith<$Res>  {
  factory $LeagueEventDataCopyWith(LeagueEventData value, $Res Function(LeagueEventData) _then) = _$LeagueEventDataCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'ei') int eventId,@JsonKey(name: 'en') String? eventName,@JsonKey(name: 'hi') int homeId,@JsonKey(name: 'hn') String homeName,@JsonKey(name: 'ai') int awayId,@JsonKey(name: 'an') String awayName,@JsonKey(name: 'hf') String? homeLogoFirst,@JsonKey(name: 'hl') String? homeLogoLast,@JsonKey(name: 'af') String? awayLogoFirst,@JsonKey(name: 'al') String? awayLogoLast,@JsonKey(name: 'st', fromJson: _parseStartTime, readValue: _readStartTime) int startTime,@JsonKey(name: 'hs') int homeScore,@JsonKey(name: 'as') int awayScore,@JsonKey(name: 'l') bool isLive,@JsonKey(name: 'gl') bool isGoingLive,@JsonKey(name: 'ls') bool isLivestream,@JsonKey(name: 's') bool isSuspended,@JsonKey(name: 'es') String? eventStatus,@JsonKey(name: 'esi') int eventStatsId,@JsonKey(name: 'gt') int gameTime,@JsonKey(name: 'gp') int gamePart,@JsonKey(name: 'stm') int stoppageTime,@JsonKey(name: 'hc') int cornersHome,@JsonKey(name: 'ac') int cornersAway,@JsonKey(name: 'hso') int homeScoreOT,@JsonKey(name: 'aso') int awayScoreOT,@JsonKey(name: 'rch') int redCardsHome,@JsonKey(name: 'rca') int redCardsAway,@JsonKey(name: 'ych') int yellowCardsHome,@JsonKey(name: 'yca') int yellowCardsAway,@JsonKey(name: 'mc') int totalMarketsCount,@JsonKey(name: 'ip') bool isParlay,@JsonKey(name: 'min') int? minute,@JsonKey(name: 'm') List<LeagueMarketData> markets
});

}
class _$LeagueEventDataCopyWithImpl<$Res>
    implements $LeagueEventDataCopyWith<$Res> {
  _$LeagueEventDataCopyWithImpl(this._self, this._then);

  final LeagueEventData _self;
  final $Res Function(LeagueEventData) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? eventId = null,Object? eventName = freezed,Object? homeId = null,Object? homeName = null,Object? awayId = null,Object? awayName = null,Object? homeLogoFirst = freezed,Object? homeLogoLast = freezed,Object? awayLogoFirst = freezed,Object? awayLogoLast = freezed,Object? startTime = null,Object? homeScore = null,Object? awayScore = null,Object? isLive = null,Object? isGoingLive = null,Object? isLivestream = null,Object? isSuspended = null,Object? eventStatus = freezed,Object? eventStatsId = null,Object? gameTime = null,Object? gamePart = null,Object? stoppageTime = null,Object? cornersHome = null,Object? cornersAway = null,Object? homeScoreOT = null,Object? awayScoreOT = null,Object? redCardsHome = null,Object? redCardsAway = null,Object? yellowCardsHome = null,Object? yellowCardsAway = null,Object? totalMarketsCount = null,Object? isParlay = null,Object? minute = freezed,Object? markets = null,}) {
  return _then(_self.copyWith(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as int,eventName: freezed == eventName ? _self.eventName : eventName // ignore: cast_nullable_to_non_nullable
as String?,homeId: null == homeId ? _self.homeId : homeId // ignore: cast_nullable_to_non_nullable
as int,homeName: null == homeName ? _self.homeName : homeName // ignore: cast_nullable_to_non_nullable
as String,awayId: null == awayId ? _self.awayId : awayId // ignore: cast_nullable_to_non_nullable
as int,awayName: null == awayName ? _self.awayName : awayName // ignore: cast_nullable_to_non_nullable
as String,homeLogoFirst: freezed == homeLogoFirst ? _self.homeLogoFirst : homeLogoFirst // ignore: cast_nullable_to_non_nullable
as String?,homeLogoLast: freezed == homeLogoLast ? _self.homeLogoLast : homeLogoLast // ignore: cast_nullable_to_non_nullable
as String?,awayLogoFirst: freezed == awayLogoFirst ? _self.awayLogoFirst : awayLogoFirst // ignore: cast_nullable_to_non_nullable
as String?,awayLogoLast: freezed == awayLogoLast ? _self.awayLogoLast : awayLogoLast // ignore: cast_nullable_to_non_nullable
as String?,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as int,homeScore: null == homeScore ? _self.homeScore : homeScore // ignore: cast_nullable_to_non_nullable
as int,awayScore: null == awayScore ? _self.awayScore : awayScore // ignore: cast_nullable_to_non_nullable
as int,isLive: null == isLive ? _self.isLive : isLive // ignore: cast_nullable_to_non_nullable
as bool,isGoingLive: null == isGoingLive ? _self.isGoingLive : isGoingLive // ignore: cast_nullable_to_non_nullable
as bool,isLivestream: null == isLivestream ? _self.isLivestream : isLivestream // ignore: cast_nullable_to_non_nullable
as bool,isSuspended: null == isSuspended ? _self.isSuspended : isSuspended // ignore: cast_nullable_to_non_nullable
as bool,eventStatus: freezed == eventStatus ? _self.eventStatus : eventStatus // ignore: cast_nullable_to_non_nullable
as String?,eventStatsId: null == eventStatsId ? _self.eventStatsId : eventStatsId // ignore: cast_nullable_to_non_nullable
as int,gameTime: null == gameTime ? _self.gameTime : gameTime // ignore: cast_nullable_to_non_nullable
as int,gamePart: null == gamePart ? _self.gamePart : gamePart // ignore: cast_nullable_to_non_nullable
as int,stoppageTime: null == stoppageTime ? _self.stoppageTime : stoppageTime // ignore: cast_nullable_to_non_nullable
as int,cornersHome: null == cornersHome ? _self.cornersHome : cornersHome // ignore: cast_nullable_to_non_nullable
as int,cornersAway: null == cornersAway ? _self.cornersAway : cornersAway // ignore: cast_nullable_to_non_nullable
as int,homeScoreOT: null == homeScoreOT ? _self.homeScoreOT : homeScoreOT // ignore: cast_nullable_to_non_nullable
as int,awayScoreOT: null == awayScoreOT ? _self.awayScoreOT : awayScoreOT // ignore: cast_nullable_to_non_nullable
as int,redCardsHome: null == redCardsHome ? _self.redCardsHome : redCardsHome // ignore: cast_nullable_to_non_nullable
as int,redCardsAway: null == redCardsAway ? _self.redCardsAway : redCardsAway // ignore: cast_nullable_to_non_nullable
as int,yellowCardsHome: null == yellowCardsHome ? _self.yellowCardsHome : yellowCardsHome // ignore: cast_nullable_to_non_nullable
as int,yellowCardsAway: null == yellowCardsAway ? _self.yellowCardsAway : yellowCardsAway // ignore: cast_nullable_to_non_nullable
as int,totalMarketsCount: null == totalMarketsCount ? _self.totalMarketsCount : totalMarketsCount // ignore: cast_nullable_to_non_nullable
as int,isParlay: null == isParlay ? _self.isParlay : isParlay // ignore: cast_nullable_to_non_nullable
as bool,minute: freezed == minute ? _self.minute : minute // ignore: cast_nullable_to_non_nullable
as int?,markets: null == markets ? _self.markets : markets // ignore: cast_nullable_to_non_nullable
as List<LeagueMarketData>,
  ));
}

}

extension LeagueEventDataPatterns on LeagueEventData {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeagueEventData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeagueEventData() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeagueEventData value)  $default,){
final _that = this;
switch (_that) {
case _LeagueEventData():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeagueEventData value)?  $default,){
final _that = this;
switch (_that) {
case _LeagueEventData() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'ei')  int eventId, @JsonKey(name: 'en')  String? eventName, @JsonKey(name: 'hi')  int homeId, @JsonKey(name: 'hn')  String homeName, @JsonKey(name: 'ai')  int awayId, @JsonKey(name: 'an')  String awayName, @JsonKey(name: 'hf')  String? homeLogoFirst, @JsonKey(name: 'hl')  String? homeLogoLast, @JsonKey(name: 'af')  String? awayLogoFirst, @JsonKey(name: 'al')  String? awayLogoLast, @JsonKey(name: 'st', fromJson: _parseStartTime, readValue: _readStartTime)  int startTime, @JsonKey(name: 'hs')  int homeScore, @JsonKey(name: 'as')  int awayScore, @JsonKey(name: 'l')  bool isLive, @JsonKey(name: 'gl')  bool isGoingLive, @JsonKey(name: 'ls')  bool isLivestream, @JsonKey(name: 's')  bool isSuspended, @JsonKey(name: 'es')  String? eventStatus, @JsonKey(name: 'esi')  int eventStatsId, @JsonKey(name: 'gt')  int gameTime, @JsonKey(name: 'gp')  int gamePart, @JsonKey(name: 'stm')  int stoppageTime, @JsonKey(name: 'hc')  int cornersHome, @JsonKey(name: 'ac')  int cornersAway, @JsonKey(name: 'hso')  int homeScoreOT, @JsonKey(name: 'aso')  int awayScoreOT, @JsonKey(name: 'rch')  int redCardsHome, @JsonKey(name: 'rca')  int redCardsAway, @JsonKey(name: 'ych')  int yellowCardsHome, @JsonKey(name: 'yca')  int yellowCardsAway, @JsonKey(name: 'mc')  int totalMarketsCount, @JsonKey(name: 'ip')  bool isParlay, @JsonKey(name: 'min')  int? minute, @JsonKey(name: 'm')  List<LeagueMarketData> markets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeagueEventData() when $default != null:
return $default(_that.eventId,_that.eventName,_that.homeId,_that.homeName,_that.awayId,_that.awayName,_that.homeLogoFirst,_that.homeLogoLast,_that.awayLogoFirst,_that.awayLogoLast,_that.startTime,_that.homeScore,_that.awayScore,_that.isLive,_that.isGoingLive,_that.isLivestream,_that.isSuspended,_that.eventStatus,_that.eventStatsId,_that.gameTime,_that.gamePart,_that.stoppageTime,_that.cornersHome,_that.cornersAway,_that.homeScoreOT,_that.awayScoreOT,_that.redCardsHome,_that.redCardsAway,_that.yellowCardsHome,_that.yellowCardsAway,_that.totalMarketsCount,_that.isParlay,_that.minute,_that.markets);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'ei')  int eventId, @JsonKey(name: 'en')  String? eventName, @JsonKey(name: 'hi')  int homeId, @JsonKey(name: 'hn')  String homeName, @JsonKey(name: 'ai')  int awayId, @JsonKey(name: 'an')  String awayName, @JsonKey(name: 'hf')  String? homeLogoFirst, @JsonKey(name: 'hl')  String? homeLogoLast, @JsonKey(name: 'af')  String? awayLogoFirst, @JsonKey(name: 'al')  String? awayLogoLast, @JsonKey(name: 'st', fromJson: _parseStartTime, readValue: _readStartTime)  int startTime, @JsonKey(name: 'hs')  int homeScore, @JsonKey(name: 'as')  int awayScore, @JsonKey(name: 'l')  bool isLive, @JsonKey(name: 'gl')  bool isGoingLive, @JsonKey(name: 'ls')  bool isLivestream, @JsonKey(name: 's')  bool isSuspended, @JsonKey(name: 'es')  String? eventStatus, @JsonKey(name: 'esi')  int eventStatsId, @JsonKey(name: 'gt')  int gameTime, @JsonKey(name: 'gp')  int gamePart, @JsonKey(name: 'stm')  int stoppageTime, @JsonKey(name: 'hc')  int cornersHome, @JsonKey(name: 'ac')  int cornersAway, @JsonKey(name: 'hso')  int homeScoreOT, @JsonKey(name: 'aso')  int awayScoreOT, @JsonKey(name: 'rch')  int redCardsHome, @JsonKey(name: 'rca')  int redCardsAway, @JsonKey(name: 'ych')  int yellowCardsHome, @JsonKey(name: 'yca')  int yellowCardsAway, @JsonKey(name: 'mc')  int totalMarketsCount, @JsonKey(name: 'ip')  bool isParlay, @JsonKey(name: 'min')  int? minute, @JsonKey(name: 'm')  List<LeagueMarketData> markets)  $default,) {final _that = this;
switch (_that) {
case _LeagueEventData():
return $default(_that.eventId,_that.eventName,_that.homeId,_that.homeName,_that.awayId,_that.awayName,_that.homeLogoFirst,_that.homeLogoLast,_that.awayLogoFirst,_that.awayLogoLast,_that.startTime,_that.homeScore,_that.awayScore,_that.isLive,_that.isGoingLive,_that.isLivestream,_that.isSuspended,_that.eventStatus,_that.eventStatsId,_that.gameTime,_that.gamePart,_that.stoppageTime,_that.cornersHome,_that.cornersAway,_that.homeScoreOT,_that.awayScoreOT,_that.redCardsHome,_that.redCardsAway,_that.yellowCardsHome,_that.yellowCardsAway,_that.totalMarketsCount,_that.isParlay,_that.minute,_that.markets);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'ei')  int eventId, @JsonKey(name: 'en')  String? eventName, @JsonKey(name: 'hi')  int homeId, @JsonKey(name: 'hn')  String homeName, @JsonKey(name: 'ai')  int awayId, @JsonKey(name: 'an')  String awayName, @JsonKey(name: 'hf')  String? homeLogoFirst, @JsonKey(name: 'hl')  String? homeLogoLast, @JsonKey(name: 'af')  String? awayLogoFirst, @JsonKey(name: 'al')  String? awayLogoLast, @JsonKey(name: 'st', fromJson: _parseStartTime, readValue: _readStartTime)  int startTime, @JsonKey(name: 'hs')  int homeScore, @JsonKey(name: 'as')  int awayScore, @JsonKey(name: 'l')  bool isLive, @JsonKey(name: 'gl')  bool isGoingLive, @JsonKey(name: 'ls')  bool isLivestream, @JsonKey(name: 's')  bool isSuspended, @JsonKey(name: 'es')  String? eventStatus, @JsonKey(name: 'esi')  int eventStatsId, @JsonKey(name: 'gt')  int gameTime, @JsonKey(name: 'gp')  int gamePart, @JsonKey(name: 'stm')  int stoppageTime, @JsonKey(name: 'hc')  int cornersHome, @JsonKey(name: 'ac')  int cornersAway, @JsonKey(name: 'hso')  int homeScoreOT, @JsonKey(name: 'aso')  int awayScoreOT, @JsonKey(name: 'rch')  int redCardsHome, @JsonKey(name: 'rca')  int redCardsAway, @JsonKey(name: 'ych')  int yellowCardsHome, @JsonKey(name: 'yca')  int yellowCardsAway, @JsonKey(name: 'mc')  int totalMarketsCount, @JsonKey(name: 'ip')  bool isParlay, @JsonKey(name: 'min')  int? minute, @JsonKey(name: 'm')  List<LeagueMarketData> markets)?  $default,) {final _that = this;
switch (_that) {
case _LeagueEventData() when $default != null:
return $default(_that.eventId,_that.eventName,_that.homeId,_that.homeName,_that.awayId,_that.awayName,_that.homeLogoFirst,_that.homeLogoLast,_that.awayLogoFirst,_that.awayLogoLast,_that.startTime,_that.homeScore,_that.awayScore,_that.isLive,_that.isGoingLive,_that.isLivestream,_that.isSuspended,_that.eventStatus,_that.eventStatsId,_that.gameTime,_that.gamePart,_that.stoppageTime,_that.cornersHome,_that.cornersAway,_that.homeScoreOT,_that.awayScoreOT,_that.redCardsHome,_that.redCardsAway,_that.yellowCardsHome,_that.yellowCardsAway,_that.totalMarketsCount,_that.isParlay,_that.minute,_that.markets);case _:
  return null;

}
}

}

@JsonSerializable()

class _LeagueEventData implements LeagueEventData {
  const _LeagueEventData({@JsonKey(name: 'ei') this.eventId = 0, @JsonKey(name: 'en') this.eventName, @JsonKey(name: 'hi') this.homeId = 0, @JsonKey(name: 'hn') this.homeName = '', @JsonKey(name: 'ai') this.awayId = 0, @JsonKey(name: 'an') this.awayName = '', @JsonKey(name: 'hf') this.homeLogoFirst, @JsonKey(name: 'hl') this.homeLogoLast, @JsonKey(name: 'af') this.awayLogoFirst, @JsonKey(name: 'al') this.awayLogoLast, @JsonKey(name: 'st', fromJson: _parseStartTime, readValue: _readStartTime) this.startTime = 0, @JsonKey(name: 'hs') this.homeScore = 0, @JsonKey(name: 'as') this.awayScore = 0, @JsonKey(name: 'l') this.isLive = false, @JsonKey(name: 'gl') this.isGoingLive = false, @JsonKey(name: 'ls') this.isLivestream = false, @JsonKey(name: 's') this.isSuspended = false, @JsonKey(name: 'es') this.eventStatus, @JsonKey(name: 'esi') this.eventStatsId = 0, @JsonKey(name: 'gt') this.gameTime = 0, @JsonKey(name: 'gp') this.gamePart = 0, @JsonKey(name: 'stm') this.stoppageTime = 0, @JsonKey(name: 'hc') this.cornersHome = 0, @JsonKey(name: 'ac') this.cornersAway = 0, @JsonKey(name: 'hso') this.homeScoreOT = 0, @JsonKey(name: 'aso') this.awayScoreOT = 0, @JsonKey(name: 'rch') this.redCardsHome = 0, @JsonKey(name: 'rca') this.redCardsAway = 0, @JsonKey(name: 'ych') this.yellowCardsHome = 0, @JsonKey(name: 'yca') this.yellowCardsAway = 0, @JsonKey(name: 'mc') this.totalMarketsCount = 0, @JsonKey(name: 'ip') this.isParlay = false, @JsonKey(name: 'min') this.minute, @JsonKey(name: 'm') final  List<LeagueMarketData> markets = const []}): _markets = markets;
  factory _LeagueEventData.fromJson(Map<String, dynamic> json) => _$LeagueEventDataFromJson(json);

@override@JsonKey(name: 'ei') final  int eventId;
@override@JsonKey(name: 'en') final  String? eventName;
@override@JsonKey(name: 'hi') final  int homeId;
@override@JsonKey(name: 'hn') final  String homeName;
@override@JsonKey(name: 'ai') final  int awayId;
@override@JsonKey(name: 'an') final  String awayName;
@override@JsonKey(name: 'hf') final  String? homeLogoFirst;
@override@JsonKey(name: 'hl') final  String? homeLogoLast;
@override@JsonKey(name: 'af') final  String? awayLogoFirst;
@override@JsonKey(name: 'al') final  String? awayLogoLast;
@override@JsonKey(name: 'st', fromJson: _parseStartTime, readValue: _readStartTime) final  int startTime;
@override@JsonKey(name: 'hs') final  int homeScore;
@override@JsonKey(name: 'as') final  int awayScore;
@override@JsonKey(name: 'l') final  bool isLive;
@override@JsonKey(name: 'gl') final  bool isGoingLive;
@override@JsonKey(name: 'ls') final  bool isLivestream;
@override@JsonKey(name: 's') final  bool isSuspended;
@override@JsonKey(name: 'es') final  String? eventStatus;
@override@JsonKey(name: 'esi') final  int eventStatsId;
@override@JsonKey(name: 'gt') final  int gameTime;
@override@JsonKey(name: 'gp') final  int gamePart;
@override@JsonKey(name: 'stm') final  int stoppageTime;
@override@JsonKey(name: 'hc') final  int cornersHome;
@override@JsonKey(name: 'ac') final  int cornersAway;
@override@JsonKey(name: 'hso') final  int homeScoreOT;
@override@JsonKey(name: 'aso') final  int awayScoreOT;
@override@JsonKey(name: 'rch') final  int redCardsHome;
@override@JsonKey(name: 'rca') final  int redCardsAway;
@override@JsonKey(name: 'ych') final  int yellowCardsHome;
@override@JsonKey(name: 'yca') final  int yellowCardsAway;
@override@JsonKey(name: 'mc') final  int totalMarketsCount;
@override@JsonKey(name: 'ip') final  bool isParlay;
@override@JsonKey(name: 'min') final  int? minute;
 final  List<LeagueMarketData> _markets;
@override@JsonKey(name: 'm') List<LeagueMarketData> get markets {
  if (_markets is EqualUnmodifiableListView) return _markets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_markets);
}

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeagueEventDataCopyWith<_LeagueEventData> get copyWith => __$LeagueEventDataCopyWithImpl<_LeagueEventData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeagueEventDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeagueEventData&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.eventName, eventName) || other.eventName == eventName)&&(identical(other.homeId, homeId) || other.homeId == homeId)&&(identical(other.homeName, homeName) || other.homeName == homeName)&&(identical(other.awayId, awayId) || other.awayId == awayId)&&(identical(other.awayName, awayName) || other.awayName == awayName)&&(identical(other.homeLogoFirst, homeLogoFirst) || other.homeLogoFirst == homeLogoFirst)&&(identical(other.homeLogoLast, homeLogoLast) || other.homeLogoLast == homeLogoLast)&&(identical(other.awayLogoFirst, awayLogoFirst) || other.awayLogoFirst == awayLogoFirst)&&(identical(other.awayLogoLast, awayLogoLast) || other.awayLogoLast == awayLogoLast)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.homeScore, homeScore) || other.homeScore == homeScore)&&(identical(other.awayScore, awayScore) || other.awayScore == awayScore)&&(identical(other.isLive, isLive) || other.isLive == isLive)&&(identical(other.isGoingLive, isGoingLive) || other.isGoingLive == isGoingLive)&&(identical(other.isLivestream, isLivestream) || other.isLivestream == isLivestream)&&(identical(other.isSuspended, isSuspended) || other.isSuspended == isSuspended)&&(identical(other.eventStatus, eventStatus) || other.eventStatus == eventStatus)&&(identical(other.eventStatsId, eventStatsId) || other.eventStatsId == eventStatsId)&&(identical(other.gameTime, gameTime) || other.gameTime == gameTime)&&(identical(other.gamePart, gamePart) || other.gamePart == gamePart)&&(identical(other.stoppageTime, stoppageTime) || other.stoppageTime == stoppageTime)&&(identical(other.cornersHome, cornersHome) || other.cornersHome == cornersHome)&&(identical(other.cornersAway, cornersAway) || other.cornersAway == cornersAway)&&(identical(other.homeScoreOT, homeScoreOT) || other.homeScoreOT == homeScoreOT)&&(identical(other.awayScoreOT, awayScoreOT) || other.awayScoreOT == awayScoreOT)&&(identical(other.redCardsHome, redCardsHome) || other.redCardsHome == redCardsHome)&&(identical(other.redCardsAway, redCardsAway) || other.redCardsAway == redCardsAway)&&(identical(other.yellowCardsHome, yellowCardsHome) || other.yellowCardsHome == yellowCardsHome)&&(identical(other.yellowCardsAway, yellowCardsAway) || other.yellowCardsAway == yellowCardsAway)&&(identical(other.totalMarketsCount, totalMarketsCount) || other.totalMarketsCount == totalMarketsCount)&&(identical(other.isParlay, isParlay) || other.isParlay == isParlay)&&(identical(other.minute, minute) || other.minute == minute)&&const DeepCollectionEquality().equals(other._markets, _markets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,eventId,eventName,homeId,homeName,awayId,awayName,homeLogoFirst,homeLogoLast,awayLogoFirst,awayLogoLast,startTime,homeScore,awayScore,isLive,isGoingLive,isLivestream,isSuspended,eventStatus,eventStatsId,gameTime,gamePart,stoppageTime,cornersHome,cornersAway,homeScoreOT,awayScoreOT,redCardsHome,redCardsAway,yellowCardsHome,yellowCardsAway,totalMarketsCount,isParlay,minute,const DeepCollectionEquality().hash(_markets)]);

@override
String toString() {
  return 'LeagueEventData(eventId: $eventId, eventName: $eventName, homeId: $homeId, homeName: $homeName, awayId: $awayId, awayName: $awayName, homeLogoFirst: $homeLogoFirst, homeLogoLast: $homeLogoLast, awayLogoFirst: $awayLogoFirst, awayLogoLast: $awayLogoLast, startTime: $startTime, homeScore: $homeScore, awayScore: $awayScore, isLive: $isLive, isGoingLive: $isGoingLive, isLivestream: $isLivestream, isSuspended: $isSuspended, eventStatus: $eventStatus, eventStatsId: $eventStatsId, gameTime: $gameTime, gamePart: $gamePart, stoppageTime: $stoppageTime, cornersHome: $cornersHome, cornersAway: $cornersAway, homeScoreOT: $homeScoreOT, awayScoreOT: $awayScoreOT, redCardsHome: $redCardsHome, redCardsAway: $redCardsAway, yellowCardsHome: $yellowCardsHome, yellowCardsAway: $yellowCardsAway, totalMarketsCount: $totalMarketsCount, isParlay: $isParlay, minute: $minute, markets: $markets)';
}

}

abstract mixin class _$LeagueEventDataCopyWith<$Res> implements $LeagueEventDataCopyWith<$Res> {
  factory _$LeagueEventDataCopyWith(_LeagueEventData value, $Res Function(_LeagueEventData) _then) = __$LeagueEventDataCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'ei') int eventId,@JsonKey(name: 'en') String? eventName,@JsonKey(name: 'hi') int homeId,@JsonKey(name: 'hn') String homeName,@JsonKey(name: 'ai') int awayId,@JsonKey(name: 'an') String awayName,@JsonKey(name: 'hf') String? homeLogoFirst,@JsonKey(name: 'hl') String? homeLogoLast,@JsonKey(name: 'af') String? awayLogoFirst,@JsonKey(name: 'al') String? awayLogoLast,@JsonKey(name: 'st', fromJson: _parseStartTime, readValue: _readStartTime) int startTime,@JsonKey(name: 'hs') int homeScore,@JsonKey(name: 'as') int awayScore,@JsonKey(name: 'l') bool isLive,@JsonKey(name: 'gl') bool isGoingLive,@JsonKey(name: 'ls') bool isLivestream,@JsonKey(name: 's') bool isSuspended,@JsonKey(name: 'es') String? eventStatus,@JsonKey(name: 'esi') int eventStatsId,@JsonKey(name: 'gt') int gameTime,@JsonKey(name: 'gp') int gamePart,@JsonKey(name: 'stm') int stoppageTime,@JsonKey(name: 'hc') int cornersHome,@JsonKey(name: 'ac') int cornersAway,@JsonKey(name: 'hso') int homeScoreOT,@JsonKey(name: 'aso') int awayScoreOT,@JsonKey(name: 'rch') int redCardsHome,@JsonKey(name: 'rca') int redCardsAway,@JsonKey(name: 'ych') int yellowCardsHome,@JsonKey(name: 'yca') int yellowCardsAway,@JsonKey(name: 'mc') int totalMarketsCount,@JsonKey(name: 'ip') bool isParlay,@JsonKey(name: 'min') int? minute,@JsonKey(name: 'm') List<LeagueMarketData> markets
});

}
class __$LeagueEventDataCopyWithImpl<$Res>
    implements _$LeagueEventDataCopyWith<$Res> {
  __$LeagueEventDataCopyWithImpl(this._self, this._then);

  final _LeagueEventData _self;
  final $Res Function(_LeagueEventData) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? eventId = null,Object? eventName = freezed,Object? homeId = null,Object? homeName = null,Object? awayId = null,Object? awayName = null,Object? homeLogoFirst = freezed,Object? homeLogoLast = freezed,Object? awayLogoFirst = freezed,Object? awayLogoLast = freezed,Object? startTime = null,Object? homeScore = null,Object? awayScore = null,Object? isLive = null,Object? isGoingLive = null,Object? isLivestream = null,Object? isSuspended = null,Object? eventStatus = freezed,Object? eventStatsId = null,Object? gameTime = null,Object? gamePart = null,Object? stoppageTime = null,Object? cornersHome = null,Object? cornersAway = null,Object? homeScoreOT = null,Object? awayScoreOT = null,Object? redCardsHome = null,Object? redCardsAway = null,Object? yellowCardsHome = null,Object? yellowCardsAway = null,Object? totalMarketsCount = null,Object? isParlay = null,Object? minute = freezed,Object? markets = null,}) {
  return _then(_LeagueEventData(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as int,eventName: freezed == eventName ? _self.eventName : eventName // ignore: cast_nullable_to_non_nullable
as String?,homeId: null == homeId ? _self.homeId : homeId // ignore: cast_nullable_to_non_nullable
as int,homeName: null == homeName ? _self.homeName : homeName // ignore: cast_nullable_to_non_nullable
as String,awayId: null == awayId ? _self.awayId : awayId // ignore: cast_nullable_to_non_nullable
as int,awayName: null == awayName ? _self.awayName : awayName // ignore: cast_nullable_to_non_nullable
as String,homeLogoFirst: freezed == homeLogoFirst ? _self.homeLogoFirst : homeLogoFirst // ignore: cast_nullable_to_non_nullable
as String?,homeLogoLast: freezed == homeLogoLast ? _self.homeLogoLast : homeLogoLast // ignore: cast_nullable_to_non_nullable
as String?,awayLogoFirst: freezed == awayLogoFirst ? _self.awayLogoFirst : awayLogoFirst // ignore: cast_nullable_to_non_nullable
as String?,awayLogoLast: freezed == awayLogoLast ? _self.awayLogoLast : awayLogoLast // ignore: cast_nullable_to_non_nullable
as String?,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as int,homeScore: null == homeScore ? _self.homeScore : homeScore // ignore: cast_nullable_to_non_nullable
as int,awayScore: null == awayScore ? _self.awayScore : awayScore // ignore: cast_nullable_to_non_nullable
as int,isLive: null == isLive ? _self.isLive : isLive // ignore: cast_nullable_to_non_nullable
as bool,isGoingLive: null == isGoingLive ? _self.isGoingLive : isGoingLive // ignore: cast_nullable_to_non_nullable
as bool,isLivestream: null == isLivestream ? _self.isLivestream : isLivestream // ignore: cast_nullable_to_non_nullable
as bool,isSuspended: null == isSuspended ? _self.isSuspended : isSuspended // ignore: cast_nullable_to_non_nullable
as bool,eventStatus: freezed == eventStatus ? _self.eventStatus : eventStatus // ignore: cast_nullable_to_non_nullable
as String?,eventStatsId: null == eventStatsId ? _self.eventStatsId : eventStatsId // ignore: cast_nullable_to_non_nullable
as int,gameTime: null == gameTime ? _self.gameTime : gameTime // ignore: cast_nullable_to_non_nullable
as int,gamePart: null == gamePart ? _self.gamePart : gamePart // ignore: cast_nullable_to_non_nullable
as int,stoppageTime: null == stoppageTime ? _self.stoppageTime : stoppageTime // ignore: cast_nullable_to_non_nullable
as int,cornersHome: null == cornersHome ? _self.cornersHome : cornersHome // ignore: cast_nullable_to_non_nullable
as int,cornersAway: null == cornersAway ? _self.cornersAway : cornersAway // ignore: cast_nullable_to_non_nullable
as int,homeScoreOT: null == homeScoreOT ? _self.homeScoreOT : homeScoreOT // ignore: cast_nullable_to_non_nullable
as int,awayScoreOT: null == awayScoreOT ? _self.awayScoreOT : awayScoreOT // ignore: cast_nullable_to_non_nullable
as int,redCardsHome: null == redCardsHome ? _self.redCardsHome : redCardsHome // ignore: cast_nullable_to_non_nullable
as int,redCardsAway: null == redCardsAway ? _self.redCardsAway : redCardsAway // ignore: cast_nullable_to_non_nullable
as int,yellowCardsHome: null == yellowCardsHome ? _self.yellowCardsHome : yellowCardsHome // ignore: cast_nullable_to_non_nullable
as int,yellowCardsAway: null == yellowCardsAway ? _self.yellowCardsAway : yellowCardsAway // ignore: cast_nullable_to_non_nullable
as int,totalMarketsCount: null == totalMarketsCount ? _self.totalMarketsCount : totalMarketsCount // ignore: cast_nullable_to_non_nullable
as int,isParlay: null == isParlay ? _self.isParlay : isParlay // ignore: cast_nullable_to_non_nullable
as bool,minute: freezed == minute ? _self.minute : minute // ignore: cast_nullable_to_non_nullable
as int?,markets: null == markets ? _self._markets : markets // ignore: cast_nullable_to_non_nullable
as List<LeagueMarketData>,
  ));
}

}

mixin _$LeagueMarketData {

@JsonKey(name: 'mi') int get marketId;
@JsonKey(name: 'mn') String get marketName;
@JsonKey(name: 'mt') String? get marketType;
@JsonKey(name: 'ip') bool get isParlay;
@JsonKey(name: 'o') List<LeagueOddsData> get odds;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeagueMarketDataCopyWith<LeagueMarketData> get copyWith => _$LeagueMarketDataCopyWithImpl<LeagueMarketData>(this as LeagueMarketData, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeagueMarketData&&(identical(other.marketId, marketId) || other.marketId == marketId)&&(identical(other.marketName, marketName) || other.marketName == marketName)&&(identical(other.marketType, marketType) || other.marketType == marketType)&&(identical(other.isParlay, isParlay) || other.isParlay == isParlay)&&const DeepCollectionEquality().equals(other.odds, odds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,marketId,marketName,marketType,isParlay,const DeepCollectionEquality().hash(odds));

@override
String toString() {
  return 'LeagueMarketData(marketId: $marketId, marketName: $marketName, marketType: $marketType, isParlay: $isParlay, odds: $odds)';
}

}

abstract mixin class $LeagueMarketDataCopyWith<$Res>  {
  factory $LeagueMarketDataCopyWith(LeagueMarketData value, $Res Function(LeagueMarketData) _then) = _$LeagueMarketDataCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'mi') int marketId,@JsonKey(name: 'mn') String marketName,@JsonKey(name: 'mt') String? marketType,@JsonKey(name: 'ip') bool isParlay,@JsonKey(name: 'o') List<LeagueOddsData> odds
});

}
class _$LeagueMarketDataCopyWithImpl<$Res>
    implements $LeagueMarketDataCopyWith<$Res> {
  _$LeagueMarketDataCopyWithImpl(this._self, this._then);

  final LeagueMarketData _self;
  final $Res Function(LeagueMarketData) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? marketId = null,Object? marketName = null,Object? marketType = freezed,Object? isParlay = null,Object? odds = null,}) {
  return _then(_self.copyWith(
marketId: null == marketId ? _self.marketId : marketId // ignore: cast_nullable_to_non_nullable
as int,marketName: null == marketName ? _self.marketName : marketName // ignore: cast_nullable_to_non_nullable
as String,marketType: freezed == marketType ? _self.marketType : marketType // ignore: cast_nullable_to_non_nullable
as String?,isParlay: null == isParlay ? _self.isParlay : isParlay // ignore: cast_nullable_to_non_nullable
as bool,odds: null == odds ? _self.odds : odds // ignore: cast_nullable_to_non_nullable
as List<LeagueOddsData>,
  ));
}

}

extension LeagueMarketDataPatterns on LeagueMarketData {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeagueMarketData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeagueMarketData() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeagueMarketData value)  $default,){
final _that = this;
switch (_that) {
case _LeagueMarketData():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeagueMarketData value)?  $default,){
final _that = this;
switch (_that) {
case _LeagueMarketData() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'mi')  int marketId, @JsonKey(name: 'mn')  String marketName, @JsonKey(name: 'mt')  String? marketType, @JsonKey(name: 'ip')  bool isParlay, @JsonKey(name: 'o')  List<LeagueOddsData> odds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeagueMarketData() when $default != null:
return $default(_that.marketId,_that.marketName,_that.marketType,_that.isParlay,_that.odds);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'mi')  int marketId, @JsonKey(name: 'mn')  String marketName, @JsonKey(name: 'mt')  String? marketType, @JsonKey(name: 'ip')  bool isParlay, @JsonKey(name: 'o')  List<LeagueOddsData> odds)  $default,) {final _that = this;
switch (_that) {
case _LeagueMarketData():
return $default(_that.marketId,_that.marketName,_that.marketType,_that.isParlay,_that.odds);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'mi')  int marketId, @JsonKey(name: 'mn')  String marketName, @JsonKey(name: 'mt')  String? marketType, @JsonKey(name: 'ip')  bool isParlay, @JsonKey(name: 'o')  List<LeagueOddsData> odds)?  $default,) {final _that = this;
switch (_that) {
case _LeagueMarketData() when $default != null:
return $default(_that.marketId,_that.marketName,_that.marketType,_that.isParlay,_that.odds);case _:
  return null;

}
}

}

@JsonSerializable()

class _LeagueMarketData implements LeagueMarketData {
  const _LeagueMarketData({@JsonKey(name: 'mi') this.marketId = 0, @JsonKey(name: 'mn') this.marketName = '', @JsonKey(name: 'mt') this.marketType, @JsonKey(name: 'ip') this.isParlay = false, @JsonKey(name: 'o') final  List<LeagueOddsData> odds = const []}): _odds = odds;
  factory _LeagueMarketData.fromJson(Map<String, dynamic> json) => _$LeagueMarketDataFromJson(json);

@override@JsonKey(name: 'mi') final  int marketId;
@override@JsonKey(name: 'mn') final  String marketName;
@override@JsonKey(name: 'mt') final  String? marketType;
@override@JsonKey(name: 'ip') final  bool isParlay;
 final  List<LeagueOddsData> _odds;
@override@JsonKey(name: 'o') List<LeagueOddsData> get odds {
  if (_odds is EqualUnmodifiableListView) return _odds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_odds);
}

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeagueMarketDataCopyWith<_LeagueMarketData> get copyWith => __$LeagueMarketDataCopyWithImpl<_LeagueMarketData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeagueMarketDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeagueMarketData&&(identical(other.marketId, marketId) || other.marketId == marketId)&&(identical(other.marketName, marketName) || other.marketName == marketName)&&(identical(other.marketType, marketType) || other.marketType == marketType)&&(identical(other.isParlay, isParlay) || other.isParlay == isParlay)&&const DeepCollectionEquality().equals(other._odds, _odds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,marketId,marketName,marketType,isParlay,const DeepCollectionEquality().hash(_odds));

@override
String toString() {
  return 'LeagueMarketData(marketId: $marketId, marketName: $marketName, marketType: $marketType, isParlay: $isParlay, odds: $odds)';
}

}

abstract mixin class _$LeagueMarketDataCopyWith<$Res> implements $LeagueMarketDataCopyWith<$Res> {
  factory _$LeagueMarketDataCopyWith(_LeagueMarketData value, $Res Function(_LeagueMarketData) _then) = __$LeagueMarketDataCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'mi') int marketId,@JsonKey(name: 'mn') String marketName,@JsonKey(name: 'mt') String? marketType,@JsonKey(name: 'ip') bool isParlay,@JsonKey(name: 'o') List<LeagueOddsData> odds
});

}
class __$LeagueMarketDataCopyWithImpl<$Res>
    implements _$LeagueMarketDataCopyWith<$Res> {
  __$LeagueMarketDataCopyWithImpl(this._self, this._then);

  final _LeagueMarketData _self;
  final $Res Function(_LeagueMarketData) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? marketId = null,Object? marketName = null,Object? marketType = freezed,Object? isParlay = null,Object? odds = null,}) {
  return _then(_LeagueMarketData(
marketId: null == marketId ? _self.marketId : marketId // ignore: cast_nullable_to_non_nullable
as int,marketName: null == marketName ? _self.marketName : marketName // ignore: cast_nullable_to_non_nullable
as String,marketType: freezed == marketType ? _self.marketType : marketType // ignore: cast_nullable_to_non_nullable
as String?,isParlay: null == isParlay ? _self.isParlay : isParlay // ignore: cast_nullable_to_non_nullable
as bool,odds: null == odds ? _self._odds : odds // ignore: cast_nullable_to_non_nullable
as List<LeagueOddsData>,
  ));
}

}

mixin _$LeagueOddsData {

@JsonKey(name: 'p') String get points;
@JsonKey(name: 'ml') bool get isMainLine;
@JsonKey(name: 'shi') String? get selectionHomeId;
@JsonKey(name: 'sai') String? get selectionAwayId;
@JsonKey(name: 'sdi') String? get selectionDrawId;
@JsonKey(name: 'soi') String? get offerId;
 bool get isSuspended;
@JsonKey(name: 'oh', fromJson: OddsValue.fromJson, toJson: OddsValue.toJsonStatic) OddsValue get oddsHome;
@JsonKey(name: 'oa', fromJson: OddsValue.fromJson, toJson: OddsValue.toJsonStatic) OddsValue get oddsAway;
@JsonKey(name: 'od', fromJson: OddsValue.fromJson, toJson: OddsValue.toJsonStatic) OddsValue get oddsDraw;
@JsonKey(name: 'ho') double? get homeOddsLegacy;
@JsonKey(name: 'ao') double? get awayOddsLegacy;
@JsonKey(name: 'do') double? get drawOddsLegacy;
@JsonKey(name: 'oi') String? get offerIdLegacy;
@JsonKey(name: 'si') String? get selectionIdLegacy;
 String get playerName;
 String get playerId;
 int get period;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeagueOddsDataCopyWith<LeagueOddsData> get copyWith => _$LeagueOddsDataCopyWithImpl<LeagueOddsData>(this as LeagueOddsData, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeagueOddsData&&(identical(other.points, points) || other.points == points)&&(identical(other.isMainLine, isMainLine) || other.isMainLine == isMainLine)&&(identical(other.selectionHomeId, selectionHomeId) || other.selectionHomeId == selectionHomeId)&&(identical(other.selectionAwayId, selectionAwayId) || other.selectionAwayId == selectionAwayId)&&(identical(other.selectionDrawId, selectionDrawId) || other.selectionDrawId == selectionDrawId)&&(identical(other.offerId, offerId) || other.offerId == offerId)&&(identical(other.isSuspended, isSuspended) || other.isSuspended == isSuspended)&&(identical(other.oddsHome, oddsHome) || other.oddsHome == oddsHome)&&(identical(other.oddsAway, oddsAway) || other.oddsAway == oddsAway)&&(identical(other.oddsDraw, oddsDraw) || other.oddsDraw == oddsDraw)&&(identical(other.homeOddsLegacy, homeOddsLegacy) || other.homeOddsLegacy == homeOddsLegacy)&&(identical(other.awayOddsLegacy, awayOddsLegacy) || other.awayOddsLegacy == awayOddsLegacy)&&(identical(other.drawOddsLegacy, drawOddsLegacy) || other.drawOddsLegacy == drawOddsLegacy)&&(identical(other.offerIdLegacy, offerIdLegacy) || other.offerIdLegacy == offerIdLegacy)&&(identical(other.selectionIdLegacy, selectionIdLegacy) || other.selectionIdLegacy == selectionIdLegacy)&&(identical(other.playerName, playerName) || other.playerName == playerName)&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.period, period) || other.period == period));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,points,isMainLine,selectionHomeId,selectionAwayId,selectionDrawId,offerId,isSuspended,oddsHome,oddsAway,oddsDraw,homeOddsLegacy,awayOddsLegacy,drawOddsLegacy,offerIdLegacy,selectionIdLegacy,playerName,playerId,period);

@override
String toString() {
  return 'LeagueOddsData(points: $points, isMainLine: $isMainLine, selectionHomeId: $selectionHomeId, selectionAwayId: $selectionAwayId, selectionDrawId: $selectionDrawId, offerId: $offerId, isSuspended: $isSuspended, oddsHome: $oddsHome, oddsAway: $oddsAway, oddsDraw: $oddsDraw, homeOddsLegacy: $homeOddsLegacy, awayOddsLegacy: $awayOddsLegacy, drawOddsLegacy: $drawOddsLegacy, offerIdLegacy: $offerIdLegacy, selectionIdLegacy: $selectionIdLegacy, playerName: $playerName, playerId: $playerId, period: $period)';
}

}

abstract mixin class $LeagueOddsDataCopyWith<$Res>  {
  factory $LeagueOddsDataCopyWith(LeagueOddsData value, $Res Function(LeagueOddsData) _then) = _$LeagueOddsDataCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'p') String points,@JsonKey(name: 'ml') bool isMainLine,@JsonKey(name: 'shi') String? selectionHomeId,@JsonKey(name: 'sai') String? selectionAwayId,@JsonKey(name: 'sdi') String? selectionDrawId,@JsonKey(name: 'soi') String? offerId, bool isSuspended,@JsonKey(name: 'oh', fromJson: OddsValue.fromJson, toJson: OddsValue.toJsonStatic) OddsValue oddsHome,@JsonKey(name: 'oa', fromJson: OddsValue.fromJson, toJson: OddsValue.toJsonStatic) OddsValue oddsAway,@JsonKey(name: 'od', fromJson: OddsValue.fromJson, toJson: OddsValue.toJsonStatic) OddsValue oddsDraw,@JsonKey(name: 'ho') double? homeOddsLegacy,@JsonKey(name: 'ao') double? awayOddsLegacy,@JsonKey(name: 'do') double? drawOddsLegacy,@JsonKey(name: 'oi') String? offerIdLegacy,@JsonKey(name: 'si') String? selectionIdLegacy, String playerName, String playerId, int period
});

}
class _$LeagueOddsDataCopyWithImpl<$Res>
    implements $LeagueOddsDataCopyWith<$Res> {
  _$LeagueOddsDataCopyWithImpl(this._self, this._then);

  final LeagueOddsData _self;
  final $Res Function(LeagueOddsData) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? points = null,Object? isMainLine = null,Object? selectionHomeId = freezed,Object? selectionAwayId = freezed,Object? selectionDrawId = freezed,Object? offerId = freezed,Object? isSuspended = null,Object? oddsHome = null,Object? oddsAway = null,Object? oddsDraw = null,Object? homeOddsLegacy = freezed,Object? awayOddsLegacy = freezed,Object? drawOddsLegacy = freezed,Object? offerIdLegacy = freezed,Object? selectionIdLegacy = freezed,Object? playerName = null,Object? playerId = null,Object? period = null,}) {
  return _then(_self.copyWith(
points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as String,isMainLine: null == isMainLine ? _self.isMainLine : isMainLine // ignore: cast_nullable_to_non_nullable
as bool,selectionHomeId: freezed == selectionHomeId ? _self.selectionHomeId : selectionHomeId // ignore: cast_nullable_to_non_nullable
as String?,selectionAwayId: freezed == selectionAwayId ? _self.selectionAwayId : selectionAwayId // ignore: cast_nullable_to_non_nullable
as String?,selectionDrawId: freezed == selectionDrawId ? _self.selectionDrawId : selectionDrawId // ignore: cast_nullable_to_non_nullable
as String?,offerId: freezed == offerId ? _self.offerId : offerId // ignore: cast_nullable_to_non_nullable
as String?,isSuspended: null == isSuspended ? _self.isSuspended : isSuspended // ignore: cast_nullable_to_non_nullable
as bool,oddsHome: null == oddsHome ? _self.oddsHome : oddsHome // ignore: cast_nullable_to_non_nullable
as OddsValue,oddsAway: null == oddsAway ? _self.oddsAway : oddsAway // ignore: cast_nullable_to_non_nullable
as OddsValue,oddsDraw: null == oddsDraw ? _self.oddsDraw : oddsDraw // ignore: cast_nullable_to_non_nullable
as OddsValue,homeOddsLegacy: freezed == homeOddsLegacy ? _self.homeOddsLegacy : homeOddsLegacy // ignore: cast_nullable_to_non_nullable
as double?,awayOddsLegacy: freezed == awayOddsLegacy ? _self.awayOddsLegacy : awayOddsLegacy // ignore: cast_nullable_to_non_nullable
as double?,drawOddsLegacy: freezed == drawOddsLegacy ? _self.drawOddsLegacy : drawOddsLegacy // ignore: cast_nullable_to_non_nullable
as double?,offerIdLegacy: freezed == offerIdLegacy ? _self.offerIdLegacy : offerIdLegacy // ignore: cast_nullable_to_non_nullable
as String?,selectionIdLegacy: freezed == selectionIdLegacy ? _self.selectionIdLegacy : selectionIdLegacy // ignore: cast_nullable_to_non_nullable
as String?,playerName: null == playerName ? _self.playerName : playerName // ignore: cast_nullable_to_non_nullable
as String,playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}

extension LeagueOddsDataPatterns on LeagueOddsData {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeagueOddsData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeagueOddsData() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeagueOddsData value)  $default,){
final _that = this;
switch (_that) {
case _LeagueOddsData():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeagueOddsData value)?  $default,){
final _that = this;
switch (_that) {
case _LeagueOddsData() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'p')  String points, @JsonKey(name: 'ml')  bool isMainLine, @JsonKey(name: 'shi')  String? selectionHomeId, @JsonKey(name: 'sai')  String? selectionAwayId, @JsonKey(name: 'sdi')  String? selectionDrawId, @JsonKey(name: 'soi')  String? offerId,  bool isSuspended, @JsonKey(name: 'oh', fromJson: OddsValue.fromJson, toJson: OddsValue.toJsonStatic)  OddsValue oddsHome, @JsonKey(name: 'oa', fromJson: OddsValue.fromJson, toJson: OddsValue.toJsonStatic)  OddsValue oddsAway, @JsonKey(name: 'od', fromJson: OddsValue.fromJson, toJson: OddsValue.toJsonStatic)  OddsValue oddsDraw, @JsonKey(name: 'ho')  double? homeOddsLegacy, @JsonKey(name: 'ao')  double? awayOddsLegacy, @JsonKey(name: 'do')  double? drawOddsLegacy, @JsonKey(name: 'oi')  String? offerIdLegacy, @JsonKey(name: 'si')  String? selectionIdLegacy,  String playerName,  String playerId,  int period)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeagueOddsData() when $default != null:
return $default(_that.points,_that.isMainLine,_that.selectionHomeId,_that.selectionAwayId,_that.selectionDrawId,_that.offerId,_that.isSuspended,_that.oddsHome,_that.oddsAway,_that.oddsDraw,_that.homeOddsLegacy,_that.awayOddsLegacy,_that.drawOddsLegacy,_that.offerIdLegacy,_that.selectionIdLegacy,_that.playerName,_that.playerId,_that.period);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'p')  String points, @JsonKey(name: 'ml')  bool isMainLine, @JsonKey(name: 'shi')  String? selectionHomeId, @JsonKey(name: 'sai')  String? selectionAwayId, @JsonKey(name: 'sdi')  String? selectionDrawId, @JsonKey(name: 'soi')  String? offerId,  bool isSuspended, @JsonKey(name: 'oh', fromJson: OddsValue.fromJson, toJson: OddsValue.toJsonStatic)  OddsValue oddsHome, @JsonKey(name: 'oa', fromJson: OddsValue.fromJson, toJson: OddsValue.toJsonStatic)  OddsValue oddsAway, @JsonKey(name: 'od', fromJson: OddsValue.fromJson, toJson: OddsValue.toJsonStatic)  OddsValue oddsDraw, @JsonKey(name: 'ho')  double? homeOddsLegacy, @JsonKey(name: 'ao')  double? awayOddsLegacy, @JsonKey(name: 'do')  double? drawOddsLegacy, @JsonKey(name: 'oi')  String? offerIdLegacy, @JsonKey(name: 'si')  String? selectionIdLegacy,  String playerName,  String playerId,  int period)  $default,) {final _that = this;
switch (_that) {
case _LeagueOddsData():
return $default(_that.points,_that.isMainLine,_that.selectionHomeId,_that.selectionAwayId,_that.selectionDrawId,_that.offerId,_that.isSuspended,_that.oddsHome,_that.oddsAway,_that.oddsDraw,_that.homeOddsLegacy,_that.awayOddsLegacy,_that.drawOddsLegacy,_that.offerIdLegacy,_that.selectionIdLegacy,_that.playerName,_that.playerId,_that.period);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'p')  String points, @JsonKey(name: 'ml')  bool isMainLine, @JsonKey(name: 'shi')  String? selectionHomeId, @JsonKey(name: 'sai')  String? selectionAwayId, @JsonKey(name: 'sdi')  String? selectionDrawId, @JsonKey(name: 'soi')  String? offerId,  bool isSuspended, @JsonKey(name: 'oh', fromJson: OddsValue.fromJson, toJson: OddsValue.toJsonStatic)  OddsValue oddsHome, @JsonKey(name: 'oa', fromJson: OddsValue.fromJson, toJson: OddsValue.toJsonStatic)  OddsValue oddsAway, @JsonKey(name: 'od', fromJson: OddsValue.fromJson, toJson: OddsValue.toJsonStatic)  OddsValue oddsDraw, @JsonKey(name: 'ho')  double? homeOddsLegacy, @JsonKey(name: 'ao')  double? awayOddsLegacy, @JsonKey(name: 'do')  double? drawOddsLegacy, @JsonKey(name: 'oi')  String? offerIdLegacy, @JsonKey(name: 'si')  String? selectionIdLegacy,  String playerName,  String playerId,  int period)?  $default,) {final _that = this;
switch (_that) {
case _LeagueOddsData() when $default != null:
return $default(_that.points,_that.isMainLine,_that.selectionHomeId,_that.selectionAwayId,_that.selectionDrawId,_that.offerId,_that.isSuspended,_that.oddsHome,_that.oddsAway,_that.oddsDraw,_that.homeOddsLegacy,_that.awayOddsLegacy,_that.drawOddsLegacy,_that.offerIdLegacy,_that.selectionIdLegacy,_that.playerName,_that.playerId,_that.period);case _:
  return null;

}
}

}

@JsonSerializable()

class _LeagueOddsData implements LeagueOddsData {
  const _LeagueOddsData({@JsonKey(name: 'p') this.points = '', @JsonKey(name: 'ml') this.isMainLine = false, @JsonKey(name: 'shi') this.selectionHomeId, @JsonKey(name: 'sai') this.selectionAwayId, @JsonKey(name: 'sdi') this.selectionDrawId, @JsonKey(name: 'soi') this.offerId, this.isSuspended = false, @JsonKey(name: 'oh', fromJson: OddsValue.fromJson, toJson: OddsValue.toJsonStatic) this.oddsHome = const OddsValue(), @JsonKey(name: 'oa', fromJson: OddsValue.fromJson, toJson: OddsValue.toJsonStatic) this.oddsAway = const OddsValue(), @JsonKey(name: 'od', fromJson: OddsValue.fromJson, toJson: OddsValue.toJsonStatic) this.oddsDraw = const OddsValue(), @JsonKey(name: 'ho') this.homeOddsLegacy, @JsonKey(name: 'ao') this.awayOddsLegacy, @JsonKey(name: 'do') this.drawOddsLegacy, @JsonKey(name: 'oi') this.offerIdLegacy, @JsonKey(name: 'si') this.selectionIdLegacy, this.playerName = '', this.playerId = '', this.period = 0});
  factory _LeagueOddsData.fromJson(Map<String, dynamic> json) => _$LeagueOddsDataFromJson(json);

@override@JsonKey(name: 'p') final  String points;
@override@JsonKey(name: 'ml') final  bool isMainLine;
@override@JsonKey(name: 'shi') final  String? selectionHomeId;
@override@JsonKey(name: 'sai') final  String? selectionAwayId;
@override@JsonKey(name: 'sdi') final  String? selectionDrawId;
@override@JsonKey(name: 'soi') final  String? offerId;
@override@JsonKey() final  bool isSuspended;
@override@JsonKey(name: 'oh', fromJson: OddsValue.fromJson, toJson: OddsValue.toJsonStatic) final  OddsValue oddsHome;
@override@JsonKey(name: 'oa', fromJson: OddsValue.fromJson, toJson: OddsValue.toJsonStatic) final  OddsValue oddsAway;
@override@JsonKey(name: 'od', fromJson: OddsValue.fromJson, toJson: OddsValue.toJsonStatic) final  OddsValue oddsDraw;
@override@JsonKey(name: 'ho') final  double? homeOddsLegacy;
@override@JsonKey(name: 'ao') final  double? awayOddsLegacy;
@override@JsonKey(name: 'do') final  double? drawOddsLegacy;
@override@JsonKey(name: 'oi') final  String? offerIdLegacy;
@override@JsonKey(name: 'si') final  String? selectionIdLegacy;
@override@JsonKey() final  String playerName;
@override@JsonKey() final  String playerId;
@override@JsonKey() final  int period;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeagueOddsDataCopyWith<_LeagueOddsData> get copyWith => __$LeagueOddsDataCopyWithImpl<_LeagueOddsData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeagueOddsDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeagueOddsData&&(identical(other.points, points) || other.points == points)&&(identical(other.isMainLine, isMainLine) || other.isMainLine == isMainLine)&&(identical(other.selectionHomeId, selectionHomeId) || other.selectionHomeId == selectionHomeId)&&(identical(other.selectionAwayId, selectionAwayId) || other.selectionAwayId == selectionAwayId)&&(identical(other.selectionDrawId, selectionDrawId) || other.selectionDrawId == selectionDrawId)&&(identical(other.offerId, offerId) || other.offerId == offerId)&&(identical(other.isSuspended, isSuspended) || other.isSuspended == isSuspended)&&(identical(other.oddsHome, oddsHome) || other.oddsHome == oddsHome)&&(identical(other.oddsAway, oddsAway) || other.oddsAway == oddsAway)&&(identical(other.oddsDraw, oddsDraw) || other.oddsDraw == oddsDraw)&&(identical(other.homeOddsLegacy, homeOddsLegacy) || other.homeOddsLegacy == homeOddsLegacy)&&(identical(other.awayOddsLegacy, awayOddsLegacy) || other.awayOddsLegacy == awayOddsLegacy)&&(identical(other.drawOddsLegacy, drawOddsLegacy) || other.drawOddsLegacy == drawOddsLegacy)&&(identical(other.offerIdLegacy, offerIdLegacy) || other.offerIdLegacy == offerIdLegacy)&&(identical(other.selectionIdLegacy, selectionIdLegacy) || other.selectionIdLegacy == selectionIdLegacy)&&(identical(other.playerName, playerName) || other.playerName == playerName)&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.period, period) || other.period == period));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,points,isMainLine,selectionHomeId,selectionAwayId,selectionDrawId,offerId,isSuspended,oddsHome,oddsAway,oddsDraw,homeOddsLegacy,awayOddsLegacy,drawOddsLegacy,offerIdLegacy,selectionIdLegacy,playerName,playerId,period);

@override
String toString() {
  return 'LeagueOddsData(points: $points, isMainLine: $isMainLine, selectionHomeId: $selectionHomeId, selectionAwayId: $selectionAwayId, selectionDrawId: $selectionDrawId, offerId: $offerId, isSuspended: $isSuspended, oddsHome: $oddsHome, oddsAway: $oddsAway, oddsDraw: $oddsDraw, homeOddsLegacy: $homeOddsLegacy, awayOddsLegacy: $awayOddsLegacy, drawOddsLegacy: $drawOddsLegacy, offerIdLegacy: $offerIdLegacy, selectionIdLegacy: $selectionIdLegacy, playerName: $playerName, playerId: $playerId, period: $period)';
}

}

abstract mixin class _$LeagueOddsDataCopyWith<$Res> implements $LeagueOddsDataCopyWith<$Res> {
  factory _$LeagueOddsDataCopyWith(_LeagueOddsData value, $Res Function(_LeagueOddsData) _then) = __$LeagueOddsDataCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'p') String points,@JsonKey(name: 'ml') bool isMainLine,@JsonKey(name: 'shi') String? selectionHomeId,@JsonKey(name: 'sai') String? selectionAwayId,@JsonKey(name: 'sdi') String? selectionDrawId,@JsonKey(name: 'soi') String? offerId, bool isSuspended,@JsonKey(name: 'oh', fromJson: OddsValue.fromJson, toJson: OddsValue.toJsonStatic) OddsValue oddsHome,@JsonKey(name: 'oa', fromJson: OddsValue.fromJson, toJson: OddsValue.toJsonStatic) OddsValue oddsAway,@JsonKey(name: 'od', fromJson: OddsValue.fromJson, toJson: OddsValue.toJsonStatic) OddsValue oddsDraw,@JsonKey(name: 'ho') double? homeOddsLegacy,@JsonKey(name: 'ao') double? awayOddsLegacy,@JsonKey(name: 'do') double? drawOddsLegacy,@JsonKey(name: 'oi') String? offerIdLegacy,@JsonKey(name: 'si') String? selectionIdLegacy, String playerName, String playerId, int period
});

}
class __$LeagueOddsDataCopyWithImpl<$Res>
    implements _$LeagueOddsDataCopyWith<$Res> {
  __$LeagueOddsDataCopyWithImpl(this._self, this._then);

  final _LeagueOddsData _self;
  final $Res Function(_LeagueOddsData) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? points = null,Object? isMainLine = null,Object? selectionHomeId = freezed,Object? selectionAwayId = freezed,Object? selectionDrawId = freezed,Object? offerId = freezed,Object? isSuspended = null,Object? oddsHome = null,Object? oddsAway = null,Object? oddsDraw = null,Object? homeOddsLegacy = freezed,Object? awayOddsLegacy = freezed,Object? drawOddsLegacy = freezed,Object? offerIdLegacy = freezed,Object? selectionIdLegacy = freezed,Object? playerName = null,Object? playerId = null,Object? period = null,}) {
  return _then(_LeagueOddsData(
points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as String,isMainLine: null == isMainLine ? _self.isMainLine : isMainLine // ignore: cast_nullable_to_non_nullable
as bool,selectionHomeId: freezed == selectionHomeId ? _self.selectionHomeId : selectionHomeId // ignore: cast_nullable_to_non_nullable
as String?,selectionAwayId: freezed == selectionAwayId ? _self.selectionAwayId : selectionAwayId // ignore: cast_nullable_to_non_nullable
as String?,selectionDrawId: freezed == selectionDrawId ? _self.selectionDrawId : selectionDrawId // ignore: cast_nullable_to_non_nullable
as String?,offerId: freezed == offerId ? _self.offerId : offerId // ignore: cast_nullable_to_non_nullable
as String?,isSuspended: null == isSuspended ? _self.isSuspended : isSuspended // ignore: cast_nullable_to_non_nullable
as bool,oddsHome: null == oddsHome ? _self.oddsHome : oddsHome // ignore: cast_nullable_to_non_nullable
as OddsValue,oddsAway: null == oddsAway ? _self.oddsAway : oddsAway // ignore: cast_nullable_to_non_nullable
as OddsValue,oddsDraw: null == oddsDraw ? _self.oddsDraw : oddsDraw // ignore: cast_nullable_to_non_nullable
as OddsValue,homeOddsLegacy: freezed == homeOddsLegacy ? _self.homeOddsLegacy : homeOddsLegacy // ignore: cast_nullable_to_non_nullable
as double?,awayOddsLegacy: freezed == awayOddsLegacy ? _self.awayOddsLegacy : awayOddsLegacy // ignore: cast_nullable_to_non_nullable
as double?,drawOddsLegacy: freezed == drawOddsLegacy ? _self.drawOddsLegacy : drawOddsLegacy // ignore: cast_nullable_to_non_nullable
as double?,offerIdLegacy: freezed == offerIdLegacy ? _self.offerIdLegacy : offerIdLegacy // ignore: cast_nullable_to_non_nullable
as String?,selectionIdLegacy: freezed == selectionIdLegacy ? _self.selectionIdLegacy : selectionIdLegacy // ignore: cast_nullable_to_non_nullable
as String?,playerName: null == playerName ? _self.playerName : playerName // ignore: cast_nullable_to_non_nullable
as String,playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}

mixin _$OutrightData {

@JsonKey(name: 'oi') int get outrightId;
@JsonKey(name: 'on') String get outrightName;
@JsonKey(name: 'os') List<OutrightSelection> get selections;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OutrightDataCopyWith<OutrightData> get copyWith => _$OutrightDataCopyWithImpl<OutrightData>(this as OutrightData, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutrightData&&(identical(other.outrightId, outrightId) || other.outrightId == outrightId)&&(identical(other.outrightName, outrightName) || other.outrightName == outrightName)&&const DeepCollectionEquality().equals(other.selections, selections));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,outrightId,outrightName,const DeepCollectionEquality().hash(selections));

@override
String toString() {
  return 'OutrightData(outrightId: $outrightId, outrightName: $outrightName, selections: $selections)';
}

}

abstract mixin class $OutrightDataCopyWith<$Res>  {
  factory $OutrightDataCopyWith(OutrightData value, $Res Function(OutrightData) _then) = _$OutrightDataCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'oi') int outrightId,@JsonKey(name: 'on') String outrightName,@JsonKey(name: 'os') List<OutrightSelection> selections
});

}
class _$OutrightDataCopyWithImpl<$Res>
    implements $OutrightDataCopyWith<$Res> {
  _$OutrightDataCopyWithImpl(this._self, this._then);

  final OutrightData _self;
  final $Res Function(OutrightData) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? outrightId = null,Object? outrightName = null,Object? selections = null,}) {
  return _then(_self.copyWith(
outrightId: null == outrightId ? _self.outrightId : outrightId // ignore: cast_nullable_to_non_nullable
as int,outrightName: null == outrightName ? _self.outrightName : outrightName // ignore: cast_nullable_to_non_nullable
as String,selections: null == selections ? _self.selections : selections // ignore: cast_nullable_to_non_nullable
as List<OutrightSelection>,
  ));
}

}

extension OutrightDataPatterns on OutrightData {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OutrightData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OutrightData() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OutrightData value)  $default,){
final _that = this;
switch (_that) {
case _OutrightData():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OutrightData value)?  $default,){
final _that = this;
switch (_that) {
case _OutrightData() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'oi')  int outrightId, @JsonKey(name: 'on')  String outrightName, @JsonKey(name: 'os')  List<OutrightSelection> selections)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OutrightData() when $default != null:
return $default(_that.outrightId,_that.outrightName,_that.selections);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'oi')  int outrightId, @JsonKey(name: 'on')  String outrightName, @JsonKey(name: 'os')  List<OutrightSelection> selections)  $default,) {final _that = this;
switch (_that) {
case _OutrightData():
return $default(_that.outrightId,_that.outrightName,_that.selections);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'oi')  int outrightId, @JsonKey(name: 'on')  String outrightName, @JsonKey(name: 'os')  List<OutrightSelection> selections)?  $default,) {final _that = this;
switch (_that) {
case _OutrightData() when $default != null:
return $default(_that.outrightId,_that.outrightName,_that.selections);case _:
  return null;

}
}

}

@JsonSerializable()

class _OutrightData implements OutrightData {
  const _OutrightData({@JsonKey(name: 'oi') this.outrightId = 0, @JsonKey(name: 'on') this.outrightName = '', @JsonKey(name: 'os') final  List<OutrightSelection> selections = const []}): _selections = selections;
  factory _OutrightData.fromJson(Map<String, dynamic> json) => _$OutrightDataFromJson(json);

@override@JsonKey(name: 'oi') final  int outrightId;
@override@JsonKey(name: 'on') final  String outrightName;
 final  List<OutrightSelection> _selections;
@override@JsonKey(name: 'os') List<OutrightSelection> get selections {
  if (_selections is EqualUnmodifiableListView) return _selections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selections);
}

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OutrightDataCopyWith<_OutrightData> get copyWith => __$OutrightDataCopyWithImpl<_OutrightData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OutrightDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OutrightData&&(identical(other.outrightId, outrightId) || other.outrightId == outrightId)&&(identical(other.outrightName, outrightName) || other.outrightName == outrightName)&&const DeepCollectionEquality().equals(other._selections, _selections));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,outrightId,outrightName,const DeepCollectionEquality().hash(_selections));

@override
String toString() {
  return 'OutrightData(outrightId: $outrightId, outrightName: $outrightName, selections: $selections)';
}

}

abstract mixin class _$OutrightDataCopyWith<$Res> implements $OutrightDataCopyWith<$Res> {
  factory _$OutrightDataCopyWith(_OutrightData value, $Res Function(_OutrightData) _then) = __$OutrightDataCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'oi') int outrightId,@JsonKey(name: 'on') String outrightName,@JsonKey(name: 'os') List<OutrightSelection> selections
});

}
class __$OutrightDataCopyWithImpl<$Res>
    implements _$OutrightDataCopyWith<$Res> {
  __$OutrightDataCopyWithImpl(this._self, this._then);

  final _OutrightData _self;
  final $Res Function(_OutrightData) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? outrightId = null,Object? outrightName = null,Object? selections = null,}) {
  return _then(_OutrightData(
outrightId: null == outrightId ? _self.outrightId : outrightId // ignore: cast_nullable_to_non_nullable
as int,outrightName: null == outrightName ? _self.outrightName : outrightName // ignore: cast_nullable_to_non_nullable
as String,selections: null == selections ? _self._selections : selections // ignore: cast_nullable_to_non_nullable
as List<OutrightSelection>,
  ));
}

}

mixin _$OutrightSelection {

@JsonKey(name: 'si') String get selectionId;
@JsonKey(name: 'sn') String get selectionName;
@JsonKey(name: 'od') double get odds;
@JsonKey(name: 'oi') String? get offerId;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OutrightSelectionCopyWith<OutrightSelection> get copyWith => _$OutrightSelectionCopyWithImpl<OutrightSelection>(this as OutrightSelection, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutrightSelection&&(identical(other.selectionId, selectionId) || other.selectionId == selectionId)&&(identical(other.selectionName, selectionName) || other.selectionName == selectionName)&&(identical(other.odds, odds) || other.odds == odds)&&(identical(other.offerId, offerId) || other.offerId == offerId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,selectionId,selectionName,odds,offerId);

@override
String toString() {
  return 'OutrightSelection(selectionId: $selectionId, selectionName: $selectionName, odds: $odds, offerId: $offerId)';
}

}

abstract mixin class $OutrightSelectionCopyWith<$Res>  {
  factory $OutrightSelectionCopyWith(OutrightSelection value, $Res Function(OutrightSelection) _then) = _$OutrightSelectionCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'si') String selectionId,@JsonKey(name: 'sn') String selectionName,@JsonKey(name: 'od') double odds,@JsonKey(name: 'oi') String? offerId
});

}
class _$OutrightSelectionCopyWithImpl<$Res>
    implements $OutrightSelectionCopyWith<$Res> {
  _$OutrightSelectionCopyWithImpl(this._self, this._then);

  final OutrightSelection _self;
  final $Res Function(OutrightSelection) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? selectionId = null,Object? selectionName = null,Object? odds = null,Object? offerId = freezed,}) {
  return _then(_self.copyWith(
selectionId: null == selectionId ? _self.selectionId : selectionId // ignore: cast_nullable_to_non_nullable
as String,selectionName: null == selectionName ? _self.selectionName : selectionName // ignore: cast_nullable_to_non_nullable
as String,odds: null == odds ? _self.odds : odds // ignore: cast_nullable_to_non_nullable
as double,offerId: freezed == offerId ? _self.offerId : offerId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}

extension OutrightSelectionPatterns on OutrightSelection {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OutrightSelection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OutrightSelection() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OutrightSelection value)  $default,){
final _that = this;
switch (_that) {
case _OutrightSelection():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OutrightSelection value)?  $default,){
final _that = this;
switch (_that) {
case _OutrightSelection() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'si')  String selectionId, @JsonKey(name: 'sn')  String selectionName, @JsonKey(name: 'od')  double odds, @JsonKey(name: 'oi')  String? offerId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OutrightSelection() when $default != null:
return $default(_that.selectionId,_that.selectionName,_that.odds,_that.offerId);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'si')  String selectionId, @JsonKey(name: 'sn')  String selectionName, @JsonKey(name: 'od')  double odds, @JsonKey(name: 'oi')  String? offerId)  $default,) {final _that = this;
switch (_that) {
case _OutrightSelection():
return $default(_that.selectionId,_that.selectionName,_that.odds,_that.offerId);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'si')  String selectionId, @JsonKey(name: 'sn')  String selectionName, @JsonKey(name: 'od')  double odds, @JsonKey(name: 'oi')  String? offerId)?  $default,) {final _that = this;
switch (_that) {
case _OutrightSelection() when $default != null:
return $default(_that.selectionId,_that.selectionName,_that.odds,_that.offerId);case _:
  return null;

}
}

}

@JsonSerializable()

class _OutrightSelection implements OutrightSelection {
  const _OutrightSelection({@JsonKey(name: 'si') this.selectionId = '', @JsonKey(name: 'sn') this.selectionName = '', @JsonKey(name: 'od') this.odds = 0.0, @JsonKey(name: 'oi') this.offerId});
  factory _OutrightSelection.fromJson(Map<String, dynamic> json) => _$OutrightSelectionFromJson(json);

@override@JsonKey(name: 'si') final  String selectionId;
@override@JsonKey(name: 'sn') final  String selectionName;
@override@JsonKey(name: 'od') final  double odds;
@override@JsonKey(name: 'oi') final  String? offerId;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OutrightSelectionCopyWith<_OutrightSelection> get copyWith => __$OutrightSelectionCopyWithImpl<_OutrightSelection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OutrightSelectionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OutrightSelection&&(identical(other.selectionId, selectionId) || other.selectionId == selectionId)&&(identical(other.selectionName, selectionName) || other.selectionName == selectionName)&&(identical(other.odds, odds) || other.odds == odds)&&(identical(other.offerId, offerId) || other.offerId == offerId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,selectionId,selectionName,odds,offerId);

@override
String toString() {
  return 'OutrightSelection(selectionId: $selectionId, selectionName: $selectionName, odds: $odds, offerId: $offerId)';
}

}

abstract mixin class _$OutrightSelectionCopyWith<$Res> implements $OutrightSelectionCopyWith<$Res> {
  factory _$OutrightSelectionCopyWith(_OutrightSelection value, $Res Function(_OutrightSelection) _then) = __$OutrightSelectionCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'si') String selectionId,@JsonKey(name: 'sn') String selectionName,@JsonKey(name: 'od') double odds,@JsonKey(name: 'oi') String? offerId
});

}
class __$OutrightSelectionCopyWithImpl<$Res>
    implements _$OutrightSelectionCopyWith<$Res> {
  __$OutrightSelectionCopyWithImpl(this._self, this._then);

  final _OutrightSelection _self;
  final $Res Function(_OutrightSelection) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? selectionId = null,Object? selectionName = null,Object? odds = null,Object? offerId = freezed,}) {
  return _then(_OutrightSelection(
selectionId: null == selectionId ? _self.selectionId : selectionId // ignore: cast_nullable_to_non_nullable
as String,selectionName: null == selectionName ? _self.selectionName : selectionName // ignore: cast_nullable_to_non_nullable
as String,odds: null == odds ? _self.odds : odds // ignore: cast_nullable_to_non_nullable
as double,offerId: freezed == offerId ? _self.offerId : offerId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}

// dart format on
