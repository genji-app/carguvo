// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bet_statistics_entity.dart';

// dart format off
T _$identity<T>(T value) => value;

mixin _$BetStatisticsSimple {

@JsonKey(name: '0') int? get eventId;
@JsonKey(name: '1') Map<String, List<BetStatisticsSelection>>? get marketStatistics;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BetStatisticsSimpleCopyWith<BetStatisticsSimple> get copyWith => _$BetStatisticsSimpleCopyWithImpl<BetStatisticsSimple>(this as BetStatisticsSimple, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BetStatisticsSimple&&(identical(other.eventId, eventId) || other.eventId == eventId)&&const DeepCollectionEquality().equals(other.marketStatistics, marketStatistics));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,eventId,const DeepCollectionEquality().hash(marketStatistics));

@override
String toString() {
  return 'BetStatisticsSimple(eventId: $eventId, marketStatistics: $marketStatistics)';
}

}

abstract mixin class $BetStatisticsSimpleCopyWith<$Res>  {
  factory $BetStatisticsSimpleCopyWith(BetStatisticsSimple value, $Res Function(BetStatisticsSimple) _then) = _$BetStatisticsSimpleCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: '0') int? eventId,@JsonKey(name: '1') Map<String, List<BetStatisticsSelection>>? marketStatistics
});

}
class _$BetStatisticsSimpleCopyWithImpl<$Res>
    implements $BetStatisticsSimpleCopyWith<$Res> {
  _$BetStatisticsSimpleCopyWithImpl(this._self, this._then);

  final BetStatisticsSimple _self;
  final $Res Function(BetStatisticsSimple) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? eventId = freezed,Object? marketStatistics = freezed,}) {
  return _then(_self.copyWith(
eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as int?,marketStatistics: freezed == marketStatistics ? _self.marketStatistics : marketStatistics // ignore: cast_nullable_to_non_nullable
as Map<String, List<BetStatisticsSelection>>?,
  ));
}

}

extension BetStatisticsSimplePatterns on BetStatisticsSimple {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BetStatisticsSimple value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BetStatisticsSimple() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BetStatisticsSimple value)  $default,){
final _that = this;
switch (_that) {
case _BetStatisticsSimple():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BetStatisticsSimple value)?  $default,){
final _that = this;
switch (_that) {
case _BetStatisticsSimple() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: '0')  int? eventId, @JsonKey(name: '1')  Map<String, List<BetStatisticsSelection>>? marketStatistics)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BetStatisticsSimple() when $default != null:
return $default(_that.eventId,_that.marketStatistics);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: '0')  int? eventId, @JsonKey(name: '1')  Map<String, List<BetStatisticsSelection>>? marketStatistics)  $default,) {final _that = this;
switch (_that) {
case _BetStatisticsSimple():
return $default(_that.eventId,_that.marketStatistics);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: '0')  int? eventId, @JsonKey(name: '1')  Map<String, List<BetStatisticsSelection>>? marketStatistics)?  $default,) {final _that = this;
switch (_that) {
case _BetStatisticsSimple() when $default != null:
return $default(_that.eventId,_that.marketStatistics);case _:
  return null;

}
}

}

@JsonSerializable()

class _BetStatisticsSimple implements BetStatisticsSimple {
  const _BetStatisticsSimple({@JsonKey(name: '0') this.eventId, @JsonKey(name: '1') final  Map<String, List<BetStatisticsSelection>>? marketStatistics}): _marketStatistics = marketStatistics;
  factory _BetStatisticsSimple.fromJson(Map<String, dynamic> json) => _$BetStatisticsSimpleFromJson(json);

@override@JsonKey(name: '0') final  int? eventId;
 final  Map<String, List<BetStatisticsSelection>>? _marketStatistics;
@override@JsonKey(name: '1') Map<String, List<BetStatisticsSelection>>? get marketStatistics {
  final value = _marketStatistics;
  if (value == null) return null;
  if (_marketStatistics is EqualUnmodifiableMapView) return _marketStatistics;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BetStatisticsSimpleCopyWith<_BetStatisticsSimple> get copyWith => __$BetStatisticsSimpleCopyWithImpl<_BetStatisticsSimple>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BetStatisticsSimpleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BetStatisticsSimple&&(identical(other.eventId, eventId) || other.eventId == eventId)&&const DeepCollectionEquality().equals(other._marketStatistics, _marketStatistics));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,eventId,const DeepCollectionEquality().hash(_marketStatistics));

@override
String toString() {
  return 'BetStatisticsSimple(eventId: $eventId, marketStatistics: $marketStatistics)';
}

}

abstract mixin class _$BetStatisticsSimpleCopyWith<$Res> implements $BetStatisticsSimpleCopyWith<$Res> {
  factory _$BetStatisticsSimpleCopyWith(_BetStatisticsSimple value, $Res Function(_BetStatisticsSimple) _then) = __$BetStatisticsSimpleCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: '0') int? eventId,@JsonKey(name: '1') Map<String, List<BetStatisticsSelection>>? marketStatistics
});

}
class __$BetStatisticsSimpleCopyWithImpl<$Res>
    implements _$BetStatisticsSimpleCopyWith<$Res> {
  __$BetStatisticsSimpleCopyWithImpl(this._self, this._then);

  final _BetStatisticsSimple _self;
  final $Res Function(_BetStatisticsSimple) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? eventId = freezed,Object? marketStatistics = freezed,}) {
  return _then(_BetStatisticsSimple(
eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as int?,marketStatistics: freezed == marketStatistics ? _self._marketStatistics : marketStatistics // ignore: cast_nullable_to_non_nullable
as Map<String, List<BetStatisticsSelection>>?,
  ));
}

}

