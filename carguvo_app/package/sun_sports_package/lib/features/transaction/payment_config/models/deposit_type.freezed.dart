// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deposit_type.dart';

// dart format off
T _$identity<T>(T value) => value;

mixin _$DepositType {

@JsonKey(name: 'id') int get id;@JsonKey(name: 'description') String get description;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DepositTypeCopyWith<DepositType> get copyWith => _$DepositTypeCopyWithImpl<DepositType>(this as DepositType, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DepositType&&(identical(other.id, id) || other.id == id)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,description);

@override
String toString() {
  return 'DepositType(id: $id, description: $description)';
}

}

abstract mixin class $DepositTypeCopyWith<$Res>  {
  factory $DepositTypeCopyWith(DepositType value, $Res Function(DepositType) _then) = _$DepositTypeCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id') int id,@JsonKey(name: 'description') String description
});

}
class _$DepositTypeCopyWithImpl<$Res>
    implements $DepositTypeCopyWith<$Res> {
  _$DepositTypeCopyWithImpl(this._self, this._then);

  final DepositType _self;
  final $Res Function(DepositType) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? description = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}

extension DepositTypePatterns on DepositType {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DepositType value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DepositType() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DepositType value)  $default,){
final _that = this;
switch (_that) {
case _DepositType():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DepositType value)?  $default,){
final _that = this;
switch (_that) {
case _DepositType() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  int id, @JsonKey(name: 'description')  String description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DepositType() when $default != null:
return $default(_that.id,_that.description);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  int id, @JsonKey(name: 'description')  String description)  $default,) {final _that = this;
switch (_that) {
case _DepositType():
return $default(_that.id,_that.description);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id')  int id, @JsonKey(name: 'description')  String description)?  $default,) {final _that = this;
switch (_that) {
case _DepositType() when $default != null:
return $default(_that.id,_that.description);case _:
  return null;

}
}

}

@JsonSerializable()

class _DepositType implements DepositType {
  const _DepositType({@JsonKey(name: 'id') required this.id, @JsonKey(name: 'description') required this.description});
  factory _DepositType.fromJson(Map<String, dynamic> json) => _$DepositTypeFromJson(json);

@override@JsonKey(name: 'id') final  int id;
@override@JsonKey(name: 'description') final  String description;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DepositTypeCopyWith<_DepositType> get copyWith => __$DepositTypeCopyWithImpl<_DepositType>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DepositTypeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DepositType&&(identical(other.id, id) || other.id == id)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,description);

@override
String toString() {
  return 'DepositType(id: $id, description: $description)';
}

}

abstract mixin class _$DepositTypeCopyWith<$Res> implements $DepositTypeCopyWith<$Res> {
  factory _$DepositTypeCopyWith(_DepositType value, $Res Function(_DepositType) _then) = __$DepositTypeCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id') int id,@JsonKey(name: 'description') String description
});

}
class __$DepositTypeCopyWithImpl<$Res>
    implements _$DepositTypeCopyWith<$Res> {
  __$DepositTypeCopyWithImpl(this._self, this._then);

  final _DepositType _self;
  final $Res Function(_DepositType) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? description = null,}) {
  return _then(_DepositType(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}

// dart format on
