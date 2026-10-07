// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_state.dart';

// dart format off
T _$identity<T>(T value) => value;
mixin _$AuthState {

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthState);
}

@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthState()';
}

}

class $AuthStateCopyWith<$Res>  {
$AuthStateCopyWith(AuthState _, $Res Function(AuthState) __);
}

extension AuthStatePatterns on AuthState {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _Authenticated value)?  authenticated,TResult Function( _Unauthenticated value)?  unauthenticated,TResult Function( _Error value)?  error,TResult Function( _OtpRequired value)?  otpRequired,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Authenticated() when authenticated != null:
return authenticated(_that);case _Unauthenticated() when unauthenticated != null:
return unauthenticated(_that);case _Error() when error != null:
return error(_that);case _OtpRequired() when otpRequired != null:
return otpRequired(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _Authenticated value)  authenticated,required TResult Function( _Unauthenticated value)  unauthenticated,required TResult Function( _Error value)  error,required TResult Function( _OtpRequired value)  otpRequired,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _Authenticated():
return authenticated(_that);case _Unauthenticated():
return unauthenticated(_that);case _Error():
return error(_that);case _OtpRequired():
return otpRequired(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _Authenticated value)?  authenticated,TResult? Function( _Unauthenticated value)?  unauthenticated,TResult? Function( _Error value)?  error,TResult? Function( _OtpRequired value)?  otpRequired,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Authenticated() when authenticated != null:
return authenticated(_that);case _Unauthenticated() when unauthenticated != null:
return unauthenticated(_that);case _Error() when error != null:
return error(_that);case _OtpRequired() when otpRequired != null:
return otpRequired(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( AuthEntity auth)?  authenticated,TResult Function()?  unauthenticated,TResult Function( String message,  bool showPopup)?  error,TResult Function( String sessionId,  String message,  String username,  String password)?  otpRequired,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Authenticated() when authenticated != null:
return authenticated(_that.auth);case _Unauthenticated() when unauthenticated != null:
return unauthenticated();case _Error() when error != null:
return error(_that.message,_that.showPopup);case _OtpRequired() when otpRequired != null:
return otpRequired(_that.sessionId,_that.message,_that.username,_that.password);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( AuthEntity auth)  authenticated,required TResult Function()  unauthenticated,required TResult Function( String message,  bool showPopup)  error,required TResult Function( String sessionId,  String message,  String username,  String password)  otpRequired,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _Authenticated():
return authenticated(_that.auth);case _Unauthenticated():
return unauthenticated();case _Error():
return error(_that.message,_that.showPopup);case _OtpRequired():
return otpRequired(_that.sessionId,_that.message,_that.username,_that.password);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( AuthEntity auth)?  authenticated,TResult? Function()?  unauthenticated,TResult? Function( String message,  bool showPopup)?  error,TResult? Function( String sessionId,  String message,  String username,  String password)?  otpRequired,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Authenticated() when authenticated != null:
return authenticated(_that.auth);case _Unauthenticated() when unauthenticated != null:
return unauthenticated();case _Error() when error != null:
return error(_that.message,_that.showPopup);case _OtpRequired() when otpRequired != null:
return otpRequired(_that.sessionId,_that.message,_that.username,_that.password);case _:
  return null;

}
}

}

class _Initial implements AuthState {
  const _Initial();
  
@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}

@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthState.initial()';
}

}

class _Loading implements AuthState {
  const _Loading();
  
@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}

@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthState.loading()';
}

}

class _Authenticated implements AuthState {
  const _Authenticated(this.auth);
  
 final  AuthEntity auth;

@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthenticatedCopyWith<_Authenticated> get copyWith => __$AuthenticatedCopyWithImpl<_Authenticated>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Authenticated&&(identical(other.auth, auth) || other.auth == auth));
}

@override
int get hashCode => Object.hash(runtimeType,auth);

@override
String toString() {
  return 'AuthState.authenticated(auth: $auth)';
}

}