mixin _$BetStatisticsSelection {

@JsonKey(name: '1') int? get marketId;
@JsonKey(name: '2', fromJson: _parsePoints) String? get points;
@JsonKey(name: '3') String? get selectionName;
@JsonKey(name: '4') double? get percentage;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BetStatisticsSelectionCopyWith<BetStatisticsSelection> get copyWith => _$BetStatisticsSelectionCopyWithImpl<BetStatisticsSelection>(this as BetStatisticsSelection, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BetStatisticsSelection&&(identical(other.marketId, marketId) || other.marketId == marketId)&&(identical(other.points, points) || other.points == points)&&(identical(other.selectionName, selectionName) || other.selectionName == selectionName)&&(identical(other.percentage, percentage) || other.percentage == percentage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,marketId,points,selectionName,percentage);

@override
String toString() {
  return 'BetStatisticsSelection(marketId: $marketId, points: $points, selectionName: $selectionName, percentage: $percentage)';
}

}

abstract mixin class $BetStatisticsSelectionCopyWith<$Res>  {
  factory $BetStatisticsSelectionCopyWith(BetStatisticsSelection value, $Res Function(BetStatisticsSelection) _then) = _$BetStatisticsSelectionCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: '1') int? marketId,@JsonKey(name: '2', fromJson: _parsePoints) String? points,@JsonKey(name: '3') String? selectionName,@JsonKey(name: '4') double? percentage
});

}
class _$BetStatisticsSelectionCopyWithImpl<$Res>
    implements $BetStatisticsSelectionCopyWith<$Res> {
  _$BetStatisticsSelectionCopyWithImpl(this._self, this._then);

  final BetStatisticsSelection _self;
  final $Res Function(BetStatisticsSelection) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? marketId = freezed,Object? points = freezed,Object? selectionName = freezed,Object? percentage = freezed,}) {
  return _then(_self.copyWith(
marketId: freezed == marketId ? _self.marketId : marketId // ignore: cast_nullable_to_non_nullable
as int?,points: freezed == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as String?,selectionName: freezed == selectionName ? _self.selectionName : selectionName // ignore: cast_nullable_to_non_nullable
as String?,percentage: freezed == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}

extension BetStatisticsSelectionPatterns on BetStatisticsSelection {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BetStatisticsSelection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BetStatisticsSelection() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BetStatisticsSelection value)  $default,){
final _that = this;
switch (_that) {
case _BetStatisticsSelection():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BetStatisticsSelection value)?  $default,){
final _that = this;
switch (_that) {
case _BetStatisticsSelection() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: '1')  int? marketId, @JsonKey(name: '2', fromJson: _parsePoints)  String? points, @JsonKey(name: '3')  String? selectionName, @JsonKey(name: '4')  double? percentage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BetStatisticsSelection() when $default != null:
return $default(_that.marketId,_that.points,_that.selectionName,_that.percentage);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: '1')  int? marketId, @JsonKey(name: '2', fromJson: _parsePoints)  String? points, @JsonKey(name: '3')  String? selectionName, @JsonKey(name: '4')  double? percentage)  $default,) {final _that = this;
switch (_that) {
case _BetStatisticsSelection():
return $default(_that.marketId,_that.points,_that.selectionName,_that.percentage);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: '1')  int? marketId, @JsonKey(name: '2', fromJson: _parsePoints)  String? points, @JsonKey(name: '3')  String? selectionName, @JsonKey(name: '4')  double? percentage)?  $default,) {final _that = this;
switch (_that) {
case _BetStatisticsSelection() when $default != null:
return $default(_that.marketId,_that.points,_that.selectionName,_that.percentage);case _:
  return null;

}
}

}

@JsonSerializable()

class _BetStatisticsSelection implements BetStatisticsSelection {
  const _BetStatisticsSelection({@JsonKey(name: '1') this.marketId, @JsonKey(name: '2', fromJson: _parsePoints) this.points, @JsonKey(name: '3') this.selectionName, @JsonKey(name: '4') this.percentage});
  factory _BetStatisticsSelection.fromJson(Map<String, dynamic> json) => _$BetStatisticsSelectionFromJson(json);

@override@JsonKey(name: '1') final  int? marketId;
@override@JsonKey(name: '2', fromJson: _parsePoints) final  String? points;
@override@JsonKey(name: '3') final  String? selectionName;
@override@JsonKey(name: '4') final  double? percentage;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BetStatisticsSelectionCopyWith<_BetStatisticsSelection> get copyWith => __$BetStatisticsSelectionCopyWithImpl<_BetStatisticsSelection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BetStatisticsSelectionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BetStatisticsSelection&&(identical(other.marketId, marketId) || other.marketId == marketId)&&(identical(other.points, points) || other.points == points)&&(identical(other.selectionName, selectionName) || other.selectionName == selectionName)&&(identical(other.percentage, percentage) || other.percentage == percentage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,marketId,points,selectionName,percentage);

@override
String toString() {
  return 'BetStatisticsSelection(marketId: $marketId, points: $points, selectionName: $selectionName, percentage: $percentage)';
}

}

