// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ticket_model.dart';

// dart format off
T _$identity<T>(T value) => value;

mixin _$TicketModel {

@JsonKey(name: 'ticketId') String get ticketId; String get status; int get stake;@JsonKey(name: 'potentialWinnings') int? get potentialWinnings;@JsonKey(name: 'actualWinnings') int? get actualWinnings; String get odds;@JsonKey(name: 'selections') List<TicketSelectionModel> get selections;@JsonKey(name: 'createdAt') String get createdAt;@JsonKey(name: 'settledAt') String? get settledAt;@JsonKey(name: 'cashOutAmount') int? get cashOutAmount;@JsonKey(name: 'cashOutAvailable') bool get cashOutAvailable;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TicketModelCopyWith<TicketModel> get copyWith => _$TicketModelCopyWithImpl<TicketModel>(this as TicketModel, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TicketModel&&(identical(other.ticketId, ticketId) || other.ticketId == ticketId)&&(identical(other.status, status) || other.status == status)&&(identical(other.stake, stake) || other.stake == stake)&&(identical(other.potentialWinnings, potentialWinnings) || other.potentialWinnings == potentialWinnings)&&(identical(other.actualWinnings, actualWinnings) || other.actualWinnings == actualWinnings)&&(identical(other.odds, odds) || other.odds == odds)&&const DeepCollectionEquality().equals(other.selections, selections)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.settledAt, settledAt) || other.settledAt == settledAt)&&(identical(other.cashOutAmount, cashOutAmount) || other.cashOutAmount == cashOutAmount)&&(identical(other.cashOutAvailable, cashOutAvailable) || other.cashOutAvailable == cashOutAvailable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ticketId,status,stake,potentialWinnings,actualWinnings,odds,const DeepCollectionEquality().hash(selections),createdAt,settledAt,cashOutAmount,cashOutAvailable);

@override
String toString() {
  return 'TicketModel(ticketId: $ticketId, status: $status, stake: $stake, potentialWinnings: $potentialWinnings, actualWinnings: $actualWinnings, odds: $odds, selections: $selections, createdAt: $createdAt, settledAt: $settledAt, cashOutAmount: $cashOutAmount, cashOutAvailable: $cashOutAvailable)';
}

}

abstract mixin class $TicketModelCopyWith<$Res>  {
  factory $TicketModelCopyWith(TicketModel value, $Res Function(TicketModel) _then) = _$TicketModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'ticketId') String ticketId, String status, int stake,@JsonKey(name: 'potentialWinnings') int? potentialWinnings,@JsonKey(name: 'actualWinnings') int? actualWinnings, String odds,@JsonKey(name: 'selections') List<TicketSelectionModel> selections,@JsonKey(name: 'createdAt') String createdAt,@JsonKey(name: 'settledAt') String? settledAt,@JsonKey(name: 'cashOutAmount') int? cashOutAmount,@JsonKey(name: 'cashOutAvailable') bool cashOutAvailable
});

}
class _$TicketModelCopyWithImpl<$Res>
    implements $TicketModelCopyWith<$Res> {
  _$TicketModelCopyWithImpl(this._self, this._then);

  final TicketModel _self;
  final $Res Function(TicketModel) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? ticketId = null,Object? status = null,Object? stake = null,Object? potentialWinnings = freezed,Object? actualWinnings = freezed,Object? odds = null,Object? selections = null,Object? createdAt = null,Object? settledAt = freezed,Object? cashOutAmount = freezed,Object? cashOutAvailable = null,}) {
  return _then(_self.copyWith(
ticketId: null == ticketId ? _self.ticketId : ticketId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,stake: null == stake ? _self.stake : stake // ignore: cast_nullable_to_non_nullable
as int,potentialWinnings: freezed == potentialWinnings ? _self.potentialWinnings : potentialWinnings // ignore: cast_nullable_to_non_nullable
as int?,actualWinnings: freezed == actualWinnings ? _self.actualWinnings : actualWinnings // ignore: cast_nullable_to_non_nullable
as int?,odds: null == odds ? _self.odds : odds // ignore: cast_nullable_to_non_nullable
as String,selections: null == selections ? _self.selections : selections // ignore: cast_nullable_to_non_nullable
as List<TicketSelectionModel>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,settledAt: freezed == settledAt ? _self.settledAt : settledAt // ignore: cast_nullable_to_non_nullable
as String?,cashOutAmount: freezed == cashOutAmount ? _self.cashOutAmount : cashOutAmount // ignore: cast_nullable_to_non_nullable
as int?,cashOutAvailable: null == cashOutAvailable ? _self.cashOutAvailable : cashOutAvailable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}

extension TicketModelPatterns on TicketModel {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TicketModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TicketModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TicketModel value)  $default,){
final _that = this;
switch (_that) {
case _TicketModel():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TicketModel value)?  $default,){
final _that = this;
switch (_that) {
case _TicketModel() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'ticketId')  String ticketId,  String status,  int stake, @JsonKey(name: 'potentialWinnings')  int? potentialWinnings, @JsonKey(name: 'actualWinnings')  int? actualWinnings,  String odds, @JsonKey(name: 'selections')  List<TicketSelectionModel> selections, @JsonKey(name: 'createdAt')  String createdAt, @JsonKey(name: 'settledAt')  String? settledAt, @JsonKey(name: 'cashOutAmount')  int? cashOutAmount, @JsonKey(name: 'cashOutAvailable')  bool cashOutAvailable)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TicketModel() when $default != null:
return $default(_that.ticketId,_that.status,_that.stake,_that.potentialWinnings,_that.actualWinnings,_that.odds,_that.selections,_that.createdAt,_that.settledAt,_that.cashOutAmount,_that.cashOutAvailable);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'ticketId')  String ticketId,  String status,  int stake, @JsonKey(name: 'potentialWinnings')  int? potentialWinnings, @JsonKey(name: 'actualWinnings')  int? actualWinnings,  String odds, @JsonKey(name: 'selections')  List<TicketSelectionModel> selections, @JsonKey(name: 'createdAt')  String createdAt, @JsonKey(name: 'settledAt')  String? settledAt, @JsonKey(name: 'cashOutAmount')  int? cashOutAmount, @JsonKey(name: 'cashOutAvailable')  bool cashOutAvailable)  $default,) {final _that = this;
switch (_that) {
case _TicketModel():
return $default(_that.ticketId,_that.status,_that.stake,_that.potentialWinnings,_that.actualWinnings,_that.odds,_that.selections,_that.createdAt,_that.settledAt,_that.cashOutAmount,_that.cashOutAvailable);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'ticketId')  String ticketId,  String status,  int stake, @JsonKey(name: 'potentialWinnings')  int? potentialWinnings, @JsonKey(name: 'actualWinnings')  int? actualWinnings,  String odds, @JsonKey(name: 'selections')  List<TicketSelectionModel> selections, @JsonKey(name: 'createdAt')  String createdAt, @JsonKey(name: 'settledAt')  String? settledAt, @JsonKey(name: 'cashOutAmount')  int? cashOutAmount, @JsonKey(name: 'cashOutAvailable')  bool cashOutAvailable)?  $default,) {final _that = this;
switch (_that) {
case _TicketModel() when $default != null:
return $default(_that.ticketId,_that.status,_that.stake,_that.potentialWinnings,_that.actualWinnings,_that.odds,_that.selections,_that.createdAt,_that.settledAt,_that.cashOutAmount,_that.cashOutAvailable);case _:
  return null;

}
}

}

