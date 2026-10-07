// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'market_model_v2.dart';

// dart format off
T _$identity<T>(T value) => value;
mixin _$MarketModelV2 {

 List<OddsModelV2> get oddsList;
 int get sportId;
 int get leagueId;
 int get eventId;
 int get marketId;
 bool get isSuspended;
 bool get isParlay;
 bool get isCashOut;
 int get promotionType;
 int get groupId;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarketModelV2CopyWith<MarketModelV2> get copyWith => _$MarketModelV2CopyWithImpl<MarketModelV2>(this as MarketModelV2, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarketModelV2&&const DeepCollectionEquality().equals(other.oddsList, oddsList)&&(identical(other.sportId, sportId) || other.sportId == sportId)&&(identical(other.leagueId, leagueId) || other.leagueId == leagueId)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.marketId, marketId) || other.marketId == marketId)&&(identical(other.isSuspended, isSuspended) || other.isSuspended == isSuspended)&&(identical(other.isParlay, isParlay) || other.isParlay == isParlay)&&(identical(other.isCashOut, isCashOut) || other.isCashOut == isCashOut)&&(identical(other.promotionType, promotionType) || other.promotionType == promotionType)&&(identical(other.groupId, groupId) || other.groupId == groupId));
}

@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(oddsList),sportId,leagueId,eventId,marketId,isSuspended,isParlay,isCashOut,promotionType,groupId);

@override
String toString() {
  return 'MarketModelV2(oddsList: $oddsList, sportId: $sportId, leagueId: $leagueId, eventId: $eventId, marketId: $marketId, isSuspended: $isSuspended, isParlay: $isParlay, isCashOut: $isCashOut, promotionType: $promotionType, groupId: $groupId)';
}

}

abstract mixin class $MarketModelV2CopyWith<$Res>  {
  factory $MarketModelV2CopyWith(MarketModelV2 value, $Res Function(MarketModelV2) _then) = _$MarketModelV2CopyWithImpl;
@useResult
$Res call({
 List<OddsModelV2> oddsList, int sportId, int leagueId, int eventId, int marketId, bool isSuspended, bool isParlay, bool isCashOut, int promotionType, int groupId
});

}
class _$MarketModelV2CopyWithImpl<$Res>
    implements $MarketModelV2CopyWith<$Res> {
  _$MarketModelV2CopyWithImpl(this._self, this._then);

  final MarketModelV2 _self;
  final $Res Function(MarketModelV2) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? oddsList = null,Object? sportId = null,Object? leagueId = null,Object? eventId = null,Object? marketId = null,Object? isSuspended = null,Object? isParlay = null,Object? isCashOut = null,Object? promotionType = null,Object? groupId = null,}) {
  return _then(_self.copyWith(
oddsList: null == oddsList ? _self.oddsList : oddsList // ignore: cast_nullable_to_non_nullable
as List<OddsModelV2>,sportId: null == sportId ? _self.sportId : sportId // ignore: cast_nullable_to_non_nullable
as int,leagueId: null == leagueId ? _self.leagueId : leagueId // ignore: cast_nullable_to_non_nullable
as int,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as int,marketId: null == marketId ? _self.marketId : marketId // ignore: cast_nullable_to_non_nullable
as int,isSuspended: null == isSuspended ? _self.isSuspended : isSuspended // ignore: cast_nullable_to_non_nullable
as bool,isParlay: null == isParlay ? _self.isParlay : isParlay // ignore: cast_nullable_to_non_nullable
as bool,isCashOut: null == isCashOut ? _self.isCashOut : isCashOut // ignore: cast_nullable_to_non_nullable
as bool,promotionType: null == promotionType ? _self.promotionType : promotionType // ignore: cast_nullable_to_non_nullable
as int,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}

extension MarketModelV2Patterns on MarketModelV2 {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MarketModelV2 value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MarketModelV2() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MarketModelV2 value)  $default,){
final _that = this;
switch (_that) {
case _MarketModelV2():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MarketModelV2 value)?  $default,){
final _that = this;
switch (_that) {
case _MarketModelV2() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<OddsModelV2> oddsList,  int sportId,  int leagueId,  int eventId,  int marketId,  bool isSuspended,  bool isParlay,  bool isCashOut,  int promotionType,  int groupId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MarketModelV2() when $default != null:
return $default(_that.oddsList,_that.sportId,_that.leagueId,_that.eventId,_that.marketId,_that.isSuspended,_that.isParlay,_that.isCashOut,_that.promotionType,_that.groupId);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<OddsModelV2> oddsList,  int sportId,  int leagueId,  int eventId,  int marketId,  bool isSuspended,  bool isParlay,  bool isCashOut,  int promotionType,  int groupId)  $default,) {final _that = this;
switch (_that) {
case _MarketModelV2():
return $default(_that.oddsList,_that.sportId,_that.leagueId,_that.eventId,_that.marketId,_that.isSuspended,_that.isParlay,_that.isCashOut,_that.promotionType,_that.groupId);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<OddsModelV2> oddsList,  int sportId,  int leagueId,  int eventId,  int marketId,  bool isSuspended,  bool isParlay,  bool isCashOut,  int promotionType,  int groupId)?  $default,) {final _that = this;
switch (_that) {
case _MarketModelV2() when $default != null:
return $default(_that.oddsList,_that.sportId,_that.leagueId,_that.eventId,_that.marketId,_that.isSuspended,_that.isParlay,_that.isCashOut,_that.promotionType,_that.groupId);case _:
  return null;

}
}

}

