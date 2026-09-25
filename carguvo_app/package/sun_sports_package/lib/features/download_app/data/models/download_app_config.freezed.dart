// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'download_app_config.dart';

// dart format off
T _$identity<T>(T value) => value;

mixin _$DownloadAppConfig {

@JsonKey(name: 'app_name') String get appName;@JsonKey(name: 'description') String get description;@JsonKey(name: 'full_description') String get fullDescription;@JsonKey(name: 'type') String get type;@JsonKey(name: 'url_demo_screen') String get demoScreenshot;@JsonKey(name: 'url_icon_app') String get urlIconApp;@JsonKey(name: 'url_ios_store') String get urlIosStore;@JsonKey(name: 'url_android_store') String get urlAndroidStore;@JsonKey(name: 'url_file_android_apk') String get urlFileAndroidApk;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DownloadAppConfigCopyWith<DownloadAppConfig> get copyWith => _$DownloadAppConfigCopyWithImpl<DownloadAppConfig>(this as DownloadAppConfig, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadAppConfig&&(identical(other.appName, appName) || other.appName == appName)&&(identical(other.description, description) || other.description == description)&&(identical(other.fullDescription, fullDescription) || other.fullDescription == fullDescription)&&(identical(other.type, type) || other.type == type)&&(identical(other.demoScreenshot, demoScreenshot) || other.demoScreenshot == demoScreenshot)&&(identical(other.urlIconApp, urlIconApp) || other.urlIconApp == urlIconApp)&&(identical(other.urlIosStore, urlIosStore) || other.urlIosStore == urlIosStore)&&(identical(other.urlAndroidStore, urlAndroidStore) || other.urlAndroidStore == urlAndroidStore)&&(identical(other.urlFileAndroidApk, urlFileAndroidApk) || other.urlFileAndroidApk == urlFileAndroidApk));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,appName,description,fullDescription,type,demoScreenshot,urlIconApp,urlIosStore,urlAndroidStore,urlFileAndroidApk);

@override
String toString() {
  return 'DownloadAppConfig(appName: $appName, description: $description, fullDescription: $fullDescription, type: $type, demoScreenshot: $demoScreenshot, urlIconApp: $urlIconApp, urlIosStore: $urlIosStore, urlAndroidStore: $urlAndroidStore, urlFileAndroidApk: $urlFileAndroidApk)';
}

}