@JsonSerializable()

class _TicketModel implements TicketModel {
  const _TicketModel({@JsonKey(name: 'ticketId') required this.ticketId, required this.status, required this.stake, @JsonKey(name: 'potentialWinnings') this.potentialWinnings, @JsonKey(name: 'actualWinnings') this.actualWinnings, required this.odds, @JsonKey(name: 'selections') final  List<TicketSelectionModel> selections = const [], @JsonKey(name: 'createdAt') required this.createdAt, @JsonKey(name: 'settledAt') this.settledAt, @JsonKey(name: 'cashOutAmount') this.cashOutAmount, @JsonKey(name: 'cashOutAvailable') this.cashOutAvailable = false}): _selections = selections;
  factory _TicketModel.fromJson(Map<String, dynamic> json) => _$TicketModelFromJson(json);

@override@JsonKey(name: 'ticketId') final  String ticketId;
@override final  String status;
@override final  int stake;
@override@JsonKey(name: 'potentialWinnings') final  int? potentialWinnings;
@override@JsonKey(name: 'actualWinnings') final  int? actualWinnings;
@override final  String odds;
 final  List<TicketSelectionModel> _selections;
@override@JsonKey(name: 'selections') List<TicketSelectionModel> get selections {
  if (_selections is EqualUnmodifiableListView) return _selections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selections);
}

@override@JsonKey(name: 'createdAt') final  String createdAt;
@override@JsonKey(name: 'settledAt') final  String? settledAt;
@override@JsonKey(name: 'cashOutAmount') final  int? cashOutAmount;
@override@JsonKey(name: 'cashOutAvailable') final  bool cashOutAvailable;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TicketModelCopyWith<_TicketModel> get copyWith => __$TicketModelCopyWithImpl<_TicketModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TicketModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TicketModel&&(identical(other.ticketId, ticketId) || other.ticketId == ticketId)&&(identical(other.status, status) || other.status == status)&&(identical(other.stake, stake) || other.stake == stake)&&(identical(other.potentialWinnings, potentialWinnings) || other.potentialWinnings == potentialWinnings)&&(identical(other.actualWinnings, actualWinnings) || other.actualWinnings == actualWinnings)&&(identical(other.odds, odds) || other.odds == odds)&&const DeepCollectionEquality().equals(other._selections, _selections)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.settledAt, settledAt) || other.settledAt == settledAt)&&(identical(other.cashOutAmount, cashOutAmount) || other.cashOutAmount == cashOutAmount)&&(identical(other.cashOutAvailable, cashOutAvailable) || other.cashOutAvailable == cashOutAvailable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ticketId,status,stake,potentialWinnings,actualWinnings,odds,const DeepCollectionEquality().hash(_selections),createdAt,settledAt,cashOutAmount,cashOutAvailable);

@override
String toString() {
  return 'TicketModel(ticketId: $ticketId, status: $status, stake: $stake, potentialWinnings: $potentialWinnings, actualWinnings: $actualWinnings, odds: $odds, selections: $selections, createdAt: $createdAt, settledAt: $settledAt, cashOutAmount: $cashOutAmount, cashOutAvailable: $cashOutAvailable)';
}

}

abstract mixin class _$TicketModelCopyWith<$Res> implements $TicketModelCopyWith<$Res> {
  factory _$TicketModelCopyWith(_TicketModel value, $Res Function(_TicketModel) _then) = __$TicketModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'ticketId') String ticketId, String status, int stake,@JsonKey(name: 'potentialWinnings') int? potentialWinnings,@JsonKey(name: 'actualWinnings') int? actualWinnings, String odds,@JsonKey(name: 'selections') List<TicketSelectionModel> selections,@JsonKey(name: 'createdAt') String createdAt,@JsonKey(name: 'settledAt') String? settledAt,@JsonKey(name: 'cashOutAmount') int? cashOutAmount,@JsonKey(name: 'cashOutAvailable') bool cashOutAvailable
});

}
class __$TicketModelCopyWithImpl<$Res>
    implements _$TicketModelCopyWith<$Res> {
  __$TicketModelCopyWithImpl(this._self, this._then);

  final _TicketModel _self;
  final $Res Function(_TicketModel) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? ticketId = null,Object? status = null,Object? stake = null,Object? potentialWinnings = freezed,Object? actualWinnings = freezed,Object? odds = null,Object? selections = null,Object? createdAt = null,Object? settledAt = freezed,Object? cashOutAmount = freezed,Object? cashOutAvailable = null,}) {
  return _then(_TicketModel(
ticketId: null == ticketId ? _self.ticketId : ticketId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,stake: null == stake ? _self.stake : stake // ignore: cast_nullable_to_non_nullable
as int,potentialWinnings: freezed == potentialWinnings ? _self.potentialWinnings : potentialWinnings // ignore: cast_nullable_to_non_nullable
as int?,actualWinnings: freezed == actualWinnings ? _self.actualWinnings : actualWinnings // ignore: cast_nullable_to_non_nullable
as int?,odds: null == odds ? _self.odds : odds // ignore: cast_nullable_to_non_nullable
as String,selections: null == selections ? _self._selections : selections // ignore: cast_nullable_to_non_nullable
as List<TicketSelectionModel>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,settledAt: freezed == settledAt ? _self.settledAt : settledAt // ignore: cast_nullable_to_non_nullable
as String?,cashOutAmount: freezed == cashOutAmount ? _self.cashOutAmount : cashOutAmount // ignore: cast_nullable_to_non_nullable
as int?,cashOutAvailable: null == cashOutAvailable ? _self.cashOutAvailable : cashOutAvailable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}

mixin _$TicketSelectionModel {

@JsonKey(name: 'eventId') int? get eventId;@JsonKey(name: 'eventName') String get eventName;@JsonKey(name: 'selectionId') String? get selectionId;@JsonKey(name: 'selectionName') String get selectionName; String get odds; String get status;@JsonKey(name: 'result') MatchResultModel? get result;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TicketSelectionModelCopyWith<TicketSelectionModel> get copyWith => _$TicketSelectionModelCopyWithImpl<TicketSelectionModel>(this as TicketSelectionModel, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TicketSelectionModel&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.eventName, eventName) || other.eventName == eventName)&&(identical(other.selectionId, selectionId) || other.selectionId == selectionId)&&(identical(other.selectionName, selectionName) || other.selectionName == selectionName)&&(identical(other.odds, odds) || other.odds == odds)&&(identical(other.status, status) || other.status == status)&&(identical(other.result, result) || other.result == result));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,eventId,eventName,selectionId,selectionName,odds,status,result);

