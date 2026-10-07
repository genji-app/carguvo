// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'odds_model_v2.dart';

// dart format off
T _$identity<T>(T value) => value;
mixin _$OddsModelV2 {

 String get selectionHomeId;
 String get selectionAwayId;
 String get selectionDrawId;
 String get points;
 OddsStyleModelV2? get homeOdds;
 OddsStyleModelV2? get awayOdds;
 OddsStyleModelV2? get drawOdds;
 String get strOfferId;
 bool get isMainLine;
 bool get isSuspended;
 bool get isHidden;
 String get playerName;
 String get playerId;
 int get period;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OddsModelV2CopyWith<OddsModelV2> get copyWith => _$OddsModelV2CopyWithImpl<OddsModelV2>(this as OddsModelV2, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OddsModelV2&&(identical(other.selectionHomeId, selectionHomeId) || other.selectionHomeId == selectionHomeId)&&(identical(other.selectionAwayId, selectionAwayId) || other.selectionAwayId == selectionAwayId)&&(identical(other.selectionDrawId, selectionDrawId) || other.selectionDrawId == selectionDrawId)&&(identical(other.points, points) || other.points == points)&&(identical(other.homeOdds, homeOdds) || other.homeOdds == homeOdds)&&(identical(other.awayOdds, awayOdds) || other.awayOdds == awayOdds)&&(identical(other.drawOdds, drawOdds) || other.drawOdds == drawOdds)&&(identical(other.strOfferId, strOfferId) || other.strOfferId == strOfferId)&&(identical(other.isMainLine, isMainLine) || other.isMainLine == isMainLine)&&(identical(other.isSuspended, isSuspended) || other.isSuspended == isSuspended)&&(identical(other.isHidden, isHidden) || other.isHidden == isHidden)&&(identical(other.playerName, playerName) || other.playerName == playerName)&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.period, period) || other.period == period));
}

@override
int get hashCode => Object.hash(runtimeType,selectionHomeId,selectionAwayId,selectionDrawId,points,homeOdds,awayOdds,drawOdds,strOfferId,isMainLine,isSuspended,isHidden,playerName,playerId,period);

@override
String toString() {
  return 'OddsModelV2(selectionHomeId: $selectionHomeId, selectionAwayId: $selectionAwayId, selectionDrawId: $selectionDrawId, points: $points, homeOdds: $homeOdds, awayOdds: $awayOdds, drawOdds: $drawOdds, strOfferId: $strOfferId, isMainLine: $isMainLine, isSuspended: $isSuspended, isHidden: $isHidden, playerName: $playerName, playerId: $playerId, period: $period)';
}

}

