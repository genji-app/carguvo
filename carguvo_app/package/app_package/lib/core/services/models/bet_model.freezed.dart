// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bet_model.dart';

// dart format off
T _$identity<T>(T value) => value;

mixin _$BetSelectionModel {

 int get eventId; String get eventName;@JsonKey(name: 'selectionId') String get selectionId;@JsonKey(name: 'selectionName') String get selectionName;@JsonKey(name: 'offerId') String get offerId;@JsonKey(name: 'displayOdds') String get displayOdds;@JsonKey(name: 'oddsStyle') String get oddsStyle;@JsonKey(name: 'cls') String get cls;@JsonKey(name: 'leagueId') String? get leagueId;@JsonKey(name: 'matchTime') String? get matchTime;@JsonKey(name: 'isLive') bool get isLive;@JsonKey(name: 'sportId') int get sportId;@JsonKey(name: 'homeScore') int? get homeScore;@JsonKey(name: 'awayScore') int? get awayScore; double? get stake; double? get winnings;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BetSelectionModelCopyWith<BetSelectionModel> get copyWith => _$BetSelectionModelCopyWithImpl<BetSelectionModel>(this as BetSelectionModel, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BetSelectionModel&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.eventName, eventName) || other.eventName == eventName)&&(identical(other.selectionId, selectionId) || other.selectionId == selectionId)&&(identical(other.selectionName, selectionName) || other.selectionName == selectionName)&&(identical(other.offerId, offerId) || other.offerId == offerId)&&(identical(other.displayOdds, displayOdds) || other.displayOdds == displayOdds)&&(identical(other.oddsStyle, oddsStyle) || other.oddsStyle == oddsStyle)&&(identical(other.cls, cls) || other.cls == cls)&&(identical(other.leagueId, leagueId) || other.leagueId == leagueId)&&(identical(other.matchTime, matchTime) || other.matchTime == matchTime)&&(identical(other.isLive, isLive) || other.isLive == isLive)&&(identical(other.sportId, sportId) || other.sportId == sportId)&&(identical(other.homeScore, homeScore) || other.homeScore == homeScore)&&(identical(other.awayScore, awayScore) || other.awayScore == awayScore)&&(identical(other.stake, stake) || other.stake == stake)&&(identical(other.winnings, winnings) || other.winnings == winnings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,eventId,eventName,selectionId,selectionName,offerId,displayOdds,oddsStyle,cls,leagueId,matchTime,isLive,sportId,homeScore,awayScore,stake,winnings);

@override
String toString() {
  return 'BetSelectionModel(eventId: $eventId, eventName: $eventName, selectionId: $selectionId, selectionName: $selectionName, offerId: $offerId, displayOdds: $displayOdds, oddsStyle: $oddsStyle, cls: $cls, leagueId: $leagueId, matchTime: $matchTime, isLive: $isLive, sportId: $sportId, homeScore: $homeScore, awayScore: $awayScore, stake: $stake, winnings: $winnings)';
}

}