abstract mixin class _$AuthenticatedCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory _$AuthenticatedCopyWith(_Authenticated value, $Res Function(_Authenticated) _then) = __$AuthenticatedCopyWithImpl;
@useResult
$Res call({
 AuthEntity auth
});

$AuthEntityCopyWith<$Res> get auth;

}
class __$AuthenticatedCopyWithImpl<$Res>
    implements _$AuthenticatedCopyWith<$Res> {
  __$AuthenticatedCopyWithImpl(this._self, this._then);

  final _Authenticated _self;
  final $Res Function(_Authenticated) _then;

@pragma('vm:prefer-inline') $Res call({Object? auth = null,}) {
  return _then(_Authenticated(
null == auth ? _self.auth : auth // ignore: cast_nullable_to_non_nullable
as AuthEntity,
  ));
}

@override
@pragma('vm:prefer-inline')
$AuthEntityCopyWith<$Res> get auth {
  
  return $AuthEntityCopyWith<$Res>(_self.auth, (value) {
    return _then(_self.copyWith(auth: value));
  });
}
}

class _Unauthenticated implements AuthState {
  const _Unauthenticated();
  
@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Unauthenticated);
}

@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthState.unauthenticated()';
}

}

class _Error implements AuthState {
  const _Error(this.message, {this.showPopup = false});
  
 final  String message;
@JsonKey() final  bool showPopup;

@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorCopyWith<_Error> get copyWith => __$ErrorCopyWithImpl<_Error>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error&&(identical(other.message, message) || other.message == message)&&(identical(other.showPopup, showPopup) || other.showPopup == showPopup));
}

@override
int get hashCode => Object.hash(runtimeType,message,showPopup);

@override
String toString() {
  return 'AuthState.error(message: $message, showPopup: $showPopup)';
}

}

abstract mixin class _$ErrorCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) = __$ErrorCopyWithImpl;
@useResult
$Res call({
 String message, bool showPopup
});

}
class __$ErrorCopyWithImpl<$Res>
    implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error _self;
  final $Res Function(_Error) _then;

@pragma('vm:prefer-inline') $Res call({Object? message = null,Object? showPopup = null,}) {
  return _then(_Error(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,showPopup: null == showPopup ? _self.showPopup : showPopup // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}

class _OtpRequired implements AuthState {
  const _OtpRequired({required this.sessionId, required this.message, required this.username, required this.password});
  
 final  String sessionId;
 final  String message;
 final  String username;
 final  String password;

@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OtpRequiredCopyWith<_OtpRequired> get copyWith => __$OtpRequiredCopyWithImpl<_OtpRequired>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OtpRequired&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.message, message) || other.message == message)&&(identical(other.username, username) || other.username == username)&&(identical(other.password, password) || other.password == password));
}

@override
int get hashCode => Object.hash(runtimeType,sessionId,message,username,password);

@override
String toString() {
  return 'AuthState.otpRequired(sessionId: $sessionId, message: $message, username: $username, password: $password)';
}

}

abstract mixin class _$OtpRequiredCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory _$OtpRequiredCopyWith(_OtpRequired value, $Res Function(_OtpRequired) _then) = __$OtpRequiredCopyWithImpl;
@useResult
$Res call({
 String sessionId, String message, String username, String password
});

}
class __$OtpRequiredCopyWithImpl<$Res>
    implements _$OtpRequiredCopyWith<$Res> {
  __$OtpRequiredCopyWithImpl(this._self, this._then);

  final _OtpRequired _self;
  final $Res Function(_OtpRequired) _then;

@pragma('vm:prefer-inline') $Res call({Object? sessionId = null,Object? message = null,Object? username = null,Object? password = null,}) {
  return _then(_OtpRequired(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}

mixin _$LoginFormState {

 String get username; String get password; String? get usernameError; String? get passwordError; bool get isSubmitting; String? get generalError;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginFormStateCopyWith<LoginFormState> get copyWith => _$LoginFormStateCopyWithImpl<LoginFormState>(this as LoginFormState, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginFormState&&(identical(other.username, username) || other.username == username)&&(identical(other.password, password) || other.password == password)&&(identical(other.usernameError, usernameError) || other.usernameError == usernameError)&&(identical(other.passwordError, passwordError) || other.passwordError == passwordError)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.generalError, generalError) || other.generalError == generalError));
}

@override
int get hashCode => Object.hash(runtimeType,username,password,usernameError,passwordError,isSubmitting,generalError);

@override
String toString() {
  return 'LoginFormState(username: $username, password: $password, usernameError: $usernameError, passwordError: $passwordError, isSubmitting: $isSubmitting, generalError: $generalError)';
}

}