@override
String toString() {
  return 'TicketSelectionModel(eventId: $eventId, eventName: $eventName, selectionId: $selectionId, selectionName: $selectionName, odds: $odds, status: $status, result: $result)';
}

}

abstract mixin class $TicketSelectionModelCopyWith<$Res>  {
  factory $TicketSelectionModelCopyWith(TicketSelectionModel value, $Res Function(TicketSelectionModel) _then) = _$TicketSelectionModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'eventId') int? eventId,@JsonKey(name: 'eventName') String eventName,@JsonKey(name: 'selectionId') String? selectionId,@JsonKey(name: 'selectionName') String selectionName, String odds, String status,@JsonKey(name: 'result') MatchResultModel? result
});

$MatchResultModelCopyWith<$Res>? get result;

}
class _$TicketSelectionModelCopyWithImpl<$Res>
    implements $TicketSelectionModelCopyWith<$Res> {
  _$TicketSelectionModelCopyWithImpl(this._self, this._then);

  final TicketSelectionModel _self;
  final $Res Function(TicketSelectionModel) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? eventId = freezed,Object? eventName = null,Object? selectionId = freezed,Object? selectionName = null,Object? odds = null,Object? status = null,Object? result = freezed,}) {
  return _then(_self.copyWith(
eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as int?,eventName: null == eventName ? _self.eventName : eventName // ignore: cast_nullable_to_non_nullable
as String,selectionId: freezed == selectionId ? _self.selectionId : selectionId // ignore: cast_nullable_to_non_nullable
as String?,selectionName: null == selectionName ? _self.selectionName : selectionName // ignore: cast_nullable_to_non_nullable
as String,odds: null == odds ? _self.odds : odds // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as MatchResultModel?,
  ));
}
@override
@pragma('vm:prefer-inline')
$MatchResultModelCopyWith<$Res>? get result {
    if (_self.result == null) {
    return null;
  }

  return $MatchResultModelCopyWith<$Res>(_self.result!, (value) {
    return _then(_self.copyWith(result: value));
  });
}
}

extension TicketSelectionModelPatterns on TicketSelectionModel {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TicketSelectionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TicketSelectionModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TicketSelectionModel value)  $default,){
final _that = this;
switch (_that) {
case _TicketSelectionModel():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TicketSelectionModel value)?  $default,){
final _that = this;
switch (_that) {
case _TicketSelectionModel() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'eventId')  int? eventId, @JsonKey(name: 'eventName')  String eventName, @JsonKey(name: 'selectionId')  String? selectionId, @JsonKey(name: 'selectionName')  String selectionName,  String odds,  String status, @JsonKey(name: 'result')  MatchResultModel? result)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TicketSelectionModel() when $default != null:
return $default(_that.eventId,_that.eventName,_that.selectionId,_that.selectionName,_that.odds,_that.status,_that.result);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'eventId')  int? eventId, @JsonKey(name: 'eventName')  String eventName, @JsonKey(name: 'selectionId')  String? selectionId, @JsonKey(name: 'selectionName')  String selectionName,  String odds,  String status, @JsonKey(name: 'result')  MatchResultModel? result)  $default,) {final _that = this;
switch (_that) {
case _TicketSelectionModel():
return $default(_that.eventId,_that.eventName,_that.selectionId,_that.selectionName,_that.odds,_that.status,_that.result);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'eventId')  int? eventId, @JsonKey(name: 'eventName')  String eventName, @JsonKey(name: 'selectionId')  String? selectionId, @JsonKey(name: 'selectionName')  String selectionName,  String odds,  String status, @JsonKey(name: 'result')  MatchResultModel? result)?  $default,) {final _that = this;
switch (_that) {
case _TicketSelectionModel() when $default != null:
return $default(_that.eventId,_that.eventName,_that.selectionId,_that.selectionName,_that.odds,_that.status,_that.result);case _:
  return null;

}
}

}

@JsonSerializable()

class _TicketSelectionModel implements TicketSelectionModel {
  const _TicketSelectionModel({@JsonKey(name: 'eventId') this.eventId, @JsonKey(name: 'eventName') required this.eventName, @JsonKey(name: 'selectionId') this.selectionId, @JsonKey(name: 'selectionName') required this.selectionName, required this.odds, required this.status, @JsonKey(name: 'result') this.result});
  factory _TicketSelectionModel.fromJson(Map<String, dynamic> json) => _$TicketSelectionModelFromJson(json);

@override@JsonKey(name: 'eventId') final  int? eventId;
@override@JsonKey(name: 'eventName') final  String eventName;
@override@JsonKey(name: 'selectionId') final  String? selectionId;
@override@JsonKey(name: 'selectionName') final  String selectionName;
@override final  String odds;
@override final  String status;
@override@JsonKey(name: 'result') final  MatchResultModel? result;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TicketSelectionModelCopyWith<_TicketSelectionModel> get copyWith => __$TicketSelectionModelCopyWithImpl<_TicketSelectionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TicketSelectionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TicketSelectionModel&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.eventName, eventName) || other.eventName == eventName)&&(identical(other.selectionId, selectionId) || other.selectionId == selectionId)&&(identical(other.selectionName, selectionName) || other.selectionName == selectionName)&&(identical(other.odds, odds) || other.odds == odds)&&(identical(other.status, status) || other.status == status)&&(identical(other.result, result) || other.result == result));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,eventId,eventName,selectionId,selectionName,odds,status,result);

@override
String toString() {
  return 'TicketSelectionModel(eventId: $eventId, eventName: $eventName, selectionId: $selectionId, selectionName: $selectionName, odds: $odds, status: $status, result: $result)';
}

}

