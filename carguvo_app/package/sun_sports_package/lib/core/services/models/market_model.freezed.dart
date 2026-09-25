// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'market_model.dart';

// dart format off
T _$identity<T>(T value) => value;

mixin _$MarketModel {

 String get id; String get name;@JsonKey(name: 'cls') String get cls; List<SelectionModel> get odds; bool get isActive; String? get description;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarketModelCopyWith<MarketModel> get copyWith => _$MarketModelCopyWithImpl<MarketModel>(this as MarketModel, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarketModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.cls, cls) || other.cls == cls)&&const DeepCollectionEquality().equals(other.odds, odds)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,cls,const DeepCollectionEquality().hash(odds),isActive,description);

@override
String toString() {
  return 'MarketModel(id: $id, name: $name, cls: $cls, odds: $odds, isActive: $isActive, description: $description)';
}

}

abstract mixin class $MarketModelCopyWith<$Res>  {
  factory $MarketModelCopyWith(MarketModel value, $Res Function(MarketModel) _then) = _$MarketModelCopyWithImpl;
@useResult
$Res call({
 String id, String name,@JsonKey(name: 'cls') String cls, List<SelectionModel> odds, bool isActive, String? description
});

}
class _$MarketModelCopyWithImpl<$Res>
    implements $MarketModelCopyWith<$Res> {
  _$MarketModelCopyWithImpl(this._self, this._then);

  final MarketModel _self;
  final $Res Function(MarketModel) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? cls = null,Object? odds = null,Object? isActive = null,Object? description = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,cls: null == cls ? _self.cls : cls // ignore: cast_nullable_to_non_nullable
as String,odds: null == odds ? _self.odds : odds // ignore: cast_nullable_to_non_nullable
as List<SelectionModel>,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}

extension MarketModelPatterns on MarketModel {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MarketModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MarketModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MarketModel value)  $default,){
final _that = this;
switch (_that) {
case _MarketModel():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MarketModel value)?  $default,){
final _that = this;
switch (_that) {
case _MarketModel() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'cls')  String cls,  List<SelectionModel> odds,  bool isActive,  String? description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MarketModel() when $default != null:
return $default(_that.id,_that.name,_that.cls,_that.odds,_that.isActive,_that.description);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'cls')  String cls,  List<SelectionModel> odds,  bool isActive,  String? description)  $default,) {final _that = this;
switch (_that) {
case _MarketModel():
return $default(_that.id,_that.name,_that.cls,_that.odds,_that.isActive,_that.description);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name, @JsonKey(name: 'cls')  String cls,  List<SelectionModel> odds,  bool isActive,  String? description)?  $default,) {final _that = this;
switch (_that) {
case _MarketModel() when $default != null:
return $default(_that.id,_that.name,_that.cls,_that.odds,_that.isActive,_that.description);case _:
  return null;

}
}

}

@JsonSerializable()

class _MarketModel implements MarketModel {
  const _MarketModel({required this.id, required this.name, @JsonKey(name: 'cls') required this.cls, final  List<SelectionModel> odds = const [], this.isActive = true, this.description}): _odds = odds;
  factory _MarketModel.fromJson(Map<String, dynamic> json) => _$MarketModelFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey(name: 'cls') final  String cls;
 final  List<SelectionModel> _odds;
@override@JsonKey() List<SelectionModel> get odds {
  if (_odds is EqualUnmodifiableListView) return _odds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_odds);
}

@override@JsonKey() final  bool isActive;
@override final  String? description;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MarketModelCopyWith<_MarketModel> get copyWith => __$MarketModelCopyWithImpl<_MarketModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MarketModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MarketModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.cls, cls) || other.cls == cls)&&const DeepCollectionEquality().equals(other._odds, _odds)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,cls,const DeepCollectionEquality().hash(_odds),isActive,description);

@override
String toString() {
  return 'MarketModel(id: $id, name: $name, cls: $cls, odds: $odds, isActive: $isActive, description: $description)';
}

}

