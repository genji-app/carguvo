// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'failures.dart';

// dart format off
T _$identity<T>(T value) => value;
mixin _$Failure {

 String get message;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FailureCopyWith<Failure> get copyWith => _$FailureCopyWithImpl<Failure>(this as Failure, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Failure&&(identical(other.message, message) || other.message == message));
}

@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'Failure(message: $message)';
}

}

abstract mixin class $FailureCopyWith<$Res>  {
  factory $FailureCopyWith(Failure value, $Res Function(Failure) _then) = _$FailureCopyWithImpl;
@useResult
$Res call({
 String message
});

}
class _$FailureCopyWithImpl<$Res>
    implements $FailureCopyWith<$Res> {
  _$FailureCopyWithImpl(this._self, this._then);

  final Failure _self;
  final $Res Function(Failure) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? message = null,}) {
  return _then(_self.copyWith(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}

extension FailurePatterns on Failure {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ServerFailure value)?  server,TResult Function( NetworkFailure value)?  network,TResult Function( CacheFailure value)?  cache,TResult Function( ParseFailure value)?  parse,TResult Function( AuthenticationFailure value)?  authentication,TResult Function( AuthorizationFailure value)?  authorization,TResult Function( NotFoundFailure value)?  notFound,TResult Function( TimeoutFailure value)?  timeout,TResult Function( ValidationFailure value)?  validation,TResult Function( UnexpectedFailure value)?  unexpected,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ServerFailure() when server != null:
return server(_that);case NetworkFailure() when network != null:
return network(_that);case CacheFailure() when cache != null:
return cache(_that);case ParseFailure() when parse != null:
return parse(_that);case AuthenticationFailure() when authentication != null:
return authentication(_that);case AuthorizationFailure() when authorization != null:
return authorization(_that);case NotFoundFailure() when notFound != null:
return notFound(_that);case TimeoutFailure() when timeout != null:
return timeout(_that);case ValidationFailure() when validation != null:
return validation(_that);case UnexpectedFailure() when unexpected != null:
return unexpected(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ServerFailure value)  server,required TResult Function( NetworkFailure value)  network,required TResult Function( CacheFailure value)  cache,required TResult Function( ParseFailure value)  parse,required TResult Function( AuthenticationFailure value)  authentication,required TResult Function( AuthorizationFailure value)  authorization,required TResult Function( NotFoundFailure value)  notFound,required TResult Function( TimeoutFailure value)  timeout,required TResult Function( ValidationFailure value)  validation,required TResult Function( UnexpectedFailure value)  unexpected,}){
final _that = this;
switch (_that) {
case ServerFailure():
return server(_that);case NetworkFailure():
return network(_that);case CacheFailure():
return cache(_that);case ParseFailure():
return parse(_that);case AuthenticationFailure():
return authentication(_that);case AuthorizationFailure():
return authorization(_that);case NotFoundFailure():
return notFound(_that);case TimeoutFailure():
return timeout(_that);case ValidationFailure():
return validation(_that);case UnexpectedFailure():
return unexpected(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ServerFailure value)?  server,TResult? Function( NetworkFailure value)?  network,TResult? Function( CacheFailure value)?  cache,TResult? Function( ParseFailure value)?  parse,TResult? Function( AuthenticationFailure value)?  authentication,TResult? Function( AuthorizationFailure value)?  authorization,TResult? Function( NotFoundFailure value)?  notFound,TResult? Function( TimeoutFailure value)?  timeout,TResult? Function( ValidationFailure value)?  validation,TResult? Function( UnexpectedFailure value)?  unexpected,}){
final _that = this;
switch (_that) {
case ServerFailure() when server != null:
return server(_that);case NetworkFailure() when network != null:
return network(_that);case CacheFailure() when cache != null:
return cache(_that);case ParseFailure() when parse != null:
return parse(_that);case AuthenticationFailure() when authentication != null:
return authentication(_that);case AuthorizationFailure() when authorization != null:
return authorization(_that);case NotFoundFailure() when notFound != null:
return notFound(_that);case TimeoutFailure() when timeout != null:
return timeout(_that);case ValidationFailure() when validation != null:
return validation(_that);case UnexpectedFailure() when unexpected != null:
return unexpected(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String message,  int? statusCode)?  server,TResult Function( String message)?  network,TResult Function( String message)?  cache,TResult Function( String message)?  parse,TResult Function( String message)?  authentication,TResult Function( String message)?  authorization,TResult Function( String message)?  notFound,TResult Function( String message)?  timeout,TResult Function( String message,  Map<String, dynamic>? errors)?  validation,TResult Function( String message)?  unexpected,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ServerFailure() when server != null:
return server(_that.message,_that.statusCode);case NetworkFailure() when network != null:
return network(_that.message);case CacheFailure() when cache != null:
return cache(_that.message);case ParseFailure() when parse != null:
return parse(_that.message);case AuthenticationFailure() when authentication != null:
return authentication(_that.message);case AuthorizationFailure() when authorization != null:
return authorization(_that.message);case NotFoundFailure() when notFound != null:
return notFound(_that.message);case TimeoutFailure() when timeout != null:
return timeout(_that.message);case ValidationFailure() when validation != null:
return validation(_that.message,_that.errors);case UnexpectedFailure() when unexpected != null:
return unexpected(_that.message);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String message,  int? statusCode)  server,required TResult Function( String message)  network,required TResult Function( String message)  cache,required TResult Function( String message)  parse,required TResult Function( String message)  authentication,required TResult Function( String message)  authorization,required TResult Function( String message)  notFound,required TResult Function( String message)  timeout,required TResult Function( String message,  Map<String, dynamic>? errors)  validation,required TResult Function( String message)  unexpected,}) {final _that = this;
switch (_that) {
case ServerFailure():
return server(_that.message,_that.statusCode);case NetworkFailure():
return network(_that.message);case CacheFailure():
return cache(_that.message);case ParseFailure():
return parse(_that.message);case AuthenticationFailure():
return authentication(_that.message);case AuthorizationFailure():
return authorization(_that.message);case NotFoundFailure():
return notFound(_that.message);case TimeoutFailure():
return timeout(_that.message);case ValidationFailure():
return validation(_that.message,_that.errors);case UnexpectedFailure():
return unexpected(_that.message);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String message,  int? statusCode)?  server,TResult? Function( String message)?  network,TResult? Function( String message)?  cache,TResult? Function( String message)?  parse,TResult? Function( String message)?  authentication,TResult? Function( String message)?  authorization,TResult? Function( String message)?  notFound,TResult? Function( String message)?  timeout,TResult? Function( String message,  Map<String, dynamic>? errors)?  validation,TResult? Function( String message)?  unexpected,}) {final _that = this;
switch (_that) {
case ServerFailure() when server != null:
return server(_that.message,_that.statusCode);case NetworkFailure() when network != null:
return network(_that.message);case CacheFailure() when cache != null:
return cache(_that.message);case ParseFailure() when parse != null:
return parse(_that.message);case AuthenticationFailure() when authentication != null:
return authentication(_that.message);case AuthorizationFailure() when authorization != null:
return authorization(_that.message);case NotFoundFailure() when notFound != null:
return notFound(_that.message);case TimeoutFailure() when timeout != null:
return timeout(_that.message);case ValidationFailure() when validation != null:
return validation(_that.message,_that.errors);case UnexpectedFailure() when unexpected != null:
return unexpected(_that.message);case _:
  return null;

}
}

}