abstract mixin class $BetSelectionModelCopyWith<$Res>  {
  factory $BetSelectionModelCopyWith(BetSelectionModel value, $Res Function(BetSelectionModel) _then) = _$BetSelectionModelCopyWithImpl;
@useResult
$Res call({
 int eventId, String eventName,@JsonKey(name: 'selectionId') String selectionId,@JsonKey(name: 'selectionName') String selectionName,@JsonKey(name: 'offerId') String offerId,@JsonKey(name: 'displayOdds') String displayOdds,@JsonKey(name: 'oddsStyle') String oddsStyle,@JsonKey(name: 'cls') String cls,@JsonKey(name: 'leagueId') String? leagueId,@JsonKey(name: 'matchTime') String? matchTime,@JsonKey(name: 'isLive') bool isLive,@JsonKey(name: 'sportId') int sportId,@JsonKey(name: 'homeScore') int? homeScore,@JsonKey(name: 'awayScore') int? awayScore, double? stake, double? winnings
});

}
class _$BetSelectionModelCopyWithImpl<$Res>
    implements $BetSelectionModelCopyWith<$Res> {
  _$BetSelectionModelCopyWithImpl(this._self, this._then);

  final BetSelectionModel _self;
  final $Res Function(BetSelectionModel) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? eventId = null,Object? eventName = null,Object? selectionId = null,Object? selectionName = null,Object? offerId = null,Object? displayOdds = null,Object? oddsStyle = null,Object? cls = null,Object? leagueId = freezed,Object? matchTime = freezed,Object? isLive = null,Object? sportId = null,Object? homeScore = freezed,Object? awayScore = freezed,Object? stake = freezed,Object? winnings = freezed,}) {
  return _then(_self.copyWith(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as int,eventName: null == eventName ? _self.eventName : eventName // ignore: cast_nullable_to_non_nullable
as String,selectionId: null == selectionId ? _self.selectionId : selectionId // ignore: cast_nullable_to_non_nullable
as String,selectionName: null == selectionName ? _self.selectionName : selectionName // ignore: cast_nullable_to_non_nullable
as String,offerId: null == offerId ? _self.offerId : offerId // ignore: cast_nullable_to_non_nullable
as String,displayOdds: null == displayOdds ? _self.displayOdds : displayOdds // ignore: cast_nullable_to_non_nullable
as String,oddsStyle: null == oddsStyle ? _self.oddsStyle : oddsStyle // ignore: cast_nullable_to_non_nullable
as String,cls: null == cls ? _self.cls : cls // ignore: cast_nullable_to_non_nullable
as String,leagueId: freezed == leagueId ? _self.leagueId : leagueId // ignore: cast_nullable_to_non_nullable
as String?,matchTime: freezed == matchTime ? _self.matchTime : matchTime // ignore: cast_nullable_to_non_nullable
as String?,isLive: null == isLive ? _self.isLive : isLive // ignore: cast_nullable_to_non_nullable
as bool,sportId: null == sportId ? _self.sportId : sportId // ignore: cast_nullable_to_non_nullable
as int,homeScore: freezed == homeScore ? _self.homeScore : homeScore // ignore: cast_nullable_to_non_nullable
as int?,awayScore: freezed == awayScore ? _self.awayScore : awayScore // ignore: cast_nullable_to_non_nullable
as int?,stake: freezed == stake ? _self.stake : stake // ignore: cast_nullable_to_non_nullable
as double?,winnings: freezed == winnings ? _self.winnings : winnings // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}

extension BetSelectionModelPatterns on BetSelectionModel {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BetSelectionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BetSelectionModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BetSelectionModel value)  $default,){
final _that = this;
switch (_that) {
case _BetSelectionModel():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BetSelectionModel value)?  $default,){
final _that = this;
switch (_that) {
case _BetSelectionModel() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int eventId,  String eventName, @JsonKey(name: 'selectionId')  String selectionId, @JsonKey(name: 'selectionName')  String selectionName, @JsonKey(name: 'offerId')  String offerId, @JsonKey(name: 'displayOdds')  String displayOdds, @JsonKey(name: 'oddsStyle')  String oddsStyle, @JsonKey(name: 'cls')  String cls, @JsonKey(name: 'leagueId')  String? leagueId, @JsonKey(name: 'matchTime')  String? matchTime, @JsonKey(name: 'isLive')  bool isLive, @JsonKey(name: 'sportId')  int sportId, @JsonKey(name: 'homeScore')  int? homeScore, @JsonKey(name: 'awayScore')  int? awayScore,  double? stake,  double? winnings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BetSelectionModel() when $default != null:
return $default(_that.eventId,_that.eventName,_that.selectionId,_that.selectionName,_that.offerId,_that.displayOdds,_that.oddsStyle,_that.cls,_that.leagueId,_that.matchTime,_that.isLive,_that.sportId,_that.homeScore,_that.awayScore,_that.stake,_that.winnings);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int eventId,  String eventName, @JsonKey(name: 'selectionId')  String selectionId, @JsonKey(name: 'selectionName')  String selectionName, @JsonKey(name: 'offerId')  String offerId, @JsonKey(name: 'displayOdds')  String displayOdds, @JsonKey(name: 'oddsStyle')  String oddsStyle, @JsonKey(name: 'cls')  String cls, @JsonKey(name: 'leagueId')  String? leagueId, @JsonKey(name: 'matchTime')  String? matchTime, @JsonKey(name: 'isLive')  bool isLive, @JsonKey(name: 'sportId')  int sportId, @JsonKey(name: 'homeScore')  int? homeScore, @JsonKey(name: 'awayScore')  int? awayScore,  double? stake,  double? winnings)  $default,) {final _that = this;
switch (_that) {
case _BetSelectionModel():
return $default(_that.eventId,_that.eventName,_that.selectionId,_that.selectionName,_that.offerId,_that.displayOdds,_that.oddsStyle,_that.cls,_that.leagueId,_that.matchTime,_that.isLive,_that.sportId,_that.homeScore,_that.awayScore,_that.stake,_that.winnings);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int eventId,  String eventName, @JsonKey(name: 'selectionId')  String selectionId, @JsonKey(name: 'selectionName')  String selectionName, @JsonKey(name: 'offerId')  String offerId, @JsonKey(name: 'displayOdds')  String displayOdds, @JsonKey(name: 'oddsStyle')  String oddsStyle, @JsonKey(name: 'cls')  String cls, @JsonKey(name: 'leagueId')  String? leagueId, @JsonKey(name: 'matchTime')  String? matchTime, @JsonKey(name: 'isLive')  bool isLive, @JsonKey(name: 'sportId')  int sportId, @JsonKey(name: 'homeScore')  int? homeScore, @JsonKey(name: 'awayScore')  int? awayScore,  double? stake,  double? winnings)?  $default,) {final _that = this;
switch (_that) {
case _BetSelectionModel() when $default != null:
return $default(_that.eventId,_that.eventName,_that.selectionId,_that.selectionName,_that.offerId,_that.displayOdds,_that.oddsStyle,_that.cls,_that.leagueId,_that.matchTime,_that.isLive,_that.sportId,_that.homeScore,_that.awayScore,_that.stake,_that.winnings);case _:
  return null;

}
}

}

@JsonSerializable()

class _BetSelectionModel implements BetSelectionModel {
  const _BetSelectionModel({required this.eventId, required this.eventName, @JsonKey(name: 'selectionId') required this.selectionId, @JsonKey(name: 'selectionName') required this.selectionName, @JsonKey(name: 'offerId') required this.offerId, @JsonKey(name: 'displayOdds') required this.displayOdds, @JsonKey(name: 'oddsStyle') this.oddsStyle = 'decimal', @JsonKey(name: 'cls') required this.cls, @JsonKey(name: 'leagueId') this.leagueId, @JsonKey(name: 'matchTime') this.matchTime, @JsonKey(name: 'isLive') this.isLive = false, @JsonKey(name: 'sportId') this.sportId = 1, @JsonKey(name: 'homeScore') this.homeScore, @JsonKey(name: 'awayScore') this.awayScore, this.stake, this.winnings});
  factory _BetSelectionModel.fromJson(Map<String, dynamic> json) => _$BetSelectionModelFromJson(json);

@override final  int eventId;
@override final  String eventName;
@override@JsonKey(name: 'selectionId') final  String selectionId;
@override@JsonKey(name: 'selectionName') final  String selectionName;
@override@JsonKey(name: 'offerId') final  String offerId;
@override@JsonKey(name: 'displayOdds') final  String displayOdds;
@override@JsonKey(name: 'oddsStyle') final  String oddsStyle;
@override@JsonKey(name: 'cls') final  String cls;
@override@JsonKey(name: 'leagueId') final  String? leagueId;
@override@JsonKey(name: 'matchTime') final  String? matchTime;
@override@JsonKey(name: 'isLive') final  bool isLive;
@override@JsonKey(name: 'sportId') final  int sportId;
@override@JsonKey(name: 'homeScore') final  int? homeScore;
@override@JsonKey(name: 'awayScore') final  int? awayScore;
@override final  double? stake;
@override final  double? winnings;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BetSelectionModelCopyWith<_BetSelectionModel> get copyWith => __$BetSelectionModelCopyWithImpl<_BetSelectionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BetSelectionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BetSelectionModel&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.eventName, eventName) || other.eventName == eventName)&&(identical(other.selectionId, selectionId) || other.selectionId == selectionId)&&(identical(other.selectionName, selectionName) || other.selectionName == selectionName)&&(identical(other.offerId, offerId) || other.offerId == offerId)&&(identical(other.displayOdds, displayOdds) || other.displayOdds == displayOdds)&&(identical(other.oddsStyle, oddsStyle) || other.oddsStyle == oddsStyle)&&(identical(other.cls, cls) || other.cls == cls)&&(identical(other.leagueId, leagueId) || other.leagueId == leagueId)&&(identical(other.matchTime, matchTime) || other.matchTime == matchTime)&&(identical(other.isLive, isLive) || other.isLive == isLive)&&(identical(other.sportId, sportId) || other.sportId == sportId)&&(identical(other.homeScore, homeScore) || other.homeScore == homeScore)&&(identical(other.awayScore, awayScore) || other.awayScore == awayScore)&&(identical(other.stake, stake) || other.stake == stake)&&(identical(other.winnings, winnings) || other.winnings == winnings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,eventId,eventName,selectionId,selectionName,offerId,displayOdds,oddsStyle,cls,leagueId,matchTime,isLive,sportId,homeScore,awayScore,stake,winnings);

@override
String toString() {
  return 'BetSelectionModel(eventId: $eventId, eventName: $eventName, selectionId: $selectionId, selectionName: $selectionName, offerId: $offerId, displayOdds: $displayOdds, oddsStyle: $oddsStyle, cls: $cls, leagueId: $leagueId, matchTime: $matchTime, isLive: $isLive, sportId: $sportId, homeScore: $homeScore, awayScore: $awayScore, stake: $stake, winnings: $winnings)';
}

}

