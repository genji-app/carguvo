// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'change_password_provider.dart';

// dart format off
T _$identity<T>(T value) => value;
mixin _$ChangePasswordState {

 ChangePasswordStatus get status; String? get errorMessage; String get currentPassword; String get newPassword; String get confirmPassword; String? get currentPasswordError; String? get newPasswordError; String? get confirmPasswordError;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChangePasswordStateCopyWith<ChangePasswordState> get copyWith => _$ChangePasswordStateCopyWithImpl<ChangePasswordState>(this as ChangePasswordState, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangePasswordState&&(identical(other.status, status) || other.status == status)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.currentPassword, currentPassword) || other.currentPassword == currentPassword)&&(identical(other.newPassword, newPassword) || other.newPassword == newPassword)&&(identical(other.confirmPassword, confirmPassword) || other.confirmPassword == confirmPassword)&&(identical(other.currentPasswordError, currentPasswordError) || other.currentPasswordError == currentPasswordError)&&(identical(other.newPasswordError, newPasswordError) || other.newPasswordError == newPasswordError)&&(identical(other.confirmPasswordError, confirmPasswordError) || other.confirmPasswordError == confirmPasswordError));
}

@override
int get hashCode => Object.hash(runtimeType,status,errorMessage,currentPassword,newPassword,confirmPassword,currentPasswordError,newPasswordError,confirmPasswordError);

@override
String toString() {
  return 'ChangePasswordState(status: $status, errorMessage: $errorMessage, currentPassword: $currentPassword, newPassword: $newPassword, confirmPassword: $confirmPassword, currentPasswordError: $currentPasswordError, newPasswordError: $newPasswordError, confirmPasswordError: $confirmPasswordError)';
}

}

abstract mixin class $ChangePasswordStateCopyWith<$Res>  {
  factory $ChangePasswordStateCopyWith(ChangePasswordState value, $Res Function(ChangePasswordState) _then) = _$ChangePasswordStateCopyWithImpl;
@useResult
$Res call({
 ChangePasswordStatus status, String? errorMessage, String currentPassword, String newPassword, String confirmPassword, String? currentPasswordError, String? newPasswordError, String? confirmPasswordError
});

}
class _$ChangePasswordStateCopyWithImpl<$Res>
    implements $ChangePasswordStateCopyWith<$Res> {
  _$ChangePasswordStateCopyWithImpl(this._self, this._then);

  final ChangePasswordState _self;
  final $Res Function(ChangePasswordState) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? errorMessage = freezed,Object? currentPassword = null,Object? newPassword = null,Object? confirmPassword = null,Object? currentPasswordError = freezed,Object? newPasswordError = freezed,Object? confirmPasswordError = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ChangePasswordStatus,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,currentPassword: null == currentPassword ? _self.currentPassword : currentPassword // ignore: cast_nullable_to_non_nullable
as String,newPassword: null == newPassword ? _self.newPassword : newPassword // ignore: cast_nullable_to_non_nullable
as String,confirmPassword: null == confirmPassword ? _self.confirmPassword : confirmPassword // ignore: cast_nullable_to_non_nullable
as String,currentPasswordError: freezed == currentPasswordError ? _self.currentPasswordError : currentPasswordError // ignore: cast_nullable_to_non_nullable
as String?,newPasswordError: freezed == newPasswordError ? _self.newPasswordError : newPasswordError // ignore: cast_nullable_to_non_nullable
as String?,confirmPasswordError: freezed == confirmPasswordError ? _self.confirmPasswordError : confirmPasswordError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}

extension ChangePasswordStatePatterns on ChangePasswordState {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChangePasswordState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChangePasswordState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChangePasswordState value)  $default,){
final _that = this;
switch (_that) {
case _ChangePasswordState():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChangePasswordState value)?  $default,){
final _that = this;
switch (_that) {
case _ChangePasswordState() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ChangePasswordStatus status,  String? errorMessage,  String currentPassword,  String newPassword,  String confirmPassword,  String? currentPasswordError,  String? newPasswordError,  String? confirmPasswordError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChangePasswordState() when $default != null:
return $default(_that.status,_that.errorMessage,_that.currentPassword,_that.newPassword,_that.confirmPassword,_that.currentPasswordError,_that.newPasswordError,_that.confirmPasswordError);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ChangePasswordStatus status,  String? errorMessage,  String currentPassword,  String newPassword,  String confirmPassword,  String? currentPasswordError,  String? newPasswordError,  String? confirmPasswordError)  $default,) {final _that = this;
switch (_that) {
case _ChangePasswordState():
return $default(_that.status,_that.errorMessage,_that.currentPassword,_that.newPassword,_that.confirmPassword,_that.currentPasswordError,_that.newPasswordError,_that.confirmPasswordError);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ChangePasswordStatus status,  String? errorMessage,  String currentPassword,  String newPassword,  String confirmPassword,  String? currentPasswordError,  String? newPasswordError,  String? confirmPasswordError)?  $default,) {final _that = this;
switch (_that) {
case _ChangePasswordState() when $default != null:
return $default(_that.status,_that.errorMessage,_that.currentPassword,_that.newPassword,_that.confirmPassword,_that.currentPasswordError,_that.newPasswordError,_that.confirmPasswordError);case _:
  return null;

}
}

}

