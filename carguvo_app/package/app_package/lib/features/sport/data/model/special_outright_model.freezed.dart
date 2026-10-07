// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'special_outright_model.dart';

// dart format off
T _$identity<T>(T value) => value;
mixin _$SpecialOutrightModel {

 List<SpecialOutrightSelection> get selections;
 int get outrightId;
 int get eventId;
 String get outrightName;
 String get eventName;
 int get lineOrder;
 String get endDate;
 int get startTime;
 int get leagueId;
 String get leagueLogo;
 String get leagueName;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpecialOutrightModelCopyWith<SpecialOutrightModel> get copyWith => _$SpecialOutrightModelCopyWithImpl<SpecialOutrightModel>(this as SpecialOutrightModel, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpecialOutrightModel&&const DeepCollectionEquality().equals(other.selections, selections)&&(identical(other.outrightId, outrightId) || other.outrightId == outrightId)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.outrightName, outrightName) || other.outrightName == outrightName)&&(identical(other.eventName, eventName) || other.eventName == eventName)&&(identical(other.lineOrder, lineOrder) || other.lineOrder == lineOrder)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.leagueId, leagueId) || other.leagueId == leagueId)&&(identical(other.leagueLogo, leagueLogo) || other.leagueLogo == leagueLogo)&&(identical(other.leagueName, leagueName) || other.leagueName == leagueName));
}

@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(selections),outrightId,eventId,outrightName,eventName,lineOrder,endDate,startTime,leagueId,leagueLogo,leagueName);

@override
String toString() {
  return 'SpecialOutrightModel(selections: $selections, outrightId: $outrightId, eventId: $eventId, outrightName: $outrightName, eventName: $eventName, lineOrder: $lineOrder, endDate: $endDate, startTime: $startTime, leagueId: $leagueId, leagueLogo: $leagueLogo, leagueName: $leagueName)';
}

}

abstract mixin class $SpecialOutrightModelCopyWith<$Res>  {
  factory $SpecialOutrightModelCopyWith(SpecialOutrightModel value, $Res Function(SpecialOutrightModel) _then) = _$SpecialOutrightModelCopyWithImpl;
@useResult
$Res call({
 List<SpecialOutrightSelection> selections, int outrightId, int eventId, String outrightName, String eventName, int lineOrder, String endDate, int startTime, int leagueId, String leagueLogo, String leagueName
});

}
class _$SpecialOutrightModelCopyWithImpl<$Res>
    implements $SpecialOutrightModelCopyWith<$Res> {
  _$SpecialOutrightModelCopyWithImpl(this._self, this._then);

  final SpecialOutrightModel _self;
  final $Res Function(SpecialOutrightModel) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? selections = null,Object? outrightId = null,Object? eventId = null,Object? outrightName = null,Object? eventName = null,Object? lineOrder = null,Object? endDate = null,Object? startTime = null,Object? leagueId = null,Object? leagueLogo = null,Object? leagueName = null,}) {
  return _then(_self.copyWith(
selections: null == selections ? _self.selections : selections // ignore: cast_nullable_to_non_nullable
as List<SpecialOutrightSelection>,outrightId: null == outrightId ? _self.outrightId : outrightId // ignore: cast_nullable_to_non_nullable
as int,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as int,outrightName: null == outrightName ? _self.outrightName : outrightName // ignore: cast_nullable_to_non_nullable
as String,eventName: null == eventName ? _self.eventName : eventName // ignore: cast_nullable_to_non_nullable
as String,lineOrder: null == lineOrder ? _self.lineOrder : lineOrder // ignore: cast_nullable_to_non_nullable
as int,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as int,leagueId: null == leagueId ? _self.leagueId : leagueId // ignore: cast_nullable_to_non_nullable
as int,leagueLogo: null == leagueLogo ? _self.leagueLogo : leagueLogo // ignore: cast_nullable_to_non_nullable
as String,leagueName: null == leagueName ? _self.leagueName : leagueName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}

extension SpecialOutrightModelPatterns on SpecialOutrightModel {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SpecialOutrightModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SpecialOutrightModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SpecialOutrightModel value)  $default,){
final _that = this;
switch (_that) {
case _SpecialOutrightModel():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SpecialOutrightModel value)?  $default,){
final _that = this;
switch (_that) {
case _SpecialOutrightModel() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<SpecialOutrightSelection> selections,  int outrightId,  int eventId,  String outrightName,  String eventName,  int lineOrder,  String endDate,  int startTime,  int leagueId,  String leagueLogo,  String leagueName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SpecialOutrightModel() when $default != null:
return $default(_that.selections,_that.outrightId,_that.eventId,_that.outrightName,_that.eventName,_that.lineOrder,_that.endDate,_that.startTime,_that.leagueId,_that.leagueLogo,_that.leagueName);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<SpecialOutrightSelection> selections,  int outrightId,  int eventId,  String outrightName,  String eventName,  int lineOrder,  String endDate,  int startTime,  int leagueId,  String leagueLogo,  String leagueName)  $default,) {final _that = this;
switch (_that) {
case _SpecialOutrightModel():
return $default(_that.selections,_that.outrightId,_that.eventId,_that.outrightName,_that.eventName,_that.lineOrder,_that.endDate,_that.startTime,_that.leagueId,_that.leagueLogo,_that.leagueName);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<SpecialOutrightSelection> selections,  int outrightId,  int eventId,  String outrightName,  String eventName,  int lineOrder,  String endDate,  int startTime,  int leagueId,  String leagueLogo,  String leagueName)?  $default,) {final _that = this;
switch (_that) {
case _SpecialOutrightModel() when $default != null:
return $default(_that.selections,_that.outrightId,_that.eventId,_that.outrightName,_that.eventName,_that.lineOrder,_that.endDate,_that.startTime,_that.leagueId,_that.leagueLogo,_that.leagueName);case _:
  return null;

}
}

}