abstract mixin class _$BetSelectionModelCopyWith<$Res> implements $BetSelectionModelCopyWith<$Res> {
  factory _$BetSelectionModelCopyWith(_BetSelectionModel value, $Res Function(_BetSelectionModel) _then) = __$BetSelectionModelCopyWithImpl;
@override @useResult
$Res call({
 int eventId, String eventName,@JsonKey(name: 'selectionId') String selectionId,@JsonKey(name: 'selectionName') String selectionName,@JsonKey(name: 'offerId') String offerId,@JsonKey(name: 'displayOdds') String displayOdds,@JsonKey(name: 'oddsStyle') String oddsStyle,@JsonKey(name: 'cls') String cls,@JsonKey(name: 'leagueId') String? leagueId,@JsonKey(name: 'matchTime') String? matchTime,@JsonKey(name: 'isLive') bool isLive,@JsonKey(name: 'sportId') int sportId,@JsonKey(name: 'homeScore') int? homeScore,@JsonKey(name: 'awayScore') int? awayScore, double? stake, double? winnings
});

}
class __$BetSelectionModelCopyWithImpl<$Res>
    implements _$BetSelectionModelCopyWith<$Res> {
  __$BetSelectionModelCopyWithImpl(this._self, this._then);

  final _BetSelectionModel _self;
  final $Res Function(_BetSelectionModel) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? eventId = null,Object? eventName = null,Object? selectionId = null,Object? selectionName = null,Object? offerId = null,Object? displayOdds = null,Object? oddsStyle = null,Object? cls = null,Object? leagueId = freezed,Object? matchTime = freezed,Object? isLive = null,Object? sportId = null,Object? homeScore = freezed,Object? awayScore = freezed,Object? stake = freezed,Object? winnings = freezed,}) {
  return _then(_BetSelectionModel(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as int,eventName: null == eventName ? _self.eventName : eventName // ignore: cast_nullable_to_non_nullable
as String,selectionId: null == selectionId ? _self.selectionId : selectionId // ignore: cast_nullable_to_non_nullable
as String,selectionName: null == selectionName ? _self.selectionName : selectionName // ignore: cast_nullable_to_non_nullable
as String,offerId: null == offerId ? _self.offerId : offerId // ignore: cast_nullable_to_non_nullable
as String,displayOdds: null == displayOdds ? _self.displayOdds : displayOdds // ignore: cast_nullable_to_non_nullable
as String,oddsStyle: null == oddsStyle ? _self.oddsStyle : oddsStyle // ignore: cast_nullable_to_non_nullable
as String,cls: null == cls ? _self.cls : cls // ignore: cast_nullable_to_non_nullable
as String,leagueId: freezed == leagueId ? _self.leagueId : leagueId // ignore: cast_nullable_to_non_nullable
as String?,matchTime: freezed == matchTime ? _self.matchTime : matchTime // ignore: cast_nullable_to_non_nullable
as String?,isLive: null == isLive ? _self.isLive : isLive // ignore: cast_nullable_to_non_nullable
as bool,sportId: null == sportId ? _self.sportId : sportId // ignore: cast_nullable_to_non_nullable
as int,homeScore: freezed == homeScore ? _self.homeScore : homeScore // ignore: cast_nullable_to_non_nullable
as int?,awayScore: freezed == awayScore ? _self.awayScore : awayScore // ignore: cast_nullable_to_non_nullable
as int?,stake: freezed == stake ? _self.stake : stake // ignore: cast_nullable_to_non_nullable
as double?,winnings: freezed == winnings ? _self.winnings : winnings // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}

mixin _$CalculateBetRequest {

@JsonKey(name: 'leagueId') String get leagueId;@JsonKey(name: 'matchTime') String get matchTime;@JsonKey(name: 'isLive') bool get isLive;@JsonKey(name: 'offerId') String get offerId;@JsonKey(name: 'selectionId') String get selectionId;@JsonKey(name: 'displayOdds') String get displayOdds;@JsonKey(name: 'oddsStyle') String get oddsStyle;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalculateBetRequestCopyWith<CalculateBetRequest> get copyWith => _$CalculateBetRequestCopyWithImpl<CalculateBetRequest>(this as CalculateBetRequest, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalculateBetRequest&&(identical(other.leagueId, leagueId) || other.leagueId == leagueId)&&(identical(other.matchTime, matchTime) || other.matchTime == matchTime)&&(identical(other.isLive, isLive) || other.isLive == isLive)&&(identical(other.offerId, offerId) || other.offerId == offerId)&&(identical(other.selectionId, selectionId) || other.selectionId == selectionId)&&(identical(other.displayOdds, displayOdds) || other.displayOdds == displayOdds)&&(identical(other.oddsStyle, oddsStyle) || other.oddsStyle == oddsStyle));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,leagueId,matchTime,isLive,offerId,selectionId,displayOdds,oddsStyle);

@override
String toString() {
  return 'CalculateBetRequest(leagueId: $leagueId, matchTime: $matchTime, isLive: $isLive, offerId: $offerId, selectionId: $selectionId, displayOdds: $displayOdds, oddsStyle: $oddsStyle)';
}

}

abstract mixin class $CalculateBetRequestCopyWith<$Res>  {
  factory $CalculateBetRequestCopyWith(CalculateBetRequest value, $Res Function(CalculateBetRequest) _then) = _$CalculateBetRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'leagueId') String leagueId,@JsonKey(name: 'matchTime') String matchTime,@JsonKey(name: 'isLive') bool isLive,@JsonKey(name: 'offerId') String offerId,@JsonKey(name: 'selectionId') String selectionId,@JsonKey(name: 'displayOdds') String displayOdds,@JsonKey(name: 'oddsStyle') String oddsStyle
});

}
class _$CalculateBetRequestCopyWithImpl<$Res>
    implements $CalculateBetRequestCopyWith<$Res> {
  _$CalculateBetRequestCopyWithImpl(this._self, this._then);

  final CalculateBetRequest _self;
  final $Res Function(CalculateBetRequest) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? leagueId = null,Object? matchTime = null,Object? isLive = null,Object? offerId = null,Object? selectionId = null,Object? displayOdds = null,Object? oddsStyle = null,}) {
  return _then(_self.copyWith(
leagueId: null == leagueId ? _self.leagueId : leagueId // ignore: cast_nullable_to_non_nullable
as String,matchTime: null == matchTime ? _self.matchTime : matchTime // ignore: cast_nullable_to_non_nullable
as String,isLive: null == isLive ? _self.isLive : isLive // ignore: cast_nullable_to_non_nullable
as bool,offerId: null == offerId ? _self.offerId : offerId // ignore: cast_nullable_to_non_nullable
as String,selectionId: null == selectionId ? _self.selectionId : selectionId // ignore: cast_nullable_to_non_nullable
as String,displayOdds: null == displayOdds ? _self.displayOdds : displayOdds // ignore: cast_nullable_to_non_nullable
as String,oddsStyle: null == oddsStyle ? _self.oddsStyle : oddsStyle // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}

extension CalculateBetRequestPatterns on CalculateBetRequest {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CalculateBetRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CalculateBetRequest() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CalculateBetRequest value)  $default,){
final _that = this;
switch (_that) {
case _CalculateBetRequest():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CalculateBetRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CalculateBetRequest() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'leagueId')  String leagueId, @JsonKey(name: 'matchTime')  String matchTime, @JsonKey(name: 'isLive')  bool isLive, @JsonKey(name: 'offerId')  String offerId, @JsonKey(name: 'selectionId')  String selectionId, @JsonKey(name: 'displayOdds')  String displayOdds, @JsonKey(name: 'oddsStyle')  String oddsStyle)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CalculateBetRequest() when $default != null:
return $default(_that.leagueId,_that.matchTime,_that.isLive,_that.offerId,_that.selectionId,_that.displayOdds,_that.oddsStyle);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'leagueId')  String leagueId, @JsonKey(name: 'matchTime')  String matchTime, @JsonKey(name: 'isLive')  bool isLive, @JsonKey(name: 'offerId')  String offerId, @JsonKey(name: 'selectionId')  String selectionId, @JsonKey(name: 'displayOdds')  String displayOdds, @JsonKey(name: 'oddsStyle')  String oddsStyle)  $default,) {final _that = this;
switch (_that) {
case _CalculateBetRequest():
return $default(_that.leagueId,_that.matchTime,_that.isLive,_that.offerId,_that.selectionId,_that.displayOdds,_that.oddsStyle);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'leagueId')  String leagueId, @JsonKey(name: 'matchTime')  String matchTime, @JsonKey(name: 'isLive')  bool isLive, @JsonKey(name: 'offerId')  String offerId, @JsonKey(name: 'selectionId')  String selectionId, @JsonKey(name: 'displayOdds')  String displayOdds, @JsonKey(name: 'oddsStyle')  String oddsStyle)?  $default,) {final _that = this;
switch (_that) {
case _CalculateBetRequest() when $default != null:
return $default(_that.leagueId,_that.matchTime,_that.isLive,_that.offerId,_that.selectionId,_that.displayOdds,_that.oddsStyle);case _:
  return null;

}
}

}

@JsonSerializable()

