// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sun_api_response.dart';

// dart format off
T _$identity<T>(T value) => value;
mixin _$SunApiResponse<T> {

@JsonKey(name: 'messageKey') String get messageKey;@JsonKey(name: 'Locale') String? get locale;@JsonKey(name: 'data') Object? get data;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SunApiResponseCopyWith<T, SunApiResponse<T>> get copyWith => _$SunApiResponseCopyWithImpl<T, SunApiResponse<T>>(this as SunApiResponse<T>, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SunApiResponse<T>&&(identical(other.messageKey, messageKey) || other.messageKey == messageKey)&&(identical(other.locale, locale) || other.locale == locale)&&const DeepCollectionEquality().equals(other.data, data));
}

@override
int get hashCode => Object.hash(runtimeType,messageKey,locale,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'SunApiResponse<$T>(messageKey: $messageKey, locale: $locale, data: $data)';
}

}

abstract mixin class $SunApiResponseCopyWith<T,$Res>  {
  factory $SunApiResponseCopyWith(SunApiResponse<T> value, $Res Function(SunApiResponse<T>) _then) = _$SunApiResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'messageKey') String messageKey,@JsonKey(name: 'Locale') String? locale
});

}
class _$SunApiResponseCopyWithImpl<T,$Res>
    implements $SunApiResponseCopyWith<T, $Res> {
  _$SunApiResponseCopyWithImpl(this._self, this._then);

  final SunApiResponse<T> _self;
  final $Res Function(SunApiResponse<T>) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? messageKey = null,Object? locale = freezed,}) {
  return _then(_self.copyWith(
messageKey: null == messageKey ? _self.messageKey : messageKey // ignore: cast_nullable_to_non_nullable
as String,locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}

extension SunApiResponsePatterns<T> on SunApiResponse<T> {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SunApiSuccessResponse<T> value)?  success,TResult Function( SunApiFailureResponse<T> value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SunApiSuccessResponse() when success != null:
return success(_that);case SunApiFailureResponse() when failure != null:
return failure(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SunApiSuccessResponse<T> value)  success,required TResult Function( SunApiFailureResponse<T> value)  failure,}){
final _that = this;
switch (_that) {
case SunApiSuccessResponse():
return success(_that);case SunApiFailureResponse():
return failure(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SunApiSuccessResponse<T> value)?  success,TResult? Function( SunApiFailureResponse<T> value)?  failure,}){
final _that = this;
switch (_that) {
case SunApiSuccessResponse() when success != null:
return success(_that);case SunApiFailureResponse() when failure != null:
return failure(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function(@JsonKey(name: 'messageKey')  String messageKey, @JsonKey(name: 'status')  int status, @JsonKey(name: 'Locale')  String? locale, @JsonKey(name: 'data')  T? data)?  success,TResult Function(@JsonKey(name: 'messageKey')  String messageKey, @JsonKey(name: 'status')  int code, @JsonKey(name: 'Locale')  String? locale,  String? error,  Object? data)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SunApiSuccessResponse() when success != null:
return success(_that.messageKey,_that.status,_that.locale,_that.data);case SunApiFailureResponse() when failure != null:
return failure(_that.messageKey,_that.code,_that.locale,_that.error,_that.data);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function(@JsonKey(name: 'messageKey')  String messageKey, @JsonKey(name: 'status')  int status, @JsonKey(name: 'Locale')  String? locale, @JsonKey(name: 'data')  T? data)  success,required TResult Function(@JsonKey(name: 'messageKey')  String messageKey, @JsonKey(name: 'status')  int code, @JsonKey(name: 'Locale')  String? locale,  String? error,  Object? data)  failure,}) {final _that = this;
switch (_that) {
case SunApiSuccessResponse():
return success(_that.messageKey,_that.status,_that.locale,_that.data);case SunApiFailureResponse():
return failure(_that.messageKey,_that.code,_that.locale,_that.error,_that.data);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function(@JsonKey(name: 'messageKey')  String messageKey, @JsonKey(name: 'status')  int status, @JsonKey(name: 'Locale')  String? locale, @JsonKey(name: 'data')  T? data)?  success,TResult? Function(@JsonKey(name: 'messageKey')  String messageKey, @JsonKey(name: 'status')  int code, @JsonKey(name: 'Locale')  String? locale,  String? error,  Object? data)?  failure,}) {final _that = this;
switch (_that) {
case SunApiSuccessResponse() when success != null:
return success(_that.messageKey,_that.status,_that.locale,_that.data);case SunApiFailureResponse() when failure != null:
return failure(_that.messageKey,_that.code,_that.locale,_that.error,_that.data);case _:
  return null;

}
}

}

class SunApiSuccessResponse<T> implements SunApiResponse<T> {
  const SunApiSuccessResponse({@JsonKey(name: 'messageKey') required this.messageKey, @JsonKey(name: 'status') required this.status, @JsonKey(name: 'Locale') this.locale, @JsonKey(name: 'data') this.data});
  
@override@JsonKey(name: 'messageKey') final  String messageKey;
@JsonKey(name: 'status') final  int status;
@override@JsonKey(name: 'Locale') final  String? locale;
@override@JsonKey(name: 'data') final  T? data;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SunApiSuccessResponseCopyWith<T, SunApiSuccessResponse<T>> get copyWith => _$SunApiSuccessResponseCopyWithImpl<T, SunApiSuccessResponse<T>>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SunApiSuccessResponse<T>&&(identical(other.messageKey, messageKey) || other.messageKey == messageKey)&&(identical(other.status, status) || other.status == status)&&(identical(other.locale, locale) || other.locale == locale)&&const DeepCollectionEquality().equals(other.data, data));
}