class _SpecialOutrightModel implements SpecialOutrightModel {
  const _SpecialOutrightModel({final  List<SpecialOutrightSelection> selections = const [], this.outrightId = 0, this.eventId = 0, this.outrightName = '', this.eventName = '', this.lineOrder = 0, this.endDate = '', this.startTime = 0, this.leagueId = 0, this.leagueLogo = '', this.leagueName = ''}): _selections = selections;
  
 final  List<SpecialOutrightSelection> _selections;
@override@JsonKey() List<SpecialOutrightSelection> get selections {
  if (_selections is EqualUnmodifiableListView) return _selections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selections);
}

@override@JsonKey() final  int outrightId;
@override@JsonKey() final  int eventId;
@override@JsonKey() final  String outrightName;
@override@JsonKey() final  String eventName;
@override@JsonKey() final  int lineOrder;
@override@JsonKey() final  String endDate;
@override@JsonKey() final  int startTime;
@override@JsonKey() final  int leagueId;
@override@JsonKey() final  String leagueLogo;
@override@JsonKey() final  String leagueName;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpecialOutrightModelCopyWith<_SpecialOutrightModel> get copyWith => __$SpecialOutrightModelCopyWithImpl<_SpecialOutrightModel>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SpecialOutrightModel&&const DeepCollectionEquality().equals(other._selections, _selections)&&(identical(other.outrightId, outrightId) || other.outrightId == outrightId)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.outrightName, outrightName) || other.outrightName == outrightName)&&(identical(other.eventName, eventName) || other.eventName == eventName)&&(identical(other.lineOrder, lineOrder) || other.lineOrder == lineOrder)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.leagueId, leagueId) || other.leagueId == leagueId)&&(identical(other.leagueLogo, leagueLogo) || other.leagueLogo == leagueLogo)&&(identical(other.leagueName, leagueName) || other.leagueName == leagueName));
}

@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_selections),outrightId,eventId,outrightName,eventName,lineOrder,endDate,startTime,leagueId,leagueLogo,leagueName);

@override
String toString() {
  return 'SpecialOutrightModel(selections: $selections, outrightId: $outrightId, eventId: $eventId, outrightName: $outrightName, eventName: $eventName, lineOrder: $lineOrder, endDate: $endDate, startTime: $startTime, leagueId: $leagueId, leagueLogo: $leagueLogo, leagueName: $leagueName)';
}

}