class _CalculateBetRequest implements CalculateBetRequest {
  const _CalculateBetRequest({@JsonKey(name: 'leagueId') required this.leagueId, @JsonKey(name: 'matchTime') required this.matchTime, @JsonKey(name: 'isLive') this.isLive = false, @JsonKey(name: 'offerId') required this.offerId, @JsonKey(name: 'selectionId') required this.selectionId, @JsonKey(name: 'displayOdds') required this.displayOdds, @JsonKey(name: 'oddsStyle') this.oddsStyle = 'decimal'});
  factory _CalculateBetRequest.fromJson(Map<String, dynamic> json) => _$CalculateBetRequestFromJson(json);

@override@JsonKey(name: 'leagueId') final  String leagueId;
@override@JsonKey(name: 'matchTime') final  String matchTime;
@override@JsonKey(name: 'isLive') final  bool isLive;
@override@JsonKey(name: 'offerId') final  String offerId;
@override@JsonKey(name: 'selectionId') final  String selectionId;
@override@JsonKey(name: 'displayOdds') final  String displayOdds;
@override@JsonKey(name: 'oddsStyle') final  String oddsStyle;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CalculateBetRequestCopyWith<_CalculateBetRequest> get copyWith => __$CalculateBetRequestCopyWithImpl<_CalculateBetRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CalculateBetRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CalculateBetRequest&&(identical(other.leagueId, leagueId) || other.leagueId == leagueId)&&(identical(other.matchTime, matchTime) || other.matchTime == matchTime)&&(identical(other.isLive, isLive) || other.isLive == isLive)&&(identical(other.offerId, offerId) || other.offerId == offerId)&&(identical(other.selectionId, selectionId) || other.selectionId == selectionId)&&(identical(other.displayOdds, displayOdds) || other.displayOdds == displayOdds)&&(identical(other.oddsStyle, oddsStyle) || other.oddsStyle == oddsStyle));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,leagueId,matchTime,isLive,offerId,selectionId,displayOdds,oddsStyle);

@override
String toString() {
  return 'CalculateBetRequest(leagueId: $leagueId, matchTime: $matchTime, isLive: $isLive, offerId: $offerId, selectionId: $selectionId, displayOdds: $displayOdds, oddsStyle: $oddsStyle)';
}

}

abstract mixin class _$CalculateBetRequestCopyWith<$Res> implements $CalculateBetRequestCopyWith<$Res> {
  factory _$CalculateBetRequestCopyWith(_CalculateBetRequest value, $Res Function(_CalculateBetRequest) _then) = __$CalculateBetRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'leagueId') String leagueId,@JsonKey(name: 'matchTime') String matchTime,@JsonKey(name: 'isLive') bool isLive,@JsonKey(name: 'offerId') String offerId,@JsonKey(name: 'selectionId') String selectionId,@JsonKey(name: 'displayOdds') String displayOdds,@JsonKey(name: 'oddsStyle') String oddsStyle
});

}
class __$CalculateBetRequestCopyWithImpl<$Res>
    implements _$CalculateBetRequestCopyWith<$Res> {
  __$CalculateBetRequestCopyWithImpl(this._self, this._then);

  final _CalculateBetRequest _self;
  final $Res Function(_CalculateBetRequest) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? leagueId = null,Object? matchTime = null,Object? isLive = null,Object? offerId = null,Object? selectionId = null,Object? displayOdds = null,Object? oddsStyle = null,}) {
  return _then(_CalculateBetRequest(
leagueId: null == leagueId ? _self.leagueId : leagueId // ignore: cast_nullable_to_non_nullable
as String,matchTime: null == matchTime ? _self.matchTime : matchTime // ignore: cast_nullable_to_non_nullable
as String,isLive: null == isLive ? _self.isLive : isLive // ignore: cast_nullable_to_non_nullable
as bool,offerId: null == offerId ? _self.offerId : offerId // ignore: cast_nullable_to_non_nullable
as String,selectionId: null == selectionId ? _self.selectionId : selectionId // ignore: cast_nullable_to_non_nullable
as String,displayOdds: null == displayOdds ? _self.displayOdds : displayOdds // ignore: cast_nullable_to_non_nullable
as String,oddsStyle: null == oddsStyle ? _self.oddsStyle : oddsStyle // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}

mixin _$CalculateBetResponse {

@JsonKey(name: 'minStake', fromJson: _numToInt) int get minStake;@JsonKey(name: 'maxStake', fromJson: _numToInt) int get maxStake;@JsonKey(name: 'maxPayout') int get maxPayout;@JsonKey(name: 'displayOdds') String get displayOdds;@JsonKey(name: 'trueOdds') double? get trueOdds;@JsonKey(name: 'errorCode') int get errorCode; String? get message;
@JsonKey(name: 'minMatches') int get minMatches;@JsonKey(name: 'maxMatches') int get maxMatches;@JsonKey(name: 'selectionIdOdds') Map<String, String>? get selectionIdOdds;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalculateBetResponseCopyWith<CalculateBetResponse> get copyWith => _$CalculateBetResponseCopyWithImpl<CalculateBetResponse>(this as CalculateBetResponse, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalculateBetResponse&&(identical(other.minStake, minStake) || other.minStake == minStake)&&(identical(other.maxStake, maxStake) || other.maxStake == maxStake)&&(identical(other.maxPayout, maxPayout) || other.maxPayout == maxPayout)&&(identical(other.displayOdds, displayOdds) || other.displayOdds == displayOdds)&&(identical(other.trueOdds, trueOdds) || other.trueOdds == trueOdds)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode)&&(identical(other.message, message) || other.message == message)&&(identical(other.minMatches, minMatches) || other.minMatches == minMatches)&&(identical(other.maxMatches, maxMatches) || other.maxMatches == maxMatches)&&const DeepCollectionEquality().equals(other.selectionIdOdds, selectionIdOdds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,minStake,maxStake,maxPayout,displayOdds,trueOdds,errorCode,message,minMatches,maxMatches,const DeepCollectionEquality().hash(selectionIdOdds));

@override
String toString() {
  return 'CalculateBetResponse(minStake: $minStake, maxStake: $maxStake, maxPayout: $maxPayout, displayOdds: $displayOdds, trueOdds: $trueOdds, errorCode: $errorCode, message: $message, minMatches: $minMatches, maxMatches: $maxMatches, selectionIdOdds: $selectionIdOdds)';
}

}

abstract mixin class $CalculateBetResponseCopyWith<$Res>  {
  factory $CalculateBetResponseCopyWith(CalculateBetResponse value, $Res Function(CalculateBetResponse) _then) = _$CalculateBetResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'minStake', fromJson: _numToInt) int minStake,@JsonKey(name: 'maxStake', fromJson: _numToInt) int maxStake,@JsonKey(name: 'maxPayout') int maxPayout,@JsonKey(name: 'displayOdds') String displayOdds,@JsonKey(name: 'trueOdds') double? trueOdds,@JsonKey(name: 'errorCode') int errorCode, String? message,@JsonKey(name: 'minMatches') int minMatches,@JsonKey(name: 'maxMatches') int maxMatches,@JsonKey(name: 'selectionIdOdds') Map<String, String>? selectionIdOdds
});

}
class _$CalculateBetResponseCopyWithImpl<$Res>
    implements $CalculateBetResponseCopyWith<$Res> {
  _$CalculateBetResponseCopyWithImpl(this._self, this._then);

  final CalculateBetResponse _self;
  final $Res Function(CalculateBetResponse) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? minStake = null,Object? maxStake = null,Object? maxPayout = null,Object? displayOdds = null,Object? trueOdds = freezed,Object? errorCode = null,Object? message = freezed,Object? minMatches = null,Object? maxMatches = null,Object? selectionIdOdds = freezed,}) {
  return _then(_self.copyWith(
minStake: null == minStake ? _self.minStake : minStake // ignore: cast_nullable_to_non_nullable
as int,maxStake: null == maxStake ? _self.maxStake : maxStake // ignore: cast_nullable_to_non_nullable
as int,maxPayout: null == maxPayout ? _self.maxPayout : maxPayout // ignore: cast_nullable_to_non_nullable
as int,displayOdds: null == displayOdds ? _self.displayOdds : displayOdds // ignore: cast_nullable_to_non_nullable
as String,trueOdds: freezed == trueOdds ? _self.trueOdds : trueOdds // ignore: cast_nullable_to_non_nullable
as double?,errorCode: null == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as int,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,minMatches: null == minMatches ? _self.minMatches : minMatches // ignore: cast_nullable_to_non_nullable
as int,maxMatches: null == maxMatches ? _self.maxMatches : maxMatches // ignore: cast_nullable_to_non_nullable
as int,selectionIdOdds: freezed == selectionIdOdds ? _self.selectionIdOdds : selectionIdOdds // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,
  ));
}

}

