// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mini_game_remote_config.dart';

// dart format off
T _$identity<T>(T value) => value;

mixin _$MiniGameRemoteConfig {

@JsonKey(name: 'DOMAIN') String get domain;@JsonKey(name: 'useWSJSON', fromJson: _boolFromString) bool get useWsJson;@JsonKey(name: 'WS_MINIGAME_SOCKET_JSON_URL') String get wsJsonUrl;@JsonKey(name: 'WS_MINIGAME_SOCKET_BINARY_URL') String get wsBinaryUrl;@JsonKey(name: 'RESOURCE_MINI_GAME_URL_APP_PORTRAIT') String get resourceAppUrl;@JsonKey(name: 'RESOURCE_MINI_GAME_URL_WEB_PORTRAIT') String get resourceWebUrl;@JsonKey(name: 'HELP_URL') String get helpUrl;@JsonKey(name: 'BRAND') String get brand;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MiniGameRemoteConfigCopyWith<MiniGameRemoteConfig> get copyWith => _$MiniGameRemoteConfigCopyWithImpl<MiniGameRemoteConfig>(this as MiniGameRemoteConfig, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MiniGameRemoteConfig&&(identical(other.domain, domain) || other.domain == domain)&&(identical(other.useWsJson, useWsJson) || other.useWsJson == useWsJson)&&(identical(other.wsJsonUrl, wsJsonUrl) || other.wsJsonUrl == wsJsonUrl)&&(identical(other.wsBinaryUrl, wsBinaryUrl) || other.wsBinaryUrl == wsBinaryUrl)&&(identical(other.resourceAppUrl, resourceAppUrl) || other.resourceAppUrl == resourceAppUrl)&&(identical(other.resourceWebUrl, resourceWebUrl) || other.resourceWebUrl == resourceWebUrl)&&(identical(other.helpUrl, helpUrl) || other.helpUrl == helpUrl)&&(identical(other.brand, brand) || other.brand == brand));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,domain,useWsJson,wsJsonUrl,wsBinaryUrl,resourceAppUrl,resourceWebUrl,helpUrl,brand);

@override
String toString() {
  return 'MiniGameRemoteConfig(domain: $domain, useWsJson: $useWsJson, wsJsonUrl: $wsJsonUrl, wsBinaryUrl: $wsBinaryUrl, resourceAppUrl: $resourceAppUrl, resourceWebUrl: $resourceWebUrl, helpUrl: $helpUrl, brand: $brand)';
}

}

