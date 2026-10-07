// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'jackpot_data.dart';

// dart format off
T _$identity<T>(T value) => value;
mixin _$JackpotData {

 int get jackpot; int get accountId; int get bet;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JackpotDataCopyWith<JackpotData> get copyWith => _$JackpotDataCopyWithImpl<JackpotData>(this as JackpotData, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JackpotData&&(identical(other.jackpot, jackpot) || other.jackpot == jackpot)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.bet, bet) || other.bet == bet));
}

@override
int get hashCode => Object.hash(runtimeType,jackpot,accountId,bet);

@override
String toString() {
  return 'JackpotData(jackpot: $jackpot, accountId: $accountId, bet: $bet)';
}

}

abstract mixin class $JackpotDataCopyWith<$Res>  {
  factory $JackpotDataCopyWith(JackpotData value, $Res Function(JackpotData) _then) = _$JackpotDataCopyWithImpl;
@useResult
$Res call({
 int jackpot, int accountId, int bet
});

}
class _$JackpotDataCopyWithImpl<$Res>
    implements $JackpotDataCopyWith<$Res> {
  _$JackpotDataCopyWithImpl(this._self, this._then);

  final JackpotData _self;
  final $Res Function(JackpotData) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? jackpot = null,Object? accountId = null,Object? bet = null,}) {
  return _then(_self.copyWith(
jackpot: null == jackpot ? _self.jackpot : jackpot // ignore: cast_nullable_to_non_nullable
as int,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as int,bet: null == bet ? _self.bet : bet // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}

extension JackpotDataPatterns on JackpotData {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JackpotData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JackpotData() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JackpotData value)  $default,){
final _that = this;
switch (_that) {
case _JackpotData():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JackpotData value)?  $default,){
final _that = this;
switch (_that) {
case _JackpotData() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int jackpot,  int accountId,  int bet)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JackpotData() when $default != null:
return $default(_that.jackpot,_that.accountId,_that.bet);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int jackpot,  int accountId,  int bet)  $default,) {final _that = this;
switch (_that) {
case _JackpotData():
return $default(_that.jackpot,_that.accountId,_that.bet);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int jackpot,  int accountId,  int bet)?  $default,) {final _that = this;
switch (_that) {
case _JackpotData() when $default != null:
return $default(_that.jackpot,_that.accountId,_that.bet);case _:
  return null;

}
}

}

class _JackpotData implements JackpotData {
  const _JackpotData({this.jackpot = 0, this.accountId = 0, this.bet = 0});
  
@override@JsonKey() final  int jackpot;
@override@JsonKey() final  int accountId;
@override@JsonKey() final  int bet;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JackpotDataCopyWith<_JackpotData> get copyWith => __$JackpotDataCopyWithImpl<_JackpotData>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _JackpotData&&(identical(other.jackpot, jackpot) || other.jackpot == jackpot)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.bet, bet) || other.bet == bet));
}

@override
int get hashCode => Object.hash(runtimeType,jackpot,accountId,bet);

@override
String toString() {
  return 'JackpotData(jackpot: $jackpot, accountId: $accountId, bet: $bet)';
}

}

abstract mixin class _$JackpotDataCopyWith<$Res> implements $JackpotDataCopyWith<$Res> {
  factory _$JackpotDataCopyWith(_JackpotData value, $Res Function(_JackpotData) _then) = __$JackpotDataCopyWithImpl;
@override @useResult
$Res call({
 int jackpot, int accountId, int bet
});

}
class __$JackpotDataCopyWithImpl<$Res>
    implements _$JackpotDataCopyWith<$Res> {
  __$JackpotDataCopyWithImpl(this._self, this._then);

  final _JackpotData _self;
  final $Res Function(_JackpotData) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? jackpot = null,Object? accountId = null,Object? bet = null,}) {
  return _then(_JackpotData(
jackpot: null == jackpot ? _self.jackpot : jackpot // ignore: cast_nullable_to_non_nullable
as int,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as int,bet: null == bet ? _self.bet : bet // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}

// dart format on