extension CalculateBetResponsePatterns on CalculateBetResponse {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CalculateBetResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CalculateBetResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CalculateBetResponse value)  $default,){
final _that = this;
switch (_that) {
case _CalculateBetResponse():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CalculateBetResponse value)?  $default,){
final _that = this;
switch (_that) {
case _CalculateBetResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'minStake', fromJson: _numToInt)  int minStake, @JsonKey(name: 'maxStake', fromJson: _numToInt)  int maxStake, @JsonKey(name: 'maxPayout')  int maxPayout, @JsonKey(name: 'displayOdds')  String displayOdds, @JsonKey(name: 'trueOdds')  double? trueOdds, @JsonKey(name: 'errorCode')  int errorCode,  String? message, @JsonKey(name: 'minMatches')  int minMatches, @JsonKey(name: 'maxMatches')  int maxMatches, @JsonKey(name: 'selectionIdOdds')  Map<String, String>? selectionIdOdds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CalculateBetResponse() when $default != null:
return $default(_that.minStake,_that.maxStake,_that.maxPayout,_that.displayOdds,_that.trueOdds,_that.errorCode,_that.message,_that.minMatches,_that.maxMatches,_that.selectionIdOdds);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'minStake', fromJson: _numToInt)  int minStake, @JsonKey(name: 'maxStake', fromJson: _numToInt)  int maxStake, @JsonKey(name: 'maxPayout')  int maxPayout, @JsonKey(name: 'displayOdds')  String displayOdds, @JsonKey(name: 'trueOdds')  double? trueOdds, @JsonKey(name: 'errorCode')  int errorCode,  String? message, @JsonKey(name: 'minMatches')  int minMatches, @JsonKey(name: 'maxMatches')  int maxMatches, @JsonKey(name: 'selectionIdOdds')  Map<String, String>? selectionIdOdds)  $default,) {final _that = this;
switch (_that) {
case _CalculateBetResponse():
return $default(_that.minStake,_that.maxStake,_that.maxPayout,_that.displayOdds,_that.trueOdds,_that.errorCode,_that.message,_that.minMatches,_that.maxMatches,_that.selectionIdOdds);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'minStake', fromJson: _numToInt)  int minStake, @JsonKey(name: 'maxStake', fromJson: _numToInt)  int maxStake, @JsonKey(name: 'maxPayout')  int maxPayout, @JsonKey(name: 'displayOdds')  String displayOdds, @JsonKey(name: 'trueOdds')  double? trueOdds, @JsonKey(name: 'errorCode')  int errorCode,  String? message, @JsonKey(name: 'minMatches')  int minMatches, @JsonKey(name: 'maxMatches')  int maxMatches, @JsonKey(name: 'selectionIdOdds')  Map<String, String>? selectionIdOdds)?  $default,) {final _that = this;
switch (_that) {
case _CalculateBetResponse() when $default != null:
return $default(_that.minStake,_that.maxStake,_that.maxPayout,_that.displayOdds,_that.trueOdds,_that.errorCode,_that.message,_that.minMatches,_that.maxMatches,_that.selectionIdOdds);case _:
  return null;

}
}

}

@JsonSerializable()

class _CalculateBetResponse implements CalculateBetResponse {
  const _CalculateBetResponse({@JsonKey(name: 'minStake', fromJson: _numToInt) this.minStake = 0, @JsonKey(name: 'maxStake', fromJson: _numToInt) this.maxStake = 0, @JsonKey(name: 'maxPayout') this.maxPayout = 0, @JsonKey(name: 'displayOdds') this.displayOdds = '', @JsonKey(name: 'trueOdds') this.trueOdds, @JsonKey(name: 'errorCode') this.errorCode = 0, this.message, @JsonKey(name: 'minMatches') this.minMatches = 2, @JsonKey(name: 'maxMatches') this.maxMatches = 10, @JsonKey(name: 'selectionIdOdds') final  Map<String, String>? selectionIdOdds}): _selectionIdOdds = selectionIdOdds;
  factory _CalculateBetResponse.fromJson(Map<String, dynamic> json) => _$CalculateBetResponseFromJson(json);

@override@JsonKey(name: 'minStake', fromJson: _numToInt) final  int minStake;
@override@JsonKey(name: 'maxStake', fromJson: _numToInt) final  int maxStake;
@override@JsonKey(name: 'maxPayout') final  int maxPayout;
@override@JsonKey(name: 'displayOdds') final  String displayOdds;
@override@JsonKey(name: 'trueOdds') final  double? trueOdds;
@override@JsonKey(name: 'errorCode') final  int errorCode;
@override final  String? message;
@override@JsonKey(name: 'minMatches') final  int minMatches;
@override@JsonKey(name: 'maxMatches') final  int maxMatches;
 final  Map<String, String>? _selectionIdOdds;
@override@JsonKey(name: 'selectionIdOdds') Map<String, String>? get selectionIdOdds {
  final value = _selectionIdOdds;
  if (value == null) return null;
  if (_selectionIdOdds is EqualUnmodifiableMapView) return _selectionIdOdds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CalculateBetResponseCopyWith<_CalculateBetResponse> get copyWith => __$CalculateBetResponseCopyWithImpl<_CalculateBetResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CalculateBetResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CalculateBetResponse&&(identical(other.minStake, minStake) || other.minStake == minStake)&&(identical(other.maxStake, maxStake) || other.maxStake == maxStake)&&(identical(other.maxPayout, maxPayout) || other.maxPayout == maxPayout)&&(identical(other.displayOdds, displayOdds) || other.displayOdds == displayOdds)&&(identical(other.trueOdds, trueOdds) || other.trueOdds == trueOdds)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode)&&(identical(other.message, message) || other.message == message)&&(identical(other.minMatches, minMatches) || other.minMatches == minMatches)&&(identical(other.maxMatches, maxMatches) || other.maxMatches == maxMatches)&&const DeepCollectionEquality().equals(other._selectionIdOdds, _selectionIdOdds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,minStake,maxStake,maxPayout,displayOdds,trueOdds,errorCode,message,minMatches,maxMatches,const DeepCollectionEquality().hash(_selectionIdOdds));

@override
String toString() {
  return 'CalculateBetResponse(minStake: $minStake, maxStake: $maxStake, maxPayout: $maxPayout, displayOdds: $displayOdds, trueOdds: $trueOdds, errorCode: $errorCode, message: $message, minMatches: $minMatches, maxMatches: $maxMatches, selectionIdOdds: $selectionIdOdds)';
}

}