abstract mixin class _$SpecialOutrightModelCopyWith<$Res> implements $SpecialOutrightModelCopyWith<$Res> {
  factory _$SpecialOutrightModelCopyWith(_SpecialOutrightModel value, $Res Function(_SpecialOutrightModel) _then) = __$SpecialOutrightModelCopyWithImpl;
@override @useResult
$Res call({
 List<SpecialOutrightSelection> selections, int outrightId, int eventId, String outrightName, String eventName, int lineOrder, String endDate, int startTime, int leagueId, String leagueLogo, String leagueName
});

}
class __$SpecialOutrightModelCopyWithImpl<$Res>
    implements _$SpecialOutrightModelCopyWith<$Res> {
  __$SpecialOutrightModelCopyWithImpl(this._self, this._then);

  final _SpecialOutrightModel _self;
  final $Res Function(_SpecialOutrightModel) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? selections = null,Object? outrightId = null,Object? eventId = null,Object? outrightName = null,Object? eventName = null,Object? lineOrder = null,Object? endDate = null,Object? startTime = null,Object? leagueId = null,Object? leagueLogo = null,Object? leagueName = null,}) {
  return _then(_SpecialOutrightModel(
selections: null == selections ? _self._selections : selections // ignore: cast_nullable_to_non_nullable
as List<SpecialOutrightSelection>,outrightId: null == outrightId ? _self.outrightId : outrightId // ignore: cast_nullable_to_non_nullable
as int,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as int,outrightName: null == outrightName ? _self.outrightName : outrightName // ignore: cast_nullable_to_non_nullable
as String,eventName: null == eventName ? _self.eventName : eventName // ignore: cast_nullable_to_non_nullable
as String,lineOrder: null == lineOrder ? _self.lineOrder : lineOrder // ignore: cast_nullable_to_non_nullable
as int,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as int,leagueId: null == leagueId ? _self.leagueId : leagueId // ignore: cast_nullable_to_non_nullable
as int,leagueLogo: null == leagueLogo ? _self.leagueLogo : leagueLogo // ignore: cast_nullable_to_non_nullable
as String,leagueName: null == leagueName ? _self.leagueName : leagueName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}

mixin _$SpecialOutrightSelection {

@JsonKey(name: '0') String get selectionId;
@JsonKey(name: '1') String get selectionName;
@JsonKey(name: '2') String get logoUrl;
@JsonKey(name: '3') String get offerId;
@JsonKey(name: '4', fromJson: _safeParseDouble) double get odds;
@JsonKey(name: '5') String get selectionCode;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpecialOutrightSelectionCopyWith<SpecialOutrightSelection> get copyWith => _$SpecialOutrightSelectionCopyWithImpl<SpecialOutrightSelection>(this as SpecialOutrightSelection, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpecialOutrightSelection&&(identical(other.selectionId, selectionId) || other.selectionId == selectionId)&&(identical(other.selectionName, selectionName) || other.selectionName == selectionName)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.offerId, offerId) || other.offerId == offerId)&&(identical(other.odds, odds) || other.odds == odds)&&(identical(other.selectionCode, selectionCode) || other.selectionCode == selectionCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,selectionId,selectionName,logoUrl,offerId,odds,selectionCode);

@override
String toString() {
  return 'SpecialOutrightSelection(selectionId: $selectionId, selectionName: $selectionName, logoUrl: $logoUrl, offerId: $offerId, odds: $odds, selectionCode: $selectionCode)';
}

}

abstract mixin class $SpecialOutrightSelectionCopyWith<$Res>  {
  factory $SpecialOutrightSelectionCopyWith(SpecialOutrightSelection value, $Res Function(SpecialOutrightSelection) _then) = _$SpecialOutrightSelectionCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: '0') String selectionId,@JsonKey(name: '1') String selectionName,@JsonKey(name: '2') String logoUrl,@JsonKey(name: '3') String offerId,@JsonKey(name: '4', fromJson: _safeParseDouble) double odds,@JsonKey(name: '5') String selectionCode
});

}
class _$SpecialOutrightSelectionCopyWithImpl<$Res>
    implements $SpecialOutrightSelectionCopyWith<$Res> {
  _$SpecialOutrightSelectionCopyWithImpl(this._self, this._then);

  final SpecialOutrightSelection _self;
  final $Res Function(SpecialOutrightSelection) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? selectionId = null,Object? selectionName = null,Object? logoUrl = null,Object? offerId = null,Object? odds = null,Object? selectionCode = null,}) {
  return _then(_self.copyWith(
selectionId: null == selectionId ? _self.selectionId : selectionId // ignore: cast_nullable_to_non_nullable
as String,selectionName: null == selectionName ? _self.selectionName : selectionName // ignore: cast_nullable_to_non_nullable
as String,logoUrl: null == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String,offerId: null == offerId ? _self.offerId : offerId // ignore: cast_nullable_to_non_nullable
as String,odds: null == odds ? _self.odds : odds // ignore: cast_nullable_to_non_nullable
as double,selectionCode: null == selectionCode ? _self.selectionCode : selectionCode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}

extension SpecialOutrightSelectionPatterns on SpecialOutrightSelection {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SpecialOutrightSelection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SpecialOutrightSelection() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SpecialOutrightSelection value)  $default,){
final _that = this;
switch (_that) {
case _SpecialOutrightSelection():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SpecialOutrightSelection value)?  $default,){
final _that = this;
switch (_that) {
case _SpecialOutrightSelection() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: '0')  String selectionId, @JsonKey(name: '1')  String selectionName, @JsonKey(name: '2')  String logoUrl, @JsonKey(name: '3')  String offerId, @JsonKey(name: '4', fromJson: _safeParseDouble)  double odds, @JsonKey(name: '5')  String selectionCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SpecialOutrightSelection() when $default != null:
return $default(_that.selectionId,_that.selectionName,_that.logoUrl,_that.offerId,_that.odds,_that.selectionCode);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: '0')  String selectionId, @JsonKey(name: '1')  String selectionName, @JsonKey(name: '2')  String logoUrl, @JsonKey(name: '3')  String offerId, @JsonKey(name: '4', fromJson: _safeParseDouble)  double odds, @JsonKey(name: '5')  String selectionCode)  $default,) {final _that = this;
switch (_that) {
case _SpecialOutrightSelection():
return $default(_that.selectionId,_that.selectionName,_that.logoUrl,_that.offerId,_that.odds,_that.selectionCode);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: '0')  String selectionId, @JsonKey(name: '1')  String selectionName, @JsonKey(name: '2')  String logoUrl, @JsonKey(name: '3')  String offerId, @JsonKey(name: '4', fromJson: _safeParseDouble)  double odds, @JsonKey(name: '5')  String selectionCode)?  $default,) {final _that = this;
switch (_that) {
case _SpecialOutrightSelection() when $default != null:
return $default(_that.selectionId,_that.selectionName,_that.logoUrl,_that.offerId,_that.odds,_that.selectionCode);case _:
  return null;

}
}

}

