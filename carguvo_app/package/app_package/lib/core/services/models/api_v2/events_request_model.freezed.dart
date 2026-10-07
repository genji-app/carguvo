// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'events_request_model.dart';

// dart format off
T _$identity<T>(T value) => value;
mixin _$EventsRequestModel {

 int get sportId;
 int get timeRange;
 int? get sportTypeId;
 int? get teamId;
 List<int>? get leagueIds;
 String? get date;
 int get tzOffset;
 bool get isMobile;
 bool get sortByTime;
 bool get onlyPinLeague;
 bool get onlyParlay;
 bool get onlyGs;
 bool get isLiveStream;
 bool get isLiveTracker;
 bool get isSportRadar;
 bool get isCashOut;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventsRequestModelCopyWith<EventsRequestModel> get copyWith => _$EventsRequestModelCopyWithImpl<EventsRequestModel>(this as EventsRequestModel, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventsRequestModel&&(identical(other.sportId, sportId) || other.sportId == sportId)&&(identical(other.timeRange, timeRange) || other.timeRange == timeRange)&&(identical(other.sportTypeId, sportTypeId) || other.sportTypeId == sportTypeId)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&const DeepCollectionEquality().equals(other.leagueIds, leagueIds)&&(identical(other.date, date) || other.date == date)&&(identical(other.tzOffset, tzOffset) || other.tzOffset == tzOffset)&&(identical(other.isMobile, isMobile) || other.isMobile == isMobile)&&(identical(other.sortByTime, sortByTime) || other.sortByTime == sortByTime)&&(identical(other.onlyPinLeague, onlyPinLeague) || other.onlyPinLeague == onlyPinLeague)&&(identical(other.onlyParlay, onlyParlay) || other.onlyParlay == onlyParlay)&&(identical(other.onlyGs, onlyGs) || other.onlyGs == onlyGs)&&(identical(other.isLiveStream, isLiveStream) || other.isLiveStream == isLiveStream)&&(identical(other.isLiveTracker, isLiveTracker) || other.isLiveTracker == isLiveTracker)&&(identical(other.isSportRadar, isSportRadar) || other.isSportRadar == isSportRadar)&&(identical(other.isCashOut, isCashOut) || other.isCashOut == isCashOut));
}

@override
int get hashCode => Object.hash(runtimeType,sportId,timeRange,sportTypeId,teamId,const DeepCollectionEquality().hash(leagueIds),date,tzOffset,isMobile,sortByTime,onlyPinLeague,onlyParlay,onlyGs,isLiveStream,isLiveTracker,isSportRadar,isCashOut);

@override
String toString() {
  return 'EventsRequestModel(sportId: $sportId, timeRange: $timeRange, sportTypeId: $sportTypeId, teamId: $teamId, leagueIds: $leagueIds, date: $date, tzOffset: $tzOffset, isMobile: $isMobile, sortByTime: $sortByTime, onlyPinLeague: $onlyPinLeague, onlyParlay: $onlyParlay, onlyGs: $onlyGs, isLiveStream: $isLiveStream, isLiveTracker: $isLiveTracker, isSportRadar: $isSportRadar, isCashOut: $isCashOut)';
}

}