abstract mixin class $MiniGameRemoteConfigCopyWith<$Res>  {
  factory $MiniGameRemoteConfigCopyWith(MiniGameRemoteConfig value, $Res Function(MiniGameRemoteConfig) _then) = _$MiniGameRemoteConfigCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'DOMAIN') String domain,@JsonKey(name: 'useWSJSON', fromJson: _boolFromString) bool useWsJson,@JsonKey(name: 'WS_MINIGAME_SOCKET_JSON_URL') String wsJsonUrl,@JsonKey(name: 'WS_MINIGAME_SOCKET_BINARY_URL') String wsBinaryUrl,@JsonKey(name: 'RESOURCE_MINI_GAME_URL_APP_PORTRAIT') String resourceAppUrl,@JsonKey(name: 'RESOURCE_MINI_GAME_URL_WEB_PORTRAIT') String resourceWebUrl,@JsonKey(name: 'HELP_URL') String helpUrl,@JsonKey(name: 'BRAND') String brand
});

}
class _$MiniGameRemoteConfigCopyWithImpl<$Res>
    implements $MiniGameRemoteConfigCopyWith<$Res> {
  _$MiniGameRemoteConfigCopyWithImpl(this._self, this._then);

  final MiniGameRemoteConfig _self;
  final $Res Function(MiniGameRemoteConfig) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? domain = null,Object? useWsJson = null,Object? wsJsonUrl = null,Object? wsBinaryUrl = null,Object? resourceAppUrl = null,Object? resourceWebUrl = null,Object? helpUrl = null,Object? brand = null,}) {
  return _then(_self.copyWith(
domain: null == domain ? _self.domain : domain // ignore: cast_nullable_to_non_nullable
as String,useWsJson: null == useWsJson ? _self.useWsJson : useWsJson // ignore: cast_nullable_to_non_nullable
as bool,wsJsonUrl: null == wsJsonUrl ? _self.wsJsonUrl : wsJsonUrl // ignore: cast_nullable_to_non_nullable
as String,wsBinaryUrl: null == wsBinaryUrl ? _self.wsBinaryUrl : wsBinaryUrl // ignore: cast_nullable_to_non_nullable
as String,resourceAppUrl: null == resourceAppUrl ? _self.resourceAppUrl : resourceAppUrl // ignore: cast_nullable_to_non_nullable
as String,resourceWebUrl: null == resourceWebUrl ? _self.resourceWebUrl : resourceWebUrl // ignore: cast_nullable_to_non_nullable
as String,helpUrl: null == helpUrl ? _self.helpUrl : helpUrl // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}

extension MiniGameRemoteConfigPatterns on MiniGameRemoteConfig {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MiniGameRemoteConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MiniGameRemoteConfig() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MiniGameRemoteConfig value)  $default,){
final _that = this;
switch (_that) {
case _MiniGameRemoteConfig():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MiniGameRemoteConfig value)?  $default,){
final _that = this;
switch (_that) {
case _MiniGameRemoteConfig() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'DOMAIN')  String domain, @JsonKey(name: 'useWSJSON', fromJson: _boolFromString)  bool useWsJson, @JsonKey(name: 'WS_MINIGAME_SOCKET_JSON_URL')  String wsJsonUrl, @JsonKey(name: 'WS_MINIGAME_SOCKET_BINARY_URL')  String wsBinaryUrl, @JsonKey(name: 'RESOURCE_MINI_GAME_URL_APP_PORTRAIT')  String resourceAppUrl, @JsonKey(name: 'RESOURCE_MINI_GAME_URL_WEB_PORTRAIT')  String resourceWebUrl, @JsonKey(name: 'HELP_URL')  String helpUrl, @JsonKey(name: 'BRAND')  String brand)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MiniGameRemoteConfig() when $default != null:
return $default(_that.domain,_that.useWsJson,_that.wsJsonUrl,_that.wsBinaryUrl,_that.resourceAppUrl,_that.resourceWebUrl,_that.helpUrl,_that.brand);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'DOMAIN')  String domain, @JsonKey(name: 'useWSJSON', fromJson: _boolFromString)  bool useWsJson, @JsonKey(name: 'WS_MINIGAME_SOCKET_JSON_URL')  String wsJsonUrl, @JsonKey(name: 'WS_MINIGAME_SOCKET_BINARY_URL')  String wsBinaryUrl, @JsonKey(name: 'RESOURCE_MINI_GAME_URL_APP_PORTRAIT')  String resourceAppUrl, @JsonKey(name: 'RESOURCE_MINI_GAME_URL_WEB_PORTRAIT')  String resourceWebUrl, @JsonKey(name: 'HELP_URL')  String helpUrl, @JsonKey(name: 'BRAND')  String brand)  $default,) {final _that = this;
switch (_that) {
case _MiniGameRemoteConfig():
return $default(_that.domain,_that.useWsJson,_that.wsJsonUrl,_that.wsBinaryUrl,_that.resourceAppUrl,_that.resourceWebUrl,_that.helpUrl,_that.brand);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'DOMAIN')  String domain, @JsonKey(name: 'useWSJSON', fromJson: _boolFromString)  bool useWsJson, @JsonKey(name: 'WS_MINIGAME_SOCKET_JSON_URL')  String wsJsonUrl, @JsonKey(name: 'WS_MINIGAME_SOCKET_BINARY_URL')  String wsBinaryUrl, @JsonKey(name: 'RESOURCE_MINI_GAME_URL_APP_PORTRAIT')  String resourceAppUrl, @JsonKey(name: 'RESOURCE_MINI_GAME_URL_WEB_PORTRAIT')  String resourceWebUrl, @JsonKey(name: 'HELP_URL')  String helpUrl, @JsonKey(name: 'BRAND')  String brand)?  $default,) {final _that = this;
switch (_that) {
case _MiniGameRemoteConfig() when $default != null:
return $default(_that.domain,_that.useWsJson,_that.wsJsonUrl,_that.wsBinaryUrl,_that.resourceAppUrl,_that.resourceWebUrl,_that.helpUrl,_that.brand);case _:
  return null;

}
}

}

@JsonSerializable()