abstract mixin class $OddsModelV2CopyWith<$Res>  {
  factory $OddsModelV2CopyWith(OddsModelV2 value, $Res Function(OddsModelV2) _then) = _$OddsModelV2CopyWithImpl;
@useResult
$Res call({
 String selectionHomeId, String selectionAwayId, String selectionDrawId, String points, OddsStyleModelV2? homeOdds, OddsStyleModelV2? awayOdds, OddsStyleModelV2? drawOdds, String strOfferId, bool isMainLine, bool isSuspended, bool isHidden, String playerName, String playerId, int period
});

$OddsStyleModelV2CopyWith<$Res>? get homeOdds;$OddsStyleModelV2CopyWith<$Res>? get awayOdds;$OddsStyleModelV2CopyWith<$Res>? get drawOdds;

}
class _$OddsModelV2CopyWithImpl<$Res>
    implements $OddsModelV2CopyWith<$Res> {
  _$OddsModelV2CopyWithImpl(this._self, this._then);

  final OddsModelV2 _self;
  final $Res Function(OddsModelV2) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? selectionHomeId = null,Object? selectionAwayId = null,Object? selectionDrawId = null,Object? points = null,Object? homeOdds = freezed,Object? awayOdds = freezed,Object? drawOdds = freezed,Object? strOfferId = null,Object? isMainLine = null,Object? isSuspended = null,Object? isHidden = null,Object? playerName = null,Object? playerId = null,Object? period = null,}) {
  return _then(_self.copyWith(
selectionHomeId: null == selectionHomeId ? _self.selectionHomeId : selectionHomeId // ignore: cast_nullable_to_non_nullable
as String,selectionAwayId: null == selectionAwayId ? _self.selectionAwayId : selectionAwayId // ignore: cast_nullable_to_non_nullable
as String,selectionDrawId: null == selectionDrawId ? _self.selectionDrawId : selectionDrawId // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as String,homeOdds: freezed == homeOdds ? _self.homeOdds : homeOdds // ignore: cast_nullable_to_non_nullable
as OddsStyleModelV2?,awayOdds: freezed == awayOdds ? _self.awayOdds : awayOdds // ignore: cast_nullable_to_non_nullable
as OddsStyleModelV2?,drawOdds: freezed == drawOdds ? _self.drawOdds : drawOdds // ignore: cast_nullable_to_non_nullable
as OddsStyleModelV2?,strOfferId: null == strOfferId ? _self.strOfferId : strOfferId // ignore: cast_nullable_to_non_nullable
as String,isMainLine: null == isMainLine ? _self.isMainLine : isMainLine // ignore: cast_nullable_to_non_nullable
as bool,isSuspended: null == isSuspended ? _self.isSuspended : isSuspended // ignore: cast_nullable_to_non_nullable
as bool,isHidden: null == isHidden ? _self.isHidden : isHidden // ignore: cast_nullable_to_non_nullable
as bool,playerName: null == playerName ? _self.playerName : playerName // ignore: cast_nullable_to_non_nullable
as String,playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
@override
@pragma('vm:prefer-inline')
$OddsStyleModelV2CopyWith<$Res>? get homeOdds {
    if (_self.homeOdds == null) {
    return null;
  }

  return $OddsStyleModelV2CopyWith<$Res>(_self.homeOdds!, (value) {
    return _then(_self.copyWith(homeOdds: value));
  });
}
@override
@pragma('vm:prefer-inline')
$OddsStyleModelV2CopyWith<$Res>? get awayOdds {
    if (_self.awayOdds == null) {
    return null;
  }

  return $OddsStyleModelV2CopyWith<$Res>(_self.awayOdds!, (value) {
    return _then(_self.copyWith(awayOdds: value));
  });
}
@override
@pragma('vm:prefer-inline')
$OddsStyleModelV2CopyWith<$Res>? get drawOdds {
    if (_self.drawOdds == null) {
    return null;
  }

  return $OddsStyleModelV2CopyWith<$Res>(_self.drawOdds!, (value) {
    return _then(_self.copyWith(drawOdds: value));
  });
}
}

extension OddsModelV2Patterns on OddsModelV2 {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OddsModelV2 value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OddsModelV2() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OddsModelV2 value)  $default,){
final _that = this;
switch (_that) {
case _OddsModelV2():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OddsModelV2 value)?  $default,){
final _that = this;
switch (_that) {
case _OddsModelV2() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String selectionHomeId,  String selectionAwayId,  String selectionDrawId,  String points,  OddsStyleModelV2? homeOdds,  OddsStyleModelV2? awayOdds,  OddsStyleModelV2? drawOdds,  String strOfferId,  bool isMainLine,  bool isSuspended,  bool isHidden,  String playerName,  String playerId,  int period)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OddsModelV2() when $default != null:
return $default(_that.selectionHomeId,_that.selectionAwayId,_that.selectionDrawId,_that.points,_that.homeOdds,_that.awayOdds,_that.drawOdds,_that.strOfferId,_that.isMainLine,_that.isSuspended,_that.isHidden,_that.playerName,_that.playerId,_that.period);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String selectionHomeId,  String selectionAwayId,  String selectionDrawId,  String points,  OddsStyleModelV2? homeOdds,  OddsStyleModelV2? awayOdds,  OddsStyleModelV2? drawOdds,  String strOfferId,  bool isMainLine,  bool isSuspended,  bool isHidden,  String playerName,  String playerId,  int period)  $default,) {final _that = this;
switch (_that) {
case _OddsModelV2():
return $default(_that.selectionHomeId,_that.selectionAwayId,_that.selectionDrawId,_that.points,_that.homeOdds,_that.awayOdds,_that.drawOdds,_that.strOfferId,_that.isMainLine,_that.isSuspended,_that.isHidden,_that.playerName,_that.playerId,_that.period);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String selectionHomeId,  String selectionAwayId,  String selectionDrawId,  String points,  OddsStyleModelV2? homeOdds,  OddsStyleModelV2? awayOdds,  OddsStyleModelV2? drawOdds,  String strOfferId,  bool isMainLine,  bool isSuspended,  bool isHidden,  String playerName,  String playerId,  int period)?  $default,) {final _that = this;
switch (_that) {
case _OddsModelV2() when $default != null:
return $default(_that.selectionHomeId,_that.selectionAwayId,_that.selectionDrawId,_that.points,_that.homeOdds,_that.awayOdds,_that.drawOdds,_that.strOfferId,_that.isMainLine,_that.isSuspended,_that.isHidden,_that.playerName,_that.playerId,_that.period);case _:
  return null;

}
}

}

