// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_notifier.dart';

// dart format off
T _$identity<T>(T value) => value;
mixin _$UserState {

 UserStatus get status;
 User? get user;
 String? get error;
 DateTime? get lastUpdated;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserStateCopyWith<UserState> get copyWith => _$UserStateCopyWithImpl<UserState>(this as UserState, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserState&&(identical(other.status, status) || other.status == status)&&(identical(other.user, user) || other.user == user)&&(identical(other.error, error) || other.error == error)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated));
}

@override
int get hashCode => Object.hash(runtimeType,status,user,error,lastUpdated);

@override
String toString() {
  return 'UserState(status: $status, user: $user, error: $error, lastUpdated: $lastUpdated)';
}

}

abstract mixin class $UserStateCopyWith<$Res>  {
  factory $UserStateCopyWith(UserState value, $Res Function(UserState) _then) = _$UserStateCopyWithImpl;
@useResult
$Res call({
 UserStatus status, User? user, String? error, DateTime? lastUpdated
});

$UserCopyWith<$Res>? get user;

}
class _$UserStateCopyWithImpl<$Res>
    implements $UserStateCopyWith<$Res> {
  _$UserStateCopyWithImpl(this._self, this._then);

  final UserState _self;
  final $Res Function(UserState) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? user = freezed,Object? error = freezed,Object? lastUpdated = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as UserStatus,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,lastUpdated: freezed == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $UserCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

extension UserStatePatterns on UserState {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserState value)  $default,){
final _that = this;
switch (_that) {
case _UserState():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserState value)?  $default,){
final _that = this;
switch (_that) {
case _UserState() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UserStatus status,  User? user,  String? error,  DateTime? lastUpdated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserState() when $default != null:
return $default(_that.status,_that.user,_that.error,_that.lastUpdated);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UserStatus status,  User? user,  String? error,  DateTime? lastUpdated)  $default,) {final _that = this;
switch (_that) {
case _UserState():
return $default(_that.status,_that.user,_that.error,_that.lastUpdated);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UserStatus status,  User? user,  String? error,  DateTime? lastUpdated)?  $default,) {final _that = this;
switch (_that) {
case _UserState() when $default != null:
return $default(_that.status,_that.user,_that.error,_that.lastUpdated);case _:
  return null;

}
}

}

class _UserState extends UserState {
  const _UserState({this.status = UserStatus.initial, this.user, this.error, this.lastUpdated}): super._();
  
@override@JsonKey() final  UserStatus status;
@override final  User? user;
@override final  String? error;
@override final  DateTime? lastUpdated;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserStateCopyWith<_UserState> get copyWith => __$UserStateCopyWithImpl<_UserState>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserState&&(identical(other.status, status) || other.status == status)&&(identical(other.user, user) || other.user == user)&&(identical(other.error, error) || other.error == error)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated));
}

@override
int get hashCode => Object.hash(runtimeType,status,user,error,lastUpdated);

@override
String toString() {
  return 'UserState(status: $status, user: $user, error: $error, lastUpdated: $lastUpdated)';
}

}

abstract mixin class _$UserStateCopyWith<$Res> implements $UserStateCopyWith<$Res> {
  factory _$UserStateCopyWith(_UserState value, $Res Function(_UserState) _then) = __$UserStateCopyWithImpl;
@override @useResult
$Res call({
 UserStatus status, User? user, String? error, DateTime? lastUpdated
});

@override $UserCopyWith<$Res>? get user;

}
class __$UserStateCopyWithImpl<$Res>
    implements _$UserStateCopyWith<$Res> {
  __$UserStateCopyWithImpl(this._self, this._then);

  final _UserState _self;
  final $Res Function(_UserState) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? user = freezed,Object? error = freezed,Object? lastUpdated = freezed,}) {
  return _then(_UserState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as UserStatus,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,lastUpdated: freezed == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $UserCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

// dart format on