abstract mixin class _$TicketSelectionModelCopyWith<$Res> implements $TicketSelectionModelCopyWith<$Res> {
  factory _$TicketSelectionModelCopyWith(_TicketSelectionModel value, $Res Function(_TicketSelectionModel) _then) = __$TicketSelectionModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'eventId') int? eventId,@JsonKey(name: 'eventName') String eventName,@JsonKey(name: 'selectionId') String? selectionId,@JsonKey(name: 'selectionName') String selectionName, String odds, String status,@JsonKey(name: 'result') MatchResultModel? result
});

@override $MatchResultModelCopyWith<$Res>? get result;

}
class __$TicketSelectionModelCopyWithImpl<$Res>
    implements _$TicketSelectionModelCopyWith<$Res> {
  __$TicketSelectionModelCopyWithImpl(this._self, this._then);

  final _TicketSelectionModel _self;
  final $Res Function(_TicketSelectionModel) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? eventId = freezed,Object? eventName = null,Object? selectionId = freezed,Object? selectionName = null,Object? odds = null,Object? status = null,Object? result = freezed,}) {
  return _then(_TicketSelectionModel(
eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as int?,eventName: null == eventName ? _self.eventName : eventName // ignore: cast_nullable_to_non_nullable
as String,selectionId: freezed == selectionId ? _self.selectionId : selectionId // ignore: cast_nullable_to_non_nullable
as String?,selectionName: null == selectionName ? _self.selectionName : selectionName // ignore: cast_nullable_to_non_nullable
as String,odds: null == odds ? _self.odds : odds // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as MatchResultModel?,
  ));
}

@override
@pragma('vm:prefer-inline')
$MatchResultModelCopyWith<$Res>? get result {
    if (_self.result == null) {
    return null;
  }

  return $MatchResultModelCopyWith<$Res>(_self.result!, (value) {
    return _then(_self.copyWith(result: value));
  });
}
}

mixin _$MatchResultModel {

@JsonKey(name: 'homeScore') int get homeScore;@JsonKey(name: 'awayScore') int get awayScore;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MatchResultModelCopyWith<MatchResultModel> get copyWith => _$MatchResultModelCopyWithImpl<MatchResultModel>(this as MatchResultModel, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MatchResultModel&&(identical(other.homeScore, homeScore) || other.homeScore == homeScore)&&(identical(other.awayScore, awayScore) || other.awayScore == awayScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,homeScore,awayScore);

@override
String toString() {
  return 'MatchResultModel(homeScore: $homeScore, awayScore: $awayScore)';
}

}

abstract mixin class $MatchResultModelCopyWith<$Res>  {
  factory $MatchResultModelCopyWith(MatchResultModel value, $Res Function(MatchResultModel) _then) = _$MatchResultModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'homeScore') int homeScore,@JsonKey(name: 'awayScore') int awayScore
});

}
class _$MatchResultModelCopyWithImpl<$Res>
    implements $MatchResultModelCopyWith<$Res> {
  _$MatchResultModelCopyWithImpl(this._self, this._then);

  final MatchResultModel _self;
  final $Res Function(MatchResultModel) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? homeScore = null,Object? awayScore = null,}) {
  return _then(_self.copyWith(
homeScore: null == homeScore ? _self.homeScore : homeScore // ignore: cast_nullable_to_non_nullable
as int,awayScore: null == awayScore ? _self.awayScore : awayScore // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}

extension MatchResultModelPatterns on MatchResultModel {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MatchResultModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MatchResultModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MatchResultModel value)  $default,){
final _that = this;
switch (_that) {
case _MatchResultModel():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MatchResultModel value)?  $default,){
final _that = this;
switch (_that) {
case _MatchResultModel() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'homeScore')  int homeScore, @JsonKey(name: 'awayScore')  int awayScore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MatchResultModel() when $default != null:
return $default(_that.homeScore,_that.awayScore);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'homeScore')  int homeScore, @JsonKey(name: 'awayScore')  int awayScore)  $default,) {final _that = this;
switch (_that) {
case _MatchResultModel():
return $default(_that.homeScore,_that.awayScore);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'homeScore')  int homeScore, @JsonKey(name: 'awayScore')  int awayScore)?  $default,) {final _that = this;
switch (_that) {
case _MatchResultModel() when $default != null:
return $default(_that.homeScore,_that.awayScore);case _:
  return null;

}
}

}

@JsonSerializable()

class _MatchResultModel implements MatchResultModel {
  const _MatchResultModel({@JsonKey(name: 'homeScore') required this.homeScore, @JsonKey(name: 'awayScore') required this.awayScore});
  factory _MatchResultModel.fromJson(Map<String, dynamic> json) => _$MatchResultModelFromJson(json);

@override@JsonKey(name: 'homeScore') final  int homeScore;
@override@JsonKey(name: 'awayScore') final  int awayScore;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MatchResultModelCopyWith<_MatchResultModel> get copyWith => __$MatchResultModelCopyWithImpl<_MatchResultModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MatchResultModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MatchResultModel&&(identical(other.homeScore, homeScore) || other.homeScore == homeScore)&&(identical(other.awayScore, awayScore) || other.awayScore == awayScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,homeScore,awayScore);

@override
String toString() {
  return 'MatchResultModel(homeScore: $homeScore, awayScore: $awayScore)';
}

}

