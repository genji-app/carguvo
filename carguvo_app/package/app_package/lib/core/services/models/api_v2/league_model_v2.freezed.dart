// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'league_model_v2.dart';

// dart format off
T _$identity<T>(T value) => value;
mixin _$LeagueModelV2 {

 List<EventModelV2> get events;
 int get sportId;
 int get leagueId;
 String get leagueName;
 String get leagueNameEn;
 String get leagueLogo;
 int get priorityOrder;
 int? get leagueOrder;
 bool get isFavorited;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeagueModelV2CopyWith<LeagueModelV2> get copyWith => _$LeagueModelV2CopyWithImpl<LeagueModelV2>(this as LeagueModelV2, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeagueModelV2&&const DeepCollectionEquality().equals(other.events, events)&&(identical(other.sportId, sportId) || other.sportId == sportId)&&(identical(other.leagueId, leagueId) || other.leagueId == leagueId)&&(identical(other.leagueName, leagueName) || other.leagueName == leagueName)&&(identical(other.leagueNameEn, leagueNameEn) || other.leagueNameEn == leagueNameEn)&&(identical(other.leagueLogo, leagueLogo) || other.leagueLogo == leagueLogo)&&(identical(other.priorityOrder, priorityOrder) || other.priorityOrder == priorityOrder)&&(identical(other.leagueOrder, leagueOrder) || other.leagueOrder == leagueOrder)&&(identical(other.isFavorited, isFavorited) || other.isFavorited == isFavorited));
}

@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(events),sportId,leagueId,leagueName,leagueNameEn,leagueLogo,priorityOrder,leagueOrder,isFavorited);

@override
String toString() {
  return 'LeagueModelV2(events: $events, sportId: $sportId, leagueId: $leagueId, leagueName: $leagueName, leagueNameEn: $leagueNameEn, leagueLogo: $leagueLogo, priorityOrder: $priorityOrder, leagueOrder: $leagueOrder, isFavorited: $isFavorited)';
}

}

abstract mixin class $LeagueModelV2CopyWith<$Res>  {
  factory $LeagueModelV2CopyWith(LeagueModelV2 value, $Res Function(LeagueModelV2) _then) = _$LeagueModelV2CopyWithImpl;
@useResult
$Res call({
 List<EventModelV2> events, int sportId, int leagueId, String leagueName, String leagueNameEn, String leagueLogo, int priorityOrder, int? leagueOrder, bool isFavorited
});

}
class _$LeagueModelV2CopyWithImpl<$Res>
    implements $LeagueModelV2CopyWith<$Res> {
  _$LeagueModelV2CopyWithImpl(this._self, this._then);

  final LeagueModelV2 _self;
  final $Res Function(LeagueModelV2) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? events = null,Object? sportId = null,Object? leagueId = null,Object? leagueName = null,Object? leagueNameEn = null,Object? leagueLogo = null,Object? priorityOrder = null,Object? leagueOrder = freezed,Object? isFavorited = null,}) {
  return _then(_self.copyWith(
events: null == events ? _self.events : events // ignore: cast_nullable_to_non_nullable
as List<EventModelV2>,sportId: null == sportId ? _self.sportId : sportId // ignore: cast_nullable_to_non_nullable
as int,leagueId: null == leagueId ? _self.leagueId : leagueId // ignore: cast_nullable_to_non_nullable
as int,leagueName: null == leagueName ? _self.leagueName : leagueName // ignore: cast_nullable_to_non_nullable
as String,leagueNameEn: null == leagueNameEn ? _self.leagueNameEn : leagueNameEn // ignore: cast_nullable_to_non_nullable
as String,leagueLogo: null == leagueLogo ? _self.leagueLogo : leagueLogo // ignore: cast_nullable_to_non_nullable
as String,priorityOrder: null == priorityOrder ? _self.priorityOrder : priorityOrder // ignore: cast_nullable_to_non_nullable
as int,leagueOrder: freezed == leagueOrder ? _self.leagueOrder : leagueOrder // ignore: cast_nullable_to_non_nullable
as int?,isFavorited: null == isFavorited ? _self.isFavorited : isFavorited // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}

extension LeagueModelV2Patterns on LeagueModelV2 {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeagueModelV2 value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeagueModelV2() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeagueModelV2 value)  $default,){
final _that = this;
switch (_that) {
case _LeagueModelV2():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeagueModelV2 value)?  $default,){
final _that = this;
switch (_that) {
case _LeagueModelV2() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<EventModelV2> events,  int sportId,  int leagueId,  String leagueName,  String leagueNameEn,  String leagueLogo,  int priorityOrder,  int? leagueOrder,  bool isFavorited)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeagueModelV2() when $default != null:
return $default(_that.events,_that.sportId,_that.leagueId,_that.leagueName,_that.leagueNameEn,_that.leagueLogo,_that.priorityOrder,_that.leagueOrder,_that.isFavorited);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<EventModelV2> events,  int sportId,  int leagueId,  String leagueName,  String leagueNameEn,  String leagueLogo,  int priorityOrder,  int? leagueOrder,  bool isFavorited)  $default,) {final _that = this;
switch (_that) {
case _LeagueModelV2():
return $default(_that.events,_that.sportId,_that.leagueId,_that.leagueName,_that.leagueNameEn,_that.leagueLogo,_that.priorityOrder,_that.leagueOrder,_that.isFavorited);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<EventModelV2> events,  int sportId,  int leagueId,  String leagueName,  String leagueNameEn,  String leagueLogo,  int priorityOrder,  int? leagueOrder,  bool isFavorited)?  $default,) {final _that = this;
switch (_that) {
case _LeagueModelV2() when $default != null:
return $default(_that.events,_that.sportId,_that.leagueId,_that.leagueName,_that.leagueNameEn,_that.leagueLogo,_that.priorityOrder,_that.leagueOrder,_that.isFavorited);case _:
  return null;

}
}

}