abstract mixin class $LoginFormStateCopyWith<$Res>  {
  factory $LoginFormStateCopyWith(LoginFormState value, $Res Function(LoginFormState) _then) = _$LoginFormStateCopyWithImpl;
@useResult
$Res call({
 String username, String password, String? usernameError, String? passwordError, bool isSubmitting, String? generalError
});

}
class _$LoginFormStateCopyWithImpl<$Res>
    implements $LoginFormStateCopyWith<$Res> {
  _$LoginFormStateCopyWithImpl(this._self, this._then);

  final LoginFormState _self;
  final $Res Function(LoginFormState) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? username = null,Object? password = null,Object? usernameError = freezed,Object? passwordError = freezed,Object? isSubmitting = null,Object? generalError = freezed,}) {
  return _then(_self.copyWith(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,usernameError: freezed == usernameError ? _self.usernameError : usernameError // ignore: cast_nullable_to_non_nullable
as String?,passwordError: freezed == passwordError ? _self.passwordError : passwordError // ignore: cast_nullable_to_non_nullable
as String?,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,generalError: freezed == generalError ? _self.generalError : generalError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}

extension LoginFormStatePatterns on LoginFormState {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoginFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoginFormState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoginFormState value)  $default,){
final _that = this;
switch (_that) {
case _LoginFormState():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoginFormState value)?  $default,){
final _that = this;
switch (_that) {
case _LoginFormState() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String username,  String password,  String? usernameError,  String? passwordError,  bool isSubmitting,  String? generalError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoginFormState() when $default != null:
return $default(_that.username,_that.password,_that.usernameError,_that.passwordError,_that.isSubmitting,_that.generalError);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String username,  String password,  String? usernameError,  String? passwordError,  bool isSubmitting,  String? generalError)  $default,) {final _that = this;
switch (_that) {
case _LoginFormState():
return $default(_that.username,_that.password,_that.usernameError,_that.passwordError,_that.isSubmitting,_that.generalError);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String username,  String password,  String? usernameError,  String? passwordError,  bool isSubmitting,  String? generalError)?  $default,) {final _that = this;
switch (_that) {
case _LoginFormState() when $default != null:
return $default(_that.username,_that.password,_that.usernameError,_that.passwordError,_that.isSubmitting,_that.generalError);case _:
  return null;

}
}

}

class _LoginFormState implements LoginFormState {
  const _LoginFormState({this.username = '', this.password = '', this.usernameError, this.passwordError, this.isSubmitting = false, this.generalError});
  
@override@JsonKey() final  String username;
@override@JsonKey() final  String password;
@override final  String? usernameError;
@override final  String? passwordError;
@override@JsonKey() final  bool isSubmitting;
@override final  String? generalError;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginFormStateCopyWith<_LoginFormState> get copyWith => __$LoginFormStateCopyWithImpl<_LoginFormState>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoginFormState&&(identical(other.username, username) || other.username == username)&&(identical(other.password, password) || other.password == password)&&(identical(other.usernameError, usernameError) || other.usernameError == usernameError)&&(identical(other.passwordError, passwordError) || other.passwordError == passwordError)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.generalError, generalError) || other.generalError == generalError));
}

@override
int get hashCode => Object.hash(runtimeType,username,password,usernameError,passwordError,isSubmitting,generalError);

@override
String toString() {
  return 'LoginFormState(username: $username, password: $password, usernameError: $usernameError, passwordError: $passwordError, isSubmitting: $isSubmitting, generalError: $generalError)';
}

}