abstract mixin class _$MatchResultModelCopyWith<$Res> implements $MatchResultModelCopyWith<$Res> {
  factory _$MatchResultModelCopyWith(_MatchResultModel value, $Res Function(_MatchResultModel) _then) = __$MatchResultModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'homeScore') int homeScore,@JsonKey(name: 'awayScore') int awayScore
});

}
class __$MatchResultModelCopyWithImpl<$Res>
    implements _$MatchResultModelCopyWith<$Res> {
  __$MatchResultModelCopyWithImpl(this._self, this._then);

  final _MatchResultModel _self;
  final $Res Function(_MatchResultModel) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? homeScore = null,Object? awayScore = null,}) {
  return _then(_MatchResultModel(
homeScore: null == homeScore ? _self.homeScore : homeScore // ignore: cast_nullable_to_non_nullable
as int,awayScore: null == awayScore ? _self.awayScore : awayScore // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}

mixin _$BetHistoryResponse {

 List<TicketModel> get bets; int get total;@JsonKey(name: 'totalStake') int get totalStake;@JsonKey(name: 'totalWinnings') int get totalWinnings;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BetHistoryResponseCopyWith<BetHistoryResponse> get copyWith => _$BetHistoryResponseCopyWithImpl<BetHistoryResponse>(this as BetHistoryResponse, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BetHistoryResponse&&const DeepCollectionEquality().equals(other.bets, bets)&&(identical(other.total, total) || other.total == total)&&(identical(other.totalStake, totalStake) || other.totalStake == totalStake)&&(identical(other.totalWinnings, totalWinnings) || other.totalWinnings == totalWinnings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(bets),total,totalStake,totalWinnings);

@override
String toString() {
  return 'BetHistoryResponse(bets: $bets, total: $total, totalStake: $totalStake, totalWinnings: $totalWinnings)';
}

}

abstract mixin class $BetHistoryResponseCopyWith<$Res>  {
  factory $BetHistoryResponseCopyWith(BetHistoryResponse value, $Res Function(BetHistoryResponse) _then) = _$BetHistoryResponseCopyWithImpl;
@useResult
$Res call({
 List<TicketModel> bets, int total,@JsonKey(name: 'totalStake') int totalStake,@JsonKey(name: 'totalWinnings') int totalWinnings
});

}
class _$BetHistoryResponseCopyWithImpl<$Res>
    implements $BetHistoryResponseCopyWith<$Res> {
  _$BetHistoryResponseCopyWithImpl(this._self, this._then);

  final BetHistoryResponse _self;
  final $Res Function(BetHistoryResponse) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? bets = null,Object? total = null,Object? totalStake = null,Object? totalWinnings = null,}) {
  return _then(_self.copyWith(
bets: null == bets ? _self.bets : bets // ignore: cast_nullable_to_non_nullable
as List<TicketModel>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,totalStake: null == totalStake ? _self.totalStake : totalStake // ignore: cast_nullable_to_non_nullable
as int,totalWinnings: null == totalWinnings ? _self.totalWinnings : totalWinnings // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}

extension BetHistoryResponsePatterns on BetHistoryResponse {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BetHistoryResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BetHistoryResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BetHistoryResponse value)  $default,){
final _that = this;
switch (_that) {
case _BetHistoryResponse():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BetHistoryResponse value)?  $default,){
final _that = this;
switch (_that) {
case _BetHistoryResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TicketModel> bets,  int total, @JsonKey(name: 'totalStake')  int totalStake, @JsonKey(name: 'totalWinnings')  int totalWinnings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BetHistoryResponse() when $default != null:
return $default(_that.bets,_that.total,_that.totalStake,_that.totalWinnings);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TicketModel> bets,  int total, @JsonKey(name: 'totalStake')  int totalStake, @JsonKey(name: 'totalWinnings')  int totalWinnings)  $default,) {final _that = this;
switch (_that) {
case _BetHistoryResponse():
return $default(_that.bets,_that.total,_that.totalStake,_that.totalWinnings);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TicketModel> bets,  int total, @JsonKey(name: 'totalStake')  int totalStake, @JsonKey(name: 'totalWinnings')  int totalWinnings)?  $default,) {final _that = this;
switch (_that) {
case _BetHistoryResponse() when $default != null:
return $default(_that.bets,_that.total,_that.totalStake,_that.totalWinnings);case _:
  return null;

}
}

}

@JsonSerializable()

class _BetHistoryResponse implements BetHistoryResponse {
  const _BetHistoryResponse({final  List<TicketModel> bets = const [], this.total = 0, @JsonKey(name: 'totalStake') this.totalStake = 0, @JsonKey(name: 'totalWinnings') this.totalWinnings = 0}): _bets = bets;
  factory _BetHistoryResponse.fromJson(Map<String, dynamic> json) => _$BetHistoryResponseFromJson(json);

 final  List<TicketModel> _bets;
@override@JsonKey() List<TicketModel> get bets {
  if (_bets is EqualUnmodifiableListView) return _bets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bets);
}

@override@JsonKey() final  int total;
@override@JsonKey(name: 'totalStake') final  int totalStake;
@override@JsonKey(name: 'totalWinnings') final  int totalWinnings;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BetHistoryResponseCopyWith<_BetHistoryResponse> get copyWith => __$BetHistoryResponseCopyWithImpl<_BetHistoryResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BetHistoryResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BetHistoryResponse&&const DeepCollectionEquality().equals(other._bets, _bets)&&(identical(other.total, total) || other.total == total)&&(identical(other.totalStake, totalStake) || other.totalStake == totalStake)&&(identical(other.totalWinnings, totalWinnings) || other.totalWinnings == totalWinnings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_bets),total,totalStake,totalWinnings);

@override
String toString() {
  return 'BetHistoryResponse(bets: $bets, total: $total, totalStake: $totalStake, totalWinnings: $totalWinnings)';
}

}

abstract mixin class _$BetHistoryResponseCopyWith<$Res> implements $BetHistoryResponseCopyWith<$Res> {
  factory _$BetHistoryResponseCopyWith(_BetHistoryResponse value, $Res Function(_BetHistoryResponse) _then) = __$BetHistoryResponseCopyWithImpl;
@override @useResult
$Res call({
 List<TicketModel> bets, int total,@JsonKey(name: 'totalStake') int totalStake,@JsonKey(name: 'totalWinnings') int totalWinnings
});

}
class __$BetHistoryResponseCopyWithImpl<$Res>
    implements _$BetHistoryResponseCopyWith<$Res> {
  __$BetHistoryResponseCopyWithImpl(this._self, this._then);

  final _BetHistoryResponse _self;
  final $Res Function(_BetHistoryResponse) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? bets = null,Object? total = null,Object? totalStake = null,Object? totalWinnings = null,}) {
  return _then(_BetHistoryResponse(
bets: null == bets ? _self._bets : bets // ignore: cast_nullable_to_non_nullable
as List<TicketModel>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,totalStake: null == totalStake ? _self.totalStake : totalStake // ignore: cast_nullable_to_non_nullable
as int,totalWinnings: null == totalWinnings ? _self.totalWinnings : totalWinnings // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}

mixin _$CashOutRequest {

@JsonKey(name: 'ticketId') String get ticketId;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CashOutRequestCopyWith<CashOutRequest> get copyWith => _$CashOutRequestCopyWithImpl<CashOutRequest>(this as CashOutRequest, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CashOutRequest&&(identical(other.ticketId, ticketId) || other.ticketId == ticketId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ticketId);

@override
String toString() {
  return 'CashOutRequest(ticketId: $ticketId)';
}

}

abstract mixin class $CashOutRequestCopyWith<$Res>  {
  factory $CashOutRequestCopyWith(CashOutRequest value, $Res Function(CashOutRequest) _then) = _$CashOutRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'ticketId') String ticketId
});

}
class _$CashOutRequestCopyWithImpl<$Res>
    implements $CashOutRequestCopyWith<$Res> {
  _$CashOutRequestCopyWithImpl(this._self, this._then);

  final CashOutRequest _self;
  final $Res Function(CashOutRequest) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? ticketId = null,}) {
  return _then(_self.copyWith(
ticketId: null == ticketId ? _self.ticketId : ticketId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}

extension CashOutRequestPatterns on CashOutRequest {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CashOutRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CashOutRequest() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CashOutRequest value)  $default,){
final _that = this;
switch (_that) {
case _CashOutRequest():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CashOutRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CashOutRequest() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'ticketId')  String ticketId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CashOutRequest() when $default != null:
return $default(_that.ticketId);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'ticketId')  String ticketId)  $default,) {final _that = this;
switch (_that) {
case _CashOutRequest():
return $default(_that.ticketId);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'ticketId')  String ticketId)?  $default,) {final _that = this;
switch (_that) {
case _CashOutRequest() when $default != null:
return $default(_that.ticketId);case _:
  return null;

}
}

}