class _LeagueModelV2 extends LeagueModelV2 {
  const _LeagueModelV2({final  List<EventModelV2> events = const [], this.sportId = 0, this.leagueId = 0, this.leagueName = '', this.leagueNameEn = '', this.leagueLogo = '', this.priorityOrder = 0, this.leagueOrder, this.isFavorited = false}): _events = events,super._();
  
 final  List<EventModelV2> _events;
@override@JsonKey() List<EventModelV2> get events {
  if (_events is EqualUnmodifiableListView) return _events;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_events);
}

@override@JsonKey() final  int sportId;
@override@JsonKey() final  int leagueId;
@override@JsonKey() final  String leagueName;
@override@JsonKey() final  String leagueNameEn;
@override@JsonKey() final  String leagueLogo;
@override@JsonKey() final  int priorityOrder;
@override final  int? leagueOrder;
@override@JsonKey() final  bool isFavorited;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeagueModelV2CopyWith<_LeagueModelV2> get copyWith => __$LeagueModelV2CopyWithImpl<_LeagueModelV2>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeagueModelV2&&const DeepCollectionEquality().equals(other._events, _events)&&(identical(other.sportId, sportId) || other.sportId == sportId)&&(identical(other.leagueId, leagueId) || other.leagueId == leagueId)&&(identical(other.leagueName, leagueName) || other.leagueName == leagueName)&&(identical(other.leagueNameEn, leagueNameEn) || other.leagueNameEn == leagueNameEn)&&(identical(other.leagueLogo, leagueLogo) || other.leagueLogo == leagueLogo)&&(identical(other.priorityOrder, priorityOrder) || other.priorityOrder == priorityOrder)&&(identical(other.leagueOrder, leagueOrder) || other.leagueOrder == leagueOrder)&&(identical(other.isFavorited, isFavorited) || other.isFavorited == isFavorited));
}

@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_events),sportId,leagueId,leagueName,leagueNameEn,leagueLogo,priorityOrder,leagueOrder,isFavorited);

@override
String toString() {
  return 'LeagueModelV2(events: $events, sportId: $sportId, leagueId: $leagueId, leagueName: $leagueName, leagueNameEn: $leagueNameEn, leagueLogo: $leagueLogo, priorityOrder: $priorityOrder, leagueOrder: $leagueOrder, isFavorited: $isFavorited)';
}

}

abstract mixin class _$LeagueModelV2CopyWith<$Res> implements $LeagueModelV2CopyWith<$Res> {
  factory _$LeagueModelV2CopyWith(_LeagueModelV2 value, $Res Function(_LeagueModelV2) _then) = __$LeagueModelV2CopyWithImpl;
@override @useResult
$Res call({
 List<EventModelV2> events, int sportId, int leagueId, String leagueName, String leagueNameEn, String leagueLogo, int priorityOrder, int? leagueOrder, bool isFavorited
});

}
class __$LeagueModelV2CopyWithImpl<$Res>
    implements _$LeagueModelV2CopyWith<$Res> {
  __$LeagueModelV2CopyWithImpl(this._self, this._then);

  final _LeagueModelV2 _self;
  final $Res Function(_LeagueModelV2) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? events = null,Object? sportId = null,Object? leagueId = null,Object? leagueName = null,Object? leagueNameEn = null,Object? leagueLogo = null,Object? priorityOrder = null,Object? leagueOrder = freezed,Object? isFavorited = null,}) {
  return _then(_LeagueModelV2(
events: null == events ? _self._events : events // ignore: cast_nullable_to_non_nullable
as List<EventModelV2>,sportId: null == sportId ? _self.sportId : sportId // ignore: cast_nullable_to_non_nullable
as int,leagueId: null == leagueId ? _self.leagueId : leagueId // ignore: cast_nullable_to_non_nullable
as int,leagueName: null == leagueName ? _self.leagueName : leagueName // ignore: cast_nullable_to_non_nullable
as String,leagueNameEn: null == leagueNameEn ? _self.leagueNameEn : leagueNameEn // ignore: cast_nullable_to_non_nullable
as String,leagueLogo: null == leagueLogo ? _self.leagueLogo : leagueLogo // ignore: cast_nullable_to_non_nullable
as String,priorityOrder: null == priorityOrder ? _self.priorityOrder : priorityOrder // ignore: cast_nullable_to_non_nullable
as int,leagueOrder: freezed == leagueOrder ? _self.leagueOrder : leagueOrder // ignore: cast_nullable_to_non_nullable
as int?,isFavorited: null == isFavorited ? _self.isFavorited : isFavorited // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}

// dart format on