abstract mixin class $EventsRequestModelCopyWith<$Res>  {
  factory $EventsRequestModelCopyWith(EventsRequestModel value, $Res Function(EventsRequestModel) _then) = _$EventsRequestModelCopyWithImpl;
@useResult
$Res call({
 int sportId, int timeRange, int? sportTypeId, int? teamId, List<int>? leagueIds, String? date, int tzOffset, bool isMobile, bool sortByTime, bool onlyPinLeague, bool onlyParlay, bool onlyGs, bool isLiveStream, bool isLiveTracker, bool isSportRadar, bool isCashOut
});

}
class _$EventsRequestModelCopyWithImpl<$Res>
    implements $EventsRequestModelCopyWith<$Res> {
  _$EventsRequestModelCopyWithImpl(this._self, this._then);

  final EventsRequestModel _self;
  final $Res Function(EventsRequestModel) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? sportId = null,Object? timeRange = null,Object? sportTypeId = freezed,Object? teamId = freezed,Object? leagueIds = freezed,Object? date = freezed,Object? tzOffset = null,Object? isMobile = null,Object? sortByTime = null,Object? onlyPinLeague = null,Object? onlyParlay = null,Object? onlyGs = null,Object? isLiveStream = null,Object? isLiveTracker = null,Object? isSportRadar = null,Object? isCashOut = null,}) {
  return _then(_self.copyWith(
sportId: null == sportId ? _self.sportId : sportId // ignore: cast_nullable_to_non_nullable
as int,timeRange: null == timeRange ? _self.timeRange : timeRange // ignore: cast_nullable_to_non_nullable
as int,sportTypeId: freezed == sportTypeId ? _self.sportTypeId : sportTypeId // ignore: cast_nullable_to_non_nullable
as int?,teamId: freezed == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as int?,leagueIds: freezed == leagueIds ? _self.leagueIds : leagueIds // ignore: cast_nullable_to_non_nullable
as List<int>?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String?,tzOffset: null == tzOffset ? _self.tzOffset : tzOffset // ignore: cast_nullable_to_non_nullable
as int,isMobile: null == isMobile ? _self.isMobile : isMobile // ignore: cast_nullable_to_non_nullable
as bool,sortByTime: null == sortByTime ? _self.sortByTime : sortByTime // ignore: cast_nullable_to_non_nullable
as bool,onlyPinLeague: null == onlyPinLeague ? _self.onlyPinLeague : onlyPinLeague // ignore: cast_nullable_to_non_nullable
as bool,onlyParlay: null == onlyParlay ? _self.onlyParlay : onlyParlay // ignore: cast_nullable_to_non_nullable
as bool,onlyGs: null == onlyGs ? _self.onlyGs : onlyGs // ignore: cast_nullable_to_non_nullable
as bool,isLiveStream: null == isLiveStream ? _self.isLiveStream : isLiveStream // ignore: cast_nullable_to_non_nullable
as bool,isLiveTracker: null == isLiveTracker ? _self.isLiveTracker : isLiveTracker // ignore: cast_nullable_to_non_nullable
as bool,isSportRadar: null == isSportRadar ? _self.isSportRadar : isSportRadar // ignore: cast_nullable_to_non_nullable
as bool,isCashOut: null == isCashOut ? _self.isCashOut : isCashOut // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}

extension EventsRequestModelPatterns on EventsRequestModel {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventsRequestModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventsRequestModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventsRequestModel value)  $default,){
final _that = this;
switch (_that) {
case _EventsRequestModel():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventsRequestModel value)?  $default,){
final _that = this;
switch (_that) {
case _EventsRequestModel() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int sportId,  int timeRange,  int? sportTypeId,  int? teamId,  List<int>? leagueIds,  String? date,  int tzOffset,  bool isMobile,  bool sortByTime,  bool onlyPinLeague,  bool onlyParlay,  bool onlyGs,  bool isLiveStream,  bool isLiveTracker,  bool isSportRadar,  bool isCashOut)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventsRequestModel() when $default != null:
return $default(_that.sportId,_that.timeRange,_that.sportTypeId,_that.teamId,_that.leagueIds,_that.date,_that.tzOffset,_that.isMobile,_that.sortByTime,_that.onlyPinLeague,_that.onlyParlay,_that.onlyGs,_that.isLiveStream,_that.isLiveTracker,_that.isSportRadar,_that.isCashOut);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int sportId,  int timeRange,  int? sportTypeId,  int? teamId,  List<int>? leagueIds,  String? date,  int tzOffset,  bool isMobile,  bool sortByTime,  bool onlyPinLeague,  bool onlyParlay,  bool onlyGs,  bool isLiveStream,  bool isLiveTracker,  bool isSportRadar,  bool isCashOut)  $default,) {final _that = this;
switch (_that) {
case _EventsRequestModel():
return $default(_that.sportId,_that.timeRange,_that.sportTypeId,_that.teamId,_that.leagueIds,_that.date,_that.tzOffset,_that.isMobile,_that.sortByTime,_that.onlyPinLeague,_that.onlyParlay,_that.onlyGs,_that.isLiveStream,_that.isLiveTracker,_that.isSportRadar,_that.isCashOut);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int sportId,  int timeRange,  int? sportTypeId,  int? teamId,  List<int>? leagueIds,  String? date,  int tzOffset,  bool isMobile,  bool sortByTime,  bool onlyPinLeague,  bool onlyParlay,  bool onlyGs,  bool isLiveStream,  bool isLiveTracker,  bool isSportRadar,  bool isCashOut)?  $default,) {final _that = this;
switch (_that) {
case _EventsRequestModel() when $default != null:
return $default(_that.sportId,_that.timeRange,_that.sportTypeId,_that.teamId,_that.leagueIds,_that.date,_that.tzOffset,_that.isMobile,_that.sortByTime,_that.onlyPinLeague,_that.onlyParlay,_that.onlyGs,_that.isLiveStream,_that.isLiveTracker,_that.isSportRadar,_that.isCashOut);case _:
  return null;

}
}

}

