// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bank_model.dart';

// dart format off
T _$identity<T>(T value) => value;

mixin _$BankModel {

 String get id; String get name;@JsonKey(name: 'icon_url') String? get iconUrl;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BankModelCopyWith<BankModel> get copyWith => _$BankModelCopyWithImpl<BankModel>(this as BankModel, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BankModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,iconUrl);

@override
String toString() {
  return 'BankModel(id: $id, name: $name, iconUrl: $iconUrl)';
}

}

abstract mixin class $BankModelCopyWith<$Res>  {
  factory $BankModelCopyWith(BankModel value, $Res Function(BankModel) _then) = _$BankModelCopyWithImpl;
@useResult
$Res call({
 String id, String name,@JsonKey(name: 'icon_url') String? iconUrl
});

}
class _$BankModelCopyWithImpl<$Res>
    implements $BankModelCopyWith<$Res> {
  _$BankModelCopyWithImpl(this._self, this._then);

  final BankModel _self;
  final $Res Function(BankModel) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? iconUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}

extension BankModelPatterns on BankModel {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BankModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BankModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BankModel value)  $default,){
final _that = this;
switch (_that) {
case _BankModel():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BankModel value)?  $default,){
final _that = this;
switch (_that) {
case _BankModel() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'icon_url')  String? iconUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BankModel() when $default != null:
return $default(_that.id,_that.name,_that.iconUrl);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'icon_url')  String? iconUrl)  $default,) {final _that = this;
switch (_that) {
case _BankModel():
return $default(_that.id,_that.name,_that.iconUrl);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name, @JsonKey(name: 'icon_url')  String? iconUrl)?  $default,) {final _that = this;
switch (_that) {
case _BankModel() when $default != null:
return $default(_that.id,_that.name,_that.iconUrl);case _:
  return null;

}
}

}

@JsonSerializable()

class _BankModel implements BankModel {
  const _BankModel({required this.id, required this.name, @JsonKey(name: 'icon_url') this.iconUrl});
  factory _BankModel.fromJson(Map<String, dynamic> json) => _$BankModelFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey(name: 'icon_url') final  String? iconUrl;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BankModelCopyWith<_BankModel> get copyWith => __$BankModelCopyWithImpl<_BankModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BankModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BankModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,iconUrl);

@override
String toString() {
  return 'BankModel(id: $id, name: $name, iconUrl: $iconUrl)';
}

}

abstract mixin class _$BankModelCopyWith<$Res> implements $BankModelCopyWith<$Res> {
  factory _$BankModelCopyWith(_BankModel value, $Res Function(_BankModel) _then) = __$BankModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@JsonKey(name: 'icon_url') String? iconUrl
});

}
class __$BankModelCopyWithImpl<$Res>
    implements _$BankModelCopyWith<$Res> {
  __$BankModelCopyWithImpl(this._self, this._then);

  final _BankModel _self;
  final $Res Function(_BankModel) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? iconUrl = freezed,}) {
  return _then(_BankModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}

// dart format on