abstract mixin class _$CalculateBetResponseCopyWith<$Res> implements $CalculateBetResponseCopyWith<$Res> {
  factory _$CalculateBetResponseCopyWith(_CalculateBetResponse value, $Res Function(_CalculateBetResponse) _then) = __$CalculateBetResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'minStake', fromJson: _numToInt) int minStake,@JsonKey(name: 'maxStake', fromJson: _numToInt) int maxStake,@JsonKey(name: 'maxPayout') int maxPayout,@JsonKey(name: 'displayOdds') String displayOdds,@JsonKey(name: 'trueOdds') double? trueOdds,@JsonKey(name: 'errorCode') int errorCode, String? message,@JsonKey(name: 'minMatches') int minMatches,@JsonKey(name: 'maxMatches') int maxMatches,@JsonKey(name: 'selectionIdOdds') Map<String, String>? selectionIdOdds
});

}
class __$CalculateBetResponseCopyWithImpl<$Res>
    implements _$CalculateBetResponseCopyWith<$Res> {
  __$CalculateBetResponseCopyWithImpl(this._self, this._then);

  final _CalculateBetResponse _self;
  final $Res Function(_CalculateBetResponse) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? minStake = null,Object? maxStake = null,Object? maxPayout = null,Object? displayOdds = null,Object? trueOdds = freezed,Object? errorCode = null,Object? message = freezed,Object? minMatches = null,Object? maxMatches = null,Object? selectionIdOdds = freezed,}) {
  return _then(_CalculateBetResponse(
minStake: null == minStake ? _self.minStake : minStake // ignore: cast_nullable_to_non_nullable
as int,maxStake: null == maxStake ? _self.maxStake : maxStake // ignore: cast_nullable_to_non_nullable
as int,maxPayout: null == maxPayout ? _self.maxPayout : maxPayout // ignore: cast_nullable_to_non_nullable
as int,displayOdds: null == displayOdds ? _self.displayOdds : displayOdds // ignore: cast_nullable_to_non_nullable
as String,trueOdds: freezed == trueOdds ? _self.trueOdds : trueOdds // ignore: cast_nullable_to_non_nullable
as double?,errorCode: null == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as int,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,minMatches: null == minMatches ? _self.minMatches : minMatches // ignore: cast_nullable_to_non_nullable
as int,maxMatches: null == maxMatches ? _self.maxMatches : maxMatches // ignore: cast_nullable_to_non_nullable
as int,selectionIdOdds: freezed == selectionIdOdds ? _self._selectionIdOdds : selectionIdOdds // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,
  ));
}

}

mixin _$PlaceBetRequest {

@JsonKey(name: 'acceptBetterOdds') bool get acceptBetterOdds;@JsonKey(name: 'acceptMaxStake') bool get acceptMaxStake;@JsonKey(name: 'matchId') int get matchId;@JsonKey(name: 'selections') List<BetSelectionModel> get selections;@JsonKey(name: 'singleBet') bool get singleBet;
@JsonKey(name: 'parlay') bool get parlay;@JsonKey(name: 'acceptAllOdds') bool get acceptAllOdds;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaceBetRequestCopyWith<PlaceBetRequest> get copyWith => _$PlaceBetRequestCopyWithImpl<PlaceBetRequest>(this as PlaceBetRequest, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaceBetRequest&&(identical(other.acceptBetterOdds, acceptBetterOdds) || other.acceptBetterOdds == acceptBetterOdds)&&(identical(other.acceptMaxStake, acceptMaxStake) || other.acceptMaxStake == acceptMaxStake)&&(identical(other.matchId, matchId) || other.matchId == matchId)&&const DeepCollectionEquality().equals(other.selections, selections)&&(identical(other.singleBet, singleBet) || other.singleBet == singleBet)&&(identical(other.parlay, parlay) || other.parlay == parlay)&&(identical(other.acceptAllOdds, acceptAllOdds) || other.acceptAllOdds == acceptAllOdds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,acceptBetterOdds,acceptMaxStake,matchId,const DeepCollectionEquality().hash(selections),singleBet,parlay,acceptAllOdds);

@override
String toString() {
  return 'PlaceBetRequest(acceptBetterOdds: $acceptBetterOdds, acceptMaxStake: $acceptMaxStake, matchId: $matchId, selections: $selections, singleBet: $singleBet, parlay: $parlay, acceptAllOdds: $acceptAllOdds)';
}

}

abstract mixin class $PlaceBetRequestCopyWith<$Res>  {
  factory $PlaceBetRequestCopyWith(PlaceBetRequest value, $Res Function(PlaceBetRequest) _then) = _$PlaceBetRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'acceptBetterOdds') bool acceptBetterOdds,@JsonKey(name: 'acceptMaxStake') bool acceptMaxStake,@JsonKey(name: 'matchId') int matchId,@JsonKey(name: 'selections') List<BetSelectionModel> selections,@JsonKey(name: 'singleBet') bool singleBet,@JsonKey(name: 'parlay') bool parlay,@JsonKey(name: 'acceptAllOdds') bool acceptAllOdds
});

}
class _$PlaceBetRequestCopyWithImpl<$Res>
    implements $PlaceBetRequestCopyWith<$Res> {
  _$PlaceBetRequestCopyWithImpl(this._self, this._then);

  final PlaceBetRequest _self;
  final $Res Function(PlaceBetRequest) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? acceptBetterOdds = null,Object? acceptMaxStake = null,Object? matchId = null,Object? selections = null,Object? singleBet = null,Object? parlay = null,Object? acceptAllOdds = null,}) {
  return _then(_self.copyWith(
acceptBetterOdds: null == acceptBetterOdds ? _self.acceptBetterOdds : acceptBetterOdds // ignore: cast_nullable_to_non_nullable
as bool,acceptMaxStake: null == acceptMaxStake ? _self.acceptMaxStake : acceptMaxStake // ignore: cast_nullable_to_non_nullable
as bool,matchId: null == matchId ? _self.matchId : matchId // ignore: cast_nullable_to_non_nullable
as int,selections: null == selections ? _self.selections : selections // ignore: cast_nullable_to_non_nullable
as List<BetSelectionModel>,singleBet: null == singleBet ? _self.singleBet : singleBet // ignore: cast_nullable_to_non_nullable
as bool,parlay: null == parlay ? _self.parlay : parlay // ignore: cast_nullable_to_non_nullable
as bool,acceptAllOdds: null == acceptAllOdds ? _self.acceptAllOdds : acceptAllOdds // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}

extension PlaceBetRequestPatterns on PlaceBetRequest {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlaceBetRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlaceBetRequest() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlaceBetRequest value)  $default,){
final _that = this;
switch (_that) {
case _PlaceBetRequest():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlaceBetRequest value)?  $default,){
final _that = this;
switch (_that) {
case _PlaceBetRequest() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'acceptBetterOdds')  bool acceptBetterOdds, @JsonKey(name: 'acceptMaxStake')  bool acceptMaxStake, @JsonKey(name: 'matchId')  int matchId, @JsonKey(name: 'selections')  List<BetSelectionModel> selections, @JsonKey(name: 'singleBet')  bool singleBet, @JsonKey(name: 'parlay')  bool parlay, @JsonKey(name: 'acceptAllOdds')  bool acceptAllOdds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlaceBetRequest() when $default != null:
return $default(_that.acceptBetterOdds,_that.acceptMaxStake,_that.matchId,_that.selections,_that.singleBet,_that.parlay,_that.acceptAllOdds);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'acceptBetterOdds')  bool acceptBetterOdds, @JsonKey(name: 'acceptMaxStake')  bool acceptMaxStake, @JsonKey(name: 'matchId')  int matchId, @JsonKey(name: 'selections')  List<BetSelectionModel> selections, @JsonKey(name: 'singleBet')  bool singleBet, @JsonKey(name: 'parlay')  bool parlay, @JsonKey(name: 'acceptAllOdds')  bool acceptAllOdds)  $default,) {final _that = this;
switch (_that) {
case _PlaceBetRequest():
return $default(_that.acceptBetterOdds,_that.acceptMaxStake,_that.matchId,_that.selections,_that.singleBet,_that.parlay,_that.acceptAllOdds);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'acceptBetterOdds')  bool acceptBetterOdds, @JsonKey(name: 'acceptMaxStake')  bool acceptMaxStake, @JsonKey(name: 'matchId')  int matchId, @JsonKey(name: 'selections')  List<BetSelectionModel> selections, @JsonKey(name: 'singleBet')  bool singleBet, @JsonKey(name: 'parlay')  bool parlay, @JsonKey(name: 'acceptAllOdds')  bool acceptAllOdds)?  $default,) {final _that = this;
switch (_that) {
case _PlaceBetRequest() when $default != null:
return $default(_that.acceptBetterOdds,_that.acceptMaxStake,_that.matchId,_that.selections,_that.singleBet,_that.parlay,_that.acceptAllOdds);case _:
  return null;

}
}

}