class ServerFailure implements Failure {
  const ServerFailure({required this.message, this.statusCode});
  
@override final  String message;
 final  int? statusCode;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerFailureCopyWith<ServerFailure> get copyWith => _$ServerFailureCopyWithImpl<ServerFailure>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerFailure&&(identical(other.message, message) || other.message == message)&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode));
}

@override
int get hashCode => Object.hash(runtimeType,message,statusCode);

@override
String toString() {
  return 'Failure.server(message: $message, statusCode: $statusCode)';
}

}

abstract mixin class $ServerFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $ServerFailureCopyWith(ServerFailure value, $Res Function(ServerFailure) _then) = _$ServerFailureCopyWithImpl;
@override @useResult
$Res call({
 String message, int? statusCode
});

}
class _$ServerFailureCopyWithImpl<$Res>
    implements $ServerFailureCopyWith<$Res> {
  _$ServerFailureCopyWithImpl(this._self, this._then);

  final ServerFailure _self;
  final $Res Function(ServerFailure) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? statusCode = freezed,}) {
  return _then(ServerFailure(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,statusCode: freezed == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}

class NetworkFailure implements Failure {
  const NetworkFailure({this.message = 'No internet connection'});
  
@override@JsonKey() final  String message;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NetworkFailureCopyWith<NetworkFailure> get copyWith => _$NetworkFailureCopyWithImpl<NetworkFailure>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NetworkFailure&&(identical(other.message, message) || other.message == message));
}

@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'Failure.network(message: $message)';
}

}