@override
int get hashCode => Object.hash(runtimeType,messageKey,status,locale,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'SunApiResponse<$T>.success(messageKey: $messageKey, status: $status, locale: $locale, data: $data)';
}

}

abstract mixin class $SunApiSuccessResponseCopyWith<T,$Res> implements $SunApiResponseCopyWith<T, $Res> {
  factory $SunApiSuccessResponseCopyWith(SunApiSuccessResponse<T> value, $Res Function(SunApiSuccessResponse<T>) _then) = _$SunApiSuccessResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'messageKey') String messageKey,@JsonKey(name: 'status') int status,@JsonKey(name: 'Locale') String? locale,@JsonKey(name: 'data') T? data
});

}
class _$SunApiSuccessResponseCopyWithImpl<T,$Res>
    implements $SunApiSuccessResponseCopyWith<T, $Res> {
  _$SunApiSuccessResponseCopyWithImpl(this._self, this._then);

  final SunApiSuccessResponse<T> _self;
  final $Res Function(SunApiSuccessResponse<T>) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? messageKey = null,Object? status = null,Object? locale = freezed,Object? data = freezed,}) {
  return _then(SunApiSuccessResponse<T>(
messageKey: null == messageKey ? _self.messageKey : messageKey // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T?,
  ));
}

}

class SunApiFailureResponse<T> implements SunApiResponse<T> {
  const SunApiFailureResponse({@JsonKey(name: 'messageKey') required this.messageKey, @JsonKey(name: 'status') required this.code, @JsonKey(name: 'Locale') this.locale, this.error, this.data});
  
@override@JsonKey(name: 'messageKey') final  String messageKey;
@JsonKey(name: 'status') final  int code;
@override@JsonKey(name: 'Locale') final  String? locale;
 final  String? error;
@override final  Object? data;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SunApiFailureResponseCopyWith<T, SunApiFailureResponse<T>> get copyWith => _$SunApiFailureResponseCopyWithImpl<T, SunApiFailureResponse<T>>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SunApiFailureResponse<T>&&(identical(other.messageKey, messageKey) || other.messageKey == messageKey)&&(identical(other.code, code) || other.code == code)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other.data, data));
}

@override
int get hashCode => Object.hash(runtimeType,messageKey,code,locale,error,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'SunApiResponse<$T>.failure(messageKey: $messageKey, code: $code, locale: $locale, error: $error, data: $data)';
}

}

abstract mixin class $SunApiFailureResponseCopyWith<T,$Res> implements $SunApiResponseCopyWith<T, $Res> {
  factory $SunApiFailureResponseCopyWith(SunApiFailureResponse<T> value, $Res Function(SunApiFailureResponse<T>) _then) = _$SunApiFailureResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'messageKey') String messageKey,@JsonKey(name: 'status') int code,@JsonKey(name: 'Locale') String? locale, String? error, Object? data
});

}
class _$SunApiFailureResponseCopyWithImpl<T,$Res>
    implements $SunApiFailureResponseCopyWith<T, $Res> {
  _$SunApiFailureResponseCopyWithImpl(this._self, this._then);

  final SunApiFailureResponse<T> _self;
  final $Res Function(SunApiFailureResponse<T>) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? messageKey = null,Object? code = null,Object? locale = freezed,Object? error = freezed,Object? data = freezed,}) {
  return _then(SunApiFailureResponse<T>(
messageKey: null == messageKey ? _self.messageKey : messageKey // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as int,locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,data: freezed == data ? _self.data : data ,
  ));
}

}

// dart format on