class _EventsRequestModel extends EventsRequestModel {
  const _EventsRequestModel({required this.sportId, this.timeRange = 0, this.sportTypeId, this.teamId, final  List<int>? leagueIds, this.date, this.tzOffset = -420, this.isMobile = true, this.sortByTime = false, this.onlyPinLeague = false, this.onlyParlay = false, this.onlyGs = false, this.isLiveStream = false, this.isLiveTracker = false, this.isSportRadar = false, this.isCashOut = false}): _leagueIds = leagueIds,super._();
  
@override final  int sportId;
@override@JsonKey() final  int timeRange;
@override final  int? sportTypeId;
@override final  int? teamId;
 final  List<int>? _leagueIds;
@override List<int>? get leagueIds {
  final value = _leagueIds;
  if (value == null) return null;
  if (_leagueIds is EqualUnmodifiableListView) return _leagueIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? date;
@override@JsonKey() final  int tzOffset;
@override@JsonKey() final  bool isMobile;
@override@JsonKey() final  bool sortByTime;
@override@JsonKey() final  bool onlyPinLeague;
@override@JsonKey() final  bool onlyParlay;
@override@JsonKey() final  bool onlyGs;
@override@JsonKey() final  bool isLiveStream;
@override@JsonKey() final  bool isLiveTracker;
@override@JsonKey() final  bool isSportRadar;
@override@JsonKey() final  bool isCashOut;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventsRequestModelCopyWith<_EventsRequestModel> get copyWith => __$EventsRequestModelCopyWithImpl<_EventsRequestModel>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventsRequestModel&&(identical(other.sportId, sportId) || other.sportId == sportId)&&(identical(other.timeRange, timeRange) || other.timeRange == timeRange)&&(identical(other.sportTypeId, sportTypeId) || other.sportTypeId == sportTypeId)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&const DeepCollectionEquality().equals(other._leagueIds, _leagueIds)&&(identical(other.date, date) || other.date == date)&&(identical(other.tzOffset, tzOffset) || other.tzOffset == tzOffset)&&(identical(other.isMobile, isMobile) || other.isMobile == isMobile)&&(identical(other.sortByTime, sortByTime) || other.sortByTime == sortByTime)&&(identical(other.onlyPinLeague, onlyPinLeague) || other.onlyPinLeague == onlyPinLeague)&&(identical(other.onlyParlay, onlyParlay) || other.onlyParlay == onlyParlay)&&(identical(other.onlyGs, onlyGs) || other.onlyGs == onlyGs)&&(identical(other.isLiveStream, isLiveStream) || other.isLiveStream == isLiveStream)&&(identical(other.isLiveTracker, isLiveTracker) || other.isLiveTracker == isLiveTracker)&&(identical(other.isSportRadar, isSportRadar) || other.isSportRadar == isSportRadar)&&(identical(other.isCashOut, isCashOut) || other.isCashOut == isCashOut));
}

@override
int get hashCode => Object.hash(runtimeType,sportId,timeRange,sportTypeId,teamId,const DeepCollectionEquality().hash(_leagueIds),date,tzOffset,isMobile,sortByTime,onlyPinLeague,onlyParlay,onlyGs,isLiveStream,isLiveTracker,isSportRadar,isCashOut);