@JsonSerializable()

class _CashOutRequest implements CashOutRequest {
  const _CashOutRequest({@JsonKey(name: 'ticketId') required this.ticketId});
  factory _CashOutRequest.fromJson(Map<String, dynamic> json) => _$CashOutRequestFromJson(json);

@override@JsonKey(name: 'ticketId') final  String ticketId;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CashOutRequestCopyWith<_CashOutRequest> get copyWith => __$CashOutRequestCopyWithImpl<_CashOutRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CashOutRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CashOutRequest&&(identical(other.ticketId, ticketId) || other.ticketId == ticketId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ticketId);

@override
String toString() {
  return 'CashOutRequest(ticketId: $ticketId)';
}

}

abstract mixin class _$CashOutRequestCopyWith<$Res> implements $CashOutRequestCopyWith<$Res> {
  factory _$CashOutRequestCopyWith(_CashOutRequest value, $Res Function(_CashOutRequest) _then) = __$CashOutRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'ticketId') String ticketId
});

}
class __$CashOutRequestCopyWithImpl<$Res>
    implements _$CashOutRequestCopyWith<$Res> {
  __$CashOutRequestCopyWithImpl(this._self, this._then);

  final _CashOutRequest _self;
  final $Res Function(_CashOutRequest) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? ticketId = null,}) {
  return _then(_CashOutRequest(
ticketId: null == ticketId ? _self.ticketId : ticketId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}

mixin _$CashOutOptionsResponse {

@JsonKey(name: 'ticketId') String get ticketId; bool get available;@JsonKey(name: 'cashOutAmount') int? get cashOutAmount;@JsonKey(name: 'originalStake') int? get originalStake;@JsonKey(name: 'potentialWinnings') int? get potentialWinnings; int? get profit;@JsonKey(name: 'profitPercentage') double? get profitPercentage; String? get reason;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CashOutOptionsResponseCopyWith<CashOutOptionsResponse> get copyWith => _$CashOutOptionsResponseCopyWithImpl<CashOutOptionsResponse>(this as CashOutOptionsResponse, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CashOutOptionsResponse&&(identical(other.ticketId, ticketId) || other.ticketId == ticketId)&&(identical(other.available, available) || other.available == available)&&(identical(other.cashOutAmount, cashOutAmount) || other.cashOutAmount == cashOutAmount)&&(identical(other.originalStake, originalStake) || other.originalStake == originalStake)&&(identical(other.potentialWinnings, potentialWinnings) || other.potentialWinnings == potentialWinnings)&&(identical(other.profit, profit) || other.profit == profit)&&(identical(other.profitPercentage, profitPercentage) || other.profitPercentage == profitPercentage)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ticketId,available,cashOutAmount,originalStake,potentialWinnings,profit,profitPercentage,reason);

@override
String toString() {
  return 'CashOutOptionsResponse(ticketId: $ticketId, available: $available, cashOutAmount: $cashOutAmount, originalStake: $originalStake, potentialWinnings: $potentialWinnings, profit: $profit, profitPercentage: $profitPercentage, reason: $reason)';
}

}

abstract mixin class $CashOutOptionsResponseCopyWith<$Res>  {
  factory $CashOutOptionsResponseCopyWith(CashOutOptionsResponse value, $Res Function(CashOutOptionsResponse) _then) = _$CashOutOptionsResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'ticketId') String ticketId, bool available,@JsonKey(name: 'cashOutAmount') int? cashOutAmount,@JsonKey(name: 'originalStake') int? originalStake,@JsonKey(name: 'potentialWinnings') int? potentialWinnings, int? profit,@JsonKey(name: 'profitPercentage') double? profitPercentage, String? reason
});

}
class _$CashOutOptionsResponseCopyWithImpl<$Res>
    implements $CashOutOptionsResponseCopyWith<$Res> {
  _$CashOutOptionsResponseCopyWithImpl(this._self, this._then);

  final CashOutOptionsResponse _self;
  final $Res Function(CashOutOptionsResponse) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? ticketId = null,Object? available = null,Object? cashOutAmount = freezed,Object? originalStake = freezed,Object? potentialWinnings = freezed,Object? profit = freezed,Object? profitPercentage = freezed,Object? reason = freezed,}) {
  return _then(_self.copyWith(
ticketId: null == ticketId ? _self.ticketId : ticketId // ignore: cast_nullable_to_non_nullable
as String,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,cashOutAmount: freezed == cashOutAmount ? _self.cashOutAmount : cashOutAmount // ignore: cast_nullable_to_non_nullable
as int?,originalStake: freezed == originalStake ? _self.originalStake : originalStake // ignore: cast_nullable_to_non_nullable
as int?,potentialWinnings: freezed == potentialWinnings ? _self.potentialWinnings : potentialWinnings // ignore: cast_nullable_to_non_nullable
as int?,profit: freezed == profit ? _self.profit : profit // ignore: cast_nullable_to_non_nullable
as int?,profitPercentage: freezed == profitPercentage ? _self.profitPercentage : profitPercentage // ignore: cast_nullable_to_non_nullable
as double?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}

extension CashOutOptionsResponsePatterns on CashOutOptionsResponse {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CashOutOptionsResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CashOutOptionsResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CashOutOptionsResponse value)  $default,){
final _that = this;
switch (_that) {
case _CashOutOptionsResponse():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CashOutOptionsResponse value)?  $default,){
final _that = this;
switch (_that) {
case _CashOutOptionsResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'ticketId')  String ticketId,  bool available, @JsonKey(name: 'cashOutAmount')  int? cashOutAmount, @JsonKey(name: 'originalStake')  int? originalStake, @JsonKey(name: 'potentialWinnings')  int? potentialWinnings,  int? profit, @JsonKey(name: 'profitPercentage')  double? profitPercentage,  String? reason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CashOutOptionsResponse() when $default != null:
return $default(_that.ticketId,_that.available,_that.cashOutAmount,_that.originalStake,_that.potentialWinnings,_that.profit,_that.profitPercentage,_that.reason);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'ticketId')  String ticketId,  bool available, @JsonKey(name: 'cashOutAmount')  int? cashOutAmount, @JsonKey(name: 'originalStake')  int? originalStake, @JsonKey(name: 'potentialWinnings')  int? potentialWinnings,  int? profit, @JsonKey(name: 'profitPercentage')  double? profitPercentage,  String? reason)  $default,) {final _that = this;
switch (_that) {
case _CashOutOptionsResponse():
return $default(_that.ticketId,_that.available,_that.cashOutAmount,_that.originalStake,_that.potentialWinnings,_that.profit,_that.profitPercentage,_that.reason);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'ticketId')  String ticketId,  bool available, @JsonKey(name: 'cashOutAmount')  int? cashOutAmount, @JsonKey(name: 'originalStake')  int? originalStake, @JsonKey(name: 'potentialWinnings')  int? potentialWinnings,  int? profit, @JsonKey(name: 'profitPercentage')  double? profitPercentage,  String? reason)?  $default,) {final _that = this;
switch (_that) {
case _CashOutOptionsResponse() when $default != null:
return $default(_that.ticketId,_that.available,_that.cashOutAmount,_that.originalStake,_that.potentialWinnings,_that.profit,_that.profitPercentage,_that.reason);case _:
  return null;

}
}

}