class _OddsModelV2 extends OddsModelV2 {
  const _OddsModelV2({this.selectionHomeId = '', this.selectionAwayId = '', this.selectionDrawId = '', this.points = '', this.homeOdds, this.awayOdds, this.drawOdds, this.strOfferId = '', this.isMainLine = false, this.isSuspended = false, this.isHidden = false, this.playerName = '', this.playerId = '', this.period = 0}): super._();
  
@override@JsonKey() final  String selectionHomeId;
@override@JsonKey() final  String selectionAwayId;
@override@JsonKey() final  String selectionDrawId;
@override@JsonKey() final  String points;
@override final  OddsStyleModelV2? homeOdds;
@override final  OddsStyleModelV2? awayOdds;
@override final  OddsStyleModelV2? drawOdds;
@override@JsonKey() final  String strOfferId;
@override@JsonKey() final  bool isMainLine;
@override@JsonKey() final  bool isSuspended;
@override@JsonKey() final  bool isHidden;
@override@JsonKey() final  String playerName;
@override@JsonKey() final  String playerId;
@override@JsonKey() final  int period;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OddsModelV2CopyWith<_OddsModelV2> get copyWith => __$OddsModelV2CopyWithImpl<_OddsModelV2>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OddsModelV2&&(identical(other.selectionHomeId, selectionHomeId) || other.selectionHomeId == selectionHomeId)&&(identical(other.selectionAwayId, selectionAwayId) || other.selectionAwayId == selectionAwayId)&&(identical(other.selectionDrawId, selectionDrawId) || other.selectionDrawId == selectionDrawId)&&(identical(other.points, points) || other.points == points)&&(identical(other.homeOdds, homeOdds) || other.homeOdds == homeOdds)&&(identical(other.awayOdds, awayOdds) || other.awayOdds == awayOdds)&&(identical(other.drawOdds, drawOdds) || other.drawOdds == drawOdds)&&(identical(other.strOfferId, strOfferId) || other.strOfferId == strOfferId)&&(identical(other.isMainLine, isMainLine) || other.isMainLine == isMainLine)&&(identical(other.isSuspended, isSuspended) || other.isSuspended == isSuspended)&&(identical(other.isHidden, isHidden) || other.isHidden == isHidden)&&(identical(other.playerName, playerName) || other.playerName == playerName)&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.period, period) || other.period == period));
}

@override
int get hashCode => Object.hash(runtimeType,selectionHomeId,selectionAwayId,selectionDrawId,points,homeOdds,awayOdds,drawOdds,strOfferId,isMainLine,isSuspended,isHidden,playerName,playerId,period);

@override
String toString() {
  return 'OddsModelV2(selectionHomeId: $selectionHomeId, selectionAwayId: $selectionAwayId, selectionDrawId: $selectionDrawId, points: $points, homeOdds: $homeOdds, awayOdds: $awayOdds, drawOdds: $drawOdds, strOfferId: $strOfferId, isMainLine: $isMainLine, isSuspended: $isSuspended, isHidden: $isHidden, playerName: $playerName, playerId: $playerId, period: $period)';
}

}