@JsonSerializable()

class _SpecialOutrightSelection implements SpecialOutrightSelection {
  const _SpecialOutrightSelection({@JsonKey(name: '0') this.selectionId = '', @JsonKey(name: '1') this.selectionName = '', @JsonKey(name: '2') this.logoUrl = '', @JsonKey(name: '3') this.offerId = '', @JsonKey(name: '4', fromJson: _safeParseDouble) this.odds = 0.0, @JsonKey(name: '5') this.selectionCode = ''});
  factory _SpecialOutrightSelection.fromJson(Map<String, dynamic> json) => _$SpecialOutrightSelectionFromJson(json);

@override@JsonKey(name: '0') final  String selectionId;
@override@JsonKey(name: '1') final  String selectionName;
@override@JsonKey(name: '2') final  String logoUrl;
@override@JsonKey(name: '3') final  String offerId;
@override@JsonKey(name: '4', fromJson: _safeParseDouble) final  double odds;
@override@JsonKey(name: '5') final  String selectionCode;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpecialOutrightSelectionCopyWith<_SpecialOutrightSelection> get copyWith => __$SpecialOutrightSelectionCopyWithImpl<_SpecialOutrightSelection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SpecialOutrightSelectionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SpecialOutrightSelection&&(identical(other.selectionId, selectionId) || other.selectionId == selectionId)&&(identical(other.selectionName, selectionName) || other.selectionName == selectionName)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.offerId, offerId) || other.offerId == offerId)&&(identical(other.odds, odds) || other.odds == odds)&&(identical(other.selectionCode, selectionCode) || other.selectionCode == selectionCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,selectionId,selectionName,logoUrl,offerId,odds,selectionCode);

@override
String toString() {
  return 'SpecialOutrightSelection(selectionId: $selectionId, selectionName: $selectionName, logoUrl: $logoUrl, offerId: $offerId, odds: $odds, selectionCode: $selectionCode)';
}

}

abstract mixin class _$SpecialOutrightSelectionCopyWith<$Res> implements $SpecialOutrightSelectionCopyWith<$Res> {
  factory _$SpecialOutrightSelectionCopyWith(_SpecialOutrightSelection value, $Res Function(_SpecialOutrightSelection) _then) = __$SpecialOutrightSelectionCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: '0') String selectionId,@JsonKey(name: '1') String selectionName,@JsonKey(name: '2') String logoUrl,@JsonKey(name: '3') String offerId,@JsonKey(name: '4', fromJson: _safeParseDouble) double odds,@JsonKey(name: '5') String selectionCode
});

}
class __$SpecialOutrightSelectionCopyWithImpl<$Res>
    implements _$SpecialOutrightSelectionCopyWith<$Res> {
  __$SpecialOutrightSelectionCopyWithImpl(this._self, this._then);

  final _SpecialOutrightSelection _self;
  final $Res Function(_SpecialOutrightSelection) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? selectionId = null,Object? selectionName = null,Object? logoUrl = null,Object? offerId = null,Object? odds = null,Object? selectionCode = null,}) {
  return _then(_SpecialOutrightSelection(
selectionId: null == selectionId ? _self.selectionId : selectionId // ignore: cast_nullable_to_non_nullable
as String,selectionName: null == selectionName ? _self.selectionName : selectionName // ignore: cast_nullable_to_non_nullable
as String,logoUrl: null == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String,offerId: null == offerId ? _self.offerId : offerId // ignore: cast_nullable_to_non_nullable
as String,odds: null == odds ? _self.odds : odds // ignore: cast_nullable_to_non_nullable
as double,selectionCode: null == selectionCode ? _self.selectionCode : selectionCode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}

// dart format on