@JsonSerializable()

class _CashOutOptionsResponse implements CashOutOptionsResponse {
  const _CashOutOptionsResponse({@JsonKey(name: 'ticketId') required this.ticketId, this.available = false, @JsonKey(name: 'cashOutAmount') this.cashOutAmount, @JsonKey(name: 'originalStake') this.originalStake, @JsonKey(name: 'potentialWinnings') this.potentialWinnings, this.profit, @JsonKey(name: 'profitPercentage') this.profitPercentage, this.reason});
  factory _CashOutOptionsResponse.fromJson(Map<String, dynamic> json) => _$CashOutOptionsResponseFromJson(json);

@override@JsonKey(name: 'ticketId') final  String ticketId;
@override@JsonKey() final  bool available;
@override@JsonKey(name: 'cashOutAmount') final  int? cashOutAmount;
@override@JsonKey(name: 'originalStake') final  int? originalStake;
@override@JsonKey(name: 'potentialWinnings') final  int? potentialWinnings;
@override final  int? profit;
@override@JsonKey(name: 'profitPercentage') final  double? profitPercentage;
@override final  String? reason;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CashOutOptionsResponseCopyWith<_CashOutOptionsResponse> get copyWith => __$CashOutOptionsResponseCopyWithImpl<_CashOutOptionsResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CashOutOptionsResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CashOutOptionsResponse&&(identical(other.ticketId, ticketId) || other.ticketId == ticketId)&&(identical(other.available, available) || other.available == available)&&(identical(other.cashOutAmount, cashOutAmount) || other.cashOutAmount == cashOutAmount)&&(identical(other.originalStake, originalStake) || other.originalStake == originalStake)&&(identical(other.potentialWinnings, potentialWinnings) || other.potentialWinnings == potentialWinnings)&&(identical(other.profit, profit) || other.profit == profit)&&(identical(other.profitPercentage, profitPercentage) || other.profitPercentage == profitPercentage)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ticketId,available,cashOutAmount,originalStake,potentialWinnings,profit,profitPercentage,reason);

@override
String toString() {
  return 'CashOutOptionsResponse(ticketId: $ticketId, available: $available, cashOutAmount: $cashOutAmount, originalStake: $originalStake, potentialWinnings: $potentialWinnings, profit: $profit, profitPercentage: $profitPercentage, reason: $reason)';
}

}