class _MiniGameRemoteConfig implements MiniGameRemoteConfig {
  const _MiniGameRemoteConfig({@JsonKey(name: 'DOMAIN') required this.domain, @JsonKey(name: 'useWSJSON', fromJson: _boolFromString) required this.useWsJson, @JsonKey(name: 'WS_MINIGAME_SOCKET_JSON_URL') required this.wsJsonUrl, @JsonKey(name: 'WS_MINIGAME_SOCKET_BINARY_URL') required this.wsBinaryUrl, @JsonKey(name: 'RESOURCE_MINI_GAME_URL_APP_PORTRAIT') required this.resourceAppUrl, @JsonKey(name: 'RESOURCE_MINI_GAME_URL_WEB_PORTRAIT') required this.resourceWebUrl, @JsonKey(name: 'HELP_URL') required this.helpUrl, @JsonKey(name: 'BRAND') required this.brand});
  factory _MiniGameRemoteConfig.fromJson(Map<String, dynamic> json) => _$MiniGameRemoteConfigFromJson(json);

@override@JsonKey(name: 'DOMAIN') final  String domain;
@override@JsonKey(name: 'useWSJSON', fromJson: _boolFromString) final  bool useWsJson;
@override@JsonKey(name: 'WS_MINIGAME_SOCKET_JSON_URL') final  String wsJsonUrl;
@override@JsonKey(name: 'WS_MINIGAME_SOCKET_BINARY_URL') final  String wsBinaryUrl;
@override@JsonKey(name: 'RESOURCE_MINI_GAME_URL_APP_PORTRAIT') final  String resourceAppUrl;
@override@JsonKey(name: 'RESOURCE_MINI_GAME_URL_WEB_PORTRAIT') final  String resourceWebUrl;
@override@JsonKey(name: 'HELP_URL') final  String helpUrl;
@override@JsonKey(name: 'BRAND') final  String brand;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MiniGameRemoteConfigCopyWith<_MiniGameRemoteConfig> get copyWith => __$MiniGameRemoteConfigCopyWithImpl<_MiniGameRemoteConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MiniGameRemoteConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MiniGameRemoteConfig&&(identical(other.domain, domain) || other.domain == domain)&&(identical(other.useWsJson, useWsJson) || other.useWsJson == useWsJson)&&(identical(other.wsJsonUrl, wsJsonUrl) || other.wsJsonUrl == wsJsonUrl)&&(identical(other.wsBinaryUrl, wsBinaryUrl) || other.wsBinaryUrl == wsBinaryUrl)&&(identical(other.resourceAppUrl, resourceAppUrl) || other.resourceAppUrl == resourceAppUrl)&&(identical(other.resourceWebUrl, resourceWebUrl) || other.resourceWebUrl == resourceWebUrl)&&(identical(other.helpUrl, helpUrl) || other.helpUrl == helpUrl)&&(identical(other.brand, brand) || other.brand == brand));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,domain,useWsJson,wsJsonUrl,wsBinaryUrl,resourceAppUrl,resourceWebUrl,helpUrl,brand);

@override
String toString() {
  return 'MiniGameRemoteConfig(domain: $domain, useWsJson: $useWsJson, wsJsonUrl: $wsJsonUrl, wsBinaryUrl: $wsBinaryUrl, resourceAppUrl: $resourceAppUrl, resourceWebUrl: $resourceWebUrl, helpUrl: $helpUrl, brand: $brand)';
}

}

abstract mixin class _$MiniGameRemoteConfigCopyWith<$Res> implements $MiniGameRemoteConfigCopyWith<$Res> {
  factory _$MiniGameRemoteConfigCopyWith(_MiniGameRemoteConfig value, $Res Function(_MiniGameRemoteConfig) _then) = __$MiniGameRemoteConfigCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'DOMAIN') String domain,@JsonKey(name: 'useWSJSON', fromJson: _boolFromString) bool useWsJson,@JsonKey(name: 'WS_MINIGAME_SOCKET_JSON_URL') String wsJsonUrl,@JsonKey(name: 'WS_MINIGAME_SOCKET_BINARY_URL') String wsBinaryUrl,@JsonKey(name: 'RESOURCE_MINI_GAME_URL_APP_PORTRAIT') String resourceAppUrl,@JsonKey(name: 'RESOURCE_MINI_GAME_URL_WEB_PORTRAIT') String resourceWebUrl,@JsonKey(name: 'HELP_URL') String helpUrl,@JsonKey(name: 'BRAND') String brand
});

}
class __$MiniGameRemoteConfigCopyWithImpl<$Res>
    implements _$MiniGameRemoteConfigCopyWith<$Res> {
  __$MiniGameRemoteConfigCopyWithImpl(this._self, this._then);

  final _MiniGameRemoteConfig _self;
  final $Res Function(_MiniGameRemoteConfig) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? domain = null,Object? useWsJson = null,Object? wsJsonUrl = null,Object? wsBinaryUrl = null,Object? resourceAppUrl = null,Object? resourceWebUrl = null,Object? helpUrl = null,Object? brand = null,}) {
  return _then(_MiniGameRemoteConfig(
domain: null == domain ? _self.domain : domain // ignore: cast_nullable_to_non_nullable
as String,useWsJson: null == useWsJson ? _self.useWsJson : useWsJson // ignore: cast_nullable_to_non_nullable
as bool,wsJsonUrl: null == wsJsonUrl ? _self.wsJsonUrl : wsJsonUrl // ignore: cast_nullable_to_non_nullable
as String,wsBinaryUrl: null == wsBinaryUrl ? _self.wsBinaryUrl : wsBinaryUrl // ignore: cast_nullable_to_non_nullable
as String,resourceAppUrl: null == resourceAppUrl ? _self.resourceAppUrl : resourceAppUrl // ignore: cast_nullable_to_non_nullable
as String,resourceWebUrl: null == resourceWebUrl ? _self.resourceWebUrl : resourceWebUrl // ignore: cast_nullable_to_non_nullable
as String,helpUrl: null == helpUrl ? _self.helpUrl : helpUrl // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}

// dart format on
