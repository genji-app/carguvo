// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'suggested_trans_code.dart';

// dart format off
T _$identity<T>(T value) => value;

mixin _$SuggestedTransCode {

 String get text; int get type;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SuggestedTransCodeCopyWith<SuggestedTransCode> get copyWith => _$SuggestedTransCodeCopyWithImpl<SuggestedTransCode>(this as SuggestedTransCode, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SuggestedTransCode&&(identical(other.text, text) || other.text == text)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,type);

@override
String toString() {
  return 'SuggestedTransCode(text: $text, type: $type)';
}

}

abstract mixin class $SuggestedTransCodeCopyWith<$Res>  {
  factory $SuggestedTransCodeCopyWith(SuggestedTransCode value, $Res Function(SuggestedTransCode) _then) = _$SuggestedTransCodeCopyWithImpl;
@useResult
$Res call({
 String text, int type
});

}
class _$SuggestedTransCodeCopyWithImpl<$Res>
    implements $SuggestedTransCodeCopyWith<$Res> {
  _$SuggestedTransCodeCopyWithImpl(this._self, this._then);

  final SuggestedTransCode _self;
  final $Res Function(SuggestedTransCode) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? type = null,}) {
  return _then(_self.copyWith(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}

extension SuggestedTransCodePatterns on SuggestedTransCode {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SuggestedTransCode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SuggestedTransCode() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SuggestedTransCode value)  $default,){
final _that = this;
switch (_that) {
case _SuggestedTransCode():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SuggestedTransCode value)?  $default,){
final _that = this;
switch (_that) {
case _SuggestedTransCode() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text,  int type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SuggestedTransCode() when $default != null:
return $default(_that.text,_that.type);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text,  int type)  $default,) {final _that = this;
switch (_that) {
case _SuggestedTransCode():
return $default(_that.text,_that.type);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text,  int type)?  $default,) {final _that = this;
switch (_that) {
case _SuggestedTransCode() when $default != null:
return $default(_that.text,_that.type);case _:
  return null;

}
}

}

@JsonSerializable()

class _SuggestedTransCode implements SuggestedTransCode {
  const _SuggestedTransCode({required this.text, required this.type});
  factory _SuggestedTransCode.fromJson(Map<String, dynamic> json) => _$SuggestedTransCodeFromJson(json);

@override final  String text;
@override final  int type;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SuggestedTransCodeCopyWith<_SuggestedTransCode> get copyWith => __$SuggestedTransCodeCopyWithImpl<_SuggestedTransCode>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SuggestedTransCodeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SuggestedTransCode&&(identical(other.text, text) || other.text == text)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,type);

@override
String toString() {
  return 'SuggestedTransCode(text: $text, type: $type)';
}

}

abstract mixin class _$SuggestedTransCodeCopyWith<$Res> implements $SuggestedTransCodeCopyWith<$Res> {
  factory _$SuggestedTransCodeCopyWith(_SuggestedTransCode value, $Res Function(_SuggestedTransCode) _then) = __$SuggestedTransCodeCopyWithImpl;
@override @useResult
$Res call({
 String text, int type
});

}
class __$SuggestedTransCodeCopyWithImpl<$Res>
    implements _$SuggestedTransCodeCopyWith<$Res> {
  __$SuggestedTransCodeCopyWithImpl(this._self, this._then);

  final _SuggestedTransCode _self;
  final $Res Function(_SuggestedTransCode) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? type = null,}) {
  return _then(_SuggestedTransCode(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}

// dart format on