abstract mixin class _$LoginFormStateCopyWith<$Res> implements $LoginFormStateCopyWith<$Res> {
  factory _$LoginFormStateCopyWith(_LoginFormState value, $Res Function(_LoginFormState) _then) = __$LoginFormStateCopyWithImpl;
@override @useResult
$Res call({
 String username, String password, String? usernameError, String? passwordError, bool isSubmitting, String? generalError
});

}
class __$LoginFormStateCopyWithImpl<$Res>
    implements _$LoginFormStateCopyWith<$Res> {
  __$LoginFormStateCopyWithImpl(this._self, this._then);

  final _LoginFormState _self;
  final $Res Function(_LoginFormState) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? username = null,Object? password = null,Object? usernameError = freezed,Object? passwordError = freezed,Object? isSubmitting = null,Object? generalError = freezed,}) {
  return _then(_LoginFormState(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,usernameError: freezed == usernameError ? _self.usernameError : usernameError // ignore: cast_nullable_to_non_nullable
as String?,passwordError: freezed == passwordError ? _self.passwordError : passwordError // ignore: cast_nullable_to_non_nullable
as String?,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,generalError: freezed == generalError ? _self.generalError : generalError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}

mixin _$RegisterFormState {

 String get username; String get password; String get confirmPassword; String get displayName; String? get usernameError; String? get passwordError; String? get confirmPasswordError; String? get displayNameError; bool get isSubmitting; String? get generalError;
 UsernameAvailability get usernameAvailability;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterFormStateCopyWith<RegisterFormState> get copyWith => _$RegisterFormStateCopyWithImpl<RegisterFormState>(this as RegisterFormState, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterFormState&&(identical(other.username, username) || other.username == username)&&(identical(other.password, password) || other.password == password)&&(identical(other.confirmPassword, confirmPassword) || other.confirmPassword == confirmPassword)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.usernameError, usernameError) || other.usernameError == usernameError)&&(identical(other.passwordError, passwordError) || other.passwordError == passwordError)&&(identical(other.confirmPasswordError, confirmPasswordError) || other.confirmPasswordError == confirmPasswordError)&&(identical(other.displayNameError, displayNameError) || other.displayNameError == displayNameError)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.generalError, generalError) || other.generalError == generalError)&&(identical(other.usernameAvailability, usernameAvailability) || other.usernameAvailability == usernameAvailability));
}

@override
int get hashCode => Object.hash(runtimeType,username,password,confirmPassword,displayName,usernameError,passwordError,confirmPasswordError,displayNameError,isSubmitting,generalError,usernameAvailability);

@override
String toString() {
  return 'RegisterFormState(username: $username, password: $password, confirmPassword: $confirmPassword, displayName: $displayName, usernameError: $usernameError, passwordError: $passwordError, confirmPasswordError: $confirmPasswordError, displayNameError: $displayNameError, isSubmitting: $isSubmitting, generalError: $generalError, usernameAvailability: $usernameAvailability)';
}

}

abstract mixin class $RegisterFormStateCopyWith<$Res>  {
  factory $RegisterFormStateCopyWith(RegisterFormState value, $Res Function(RegisterFormState) _then) = _$RegisterFormStateCopyWithImpl;
@useResult
$Res call({
 String username, String password, String confirmPassword, String displayName, String? usernameError, String? passwordError, String? confirmPasswordError, String? displayNameError, bool isSubmitting, String? generalError, UsernameAvailability usernameAvailability
});

}
class _$RegisterFormStateCopyWithImpl<$Res>
    implements $RegisterFormStateCopyWith<$Res> {
  _$RegisterFormStateCopyWithImpl(this._self, this._then);

  final RegisterFormState _self;
  final $Res Function(RegisterFormState) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? username = null,Object? password = null,Object? confirmPassword = null,Object? displayName = null,Object? usernameError = freezed,Object? passwordError = freezed,Object? confirmPasswordError = freezed,Object? displayNameError = freezed,Object? isSubmitting = null,Object? generalError = freezed,Object? usernameAvailability = null,}) {
  return _then(_self.copyWith(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,confirmPassword: null == confirmPassword ? _self.confirmPassword : confirmPassword // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,usernameError: freezed == usernameError ? _self.usernameError : usernameError // ignore: cast_nullable_to_non_nullable
as String?,passwordError: freezed == passwordError ? _self.passwordError : passwordError // ignore: cast_nullable_to_non_nullable
as String?,confirmPasswordError: freezed == confirmPasswordError ? _self.confirmPasswordError : confirmPasswordError // ignore: cast_nullable_to_non_nullable
as String?,displayNameError: freezed == displayNameError ? _self.displayNameError : displayNameError // ignore: cast_nullable_to_non_nullable
as String?,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,generalError: freezed == generalError ? _self.generalError : generalError // ignore: cast_nullable_to_non_nullable
as String?,usernameAvailability: null == usernameAvailability ? _self.usernameAvailability : usernameAvailability // ignore: cast_nullable_to_non_nullable
as UsernameAvailability,
  ));
}

}