abstract mixin class $NetworkFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $NetworkFailureCopyWith(NetworkFailure value, $Res Function(NetworkFailure) _then) = _$NetworkFailureCopyWithImpl;
@override @useResult
$Res call({
 String message
});

}
class _$NetworkFailureCopyWithImpl<$Res>
    implements $NetworkFailureCopyWith<$Res> {
  _$NetworkFailureCopyWithImpl(this._self, this._then);

  final NetworkFailure _self;
  final $Res Function(NetworkFailure) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(NetworkFailure(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}

class CacheFailure implements Failure {
  const CacheFailure({this.message = 'Cache error occurred'});
  
@override@JsonKey() final  String message;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CacheFailureCopyWith<CacheFailure> get copyWith => _$CacheFailureCopyWithImpl<CacheFailure>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CacheFailure&&(identical(other.message, message) || other.message == message));
}

@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'Failure.cache(message: $message)';
}

}

abstract mixin class $CacheFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $CacheFailureCopyWith(CacheFailure value, $Res Function(CacheFailure) _then) = _$CacheFailureCopyWithImpl;
@override @useResult
$Res call({
 String message
});

}
class _$CacheFailureCopyWithImpl<$Res>
    implements $CacheFailureCopyWith<$Res> {
  _$CacheFailureCopyWithImpl(this._self, this._then);

  final CacheFailure _self;
  final $Res Function(CacheFailure) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(CacheFailure(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}

class ParseFailure implements Failure {
  const ParseFailure({this.message = 'Failed to parse data'});
  
@override@JsonKey() final  String message;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParseFailureCopyWith<ParseFailure> get copyWith => _$ParseFailureCopyWithImpl<ParseFailure>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParseFailure&&(identical(other.message, message) || other.message == message));
}

@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'Failure.parse(message: $message)';
}

}

abstract mixin class $ParseFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $ParseFailureCopyWith(ParseFailure value, $Res Function(ParseFailure) _then) = _$ParseFailureCopyWithImpl;
@override @useResult
$Res call({
 String message
});

}
class _$ParseFailureCopyWithImpl<$Res>
    implements $ParseFailureCopyWith<$Res> {
  _$ParseFailureCopyWithImpl(this._self, this._then);

  final ParseFailure _self;
  final $Res Function(ParseFailure) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(ParseFailure(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}

class AuthenticationFailure implements Failure {
  const AuthenticationFailure({this.message = 'Authentication failed'});
  
@override@JsonKey() final  String message;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthenticationFailureCopyWith<AuthenticationFailure> get copyWith => _$AuthenticationFailureCopyWithImpl<AuthenticationFailure>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthenticationFailure&&(identical(other.message, message) || other.message == message));
}

@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'Failure.authentication(message: $message)';
}

}

abstract mixin class $AuthenticationFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $AuthenticationFailureCopyWith(AuthenticationFailure value, $Res Function(AuthenticationFailure) _then) = _$AuthenticationFailureCopyWithImpl;
@override @useResult
$Res call({
 String message
});

}
class _$AuthenticationFailureCopyWithImpl<$Res>
    implements $AuthenticationFailureCopyWith<$Res> {
  _$AuthenticationFailureCopyWithImpl(this._self, this._then);

  final AuthenticationFailure _self;
  final $Res Function(AuthenticationFailure) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(AuthenticationFailure(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}

class AuthorizationFailure implements Failure {
  const AuthorizationFailure({this.message = 'Access denied'});
  
@override@JsonKey() final  String message;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthorizationFailureCopyWith<AuthorizationFailure> get copyWith => _$AuthorizationFailureCopyWithImpl<AuthorizationFailure>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthorizationFailure&&(identical(other.message, message) || other.message == message));
}

@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'Failure.authorization(message: $message)';
}

}

abstract mixin class $AuthorizationFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $AuthorizationFailureCopyWith(AuthorizationFailure value, $Res Function(AuthorizationFailure) _then) = _$AuthorizationFailureCopyWithImpl;
@override @useResult
$Res call({
 String message
});

}
class _$AuthorizationFailureCopyWithImpl<$Res>
    implements $AuthorizationFailureCopyWith<$Res> {
  _$AuthorizationFailureCopyWithImpl(this._self, this._then);

  final AuthorizationFailure _self;
  final $Res Function(AuthorizationFailure) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(AuthorizationFailure(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}

class NotFoundFailure implements Failure {
  const NotFoundFailure({this.message = 'Resource not found'});
  
@override@JsonKey() final  String message;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotFoundFailureCopyWith<NotFoundFailure> get copyWith => _$NotFoundFailureCopyWithImpl<NotFoundFailure>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotFoundFailure&&(identical(other.message, message) || other.message == message));
}

@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'Failure.notFound(message: $message)';
}

}