abstract mixin class $DownloadAppConfigCopyWith<$Res>  {
  factory $DownloadAppConfigCopyWith(DownloadAppConfig value, $Res Function(DownloadAppConfig) _then) = _$DownloadAppConfigCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'app_name') String appName,@JsonKey(name: 'description') String description,@JsonKey(name: 'full_description') String fullDescription,@JsonKey(name: 'type') String type,@JsonKey(name: 'url_demo_screen') String demoScreenshot,@JsonKey(name: 'url_icon_app') String urlIconApp,@JsonKey(name: 'url_ios_store') String urlIosStore,@JsonKey(name: 'url_android_store') String urlAndroidStore,@JsonKey(name: 'url_file_android_apk') String urlFileAndroidApk
});

}
class _$DownloadAppConfigCopyWithImpl<$Res>
    implements $DownloadAppConfigCopyWith<$Res> {
  _$DownloadAppConfigCopyWithImpl(this._self, this._then);

  final DownloadAppConfig _self;
  final $Res Function(DownloadAppConfig) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? appName = null,Object? description = null,Object? fullDescription = null,Object? type = null,Object? demoScreenshot = null,Object? urlIconApp = null,Object? urlIosStore = null,Object? urlAndroidStore = null,Object? urlFileAndroidApk = null,}) {
  return _then(_self.copyWith(
appName: null == appName ? _self.appName : appName // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,fullDescription: null == fullDescription ? _self.fullDescription : fullDescription // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,demoScreenshot: null == demoScreenshot ? _self.demoScreenshot : demoScreenshot // ignore: cast_nullable_to_non_nullable
as String,urlIconApp: null == urlIconApp ? _self.urlIconApp : urlIconApp // ignore: cast_nullable_to_non_nullable
as String,urlIosStore: null == urlIosStore ? _self.urlIosStore : urlIosStore // ignore: cast_nullable_to_non_nullable
as String,urlAndroidStore: null == urlAndroidStore ? _self.urlAndroidStore : urlAndroidStore // ignore: cast_nullable_to_non_nullable
as String,urlFileAndroidApk: null == urlFileAndroidApk ? _self.urlFileAndroidApk : urlFileAndroidApk // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}

extension DownloadAppConfigPatterns on DownloadAppConfig {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DownloadAppConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DownloadAppConfig() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DownloadAppConfig value)  $default,){
final _that = this;
switch (_that) {
case _DownloadAppConfig():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DownloadAppConfig value)?  $default,){
final _that = this;
switch (_that) {
case _DownloadAppConfig() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'app_name')  String appName, @JsonKey(name: 'description')  String description, @JsonKey(name: 'full_description')  String fullDescription, @JsonKey(name: 'type')  String type, @JsonKey(name: 'url_demo_screen')  String demoScreenshot, @JsonKey(name: 'url_icon_app')  String urlIconApp, @JsonKey(name: 'url_ios_store')  String urlIosStore, @JsonKey(name: 'url_android_store')  String urlAndroidStore, @JsonKey(name: 'url_file_android_apk')  String urlFileAndroidApk)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DownloadAppConfig() when $default != null:
return $default(_that.appName,_that.description,_that.fullDescription,_that.type,_that.demoScreenshot,_that.urlIconApp,_that.urlIosStore,_that.urlAndroidStore,_that.urlFileAndroidApk);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'app_name')  String appName, @JsonKey(name: 'description')  String description, @JsonKey(name: 'full_description')  String fullDescription, @JsonKey(name: 'type')  String type, @JsonKey(name: 'url_demo_screen')  String demoScreenshot, @JsonKey(name: 'url_icon_app')  String urlIconApp, @JsonKey(name: 'url_ios_store')  String urlIosStore, @JsonKey(name: 'url_android_store')  String urlAndroidStore, @JsonKey(name: 'url_file_android_apk')  String urlFileAndroidApk)  $default,) {final _that = this;
switch (_that) {
case _DownloadAppConfig():
return $default(_that.appName,_that.description,_that.fullDescription,_that.type,_that.demoScreenshot,_that.urlIconApp,_that.urlIosStore,_that.urlAndroidStore,_that.urlFileAndroidApk);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'app_name')  String appName, @JsonKey(name: 'description')  String description, @JsonKey(name: 'full_description')  String fullDescription, @JsonKey(name: 'type')  String type, @JsonKey(name: 'url_demo_screen')  String demoScreenshot, @JsonKey(name: 'url_icon_app')  String urlIconApp, @JsonKey(name: 'url_ios_store')  String urlIosStore, @JsonKey(name: 'url_android_store')  String urlAndroidStore, @JsonKey(name: 'url_file_android_apk')  String urlFileAndroidApk)?  $default,) {final _that = this;
switch (_that) {
case _DownloadAppConfig() when $default != null:
return $default(_that.appName,_that.description,_that.fullDescription,_that.type,_that.demoScreenshot,_that.urlIconApp,_that.urlIosStore,_that.urlAndroidStore,_that.urlFileAndroidApk);case _:
  return null;

}
}

}

@JsonSerializable()