extension RegisterFormStatePatterns on RegisterFormState {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegisterFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegisterFormState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegisterFormState value)  $default,){
final _that = this;
switch (_that) {
case _RegisterFormState():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegisterFormState value)?  $default,){
final _that = this;
switch (_that) {
case _RegisterFormState() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String username,  String password,  String confirmPassword,  String displayName,  String? usernameError,  String? passwordError,  String? confirmPasswordError,  String? displayNameError,  bool isSubmitting,  String? generalError,  UsernameAvailability usernameAvailability)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegisterFormState() when $default != null:
return $default(_that.username,_that.password,_that.confirmPassword,_that.displayName,_that.usernameError,_that.passwordError,_that.confirmPasswordError,_that.displayNameError,_that.isSubmitting,_that.generalError,_that.usernameAvailability);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String username,  String password,  String confirmPassword,  String displayName,  String? usernameError,  String? passwordError,  String? confirmPasswordError,  String? displayNameError,  bool isSubmitting,  String? generalError,  UsernameAvailability usernameAvailability)  $default,) {final _that = this;
switch (_that) {
case _RegisterFormState():
return $default(_that.username,_that.password,_that.confirmPassword,_that.displayName,_that.usernameError,_that.passwordError,_that.confirmPasswordError,_that.displayNameError,_that.isSubmitting,_that.generalError,_that.usernameAvailability);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String username,  String password,  String confirmPassword,  String displayName,  String? usernameError,  String? passwordError,  String? confirmPasswordError,  String? displayNameError,  bool isSubmitting,  String? generalError,  UsernameAvailability usernameAvailability)?  $default,) {final _that = this;
switch (_that) {
case _RegisterFormState() when $default != null:
return $default(_that.username,_that.password,_that.confirmPassword,_that.displayName,_that.usernameError,_that.passwordError,_that.confirmPasswordError,_that.displayNameError,_that.isSubmitting,_that.generalError,_that.usernameAvailability);case _:
  return null;

}
}

}

class _RegisterFormState implements RegisterFormState {
  const _RegisterFormState({this.username = '', this.password = '', this.confirmPassword = '', this.displayName = '', this.usernameError, this.passwordError, this.confirmPasswordError, this.displayNameError, this.isSubmitting = false, this.generalError, this.usernameAvailability = UsernameAvailability.unknown});
  
@override@JsonKey() final  String username;
@override@JsonKey() final  String password;
@override@JsonKey() final  String confirmPassword;
@override@JsonKey() final  String displayName;
@override final  String? usernameError;
@override final  String? passwordError;
@override final  String? confirmPasswordError;
@override final  String? displayNameError;
@override@JsonKey() final  bool isSubmitting;
@override final  String? generalError;
@override@JsonKey() final  UsernameAvailability usernameAvailability;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisterFormStateCopyWith<_RegisterFormState> get copyWith => __$RegisterFormStateCopyWithImpl<_RegisterFormState>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisterFormState&&(identical(other.username, username) || other.username == username)&&(identical(other.password, password) || other.password == password)&&(identical(other.confirmPassword, confirmPassword) || other.confirmPassword == confirmPassword)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.usernameError, usernameError) || other.usernameError == usernameError)&&(identical(other.passwordError, passwordError) || other.passwordError == passwordError)&&(identical(other.confirmPasswordError, confirmPasswordError) || other.confirmPasswordError == confirmPasswordError)&&(identical(other.displayNameError, displayNameError) || other.displayNameError == displayNameError)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.generalError, generalError) || other.generalError == generalError)&&(identical(other.usernameAvailability, usernameAvailability) || other.usernameAvailability == usernameAvailability));
}