abstract mixin class _$CashOutOptionsResponseCopyWith<$Res> implements $CashOutOptionsResponseCopyWith<$Res> {
  factory _$CashOutOptionsResponseCopyWith(_CashOutOptionsResponse value, $Res Function(_CashOutOptionsResponse) _then) = __$CashOutOptionsResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'ticketId') String ticketId, bool available,@JsonKey(name: 'cashOutAmount') int? cashOutAmount,@JsonKey(name: 'originalStake') int? originalStake,@JsonKey(name: 'potentialWinnings') int? potentialWinnings, int? profit,@JsonKey(name: 'profitPercentage') double? profitPercentage, String? reason
});

}
class __$CashOutOptionsResponseCopyWithImpl<$Res>
    implements _$CashOutOptionsResponseCopyWith<$Res> {
  __$CashOutOptionsResponseCopyWithImpl(this._self, this._then);

  final _CashOutOptionsResponse _self;
  final $Res Function(_CashOutOptionsResponse) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? ticketId = null,Object? available = null,Object? cashOutAmount = freezed,Object? originalStake = freezed,Object? potentialWinnings = freezed,Object? profit = freezed,Object? profitPercentage = freezed,Object? reason = freezed,}) {
  return _then(_CashOutOptionsResponse(
ticketId: null == ticketId ? _self.ticketId : ticketId // ignore: cast_nullable_to_non_nullable
as String,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,cashOutAmount: freezed == cashOutAmount ? _self.cashOutAmount : cashOutAmount // ignore: cast_nullable_to_non_nullable
as int?,originalStake: freezed == originalStake ? _self.originalStake : originalStake // ignore: cast_nullable_to_non_nullable
as int?,potentialWinnings: freezed == potentialWinnings ? _self.potentialWinnings : potentialWinnings // ignore: cast_nullable_to_non_nullable
as int?,profit: freezed == profit ? _self.profit : profit // ignore: cast_nullable_to_non_nullable
as int?,profitPercentage: freezed == profitPercentage ? _self.profitPercentage : profitPercentage // ignore: cast_nullable_to_non_nullable
as double?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}

mixin _$CashOutResponse {

@JsonKey(name: 'ticketId') String get ticketId; String get status;@JsonKey(name: 'cashOutAmount') int? get cashOutAmount; int? get profit; String? get message;@JsonKey(name: 'errorCode') int get errorCode;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CashOutResponseCopyWith<CashOutResponse> get copyWith => _$CashOutResponseCopyWithImpl<CashOutResponse>(this as CashOutResponse, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CashOutResponse&&(identical(other.ticketId, ticketId) || other.ticketId == ticketId)&&(identical(other.status, status) || other.status == status)&&(identical(other.cashOutAmount, cashOutAmount) || other.cashOutAmount == cashOutAmount)&&(identical(other.profit, profit) || other.profit == profit)&&(identical(other.message, message) || other.message == message)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ticketId,status,cashOutAmount,profit,message,errorCode);

@override
String toString() {
  return 'CashOutResponse(ticketId: $ticketId, status: $status, cashOutAmount: $cashOutAmount, profit: $profit, message: $message, errorCode: $errorCode)';
}

}

abstract mixin class $CashOutResponseCopyWith<$Res>  {
  factory $CashOutResponseCopyWith(CashOutResponse value, $Res Function(CashOutResponse) _then) = _$CashOutResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'ticketId') String ticketId, String status,@JsonKey(name: 'cashOutAmount') int? cashOutAmount, int? profit, String? message,@JsonKey(name: 'errorCode') int errorCode
});

}
class _$CashOutResponseCopyWithImpl<$Res>
    implements $CashOutResponseCopyWith<$Res> {
  _$CashOutResponseCopyWithImpl(this._self, this._then);

  final CashOutResponse _self;
  final $Res Function(CashOutResponse) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? ticketId = null,Object? status = null,Object? cashOutAmount = freezed,Object? profit = freezed,Object? message = freezed,Object? errorCode = null,}) {
  return _then(_self.copyWith(
ticketId: null == ticketId ? _self.ticketId : ticketId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,cashOutAmount: freezed == cashOutAmount ? _self.cashOutAmount : cashOutAmount // ignore: cast_nullable_to_non_nullable
as int?,profit: freezed == profit ? _self.profit : profit // ignore: cast_nullable_to_non_nullable
as int?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,errorCode: null == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}

extension CashOutResponsePatterns on CashOutResponse {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CashOutResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CashOutResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CashOutResponse value)  $default,){
final _that = this;
switch (_that) {
case _CashOutResponse():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CashOutResponse value)?  $default,){
final _that = this;
switch (_that) {
case _CashOutResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'ticketId')  String ticketId,  String status, @JsonKey(name: 'cashOutAmount')  int? cashOutAmount,  int? profit,  String? message, @JsonKey(name: 'errorCode')  int errorCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CashOutResponse() when $default != null:
return $default(_that.ticketId,_that.status,_that.cashOutAmount,_that.profit,_that.message,_that.errorCode);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'ticketId')  String ticketId,  String status, @JsonKey(name: 'cashOutAmount')  int? cashOutAmount,  int? profit,  String? message, @JsonKey(name: 'errorCode')  int errorCode)  $default,) {final _that = this;
switch (_that) {
case _CashOutResponse():
return $default(_that.ticketId,_that.status,_that.cashOutAmount,_that.profit,_that.message,_that.errorCode);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'ticketId')  String ticketId,  String status, @JsonKey(name: 'cashOutAmount')  int? cashOutAmount,  int? profit,  String? message, @JsonKey(name: 'errorCode')  int errorCode)?  $default,) {final _that = this;
switch (_that) {
case _CashOutResponse() when $default != null:
return $default(_that.ticketId,_that.status,_that.cashOutAmount,_that.profit,_that.message,_that.errorCode);case _:
  return null;

}
}

}

@JsonSerializable()

class _CashOutResponse implements CashOutResponse {
  const _CashOutResponse({@JsonKey(name: 'ticketId') required this.ticketId, required this.status, @JsonKey(name: 'cashOutAmount') this.cashOutAmount, this.profit, this.message, @JsonKey(name: 'errorCode') this.errorCode = 0});
  factory _CashOutResponse.fromJson(Map<String, dynamic> json) => _$CashOutResponseFromJson(json);

@override@JsonKey(name: 'ticketId') final  String ticketId;
@override final  String status;
@override@JsonKey(name: 'cashOutAmount') final  int? cashOutAmount;
@override final  int? profit;
@override final  String? message;
@override@JsonKey(name: 'errorCode') final  int errorCode;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CashOutResponseCopyWith<_CashOutResponse> get copyWith => __$CashOutResponseCopyWithImpl<_CashOutResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CashOutResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CashOutResponse&&(identical(other.ticketId, ticketId) || other.ticketId == ticketId)&&(identical(other.status, status) || other.status == status)&&(identical(other.cashOutAmount, cashOutAmount) || other.cashOutAmount == cashOutAmount)&&(identical(other.profit, profit) || other.profit == profit)&&(identical(other.message, message) || other.message == message)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ticketId,status,cashOutAmount,profit,message,errorCode);

@override
String toString() {
  return 'CashOutResponse(ticketId: $ticketId, status: $status, cashOutAmount: $cashOutAmount, profit: $profit, message: $message, errorCode: $errorCode)';
}

}

abstract mixin class _$CashOutResponseCopyWith<$Res> implements $CashOutResponseCopyWith<$Res> {
  factory _$CashOutResponseCopyWith(_CashOutResponse value, $Res Function(_CashOutResponse) _then) = __$CashOutResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'ticketId') String ticketId, String status,@JsonKey(name: 'cashOutAmount') int? cashOutAmount, int? profit, String? message,@JsonKey(name: 'errorCode') int errorCode
});

}
class __$CashOutResponseCopyWithImpl<$Res>
    implements _$CashOutResponseCopyWith<$Res> {
  __$CashOutResponseCopyWithImpl(this._self, this._then);

  final _CashOutResponse _self;
  final $Res Function(_CashOutResponse) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? ticketId = null,Object? status = null,Object? cashOutAmount = freezed,Object? profit = freezed,Object? message = freezed,Object? errorCode = null,}) {
  return _then(_CashOutResponse(
ticketId: null == ticketId ? _self.ticketId : ticketId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,cashOutAmount: freezed == cashOutAmount ? _self.cashOutAmount : cashOutAmount // ignore: cast_nullable_to_non_nullable
as int?,profit: freezed == profit ? _self.profit : profit // ignore: cast_nullable_to_non_nullable
as int?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,errorCode: null == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}

// dart format on