class _ChangePasswordState extends ChangePasswordState {
  const _ChangePasswordState({this.status = ChangePasswordStatus.initial, this.errorMessage, this.currentPassword = '', this.newPassword = '', this.confirmPassword = '', this.currentPasswordError, this.newPasswordError, this.confirmPasswordError}): super._();
  
@override@JsonKey() final  ChangePasswordStatus status;
@override final  String? errorMessage;
@override@JsonKey() final  String currentPassword;
@override@JsonKey() final  String newPassword;
@override@JsonKey() final  String confirmPassword;
@override final  String? currentPasswordError;
@override final  String? newPasswordError;
@override final  String? confirmPasswordError;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChangePasswordStateCopyWith<_ChangePasswordState> get copyWith => __$ChangePasswordStateCopyWithImpl<_ChangePasswordState>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChangePasswordState&&(identical(other.status, status) || other.status == status)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.currentPassword, currentPassword) || other.currentPassword == currentPassword)&&(identical(other.newPassword, newPassword) || other.newPassword == newPassword)&&(identical(other.confirmPassword, confirmPassword) || other.confirmPassword == confirmPassword)&&(identical(other.currentPasswordError, currentPasswordError) || other.currentPasswordError == currentPasswordError)&&(identical(other.newPasswordError, newPasswordError) || other.newPasswordError == newPasswordError)&&(identical(other.confirmPasswordError, confirmPasswordError) || other.confirmPasswordError == confirmPasswordError));
}

@override
int get hashCode => Object.hash(runtimeType,status,errorMessage,currentPassword,newPassword,confirmPassword,currentPasswordError,newPasswordError,confirmPasswordError);

@override
String toString() {
  return 'ChangePasswordState(status: $status, errorMessage: $errorMessage, currentPassword: $currentPassword, newPassword: $newPassword, confirmPassword: $confirmPassword, currentPasswordError: $currentPasswordError, newPasswordError: $newPasswordError, confirmPasswordError: $confirmPasswordError)';
}

}

abstract mixin class _$ChangePasswordStateCopyWith<$Res> implements $ChangePasswordStateCopyWith<$Res> {
  factory _$ChangePasswordStateCopyWith(_ChangePasswordState value, $Res Function(_ChangePasswordState) _then) = __$ChangePasswordStateCopyWithImpl;
@override @useResult
$Res call({
 ChangePasswordStatus status, String? errorMessage, String currentPassword, String newPassword, String confirmPassword, String? currentPasswordError, String? newPasswordError, String? confirmPasswordError
});

}
class __$ChangePasswordStateCopyWithImpl<$Res>
    implements _$ChangePasswordStateCopyWith<$Res> {
  __$ChangePasswordStateCopyWithImpl(this._self, this._then);

  final _ChangePasswordState _self;
  final $Res Function(_ChangePasswordState) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? errorMessage = freezed,Object? currentPassword = null,Object? newPassword = null,Object? confirmPassword = null,Object? currentPasswordError = freezed,Object? newPasswordError = freezed,Object? confirmPasswordError = freezed,}) {
  return _then(_ChangePasswordState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ChangePasswordStatus,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,currentPassword: null == currentPassword ? _self.currentPassword : currentPassword // ignore: cast_nullable_to_non_nullable
as String,newPassword: null == newPassword ? _self.newPassword : newPassword // ignore: cast_nullable_to_non_nullable
as String,confirmPassword: null == confirmPassword ? _self.confirmPassword : confirmPassword // ignore: cast_nullable_to_non_nullable
as String,currentPasswordError: freezed == currentPasswordError ? _self.currentPasswordError : currentPasswordError // ignore: cast_nullable_to_non_nullable
as String?,newPasswordError: freezed == newPasswordError ? _self.newPasswordError : newPasswordError // ignore: cast_nullable_to_non_nullable
as String?,confirmPasswordError: freezed == confirmPasswordError ? _self.confirmPasswordError : confirmPasswordError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}

// dart format on