@override
int get hashCode => Object.hash(runtimeType,username,password,confirmPassword,displayName,usernameError,passwordError,confirmPasswordError,displayNameError,isSubmitting,generalError,usernameAvailability);

@override
String toString() {
  return 'RegisterFormState(username: $username, password: $password, confirmPassword: $confirmPassword, displayName: $displayName, usernameError: $usernameError, passwordError: $passwordError, confirmPasswordError: $confirmPasswordError, displayNameError: $displayNameError, isSubmitting: $isSubmitting, generalError: $generalError, usernameAvailability: $usernameAvailability)';
}

}

abstract mixin class _$RegisterFormStateCopyWith<$Res> implements $RegisterFormStateCopyWith<$Res> {
  factory _$RegisterFormStateCopyWith(_RegisterFormState value, $Res Function(_RegisterFormState) _then) = __$RegisterFormStateCopyWithImpl;
@override @useResult
$Res call({
 String username, String password, String confirmPassword, String displayName, String? usernameError, String? passwordError, String? confirmPasswordError, String? displayNameError, bool isSubmitting, String? generalError, UsernameAvailability usernameAvailability
});

}
class __$RegisterFormStateCopyWithImpl<$Res>
    implements _$RegisterFormStateCopyWith<$Res> {
  __$RegisterFormStateCopyWithImpl(this._self, this._then);

  final _RegisterFormState _self;
  final $Res Function(_RegisterFormState) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? username = null,Object? password = null,Object? confirmPassword = null,Object? displayName = null,Object? usernameError = freezed,Object? passwordError = freezed,Object? confirmPasswordError = freezed,Object? displayNameError = freezed,Object? isSubmitting = null,Object? generalError = freezed,Object? usernameAvailability = null,}) {
  return _then(_RegisterFormState(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,confirmPassword: null == confirmPassword ? _self.confirmPassword : confirmPassword // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,usernameError: freezed == usernameError ? _self.usernameError : usernameError // ignore: cast_nullable_to_non_nullable
as String?,passwordError: freezed == passwordError ? _self.passwordError : passwordError // ignore: cast_nullable_to_non_nullable
as String?,confirmPasswordError: freezed == confirmPasswordError ? _self.confirmPasswordError : confirmPasswordError // ignore: cast_nullable_to_non_nullable
as String?,displayNameError: freezed == displayNameError ? _self.displayNameError : displayNameError // ignore: cast_nullable_to_non_nullable
as String?,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,generalError: freezed == generalError ? _self.generalError : generalError // ignore: cast_nullable_to_non_nullable
as String?,usernameAvailability: null == usernameAvailability ? _self.usernameAvailability : usernameAvailability // ignore: cast_nullable_to_non_nullable
as UsernameAvailability,
  ));
}

}

mixin _$OtpFormState {

 String get otp; String? get otpError; bool get isSubmitting; String? get generalError;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OtpFormStateCopyWith<OtpFormState> get copyWith => _$OtpFormStateCopyWithImpl<OtpFormState>(this as OtpFormState, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OtpFormState&&(identical(other.otp, otp) || other.otp == otp)&&(identical(other.otpError, otpError) || other.otpError == otpError)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.generalError, generalError) || other.generalError == generalError));
}

@override
int get hashCode => Object.hash(runtimeType,otp,otpError,isSubmitting,generalError);

@override
String toString() {
  return 'OtpFormState(otp: $otp, otpError: $otpError, isSubmitting: $isSubmitting, generalError: $generalError)';
}

}