@JsonSerializable()

class _PlaceBetRequest implements PlaceBetRequest {
  const _PlaceBetRequest({@JsonKey(name: 'acceptBetterOdds') this.acceptBetterOdds = true, @JsonKey(name: 'acceptMaxStake') this.acceptMaxStake = true, @JsonKey(name: 'matchId') required this.matchId, @JsonKey(name: 'selections') required final  List<BetSelectionModel> selections, @JsonKey(name: 'singleBet') this.singleBet = true, @JsonKey(name: 'parlay') this.parlay = false, @JsonKey(name: 'acceptAllOdds') this.acceptAllOdds = true}): _selections = selections;
  factory _PlaceBetRequest.fromJson(Map<String, dynamic> json) => _$PlaceBetRequestFromJson(json);

@override@JsonKey(name: 'acceptBetterOdds') final  bool acceptBetterOdds;
@override@JsonKey(name: 'acceptMaxStake') final  bool acceptMaxStake;
@override@JsonKey(name: 'matchId') final  int matchId;
 final  List<BetSelectionModel> _selections;
@override@JsonKey(name: 'selections') List<BetSelectionModel> get selections {
  if (_selections is EqualUnmodifiableListView) return _selections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selections);
}

@override@JsonKey(name: 'singleBet') final  bool singleBet;
@override@JsonKey(name: 'parlay') final  bool parlay;
@override@JsonKey(name: 'acceptAllOdds') final  bool acceptAllOdds;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaceBetRequestCopyWith<_PlaceBetRequest> get copyWith => __$PlaceBetRequestCopyWithImpl<_PlaceBetRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlaceBetRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaceBetRequest&&(identical(other.acceptBetterOdds, acceptBetterOdds) || other.acceptBetterOdds == acceptBetterOdds)&&(identical(other.acceptMaxStake, acceptMaxStake) || other.acceptMaxStake == acceptMaxStake)&&(identical(other.matchId, matchId) || other.matchId == matchId)&&const DeepCollectionEquality().equals(other._selections, _selections)&&(identical(other.singleBet, singleBet) || other.singleBet == singleBet)&&(identical(other.parlay, parlay) || other.parlay == parlay)&&(identical(other.acceptAllOdds, acceptAllOdds) || other.acceptAllOdds == acceptAllOdds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,acceptBetterOdds,acceptMaxStake,matchId,const DeepCollectionEquality().hash(_selections),singleBet,parlay,acceptAllOdds);

@override
String toString() {
  return 'PlaceBetRequest(acceptBetterOdds: $acceptBetterOdds, acceptMaxStake: $acceptMaxStake, matchId: $matchId, selections: $selections, singleBet: $singleBet, parlay: $parlay, acceptAllOdds: $acceptAllOdds)';
}

}

abstract mixin class _$PlaceBetRequestCopyWith<$Res> implements $PlaceBetRequestCopyWith<$Res> {
  factory _$PlaceBetRequestCopyWith(_PlaceBetRequest value, $Res Function(_PlaceBetRequest) _then) = __$PlaceBetRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'acceptBetterOdds') bool acceptBetterOdds,@JsonKey(name: 'acceptMaxStake') bool acceptMaxStake,@JsonKey(name: 'matchId') int matchId,@JsonKey(name: 'selections') List<BetSelectionModel> selections,@JsonKey(name: 'singleBet') bool singleBet,@JsonKey(name: 'parlay') bool parlay,@JsonKey(name: 'acceptAllOdds') bool acceptAllOdds
});

}
class __$PlaceBetRequestCopyWithImpl<$Res>
    implements _$PlaceBetRequestCopyWith<$Res> {
  __$PlaceBetRequestCopyWithImpl(this._self, this._then);

  final _PlaceBetRequest _self;
  final $Res Function(_PlaceBetRequest) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? acceptBetterOdds = null,Object? acceptMaxStake = null,Object? matchId = null,Object? selections = null,Object? singleBet = null,Object? parlay = null,Object? acceptAllOdds = null,}) {
  return _then(_PlaceBetRequest(
acceptBetterOdds: null == acceptBetterOdds ? _self.acceptBetterOdds : acceptBetterOdds // ignore: cast_nullable_to_non_nullable
as bool,acceptMaxStake: null == acceptMaxStake ? _self.acceptMaxStake : acceptMaxStake // ignore: cast_nullable_to_non_nullable
as bool,matchId: null == matchId ? _self.matchId : matchId // ignore: cast_nullable_to_non_nullable
as int,selections: null == selections ? _self._selections : selections // ignore: cast_nullable_to_non_nullable
as List<BetSelectionModel>,singleBet: null == singleBet ? _self.singleBet : singleBet // ignore: cast_nullable_to_non_nullable
as bool,parlay: null == parlay ? _self.parlay : parlay // ignore: cast_nullable_to_non_nullable
as bool,acceptAllOdds: null == acceptAllOdds ? _self.acceptAllOdds : acceptAllOdds // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}

mixin _$PlaceBetResponse {

@JsonKey(name: 'ticketId') String? get ticketId; String get status;@JsonKey(fromJson: _oddsToString) String? get odds;@JsonKey(fromJson: _numToIntNullable) int? get stake;@JsonKey(name: 'winning', fromJson: _numToIntNullable) int? get winnings;@JsonKey(name: 'errorCode') int get errorCode; String? get message;@JsonKey(name: 'createdAt') String? get createdAt;@JsonKey(name: 'values', fromJson: _valuesToDoubles) List<double>? get values;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaceBetResponseCopyWith<PlaceBetResponse> get copyWith => _$PlaceBetResponseCopyWithImpl<PlaceBetResponse>(this as PlaceBetResponse, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaceBetResponse&&(identical(other.ticketId, ticketId) || other.ticketId == ticketId)&&(identical(other.status, status) || other.status == status)&&(identical(other.odds, odds) || other.odds == odds)&&(identical(other.stake, stake) || other.stake == stake)&&(identical(other.winnings, winnings) || other.winnings == winnings)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode)&&(identical(other.message, message) || other.message == message)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.values, values));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ticketId,status,odds,stake,winnings,errorCode,message,createdAt,const DeepCollectionEquality().hash(values));

@override
String toString() {
  return 'PlaceBetResponse(ticketId: $ticketId, status: $status, odds: $odds, stake: $stake, winnings: $winnings, errorCode: $errorCode, message: $message, createdAt: $createdAt, values: $values)';
}

}