abstract mixin class _$BetStatisticsSelectionCopyWith<$Res> implements $BetStatisticsSelectionCopyWith<$Res> {
  factory _$BetStatisticsSelectionCopyWith(_BetStatisticsSelection value, $Res Function(_BetStatisticsSelection) _then) = __$BetStatisticsSelectionCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: '1') int? marketId,@JsonKey(name: '2', fromJson: _parsePoints) String? points,@JsonKey(name: '3') String? selectionName,@JsonKey(name: '4') double? percentage
});

}
class __$BetStatisticsSelectionCopyWithImpl<$Res>
    implements _$BetStatisticsSelectionCopyWith<$Res> {
  __$BetStatisticsSelectionCopyWithImpl(this._self, this._then);

  final _BetStatisticsSelection _self;
  final $Res Function(_BetStatisticsSelection) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? marketId = freezed,Object? points = freezed,Object? selectionName = freezed,Object? percentage = freezed,}) {
  return _then(_BetStatisticsSelection(
marketId: freezed == marketId ? _self.marketId : marketId // ignore: cast_nullable_to_non_nullable
as int?,points: freezed == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as String?,selectionName: freezed == selectionName ? _self.selectionName : selectionName // ignore: cast_nullable_to_non_nullable
as String?,percentage: freezed == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}

mixin _$BetStatisticsUserDetails {

@JsonKey(name: '0') List<BetStatisticsUserBetDetail> get userBets;
@JsonKey(name: '1') int? get totalCount;
@JsonKey(name: '2') List<String> get marketTypes;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BetStatisticsUserDetailsCopyWith<BetStatisticsUserDetails> get copyWith => _$BetStatisticsUserDetailsCopyWithImpl<BetStatisticsUserDetails>(this as BetStatisticsUserDetails, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BetStatisticsUserDetails&&const DeepCollectionEquality().equals(other.userBets, userBets)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&const DeepCollectionEquality().equals(other.marketTypes, marketTypes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(userBets),totalCount,const DeepCollectionEquality().hash(marketTypes));

@override
String toString() {
  return 'BetStatisticsUserDetails(userBets: $userBets, totalCount: $totalCount, marketTypes: $marketTypes)';
}

}

abstract mixin class $BetStatisticsUserDetailsCopyWith<$Res>  {
  factory $BetStatisticsUserDetailsCopyWith(BetStatisticsUserDetails value, $Res Function(BetStatisticsUserDetails) _then) = _$BetStatisticsUserDetailsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: '0') List<BetStatisticsUserBetDetail> userBets,@JsonKey(name: '1') int? totalCount,@JsonKey(name: '2') List<String> marketTypes
});

}
class _$BetStatisticsUserDetailsCopyWithImpl<$Res>
    implements $BetStatisticsUserDetailsCopyWith<$Res> {
  _$BetStatisticsUserDetailsCopyWithImpl(this._self, this._then);

  final BetStatisticsUserDetails _self;
  final $Res Function(BetStatisticsUserDetails) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? userBets = null,Object? totalCount = freezed,Object? marketTypes = null,}) {
  return _then(_self.copyWith(
userBets: null == userBets ? _self.userBets : userBets // ignore: cast_nullable_to_non_nullable
as List<BetStatisticsUserBetDetail>,totalCount: freezed == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int?,marketTypes: null == marketTypes ? _self.marketTypes : marketTypes // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}

extension BetStatisticsUserDetailsPatterns on BetStatisticsUserDetails {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BetStatisticsUserDetails value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BetStatisticsUserDetails() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BetStatisticsUserDetails value)  $default,){
final _that = this;
switch (_that) {
case _BetStatisticsUserDetails():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BetStatisticsUserDetails value)?  $default,){
final _that = this;
switch (_that) {
case _BetStatisticsUserDetails() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: '0')  List<BetStatisticsUserBetDetail> userBets, @JsonKey(name: '1')  int? totalCount, @JsonKey(name: '2')  List<String> marketTypes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BetStatisticsUserDetails() when $default != null:
return $default(_that.userBets,_that.totalCount,_that.marketTypes);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: '0')  List<BetStatisticsUserBetDetail> userBets, @JsonKey(name: '1')  int? totalCount, @JsonKey(name: '2')  List<String> marketTypes)  $default,) {final _that = this;
switch (_that) {
case _BetStatisticsUserDetails():
return $default(_that.userBets,_that.totalCount,_that.marketTypes);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: '0')  List<BetStatisticsUserBetDetail> userBets, @JsonKey(name: '1')  int? totalCount, @JsonKey(name: '2')  List<String> marketTypes)?  $default,) {final _that = this;
switch (_that) {
case _BetStatisticsUserDetails() when $default != null:
return $default(_that.userBets,_that.totalCount,_that.marketTypes);case _:
  return null;

}
}

}

@JsonSerializable()

class _BetStatisticsUserDetails implements BetStatisticsUserDetails {
  const _BetStatisticsUserDetails({@JsonKey(name: '0') final  List<BetStatisticsUserBetDetail> userBets = const [], @JsonKey(name: '1') this.totalCount, @JsonKey(name: '2') final  List<String> marketTypes = const []}): _userBets = userBets,_marketTypes = marketTypes;
  factory _BetStatisticsUserDetails.fromJson(Map<String, dynamic> json) => _$BetStatisticsUserDetailsFromJson(json);