abstract mixin class $OtpFormStateCopyWith<$Res>  {
  factory $OtpFormStateCopyWith(OtpFormState value, $Res Function(OtpFormState) _then) = _$OtpFormStateCopyWithImpl;
@useResult
$Res call({
 String otp, String? otpError, bool isSubmitting, String? generalError
});

}
class _$OtpFormStateCopyWithImpl<$Res>
    implements $OtpFormStateCopyWith<$Res> {
  _$OtpFormStateCopyWithImpl(this._self, this._then);

  final OtpFormState _self;
  final $Res Function(OtpFormState) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? otp = null,Object? otpError = freezed,Object? isSubmitting = null,Object? generalError = freezed,}) {
  return _then(_self.copyWith(
otp: null == otp ? _self.otp : otp // ignore: cast_nullable_to_non_nullable
as String,otpError: freezed == otpError ? _self.otpError : otpError // ignore: cast_nullable_to_non_nullable
as String?,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,generalError: freezed == generalError ? _self.generalError : generalError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}

extension OtpFormStatePatterns on OtpFormState {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OtpFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OtpFormState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OtpFormState value)  $default,){
final _that = this;
switch (_that) {
case _OtpFormState():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OtpFormState value)?  $default,){
final _that = this;
switch (_that) {
case _OtpFormState() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String otp,  String? otpError,  bool isSubmitting,  String? generalError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OtpFormState() when $default != null:
return $default(_that.otp,_that.otpError,_that.isSubmitting,_that.generalError);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String otp,  String? otpError,  bool isSubmitting,  String? generalError)  $default,) {final _that = this;
switch (_that) {
case _OtpFormState():
return $default(_that.otp,_that.otpError,_that.isSubmitting,_that.generalError);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String otp,  String? otpError,  bool isSubmitting,  String? generalError)?  $default,) {final _that = this;
switch (_that) {
case _OtpFormState() when $default != null:
return $default(_that.otp,_that.otpError,_that.isSubmitting,_that.generalError);case _:
  return null;

}
}

}

class _OtpFormState implements OtpFormState {
  const _OtpFormState({this.otp = '', this.otpError, this.isSubmitting = false, this.generalError});
  
@override@JsonKey() final  String otp;
@override final  String? otpError;
@override@JsonKey() final  bool isSubmitting;
@override final  String? generalError;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OtpFormStateCopyWith<_OtpFormState> get copyWith => __$OtpFormStateCopyWithImpl<_OtpFormState>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OtpFormState&&(identical(other.otp, otp) || other.otp == otp)&&(identical(other.otpError, otpError) || other.otpError == otpError)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.generalError, generalError) || other.generalError == generalError));
}

@override
int get hashCode => Object.hash(runtimeType,otp,otpError,isSubmitting,generalError);

@override
String toString() {
  return 'OtpFormState(otp: $otp, otpError: $otpError, isSubmitting: $isSubmitting, generalError: $generalError)';
}

}

abstract mixin class _$OtpFormStateCopyWith<$Res> implements $OtpFormStateCopyWith<$Res> {
  factory _$OtpFormStateCopyWith(_OtpFormState value, $Res Function(_OtpFormState) _then) = __$OtpFormStateCopyWithImpl;
@override @useResult
$Res call({
 String otp, String? otpError, bool isSubmitting, String? generalError
});

}
class __$OtpFormStateCopyWithImpl<$Res>
    implements _$OtpFormStateCopyWith<$Res> {
  __$OtpFormStateCopyWithImpl(this._self, this._then);

  final _OtpFormState _self;
  final $Res Function(_OtpFormState) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? otp = null,Object? otpError = freezed,Object? isSubmitting = null,Object? generalError = freezed,}) {
  return _then(_OtpFormState(
otp: null == otp ? _self.otp : otp // ignore: cast_nullable_to_non_nullable
as String,otpError: freezed == otpError ? _self.otpError : otpError // ignore: cast_nullable_to_non_nullable
as String?,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,generalError: freezed == generalError ? _self.generalError : generalError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}

// dart format on