abstract mixin class $NotFoundFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $NotFoundFailureCopyWith(NotFoundFailure value, $Res Function(NotFoundFailure) _then) = _$NotFoundFailureCopyWithImpl;
@override @useResult
$Res call({
 String message
});

}
class _$NotFoundFailureCopyWithImpl<$Res>
    implements $NotFoundFailureCopyWith<$Res> {
  _$NotFoundFailureCopyWithImpl(this._self, this._then);

  final NotFoundFailure _self;
  final $Res Function(NotFoundFailure) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(NotFoundFailure(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}

class TimeoutFailure implements Failure {
  const TimeoutFailure({this.message = 'Request timeout'});
  
@override@JsonKey() final  String message;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimeoutFailureCopyWith<TimeoutFailure> get copyWith => _$TimeoutFailureCopyWithImpl<TimeoutFailure>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimeoutFailure&&(identical(other.message, message) || other.message == message));
}

@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'Failure.timeout(message: $message)';
}

}

abstract mixin class $TimeoutFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $TimeoutFailureCopyWith(TimeoutFailure value, $Res Function(TimeoutFailure) _then) = _$TimeoutFailureCopyWithImpl;
@override @useResult
$Res call({
 String message
});

}
class _$TimeoutFailureCopyWithImpl<$Res>
    implements $TimeoutFailureCopyWith<$Res> {
  _$TimeoutFailureCopyWithImpl(this._self, this._then);

  final TimeoutFailure _self;
  final $Res Function(TimeoutFailure) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(TimeoutFailure(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}

class ValidationFailure implements Failure {
  const ValidationFailure({this.message = 'Validation failed', final  Map<String, dynamic>? errors}): _errors = errors;
  
@override@JsonKey() final  String message;
 final  Map<String, dynamic>? _errors;
 Map<String, dynamic>? get errors {
  final value = _errors;
  if (value == null) return null;
  if (_errors is EqualUnmodifiableMapView) return _errors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ValidationFailureCopyWith<ValidationFailure> get copyWith => _$ValidationFailureCopyWithImpl<ValidationFailure>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ValidationFailure&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other._errors, _errors));
}

@override
int get hashCode => Object.hash(runtimeType,message,const DeepCollectionEquality().hash(_errors));

@override
String toString() {
  return 'Failure.validation(message: $message, errors: $errors)';
}

}

abstract mixin class $ValidationFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $ValidationFailureCopyWith(ValidationFailure value, $Res Function(ValidationFailure) _then) = _$ValidationFailureCopyWithImpl;
@override @useResult
$Res call({
 String message, Map<String, dynamic>? errors
});

}
class _$ValidationFailureCopyWithImpl<$Res>
    implements $ValidationFailureCopyWith<$Res> {
  _$ValidationFailureCopyWithImpl(this._self, this._then);

  final ValidationFailure _self;
  final $Res Function(ValidationFailure) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? errors = freezed,}) {
  return _then(ValidationFailure(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,errors: freezed == errors ? _self._errors : errors // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}

class UnexpectedFailure implements Failure {
  const UnexpectedFailure({this.message = 'An unexpected error occurred'});
  
@override@JsonKey() final  String message;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnexpectedFailureCopyWith<UnexpectedFailure> get copyWith => _$UnexpectedFailureCopyWithImpl<UnexpectedFailure>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnexpectedFailure&&(identical(other.message, message) || other.message == message));
}

@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'Failure.unexpected(message: $message)';
}

}

abstract mixin class $UnexpectedFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $UnexpectedFailureCopyWith(UnexpectedFailure value, $Res Function(UnexpectedFailure) _then) = _$UnexpectedFailureCopyWithImpl;
@override @useResult
$Res call({
 String message
});

}
class _$UnexpectedFailureCopyWithImpl<$Res>
    implements $UnexpectedFailureCopyWith<$Res> {
  _$UnexpectedFailureCopyWithImpl(this._self, this._then);

  final UnexpectedFailure _self;
  final $Res Function(UnexpectedFailure) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(UnexpectedFailure(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}

// dart format on