 final  List<BetStatisticsUserBetDetail> _userBets;
@override@JsonKey(name: '0') List<BetStatisticsUserBetDetail> get userBets {
  if (_userBets is EqualUnmodifiableListView) return _userBets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_userBets);
}

@override@JsonKey(name: '1') final  int? totalCount;
 final  List<String> _marketTypes;
@override@JsonKey(name: '2') List<String> get marketTypes {
  if (_marketTypes is EqualUnmodifiableListView) return _marketTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_marketTypes);
}

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BetStatisticsUserDetailsCopyWith<_BetStatisticsUserDetails> get copyWith => __$BetStatisticsUserDetailsCopyWithImpl<_BetStatisticsUserDetails>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BetStatisticsUserDetailsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BetStatisticsUserDetails&&const DeepCollectionEquality().equals(other._userBets, _userBets)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&const DeepCollectionEquality().equals(other._marketTypes, _marketTypes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_userBets),totalCount,const DeepCollectionEquality().hash(_marketTypes));

@override
String toString() {
  return 'BetStatisticsUserDetails(userBets: $userBets, totalCount: $totalCount, marketTypes: $marketTypes)';
}

}

abstract mixin class _$BetStatisticsUserDetailsCopyWith<$Res> implements $BetStatisticsUserDetailsCopyWith<$Res> {
  factory _$BetStatisticsUserDetailsCopyWith(_BetStatisticsUserDetails value, $Res Function(_BetStatisticsUserDetails) _then) = __$BetStatisticsUserDetailsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: '0') List<BetStatisticsUserBetDetail> userBets,@JsonKey(name: '1') int? totalCount,@JsonKey(name: '2') List<String> marketTypes
});

}
class __$BetStatisticsUserDetailsCopyWithImpl<$Res>
    implements _$BetStatisticsUserDetailsCopyWith<$Res> {
  __$BetStatisticsUserDetailsCopyWithImpl(this._self, this._then);

  final _BetStatisticsUserDetails _self;
  final $Res Function(_BetStatisticsUserDetails) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? userBets = null,Object? totalCount = freezed,Object? marketTypes = null,}) {
  return _then(_BetStatisticsUserDetails(
userBets: null == userBets ? _self._userBets : userBets // ignore: cast_nullable_to_non_nullable
as List<BetStatisticsUserBetDetail>,totalCount: freezed == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int?,marketTypes: null == marketTypes ? _self._marketTypes : marketTypes // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}

mixin _$BetStatisticsUserBetDetail {

@JsonKey(name: '1') String? get userName;
@JsonKey(name: '2') String? get selectionName;
@JsonKey(name: '3') String? get opponentName;
@JsonKey(name: '4') int? get eventId;
@JsonKey(name: '5') String? get leagueName;
@JsonKey(name: '6') int? get leagueId;
@JsonKey(name: '7') bool? get flag;
@JsonKey(name: '8') String? get marketName;
@JsonKey(name: '9') String? get idOrTimestamp;
@JsonKey(name: '10') String? get oddsStyle;
@JsonKey(name: '11') String? get oddsValueString;
@JsonKey(name: '12') String? get score;
@JsonKey(name: '13') String? get selectionId;
@JsonKey(name: '14') String? get selectionName2;
@JsonKey(name: '15') String? get betTimestamp;
@JsonKey(name: '16') double? get oddsValue;
@JsonKey(name: '17') String? get points;
@JsonKey(name: '18') int? get number;
@JsonKey(name: '19') int? get marketId;
@JsonKey(name: '20') Map<String, String>? get oddsValues;
@JsonKey(name: '21') String? get id;
@JsonKey(name: '22') String? get matchTime;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BetStatisticsUserBetDetailCopyWith<BetStatisticsUserBetDetail> get copyWith => _$BetStatisticsUserBetDetailCopyWithImpl<BetStatisticsUserBetDetail>(this as BetStatisticsUserBetDetail, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BetStatisticsUserBetDetail&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.selectionName, selectionName) || other.selectionName == selectionName)&&(identical(other.opponentName, opponentName) || other.opponentName == opponentName)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.leagueName, leagueName) || other.leagueName == leagueName)&&(identical(other.leagueId, leagueId) || other.leagueId == leagueId)&&(identical(other.flag, flag) || other.flag == flag)&&(identical(other.marketName, marketName) || other.marketName == marketName)&&(identical(other.idOrTimestamp, idOrTimestamp) || other.idOrTimestamp == idOrTimestamp)&&(identical(other.oddsStyle, oddsStyle) || other.oddsStyle == oddsStyle)&&(identical(other.oddsValueString, oddsValueString) || other.oddsValueString == oddsValueString)&&(identical(other.score, score) || other.score == score)&&(identical(other.selectionId, selectionId) || other.selectionId == selectionId)&&(identical(other.selectionName2, selectionName2) || other.selectionName2 == selectionName2)&&(identical(other.betTimestamp, betTimestamp) || other.betTimestamp == betTimestamp)&&(identical(other.oddsValue, oddsValue) || other.oddsValue == oddsValue)&&(identical(other.points, points) || other.points == points)&&(identical(other.number, number) || other.number == number)&&(identical(other.marketId, marketId) || other.marketId == marketId)&&const DeepCollectionEquality().equals(other.oddsValues, oddsValues)&&(identical(other.id, id) || other.id == id)&&(identical(other.matchTime, matchTime) || other.matchTime == matchTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,userName,selectionName,opponentName,eventId,leagueName,leagueId,flag,marketName,idOrTimestamp,oddsStyle,oddsValueString,score,selectionId,selectionName2,betTimestamp,oddsValue,points,number,marketId,const DeepCollectionEquality().hash(oddsValues),id,matchTime]);