abstract mixin class _$OddsModelV2CopyWith<$Res> implements $OddsModelV2CopyWith<$Res> {
  factory _$OddsModelV2CopyWith(_OddsModelV2 value, $Res Function(_OddsModelV2) _then) = __$OddsModelV2CopyWithImpl;
@override @useResult
$Res call({
 String selectionHomeId, String selectionAwayId, String selectionDrawId, String points, OddsStyleModelV2? homeOdds, OddsStyleModelV2? awayOdds, OddsStyleModelV2? drawOdds, String strOfferId, bool isMainLine, bool isSuspended, bool isHidden, String playerName, String playerId, int period
});

@override $OddsStyleModelV2CopyWith<$Res>? get homeOdds;@override $OddsStyleModelV2CopyWith<$Res>? get awayOdds;@override $OddsStyleModelV2CopyWith<$Res>? get drawOdds;

}
class __$OddsModelV2CopyWithImpl<$Res>
    implements _$OddsModelV2CopyWith<$Res> {
  __$OddsModelV2CopyWithImpl(this._self, this._then);

  final _OddsModelV2 _self;
  final $Res Function(_OddsModelV2) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? selectionHomeId = null,Object? selectionAwayId = null,Object? selectionDrawId = null,Object? points = null,Object? homeOdds = freezed,Object? awayOdds = freezed,Object? drawOdds = freezed,Object? strOfferId = null,Object? isMainLine = null,Object? isSuspended = null,Object? isHidden = null,Object? playerName = null,Object? playerId = null,Object? period = null,}) {
  return _then(_OddsModelV2(
selectionHomeId: null == selectionHomeId ? _self.selectionHomeId : selectionHomeId // ignore: cast_nullable_to_non_nullable
as String,selectionAwayId: null == selectionAwayId ? _self.selectionAwayId : selectionAwayId // ignore: cast_nullable_to_non_nullable
as String,selectionDrawId: null == selectionDrawId ? _self.selectionDrawId : selectionDrawId // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as String,homeOdds: freezed == homeOdds ? _self.homeOdds : homeOdds // ignore: cast_nullable_to_non_nullable
as OddsStyleModelV2?,awayOdds: freezed == awayOdds ? _self.awayOdds : awayOdds // ignore: cast_nullable_to_non_nullable
as OddsStyleModelV2?,drawOdds: freezed == drawOdds ? _self.drawOdds : drawOdds // ignore: cast_nullable_to_non_nullable
as OddsStyleModelV2?,strOfferId: null == strOfferId ? _self.strOfferId : strOfferId // ignore: cast_nullable_to_non_nullable
as String,isMainLine: null == isMainLine ? _self.isMainLine : isMainLine // ignore: cast_nullable_to_non_nullable
as bool,isSuspended: null == isSuspended ? _self.isSuspended : isSuspended // ignore: cast_nullable_to_non_nullable
as bool,isHidden: null == isHidden ? _self.isHidden : isHidden // ignore: cast_nullable_to_non_nullable
as bool,playerName: null == playerName ? _self.playerName : playerName // ignore: cast_nullable_to_non_nullable
as String,playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

@override
@pragma('vm:prefer-inline')
$OddsStyleModelV2CopyWith<$Res>? get homeOdds {
    if (_self.homeOdds == null) {
    return null;
  }

  return $OddsStyleModelV2CopyWith<$Res>(_self.homeOdds!, (value) {
    return _then(_self.copyWith(homeOdds: value));
  });
}
@override
@pragma('vm:prefer-inline')
$OddsStyleModelV2CopyWith<$Res>? get awayOdds {
    if (_self.awayOdds == null) {
    return null;
  }

  return $OddsStyleModelV2CopyWith<$Res>(_self.awayOdds!, (value) {
    return _then(_self.copyWith(awayOdds: value));
  });
}
@override
@pragma('vm:prefer-inline')
$OddsStyleModelV2CopyWith<$Res>? get drawOdds {
    if (_self.drawOdds == null) {
    return null;
  }

  return $OddsStyleModelV2CopyWith<$Res>(_self.drawOdds!, (value) {
    return _then(_self.copyWith(drawOdds: value));
  });
}
}

// dart format on