class _MarketModelV2 extends MarketModelV2 {
  const _MarketModelV2({final  List<OddsModelV2> oddsList = const [], this.sportId = 0, this.leagueId = 0, this.eventId = 0, this.marketId = 0, this.isSuspended = false, this.isParlay = false, this.isCashOut = false, this.promotionType = 0, this.groupId = 0}): _oddsList = oddsList,super._();
  
 final  List<OddsModelV2> _oddsList;
@override@JsonKey() List<OddsModelV2> get oddsList {
  if (_oddsList is EqualUnmodifiableListView) return _oddsList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_oddsList);
}

@override@JsonKey() final  int sportId;
@override@JsonKey() final  int leagueId;
@override@JsonKey() final  int eventId;
@override@JsonKey() final  int marketId;
@override@JsonKey() final  bool isSuspended;
@override@JsonKey() final  bool isParlay;
@override@JsonKey() final  bool isCashOut;
@override@JsonKey() final  int promotionType;
@override@JsonKey() final  int groupId;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MarketModelV2CopyWith<_MarketModelV2> get copyWith => __$MarketModelV2CopyWithImpl<_MarketModelV2>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MarketModelV2&&const DeepCollectionEquality().equals(other._oddsList, _oddsList)&&(identical(other.sportId, sportId) || other.sportId == sportId)&&(identical(other.leagueId, leagueId) || other.leagueId == leagueId)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.marketId, marketId) || other.marketId == marketId)&&(identical(other.isSuspended, isSuspended) || other.isSuspended == isSuspended)&&(identical(other.isParlay, isParlay) || other.isParlay == isParlay)&&(identical(other.isCashOut, isCashOut) || other.isCashOut == isCashOut)&&(identical(other.promotionType, promotionType) || other.promotionType == promotionType)&&(identical(other.groupId, groupId) || other.groupId == groupId));
}

@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_oddsList),sportId,leagueId,eventId,marketId,isSuspended,isParlay,isCashOut,promotionType,groupId);

@override
String toString() {
  return 'MarketModelV2(oddsList: $oddsList, sportId: $sportId, leagueId: $leagueId, eventId: $eventId, marketId: $marketId, isSuspended: $isSuspended, isParlay: $isParlay, isCashOut: $isCashOut, promotionType: $promotionType, groupId: $groupId)';
}

}

abstract mixin class _$MarketModelV2CopyWith<$Res> implements $MarketModelV2CopyWith<$Res> {
  factory _$MarketModelV2CopyWith(_MarketModelV2 value, $Res Function(_MarketModelV2) _then) = __$MarketModelV2CopyWithImpl;
@override @useResult
$Res call({
 List<OddsModelV2> oddsList, int sportId, int leagueId, int eventId, int marketId, bool isSuspended, bool isParlay, bool isCashOut, int promotionType, int groupId
});

}
class __$MarketModelV2CopyWithImpl<$Res>
    implements _$MarketModelV2CopyWith<$Res> {
  __$MarketModelV2CopyWithImpl(this._self, this._then);

  final _MarketModelV2 _self;
  final $Res Function(_MarketModelV2) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? oddsList = null,Object? sportId = null,Object? leagueId = null,Object? eventId = null,Object? marketId = null,Object? isSuspended = null,Object? isParlay = null,Object? isCashOut = null,Object? promotionType = null,Object? groupId = null,}) {
  return _then(_MarketModelV2(
oddsList: null == oddsList ? _self._oddsList : oddsList // ignore: cast_nullable_to_non_nullable
as List<OddsModelV2>,sportId: null == sportId ? _self.sportId : sportId // ignore: cast_nullable_to_non_nullable
as int,leagueId: null == leagueId ? _self.leagueId : leagueId // ignore: cast_nullable_to_non_nullable
as int,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as int,marketId: null == marketId ? _self.marketId : marketId // ignore: cast_nullable_to_non_nullable
as int,isSuspended: null == isSuspended ? _self.isSuspended : isSuspended // ignore: cast_nullable_to_non_nullable
as bool,isParlay: null == isParlay ? _self.isParlay : isParlay // ignore: cast_nullable_to_non_nullable
as bool,isCashOut: null == isCashOut ? _self.isCashOut : isCashOut // ignore: cast_nullable_to_non_nullable
as bool,promotionType: null == promotionType ? _self.promotionType : promotionType // ignore: cast_nullable_to_non_nullable
as int,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}

// dart format on