@override
String toString() {
  return 'BetStatisticsUserBetDetail(userName: $userName, selectionName: $selectionName, opponentName: $opponentName, eventId: $eventId, leagueName: $leagueName, leagueId: $leagueId, flag: $flag, marketName: $marketName, idOrTimestamp: $idOrTimestamp, oddsStyle: $oddsStyle, oddsValueString: $oddsValueString, score: $score, selectionId: $selectionId, selectionName2: $selectionName2, betTimestamp: $betTimestamp, oddsValue: $oddsValue, points: $points, number: $number, marketId: $marketId, oddsValues: $oddsValues, id: $id, matchTime: $matchTime)';
}

}

abstract mixin class $BetStatisticsUserBetDetailCopyWith<$Res>  {
  factory $BetStatisticsUserBetDetailCopyWith(BetStatisticsUserBetDetail value, $Res Function(BetStatisticsUserBetDetail) _then) = _$BetStatisticsUserBetDetailCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: '1') String? userName,@JsonKey(name: '2') String? selectionName,@JsonKey(name: '3') String? opponentName,@JsonKey(name: '4') int? eventId,@JsonKey(name: '5') String? leagueName,@JsonKey(name: '6') int? leagueId,@JsonKey(name: '7') bool? flag,@JsonKey(name: '8') String? marketName,@JsonKey(name: '9') String? idOrTimestamp,@JsonKey(name: '10') String? oddsStyle,@JsonKey(name: '11') String? oddsValueString,@JsonKey(name: '12') String? score,@JsonKey(name: '13') String? selectionId,@JsonKey(name: '14') String? selectionName2,@JsonKey(name: '15') String? betTimestamp,@JsonKey(name: '16') double? oddsValue,@JsonKey(name: '17') String? points,@JsonKey(name: '18') int? number,@JsonKey(name: '19') int? marketId,@JsonKey(name: '20') Map<String, String>? oddsValues,@JsonKey(name: '21') String? id,@JsonKey(name: '22') String? matchTime
});

}
class _$BetStatisticsUserBetDetailCopyWithImpl<$Res>
    implements $BetStatisticsUserBetDetailCopyWith<$Res> {
  _$BetStatisticsUserBetDetailCopyWithImpl(this._self, this._then);

  final BetStatisticsUserBetDetail _self;
  final $Res Function(BetStatisticsUserBetDetail) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? userName = freezed,Object? selectionName = freezed,Object? opponentName = freezed,Object? eventId = freezed,Object? leagueName = freezed,Object? leagueId = freezed,Object? flag = freezed,Object? marketName = freezed,Object? idOrTimestamp = freezed,Object? oddsStyle = freezed,Object? oddsValueString = freezed,Object? score = freezed,Object? selectionId = freezed,Object? selectionName2 = freezed,Object? betTimestamp = freezed,Object? oddsValue = freezed,Object? points = freezed,Object? number = freezed,Object? marketId = freezed,Object? oddsValues = freezed,Object? id = freezed,Object? matchTime = freezed,}) {
  return _then(_self.copyWith(
userName: freezed == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String?,selectionName: freezed == selectionName ? _self.selectionName : selectionName // ignore: cast_nullable_to_non_nullable
as String?,opponentName: freezed == opponentName ? _self.opponentName : opponentName // ignore: cast_nullable_to_non_nullable
as String?,eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as int?,leagueName: freezed == leagueName ? _self.leagueName : leagueName // ignore: cast_nullable_to_non_nullable
as String?,leagueId: freezed == leagueId ? _self.leagueId : leagueId // ignore: cast_nullable_to_non_nullable
as int?,flag: freezed == flag ? _self.flag : flag // ignore: cast_nullable_to_non_nullable
as bool?,marketName: freezed == marketName ? _self.marketName : marketName // ignore: cast_nullable_to_non_nullable
as String?,idOrTimestamp: freezed == idOrTimestamp ? _self.idOrTimestamp : idOrTimestamp // ignore: cast_nullable_to_non_nullable
as String?,oddsStyle: freezed == oddsStyle ? _self.oddsStyle : oddsStyle // ignore: cast_nullable_to_non_nullable
as String?,oddsValueString: freezed == oddsValueString ? _self.oddsValueString : oddsValueString // ignore: cast_nullable_to_non_nullable
as String?,score: freezed == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as String?,selectionId: freezed == selectionId ? _self.selectionId : selectionId // ignore: cast_nullable_to_non_nullable
as String?,selectionName2: freezed == selectionName2 ? _self.selectionName2 : selectionName2 // ignore: cast_nullable_to_non_nullable
as String?,betTimestamp: freezed == betTimestamp ? _self.betTimestamp : betTimestamp // ignore: cast_nullable_to_non_nullable
as String?,oddsValue: freezed == oddsValue ? _self.oddsValue : oddsValue // ignore: cast_nullable_to_non_nullable
as double?,points: freezed == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as String?,number: freezed == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int?,marketId: freezed == marketId ? _self.marketId : marketId // ignore: cast_nullable_to_non_nullable
as int?,oddsValues: freezed == oddsValues ? _self.oddsValues : oddsValues // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,matchTime: freezed == matchTime ? _self.matchTime : matchTime // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}

extension BetStatisticsUserBetDetailPatterns on BetStatisticsUserBetDetail {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BetStatisticsUserBetDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BetStatisticsUserBetDetail() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BetStatisticsUserBetDetail value)  $default,){
final _that = this;
switch (_that) {
case _BetStatisticsUserBetDetail():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BetStatisticsUserBetDetail value)?  $default,){
final _that = this;
switch (_that) {
case _BetStatisticsUserBetDetail() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: '1')  String? userName, @JsonKey(name: '2')  String? selectionName, @JsonKey(name: '3')  String? opponentName, @JsonKey(name: '4')  int? eventId, @JsonKey(name: '5')  String? leagueName, @JsonKey(name: '6')  int? leagueId, @JsonKey(name: '7')  bool? flag, @JsonKey(name: '8')  String? marketName, @JsonKey(name: '9')  String? idOrTimestamp, @JsonKey(name: '10')  String? oddsStyle, @JsonKey(name: '11')  String? oddsValueString, @JsonKey(name: '12')  String? score, @JsonKey(name: '13')  String? selectionId, @JsonKey(name: '14')  String? selectionName2, @JsonKey(name: '15')  String? betTimestamp, @JsonKey(name: '16')  double? oddsValue, @JsonKey(name: '17')  String? points, @JsonKey(name: '18')  int? number, @JsonKey(name: '19')  int? marketId, @JsonKey(name: '20')  Map<String, String>? oddsValues, @JsonKey(name: '21')  String? id, @JsonKey(name: '22')  String? matchTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BetStatisticsUserBetDetail() when $default != null:
return $default(_that.userName,_that.selectionName,_that.opponentName,_that.eventId,_that.leagueName,_that.leagueId,_that.flag,_that.marketName,_that.idOrTimestamp,_that.oddsStyle,_that.oddsValueString,_that.score,_that.selectionId,_that.selectionName2,_that.betTimestamp,_that.oddsValue,_that.points,_that.number,_that.marketId,_that.oddsValues,_that.id,_that.matchTime);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: '1')  String? userName, @JsonKey(name: '2')  String? selectionName, @JsonKey(name: '3')  String? opponentName, @JsonKey(name: '4')  int? eventId, @JsonKey(name: '5')  String? leagueName, @JsonKey(name: '6')  int? leagueId, @JsonKey(name: '7')  bool? flag, @JsonKey(name: '8')  String? marketName, @JsonKey(name: '9')  String? idOrTimestamp, @JsonKey(name: '10')  String? oddsStyle, @JsonKey(name: '11')  String? oddsValueString, @JsonKey(name: '12')  String? score, @JsonKey(name: '13')  String? selectionId, @JsonKey(name: '14')  String? selectionName2, @JsonKey(name: '15')  String? betTimestamp, @JsonKey(name: '16')  double? oddsValue, @JsonKey(name: '17')  String? points, @JsonKey(name: '18')  int? number, @JsonKey(name: '19')  int? marketId, @JsonKey(name: '20')  Map<String, String>? oddsValues, @JsonKey(name: '21')  String? id, @JsonKey(name: '22')  String? matchTime)  $default,) {final _that = this;
switch (_that) {
case _BetStatisticsUserBetDetail():
return $default(_that.userName,_that.selectionName,_that.opponentName,_that.eventId,_that.leagueName,_that.leagueId,_that.flag,_that.marketName,_that.idOrTimestamp,_that.oddsStyle,_that.oddsValueString,_that.score,_that.selectionId,_that.selectionName2,_that.betTimestamp,_that.oddsValue,_that.points,_that.number,_that.marketId,_that.oddsValues,_that.id,_that.matchTime);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: '1')  String? userName, @JsonKey(name: '2')  String? selectionName, @JsonKey(name: '3')  String? opponentName, @JsonKey(name: '4')  int? eventId, @JsonKey(name: '5')  String? leagueName, @JsonKey(name: '6')  int? leagueId, @JsonKey(name: '7')  bool? flag, @JsonKey(name: '8')  String? marketName, @JsonKey(name: '9')  String? idOrTimestamp, @JsonKey(name: '10')  String? oddsStyle, @JsonKey(name: '11')  String? oddsValueString, @JsonKey(name: '12')  String? score, @JsonKey(name: '13')  String? selectionId, @JsonKey(name: '14')  String? selectionName2, @JsonKey(name: '15')  String? betTimestamp, @JsonKey(name: '16')  double? oddsValue, @JsonKey(name: '17')  String? points, @JsonKey(name: '18')  int? number, @JsonKey(name: '19')  int? marketId, @JsonKey(name: '20')  Map<String, String>? oddsValues, @JsonKey(name: '21')  String? id, @JsonKey(name: '22')  String? matchTime)?  $default,) {final _that = this;
switch (_that) {
case _BetStatisticsUserBetDetail() when $default != null:
return $default(_that.userName,_that.selectionName,_that.opponentName,_that.eventId,_that.leagueName,_that.leagueId,_that.flag,_that.marketName,_that.idOrTimestamp,_that.oddsStyle,_that.oddsValueString,_that.score,_that.selectionId,_that.selectionName2,_that.betTimestamp,_that.oddsValue,_that.points,_that.number,_that.marketId,_that.oddsValues,_that.id,_that.matchTime);case _:
  return null;

}
}

}