abstract mixin class $PlaceBetResponseCopyWith<$Res>  {
  factory $PlaceBetResponseCopyWith(PlaceBetResponse value, $Res Function(PlaceBetResponse) _then) = _$PlaceBetResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'ticketId') String? ticketId, String status,@JsonKey(fromJson: _oddsToString) String? odds,@JsonKey(fromJson: _numToIntNullable) int? stake,@JsonKey(name: 'winning', fromJson: _numToIntNullable) int? winnings,@JsonKey(name: 'errorCode') int errorCode, String? message,@JsonKey(name: 'createdAt') String? createdAt,@JsonKey(name: 'values', fromJson: _valuesToDoubles) List<double>? values
});

}
class _$PlaceBetResponseCopyWithImpl<$Res>
    implements $PlaceBetResponseCopyWith<$Res> {
  _$PlaceBetResponseCopyWithImpl(this._self, this._then);

  final PlaceBetResponse _self;
  final $Res Function(PlaceBetResponse) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? ticketId = freezed,Object? status = null,Object? odds = freezed,Object? stake = freezed,Object? winnings = freezed,Object? errorCode = null,Object? message = freezed,Object? createdAt = freezed,Object? values = freezed,}) {
  return _then(_self.copyWith(
ticketId: freezed == ticketId ? _self.ticketId : ticketId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,odds: freezed == odds ? _self.odds : odds // ignore: cast_nullable_to_non_nullable
as String?,stake: freezed == stake ? _self.stake : stake // ignore: cast_nullable_to_non_nullable
as int?,winnings: freezed == winnings ? _self.winnings : winnings // ignore: cast_nullable_to_non_nullable
as int?,errorCode: null == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as int,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,values: freezed == values ? _self.values : values // ignore: cast_nullable_to_non_nullable
as List<double>?,
  ));
}

}

extension PlaceBetResponsePatterns on PlaceBetResponse {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlaceBetResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlaceBetResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlaceBetResponse value)  $default,){
final _that = this;
switch (_that) {
case _PlaceBetResponse():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlaceBetResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PlaceBetResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'ticketId')  String? ticketId,  String status, @JsonKey(fromJson: _oddsToString)  String? odds, @JsonKey(fromJson: _numToIntNullable)  int? stake, @JsonKey(name: 'winning', fromJson: _numToIntNullable)  int? winnings, @JsonKey(name: 'errorCode')  int errorCode,  String? message, @JsonKey(name: 'createdAt')  String? createdAt, @JsonKey(name: 'values', fromJson: _valuesToDoubles)  List<double>? values)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlaceBetResponse() when $default != null:
return $default(_that.ticketId,_that.status,_that.odds,_that.stake,_that.winnings,_that.errorCode,_that.message,_that.createdAt,_that.values);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'ticketId')  String? ticketId,  String status, @JsonKey(fromJson: _oddsToString)  String? odds, @JsonKey(fromJson: _numToIntNullable)  int? stake, @JsonKey(name: 'winning', fromJson: _numToIntNullable)  int? winnings, @JsonKey(name: 'errorCode')  int errorCode,  String? message, @JsonKey(name: 'createdAt')  String? createdAt, @JsonKey(name: 'values', fromJson: _valuesToDoubles)  List<double>? values)  $default,) {final _that = this;
switch (_that) {
case _PlaceBetResponse():
return $default(_that.ticketId,_that.status,_that.odds,_that.stake,_that.winnings,_that.errorCode,_that.message,_that.createdAt,_that.values);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'ticketId')  String? ticketId,  String status, @JsonKey(fromJson: _oddsToString)  String? odds, @JsonKey(fromJson: _numToIntNullable)  int? stake, @JsonKey(name: 'winning', fromJson: _numToIntNullable)  int? winnings, @JsonKey(name: 'errorCode')  int errorCode,  String? message, @JsonKey(name: 'createdAt')  String? createdAt, @JsonKey(name: 'values', fromJson: _valuesToDoubles)  List<double>? values)?  $default,) {final _that = this;
switch (_that) {
case _PlaceBetResponse() when $default != null:
return $default(_that.ticketId,_that.status,_that.odds,_that.stake,_that.winnings,_that.errorCode,_that.message,_that.createdAt,_that.values);case _:
  return null;

}
}

}

@JsonSerializable()

class _PlaceBetResponse implements PlaceBetResponse {
  const _PlaceBetResponse({@JsonKey(name: 'ticketId') this.ticketId, required this.status, @JsonKey(fromJson: _oddsToString) this.odds, @JsonKey(fromJson: _numToIntNullable) this.stake, @JsonKey(name: 'winning', fromJson: _numToIntNullable) this.winnings, @JsonKey(name: 'errorCode') this.errorCode = 0, this.message, @JsonKey(name: 'createdAt') this.createdAt, @JsonKey(name: 'values', fromJson: _valuesToDoubles) final  List<double>? values}): _values = values;
  factory _PlaceBetResponse.fromJson(Map<String, dynamic> json) => _$PlaceBetResponseFromJson(json);

@override@JsonKey(name: 'ticketId') final  String? ticketId;
@override final  String status;
@override@JsonKey(fromJson: _oddsToString) final  String? odds;
@override@JsonKey(fromJson: _numToIntNullable) final  int? stake;
@override@JsonKey(name: 'winning', fromJson: _numToIntNullable) final  int? winnings;
@override@JsonKey(name: 'errorCode') final  int errorCode;
@override final  String? message;
@override@JsonKey(name: 'createdAt') final  String? createdAt;
 final  List<double>? _values;
@override@JsonKey(name: 'values', fromJson: _valuesToDoubles) List<double>? get values {
  final value = _values;
  if (value == null) return null;
  if (_values is EqualUnmodifiableListView) return _values;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaceBetResponseCopyWith<_PlaceBetResponse> get copyWith => __$PlaceBetResponseCopyWithImpl<_PlaceBetResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlaceBetResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaceBetResponse&&(identical(other.ticketId, ticketId) || other.ticketId == ticketId)&&(identical(other.status, status) || other.status == status)&&(identical(other.odds, odds) || other.odds == odds)&&(identical(other.stake, stake) || other.stake == stake)&&(identical(other.winnings, winnings) || other.winnings == winnings)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode)&&(identical(other.message, message) || other.message == message)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other._values, _values));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ticketId,status,odds,stake,winnings,errorCode,message,createdAt,const DeepCollectionEquality().hash(_values));

@override
String toString() {
  return 'PlaceBetResponse(ticketId: $ticketId, status: $status, odds: $odds, stake: $stake, winnings: $winnings, errorCode: $errorCode, message: $message, createdAt: $createdAt, values: $values)';
}

}

abstract mixin class _$PlaceBetResponseCopyWith<$Res> implements $PlaceBetResponseCopyWith<$Res> {
  factory _$PlaceBetResponseCopyWith(_PlaceBetResponse value, $Res Function(_PlaceBetResponse) _then) = __$PlaceBetResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'ticketId') String? ticketId, String status,@JsonKey(fromJson: _oddsToString) String? odds,@JsonKey(fromJson: _numToIntNullable) int? stake,@JsonKey(name: 'winning', fromJson: _numToIntNullable) int? winnings,@JsonKey(name: 'errorCode') int errorCode, String? message,@JsonKey(name: 'createdAt') String? createdAt,@JsonKey(name: 'values', fromJson: _valuesToDoubles) List<double>? values
});

}
class __$PlaceBetResponseCopyWithImpl<$Res>
    implements _$PlaceBetResponseCopyWith<$Res> {
  __$PlaceBetResponseCopyWithImpl(this._self, this._then);

  final _PlaceBetResponse _self;
  final $Res Function(_PlaceBetResponse) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? ticketId = freezed,Object? status = null,Object? odds = freezed,Object? stake = freezed,Object? winnings = freezed,Object? errorCode = null,Object? message = freezed,Object? createdAt = freezed,Object? values = freezed,}) {
  return _then(_PlaceBetResponse(
ticketId: freezed == ticketId ? _self.ticketId : ticketId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,odds: freezed == odds ? _self.odds : odds // ignore: cast_nullable_to_non_nullable
as String?,stake: freezed == stake ? _self.stake : stake // ignore: cast_nullable_to_non_nullable
as int?,winnings: freezed == winnings ? _self.winnings : winnings // ignore: cast_nullable_to_non_nullable
as int?,errorCode: null == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as int,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,values: freezed == values ? _self._values : values // ignore: cast_nullable_to_non_nullable
as List<double>?,
  ));
}

}

// dart format on