@override
String toString() {
  return 'EventsRequestModel(sportId: $sportId, timeRange: $timeRange, sportTypeId: $sportTypeId, teamId: $teamId, leagueIds: $leagueIds, date: $date, tzOffset: $tzOffset, isMobile: $isMobile, sortByTime: $sortByTime, onlyPinLeague: $onlyPinLeague, onlyParlay: $onlyParlay, onlyGs: $onlyGs, isLiveStream: $isLiveStream, isLiveTracker: $isLiveTracker, isSportRadar: $isSportRadar, isCashOut: $isCashOut)';
}

}

abstract mixin class _$EventsRequestModelCopyWith<$Res> implements $EventsRequestModelCopyWith<$Res> {
  factory _$EventsRequestModelCopyWith(_EventsRequestModel value, $Res Function(_EventsRequestModel) _then) = __$EventsRequestModelCopyWithImpl;
@override @useResult
$Res call({
 int sportId, int timeRange, int? sportTypeId, int? teamId, List<int>? leagueIds, String? date, int tzOffset, bool isMobile, bool sortByTime, bool onlyPinLeague, bool onlyParlay, bool onlyGs, bool isLiveStream, bool isLiveTracker, bool isSportRadar, bool isCashOut
});

}
class __$EventsRequestModelCopyWithImpl<$Res>
    implements _$EventsRequestModelCopyWith<$Res> {
  __$EventsRequestModelCopyWithImpl(this._self, this._then);

  final _EventsRequestModel _self;
  final $Res Function(_EventsRequestModel) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? sportId = null,Object? timeRange = null,Object? sportTypeId = freezed,Object? teamId = freezed,Object? leagueIds = freezed,Object? date = freezed,Object? tzOffset = null,Object? isMobile = null,Object? sortByTime = null,Object? onlyPinLeague = null,Object? onlyParlay = null,Object? onlyGs = null,Object? isLiveStream = null,Object? isLiveTracker = null,Object? isSportRadar = null,Object? isCashOut = null,}) {
  return _then(_EventsRequestModel(
sportId: null == sportId ? _self.sportId : sportId // ignore: cast_nullable_to_non_nullable
as int,timeRange: null == timeRange ? _self.timeRange : timeRange // ignore: cast_nullable_to_non_nullable
as int,sportTypeId: freezed == sportTypeId ? _self.sportTypeId : sportTypeId // ignore: cast_nullable_to_non_nullable
as int?,teamId: freezed == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as int?,leagueIds: freezed == leagueIds ? _self._leagueIds : leagueIds // ignore: cast_nullable_to_non_nullable
as List<int>?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String?,tzOffset: null == tzOffset ? _self.tzOffset : tzOffset // ignore: cast_nullable_to_non_nullable
as int,isMobile: null == isMobile ? _self.isMobile : isMobile // ignore: cast_nullable_to_non_nullable
as bool,sortByTime: null == sortByTime ? _self.sortByTime : sortByTime // ignore: cast_nullable_to_non_nullable
as bool,onlyPinLeague: null == onlyPinLeague ? _self.onlyPinLeague : onlyPinLeague // ignore: cast_nullable_to_non_nullable
as bool,onlyParlay: null == onlyParlay ? _self.onlyParlay : onlyParlay // ignore: cast_nullable_to_non_nullable
as bool,onlyGs: null == onlyGs ? _self.onlyGs : onlyGs // ignore: cast_nullable_to_non_nullable
as bool,isLiveStream: null == isLiveStream ? _self.isLiveStream : isLiveStream // ignore: cast_nullable_to_non_nullable
as bool,isLiveTracker: null == isLiveTracker ? _self.isLiveTracker : isLiveTracker // ignore: cast_nullable_to_non_nullable
as bool,isSportRadar: null == isSportRadar ? _self.isSportRadar : isSportRadar // ignore: cast_nullable_to_non_nullable
as bool,isCashOut: null == isCashOut ? _self.isCashOut : isCashOut // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}

// dart format on