@JsonSerializable()

class _BetStatisticsUserBetDetail implements BetStatisticsUserBetDetail {
  const _BetStatisticsUserBetDetail({@JsonKey(name: '1') this.userName, @JsonKey(name: '2') this.selectionName, @JsonKey(name: '3') this.opponentName, @JsonKey(name: '4') this.eventId, @JsonKey(name: '5') this.leagueName, @JsonKey(name: '6') this.leagueId, @JsonKey(name: '7') this.flag, @JsonKey(name: '8') this.marketName, @JsonKey(name: '9') this.idOrTimestamp, @JsonKey(name: '10') this.oddsStyle, @JsonKey(name: '11') this.oddsValueString, @JsonKey(name: '12') this.score, @JsonKey(name: '13') this.selectionId, @JsonKey(name: '14') this.selectionName2, @JsonKey(name: '15') this.betTimestamp, @JsonKey(name: '16') this.oddsValue, @JsonKey(name: '17') this.points, @JsonKey(name: '18') this.number, @JsonKey(name: '19') this.marketId, @JsonKey(name: '20') final  Map<String, String>? oddsValues, @JsonKey(name: '21') this.id, @JsonKey(name: '22') this.matchTime}): _oddsValues = oddsValues;
  factory _BetStatisticsUserBetDetail.fromJson(Map<String, dynamic> json) => _$BetStatisticsUserBetDetailFromJson(json);

@override@JsonKey(name: '1') final  String? userName;
@override@JsonKey(name: '2') final  String? selectionName;
@override@JsonKey(name: '3') final  String? opponentName;
@override@JsonKey(name: '4') final  int? eventId;
@override@JsonKey(name: '5') final  String? leagueName;
@override@JsonKey(name: '6') final  int? leagueId;
@override@JsonKey(name: '7') final  bool? flag;
@override@JsonKey(name: '8') final  String? marketName;
@override@JsonKey(name: '9') final  String? idOrTimestamp;
@override@JsonKey(name: '10') final  String? oddsStyle;
@override@JsonKey(name: '11') final  String? oddsValueString;
@override@JsonKey(name: '12') final  String? score;
@override@JsonKey(name: '13') final  String? selectionId;
@override@JsonKey(name: '14') final  String? selectionName2;
@override@JsonKey(name: '15') final  String? betTimestamp;
@override@JsonKey(name: '16') final  double? oddsValue;
@override@JsonKey(name: '17') final  String? points;
@override@JsonKey(name: '18') final  int? number;
@override@JsonKey(name: '19') final  int? marketId;
 final  Map<String, String>? _oddsValues;
@override@JsonKey(name: '20') Map<String, String>? get oddsValues {
  final value = _oddsValues;
  if (value == null) return null;
  if (_oddsValues is EqualUnmodifiableMapView) return _oddsValues;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey(name: '21') final  String? id;
@override@JsonKey(name: '22') final  String? matchTime;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BetStatisticsUserBetDetailCopyWith<_BetStatisticsUserBetDetail> get copyWith => __$BetStatisticsUserBetDetailCopyWithImpl<_BetStatisticsUserBetDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BetStatisticsUserBetDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BetStatisticsUserBetDetail&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.selectionName, selectionName) || other.selectionName == selectionName)&&(identical(other.opponentName, opponentName) || other.opponentName == opponentName)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.leagueName, leagueName) || other.leagueName == leagueName)&&(identical(other.leagueId, leagueId) || other.leagueId == leagueId)&&(identical(other.flag, flag) || other.flag == flag)&&(identical(other.marketName, marketName) || other.marketName == marketName)&&(identical(other.idOrTimestamp, idOrTimestamp) || other.idOrTimestamp == idOrTimestamp)&&(identical(other.oddsStyle, oddsStyle) || other.oddsStyle == oddsStyle)&&(identical(other.oddsValueString, oddsValueString) || other.oddsValueString == oddsValueString)&&(identical(other.score, score) || other.score == score)&&(identical(other.selectionId, selectionId) || other.selectionId == selectionId)&&(identical(other.selectionName2, selectionName2) || other.selectionName2 == selectionName2)&&(identical(other.betTimestamp, betTimestamp) || other.betTimestamp == betTimestamp)&&(identical(other.oddsValue, oddsValue) || other.oddsValue == oddsValue)&&(identical(other.points, points) || other.points == points)&&(identical(other.number, number) || other.number == number)&&(identical(other.marketId, marketId) || other.marketId == marketId)&&const DeepCollectionEquality().equals(other._oddsValues, _oddsValues)&&(identical(other.id, id) || other.id == id)&&(identical(other.matchTime, matchTime) || other.matchTime == matchTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,userName,selectionName,opponentName,eventId,leagueName,leagueId,flag,marketName,idOrTimestamp,oddsStyle,oddsValueString,score,selectionId,selectionName2,betTimestamp,oddsValue,points,number,marketId,const DeepCollectionEquality().hash(_oddsValues),id,matchTime]);