abstract mixin class _$MarketModelCopyWith<$Res> implements $MarketModelCopyWith<$Res> {
  factory _$MarketModelCopyWith(_MarketModel value, $Res Function(_MarketModel) _then) = __$MarketModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@JsonKey(name: 'cls') String cls, List<SelectionModel> odds, bool isActive, String? description
});

}
class __$MarketModelCopyWithImpl<$Res>
    implements _$MarketModelCopyWith<$Res> {
  __$MarketModelCopyWithImpl(this._self, this._then);

  final _MarketModel _self;
  final $Res Function(_MarketModel) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? cls = null,Object? odds = null,Object? isActive = null,Object? description = freezed,}) {
  return _then(_MarketModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,cls: null == cls ? _self.cls : cls // ignore: cast_nullable_to_non_nullable
as String,odds: null == odds ? _self._odds : odds // ignore: cast_nullable_to_non_nullable
as List<SelectionModel>,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}

mixin _$SelectionModel {

@JsonKey(name: 'selectionId') String get selectionId; String get name;@JsonKey(name: 'displayOdds') String get displayOdds;@JsonKey(name: 'offerId') String get offerId;@JsonKey(name: 'trueOdds') double? get trueOdds; bool get isActive;@JsonKey(name: 'handicap') double? get handicap;@JsonKey(name: 'line') double? get line;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SelectionModelCopyWith<SelectionModel> get copyWith => _$SelectionModelCopyWithImpl<SelectionModel>(this as SelectionModel, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SelectionModel&&(identical(other.selectionId, selectionId) || other.selectionId == selectionId)&&(identical(other.name, name) || other.name == name)&&(identical(other.displayOdds, displayOdds) || other.displayOdds == displayOdds)&&(identical(other.offerId, offerId) || other.offerId == offerId)&&(identical(other.trueOdds, trueOdds) || other.trueOdds == trueOdds)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.handicap, handicap) || other.handicap == handicap)&&(identical(other.line, line) || other.line == line));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,selectionId,name,displayOdds,offerId,trueOdds,isActive,handicap,line);

@override
String toString() {
  return 'SelectionModel(selectionId: $selectionId, name: $name, displayOdds: $displayOdds, offerId: $offerId, trueOdds: $trueOdds, isActive: $isActive, handicap: $handicap, line: $line)';
}

}

abstract mixin class $SelectionModelCopyWith<$Res>  {
  factory $SelectionModelCopyWith(SelectionModel value, $Res Function(SelectionModel) _then) = _$SelectionModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'selectionId') String selectionId, String name,@JsonKey(name: 'displayOdds') String displayOdds,@JsonKey(name: 'offerId') String offerId,@JsonKey(name: 'trueOdds') double? trueOdds, bool isActive,@JsonKey(name: 'handicap') double? handicap,@JsonKey(name: 'line') double? line
});

}
class _$SelectionModelCopyWithImpl<$Res>
    implements $SelectionModelCopyWith<$Res> {
  _$SelectionModelCopyWithImpl(this._self, this._then);

  final SelectionModel _self;
  final $Res Function(SelectionModel) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? selectionId = null,Object? name = null,Object? displayOdds = null,Object? offerId = null,Object? trueOdds = freezed,Object? isActive = null,Object? handicap = freezed,Object? line = freezed,}) {
  return _then(_self.copyWith(
selectionId: null == selectionId ? _self.selectionId : selectionId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,displayOdds: null == displayOdds ? _self.displayOdds : displayOdds // ignore: cast_nullable_to_non_nullable
as String,offerId: null == offerId ? _self.offerId : offerId // ignore: cast_nullable_to_non_nullable
as String,trueOdds: freezed == trueOdds ? _self.trueOdds : trueOdds // ignore: cast_nullable_to_non_nullable
as double?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,handicap: freezed == handicap ? _self.handicap : handicap // ignore: cast_nullable_to_non_nullable
as double?,line: freezed == line ? _self.line : line // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}

extension SelectionModelPatterns on SelectionModel {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SelectionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SelectionModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SelectionModel value)  $default,){
final _that = this;
switch (_that) {
case _SelectionModel():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SelectionModel value)?  $default,){
final _that = this;
switch (_that) {
case _SelectionModel() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'selectionId')  String selectionId,  String name, @JsonKey(name: 'displayOdds')  String displayOdds, @JsonKey(name: 'offerId')  String offerId, @JsonKey(name: 'trueOdds')  double? trueOdds,  bool isActive, @JsonKey(name: 'handicap')  double? handicap, @JsonKey(name: 'line')  double? line)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SelectionModel() when $default != null:
return $default(_that.selectionId,_that.name,_that.displayOdds,_that.offerId,_that.trueOdds,_that.isActive,_that.handicap,_that.line);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'selectionId')  String selectionId,  String name, @JsonKey(name: 'displayOdds')  String displayOdds, @JsonKey(name: 'offerId')  String offerId, @JsonKey(name: 'trueOdds')  double? trueOdds,  bool isActive, @JsonKey(name: 'handicap')  double? handicap, @JsonKey(name: 'line')  double? line)  $default,) {final _that = this;
switch (_that) {
case _SelectionModel():
return $default(_that.selectionId,_that.name,_that.displayOdds,_that.offerId,_that.trueOdds,_that.isActive,_that.handicap,_that.line);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'selectionId')  String selectionId,  String name, @JsonKey(name: 'displayOdds')  String displayOdds, @JsonKey(name: 'offerId')  String offerId, @JsonKey(name: 'trueOdds')  double? trueOdds,  bool isActive, @JsonKey(name: 'handicap')  double? handicap, @JsonKey(name: 'line')  double? line)?  $default,) {final _that = this;
switch (_that) {
case _SelectionModel() when $default != null:
return $default(_that.selectionId,_that.name,_that.displayOdds,_that.offerId,_that.trueOdds,_that.isActive,_that.handicap,_that.line);case _:
  return null;

}
}

}