class _DownloadAppConfig implements DownloadAppConfig {
  const _DownloadAppConfig({@JsonKey(name: 'app_name') this.appName = '', @JsonKey(name: 'description') this.description = '', @JsonKey(name: 'full_description') this.fullDescription = '', @JsonKey(name: 'type') this.type = '', @JsonKey(name: 'url_demo_screen') this.demoScreenshot = '', @JsonKey(name: 'url_icon_app') this.urlIconApp = '', @JsonKey(name: 'url_ios_store') this.urlIosStore = '', @JsonKey(name: 'url_android_store') this.urlAndroidStore = '', @JsonKey(name: 'url_file_android_apk') this.urlFileAndroidApk = ''});
  factory _DownloadAppConfig.fromJson(Map<String, dynamic> json) => _$DownloadAppConfigFromJson(json);

@override@JsonKey(name: 'app_name') final  String appName;
@override@JsonKey(name: 'description') final  String description;
@override@JsonKey(name: 'full_description') final  String fullDescription;
@override@JsonKey(name: 'type') final  String type;
@override@JsonKey(name: 'url_demo_screen') final  String demoScreenshot;
@override@JsonKey(name: 'url_icon_app') final  String urlIconApp;
@override@JsonKey(name: 'url_ios_store') final  String urlIosStore;
@override@JsonKey(name: 'url_android_store') final  String urlAndroidStore;
@override@JsonKey(name: 'url_file_android_apk') final  String urlFileAndroidApk;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DownloadAppConfigCopyWith<_DownloadAppConfig> get copyWith => __$DownloadAppConfigCopyWithImpl<_DownloadAppConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DownloadAppConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DownloadAppConfig&&(identical(other.appName, appName) || other.appName == appName)&&(identical(other.description, description) || other.description == description)&&(identical(other.fullDescription, fullDescription) || other.fullDescription == fullDescription)&&(identical(other.type, type) || other.type == type)&&(identical(other.demoScreenshot, demoScreenshot) || other.demoScreenshot == demoScreenshot)&&(identical(other.urlIconApp, urlIconApp) || other.urlIconApp == urlIconApp)&&(identical(other.urlIosStore, urlIosStore) || other.urlIosStore == urlIosStore)&&(identical(other.urlAndroidStore, urlAndroidStore) || other.urlAndroidStore == urlAndroidStore)&&(identical(other.urlFileAndroidApk, urlFileAndroidApk) || other.urlFileAndroidApk == urlFileAndroidApk));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,appName,description,fullDescription,type,demoScreenshot,urlIconApp,urlIosStore,urlAndroidStore,urlFileAndroidApk);

@override
String toString() {
  return 'DownloadAppConfig(appName: $appName, description: $description, fullDescription: $fullDescription, type: $type, demoScreenshot: $demoScreenshot, urlIconApp: $urlIconApp, urlIosStore: $urlIosStore, urlAndroidStore: $urlAndroidStore, urlFileAndroidApk: $urlFileAndroidApk)';
}

}

abstract mixin class _$DownloadAppConfigCopyWith<$Res> implements $DownloadAppConfigCopyWith<$Res> {
  factory _$DownloadAppConfigCopyWith(_DownloadAppConfig value, $Res Function(_DownloadAppConfig) _then) = __$DownloadAppConfigCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'app_name') String appName,@JsonKey(name: 'description') String description,@JsonKey(name: 'full_description') String fullDescription,@JsonKey(name: 'type') String type,@JsonKey(name: 'url_demo_screen') String demoScreenshot,@JsonKey(name: 'url_icon_app') String urlIconApp,@JsonKey(name: 'url_ios_store') String urlIosStore,@JsonKey(name: 'url_android_store') String urlAndroidStore,@JsonKey(name: 'url_file_android_apk') String urlFileAndroidApk
});

}
class __$DownloadAppConfigCopyWithImpl<$Res>
    implements _$DownloadAppConfigCopyWith<$Res> {
  __$DownloadAppConfigCopyWithImpl(this._self, this._then);

  final _DownloadAppConfig _self;
  final $Res Function(_DownloadAppConfig) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? appName = null,Object? description = null,Object? fullDescription = null,Object? type = null,Object? demoScreenshot = null,Object? urlIconApp = null,Object? urlIosStore = null,Object? urlAndroidStore = null,Object? urlFileAndroidApk = null,}) {
  return _then(_DownloadAppConfig(
appName: null == appName ? _self.appName : appName // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,fullDescription: null == fullDescription ? _self.fullDescription : fullDescription // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,demoScreenshot: null == demoScreenshot ? _self.demoScreenshot : demoScreenshot // ignore: cast_nullable_to_non_nullable
as String,urlIconApp: null == urlIconApp ? _self.urlIconApp : urlIconApp // ignore: cast_nullable_to_non_nullable
as String,urlIosStore: null == urlIosStore ? _self.urlIosStore : urlIosStore // ignore: cast_nullable_to_non_nullable
as String,urlAndroidStore: null == urlAndroidStore ? _self.urlAndroidStore : urlAndroidStore // ignore: cast_nullable_to_non_nullable
as String,urlFileAndroidApk: null == urlFileAndroidApk ? _self.urlFileAndroidApk : urlFileAndroidApk // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}

// dart format on