@override
String toString() {
  return 'BetStatisticsUserBetDetail(userName: $userName, selectionName: $selectionName, opponentName: $opponentName, eventId: $eventId, leagueName: $leagueName, leagueId: $leagueId, flag: $flag, marketName: $marketName, idOrTimestamp: $idOrTimestamp, oddsStyle: $oddsStyle, oddsValueString: $oddsValueString, score: $score, selectionId: $selectionId, selectionName2: $selectionName2, betTimestamp: $betTimestamp, oddsValue: $oddsValue, points: $points, number: $number, marketId: $marketId, oddsValues: $oddsValues, id: $id, matchTime: $matchTime)';
}

}

abstract mixin class _$BetStatisticsUserBetDetailCopyWith<$Res> implements $BetStatisticsUserBetDetailCopyWith<$Res> {
  factory _$BetStatisticsUserBetDetailCopyWith(_BetStatisticsUserBetDetail value, $Res Function(_BetStatisticsUserBetDetail) _then) = __$BetStatisticsUserBetDetailCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: '1') String? userName,@JsonKey(name: '2') String? selectionName,@JsonKey(name: '3') String? opponentName,@JsonKey(name: '4') int? eventId,@JsonKey(name: '5') String? leagueName,@JsonKey(name: '6') int? leagueId,@JsonKey(name: '7') bool? flag,@JsonKey(name: '8') String? marketName,@JsonKey(name: '9') String? idOrTimestamp,@JsonKey(name: '10') String? oddsStyle,@JsonKey(name: '11') String? oddsValueString,@JsonKey(name: '12') String? score,@JsonKey(name: '13') String? selectionId,@JsonKey(name: '14') String? selectionName2,@JsonKey(name: '15') String? betTimestamp,@JsonKey(name: '16') double? oddsValue,@JsonKey(name: '17') String? points,@JsonKey(name: '18') int? number,@JsonKey(name: '19') int? marketId,@JsonKey(name: '20') Map<String, String>? oddsValues,@JsonKey(name: '21') String? id,@JsonKey(name: '22') String? matchTime
});

}
class __$BetStatisticsUserBetDetailCopyWithImpl<$Res>
    implements _$BetStatisticsUserBetDetailCopyWith<$Res> {
  __$BetStatisticsUserBetDetailCopyWithImpl(this._self, this._then);

  final _BetStatisticsUserBetDetail _self;
  final $Res Function(_BetStatisticsUserBetDetail) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? userName = freezed,Object? selectionName = freezed,Object? opponentName = freezed,Object? eventId = freezed,Object? leagueName = freezed,Object? leagueId = freezed,Object? flag = freezed,Object? marketName = freezed,Object? idOrTimestamp = freezed,Object? oddsStyle = freezed,Object? oddsValueString = freezed,Object? score = freezed,Object? selectionId = freezed,Object? selectionName2 = freezed,Object? betTimestamp = freezed,Object? oddsValue = freezed,Object? points = freezed,Object? number = freezed,Object? marketId = freezed,Object? oddsValues = freezed,Object? id = freezed,Object? matchTime = freezed,}) {
  return _then(_BetStatisticsUserBetDetail(
userName: freezed == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String?,selectionName: freezed == selectionName ? _self.selectionName : selectionName // ignore: cast_nullable_to_non_nullable
as String?,opponentName: freezed == opponentName ? _self.opponentName : opponentName // ignore: cast_nullable_to_non_nullable
as String?,eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as int?,leagueName: freezed == leagueName ? _self.leagueName : leagueName // ignore: cast_nullable_to_non_nullable
as String?,leagueId: freezed == leagueId ? _self.leagueId : leagueId // ignore: cast_nullable_to_non_nullable
as int?,flag: freezed == flag ? _self.flag : flag // ignore: cast_nullable_to_non_nullable
as bool?,marketName: freezed == marketName ? _self.marketName : marketName // ignore: cast_nullable_to_non_nullable
as String?,idOrTimestamp: freezed == idOrTimestamp ? _self.idOrTimestamp : idOrTimestamp // ignore: cast_nullable_to_non_nullable
as String?,oddsStyle: freezed == oddsStyle ? _self.oddsStyle : oddsStyle // ignore: cast_nullable_to_non_nullable
as String?,oddsValueString: freezed == oddsValueString ? _self.oddsValueString : oddsValueString // ignore: cast_nullable_to_non_nullable
as String?,score: freezed == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as String?,selectionId: freezed == selectionId ? _self.selectionId : selectionId // ignore: cast_nullable_to_non_nullable
as String?,selectionName2: freezed == selectionName2 ? _self.selectionName2 : selectionName2 // ignore: cast_nullable_to_non_nullable
as String?,betTimestamp: freezed == betTimestamp ? _self.betTimestamp : betTimestamp // ignore: cast_nullable_to_non_nullable
as String?,oddsValue: freezed == oddsValue ? _self.oddsValue : oddsValue // ignore: cast_nullable_to_non_nullable
as double?,points: freezed == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as String?,number: freezed == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int?,marketId: freezed == marketId ? _self.marketId : marketId // ignore: cast_nullable_to_non_nullable
as int?,oddsValues: freezed == oddsValues ? _self._oddsValues : oddsValues // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,matchTime: freezed == matchTime ? _self.matchTime : matchTime // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}

// dart format on