@JsonSerializable()

class _SelectionModel implements SelectionModel {
  const _SelectionModel({@JsonKey(name: 'selectionId') required this.selectionId, required this.name, @JsonKey(name: 'displayOdds') required this.displayOdds, @JsonKey(name: 'offerId') required this.offerId, @JsonKey(name: 'trueOdds') this.trueOdds, this.isActive = true, @JsonKey(name: 'handicap') this.handicap, @JsonKey(name: 'line') this.line});
  factory _SelectionModel.fromJson(Map<String, dynamic> json) => _$SelectionModelFromJson(json);

@override@JsonKey(name: 'selectionId') final  String selectionId;
@override final  String name;
@override@JsonKey(name: 'displayOdds') final  String displayOdds;
@override@JsonKey(name: 'offerId') final  String offerId;
@override@JsonKey(name: 'trueOdds') final  double? trueOdds;
@override@JsonKey() final  bool isActive;
@override@JsonKey(name: 'handicap') final  double? handicap;
@override@JsonKey(name: 'line') final  double? line;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SelectionModelCopyWith<_SelectionModel> get copyWith => __$SelectionModelCopyWithImpl<_SelectionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SelectionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SelectionModel&&(identical(other.selectionId, selectionId) || other.selectionId == selectionId)&&(identical(other.name, name) || other.name == name)&&(identical(other.displayOdds, displayOdds) || other.displayOdds == displayOdds)&&(identical(other.offerId, offerId) || other.offerId == offerId)&&(identical(other.trueOdds, trueOdds) || other.trueOdds == trueOdds)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.handicap, handicap) || other.handicap == handicap)&&(identical(other.line, line) || other.line == line));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,selectionId,name,displayOdds,offerId,trueOdds,isActive,handicap,line);

@override
String toString() {
  return 'SelectionModel(selectionId: $selectionId, name: $name, displayOdds: $displayOdds, offerId: $offerId, trueOdds: $trueOdds, isActive: $isActive, handicap: $handicap, line: $line)';
}

}

abstract mixin class _$SelectionModelCopyWith<$Res> implements $SelectionModelCopyWith<$Res> {
  factory _$SelectionModelCopyWith(_SelectionModel value, $Res Function(_SelectionModel) _then) = __$SelectionModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'selectionId') String selectionId, String name,@JsonKey(name: 'displayOdds') String displayOdds,@JsonKey(name: 'offerId') String offerId,@JsonKey(name: 'trueOdds') double? trueOdds, bool isActive,@JsonKey(name: 'handicap') double? handicap,@JsonKey(name: 'line') double? line
});

}
class __$SelectionModelCopyWithImpl<$Res>
    implements _$SelectionModelCopyWith<$Res> {
  __$SelectionModelCopyWithImpl(this._self, this._then);

  final _SelectionModel _self;
  final $Res Function(_SelectionModel) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? selectionId = null,Object? name = null,Object? displayOdds = null,Object? offerId = null,Object? trueOdds = freezed,Object? isActive = null,Object? handicap = freezed,Object? line = freezed,}) {
  return _then(_SelectionModel(
selectionId: null == selectionId ? _self.selectionId : selectionId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,displayOdds: null == displayOdds ? _self.displayOdds : displayOdds // ignore: cast_nullable_to_non_nullable
as String,offerId: null == offerId ? _self.offerId : offerId // ignore: cast_nullable_to_non_nullable
as String,trueOdds: freezed == trueOdds ? _self.trueOdds : trueOdds // ignore: cast_nullable_to_non_nullable
as double?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,handicap: freezed == handicap ? _self.handicap : handicap // ignore: cast_nullable_to_non_nullable
as double?,line: freezed == line ? _self.line : line // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}

// dart format on
