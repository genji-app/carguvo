// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_model.dart';

// dart format off
T _$identity<T>(T value) => value;

mixin _$AuthResponseModel {

 int get status; AuthDataModel? get data;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthResponseModelCopyWith<AuthResponseModel> get copyWith => _$AuthResponseModelCopyWithImpl<AuthResponseModel>(this as AuthResponseModel, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthResponseModel&&(identical(other.status, status) || other.status == status)&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,data);

@override
String toString() {
  return 'AuthResponseModel(status: $status, data: $data)';
}

}

abstract mixin class $AuthResponseModelCopyWith<$Res>  {
  factory $AuthResponseModelCopyWith(AuthResponseModel value, $Res Function(AuthResponseModel) _then) = _$AuthResponseModelCopyWithImpl;
@useResult
$Res call({
 int status, AuthDataModel? data
});

$AuthDataModelCopyWith<$Res>? get data;

}
class _$AuthResponseModelCopyWithImpl<$Res>
    implements $AuthResponseModelCopyWith<$Res> {
  _$AuthResponseModelCopyWithImpl(this._self, this._then);

  final AuthResponseModel _self;
  final $Res Function(AuthResponseModel) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? data = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as AuthDataModel?,
  ));
}
@override
@pragma('vm:prefer-inline')
$AuthDataModelCopyWith<$Res>? get data {
    if (_self.data == null) {
    return null;
  }

  return $AuthDataModelCopyWith<$Res>(_self.data!, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

extension AuthResponseModelPatterns on AuthResponseModel {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthResponseModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthResponseModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthResponseModel value)  $default,){
final _that = this;
switch (_that) {
case _AuthResponseModel():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthResponseModel value)?  $default,){
final _that = this;
switch (_that) {
case _AuthResponseModel() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int status,  AuthDataModel? data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthResponseModel() when $default != null:
return $default(_that.status,_that.data);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int status,  AuthDataModel? data)  $default,) {final _that = this;
switch (_that) {
case _AuthResponseModel():
return $default(_that.status,_that.data);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int status,  AuthDataModel? data)?  $default,) {final _that = this;
switch (_that) {
case _AuthResponseModel() when $default != null:
return $default(_that.status,_that.data);case _:
  return null;

}
}

}

@JsonSerializable()

class _AuthResponseModel extends AuthResponseModel {
  const _AuthResponseModel({required this.status, this.data}): super._();
  factory _AuthResponseModel.fromJson(Map<String, dynamic> json) => _$AuthResponseModelFromJson(json);

@override final  int status;
@override final  AuthDataModel? data;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthResponseModelCopyWith<_AuthResponseModel> get copyWith => __$AuthResponseModelCopyWithImpl<_AuthResponseModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthResponseModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthResponseModel&&(identical(other.status, status) || other.status == status)&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,data);

@override
String toString() {
  return 'AuthResponseModel(status: $status, data: $data)';
}

}

abstract mixin class _$AuthResponseModelCopyWith<$Res> implements $AuthResponseModelCopyWith<$Res> {
  factory _$AuthResponseModelCopyWith(_AuthResponseModel value, $Res Function(_AuthResponseModel) _then) = __$AuthResponseModelCopyWithImpl;
@override @useResult
$Res call({
 int status, AuthDataModel? data
});

@override $AuthDataModelCopyWith<$Res>? get data;

}
class __$AuthResponseModelCopyWithImpl<$Res>
    implements _$AuthResponseModelCopyWith<$Res> {
  __$AuthResponseModelCopyWithImpl(this._self, this._then);

  final _AuthResponseModel _self;
  final $Res Function(_AuthResponseModel) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? data = freezed,}) {
  return _then(_AuthResponseModel(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as AuthDataModel?,
  ));
}

@override
@pragma('vm:prefer-inline')
$AuthDataModelCopyWith<$Res>? get data {
    if (_self.data == null) {
    return null;
  }

  return $AuthDataModelCopyWith<$Res>(_self.data!, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

mixin _$AuthDataModel {

 String? get accessToken; String? get refreshToken; String? get wsToken; String? get signature; UserInfoModel? get info; bool? get showPopupChangeUsername; bool? get showPopupChangeBrand;
 String? get sessionId; String? get message;
 int? get type;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthDataModelCopyWith<AuthDataModel> get copyWith => _$AuthDataModelCopyWithImpl<AuthDataModel>(this as AuthDataModel, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthDataModel&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.wsToken, wsToken) || other.wsToken == wsToken)&&(identical(other.signature, signature) || other.signature == signature)&&(identical(other.info, info) || other.info == info)&&(identical(other.showPopupChangeUsername, showPopupChangeUsername) || other.showPopupChangeUsername == showPopupChangeUsername)&&(identical(other.showPopupChangeBrand, showPopupChangeBrand) || other.showPopupChangeBrand == showPopupChangeBrand)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.message, message) || other.message == message)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accessToken,refreshToken,wsToken,signature,info,showPopupChangeUsername,showPopupChangeBrand,sessionId,message,type);

@override
String toString() {
  return 'AuthDataModel(accessToken: $accessToken, refreshToken: $refreshToken, wsToken: $wsToken, signature: $signature, info: $info, showPopupChangeUsername: $showPopupChangeUsername, showPopupChangeBrand: $showPopupChangeBrand, sessionId: $sessionId, message: $message, type: $type)';
}

}

abstract mixin class $AuthDataModelCopyWith<$Res>  {
  factory $AuthDataModelCopyWith(AuthDataModel value, $Res Function(AuthDataModel) _then) = _$AuthDataModelCopyWithImpl;
@useResult
$Res call({
 String? accessToken, String? refreshToken, String? wsToken, String? signature, UserInfoModel? info, bool? showPopupChangeUsername, bool? showPopupChangeBrand, String? sessionId, String? message, int? type
});

$UserInfoModelCopyWith<$Res>? get info;

}
class _$AuthDataModelCopyWithImpl<$Res>
    implements $AuthDataModelCopyWith<$Res> {
  _$AuthDataModelCopyWithImpl(this._self, this._then);

  final AuthDataModel _self;
  final $Res Function(AuthDataModel) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? accessToken = freezed,Object? refreshToken = freezed,Object? wsToken = freezed,Object? signature = freezed,Object? info = freezed,Object? showPopupChangeUsername = freezed,Object? showPopupChangeBrand = freezed,Object? sessionId = freezed,Object? message = freezed,Object? type = freezed,}) {
  return _then(_self.copyWith(
accessToken: freezed == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String?,refreshToken: freezed == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String?,wsToken: freezed == wsToken ? _self.wsToken : wsToken // ignore: cast_nullable_to_non_nullable
as String?,signature: freezed == signature ? _self.signature : signature // ignore: cast_nullable_to_non_nullable
as String?,info: freezed == info ? _self.info : info // ignore: cast_nullable_to_non_nullable
as UserInfoModel?,showPopupChangeUsername: freezed == showPopupChangeUsername ? _self.showPopupChangeUsername : showPopupChangeUsername // ignore: cast_nullable_to_non_nullable
as bool?,showPopupChangeBrand: freezed == showPopupChangeBrand ? _self.showPopupChangeBrand : showPopupChangeBrand // ignore: cast_nullable_to_non_nullable
as bool?,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
@override
@pragma('vm:prefer-inline')
$UserInfoModelCopyWith<$Res>? get info {
    if (_self.info == null) {
    return null;
  }

  return $UserInfoModelCopyWith<$Res>(_self.info!, (value) {
    return _then(_self.copyWith(info: value));
  });
}
}

extension AuthDataModelPatterns on AuthDataModel {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthDataModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthDataModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthDataModel value)  $default,){
final _that = this;
switch (_that) {
case _AuthDataModel():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthDataModel value)?  $default,){
final _that = this;
switch (_that) {
case _AuthDataModel() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? accessToken,  String? refreshToken,  String? wsToken,  String? signature,  UserInfoModel? info,  bool? showPopupChangeUsername,  bool? showPopupChangeBrand,  String? sessionId,  String? message,  int? type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthDataModel() when $default != null:
return $default(_that.accessToken,_that.refreshToken,_that.wsToken,_that.signature,_that.info,_that.showPopupChangeUsername,_that.showPopupChangeBrand,_that.sessionId,_that.message,_that.type);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? accessToken,  String? refreshToken,  String? wsToken,  String? signature,  UserInfoModel? info,  bool? showPopupChangeUsername,  bool? showPopupChangeBrand,  String? sessionId,  String? message,  int? type)  $default,) {final _that = this;
switch (_that) {
case _AuthDataModel():
return $default(_that.accessToken,_that.refreshToken,_that.wsToken,_that.signature,_that.info,_that.showPopupChangeUsername,_that.showPopupChangeBrand,_that.sessionId,_that.message,_that.type);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? accessToken,  String? refreshToken,  String? wsToken,  String? signature,  UserInfoModel? info,  bool? showPopupChangeUsername,  bool? showPopupChangeBrand,  String? sessionId,  String? message,  int? type)?  $default,) {final _that = this;
switch (_that) {
case _AuthDataModel() when $default != null:
return $default(_that.accessToken,_that.refreshToken,_that.wsToken,_that.signature,_that.info,_that.showPopupChangeUsername,_that.showPopupChangeBrand,_that.sessionId,_that.message,_that.type);case _:
  return null;

}
}

}

@JsonSerializable()

class _AuthDataModel extends AuthDataModel {
  const _AuthDataModel({this.accessToken, this.refreshToken, this.wsToken, this.signature, this.info, this.showPopupChangeUsername, this.showPopupChangeBrand, this.sessionId, this.message, this.type}): super._();
  factory _AuthDataModel.fromJson(Map<String, dynamic> json) => _$AuthDataModelFromJson(json);

@override final  String? accessToken;
@override final  String? refreshToken;
@override final  String? wsToken;
@override final  String? signature;
@override final  UserInfoModel? info;
@override final  bool? showPopupChangeUsername;
@override final  bool? showPopupChangeBrand;
@override final  String? sessionId;
@override final  String? message;
@override final  int? type;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthDataModelCopyWith<_AuthDataModel> get copyWith => __$AuthDataModelCopyWithImpl<_AuthDataModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthDataModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthDataModel&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.wsToken, wsToken) || other.wsToken == wsToken)&&(identical(other.signature, signature) || other.signature == signature)&&(identical(other.info, info) || other.info == info)&&(identical(other.showPopupChangeUsername, showPopupChangeUsername) || other.showPopupChangeUsername == showPopupChangeUsername)&&(identical(other.showPopupChangeBrand, showPopupChangeBrand) || other.showPopupChangeBrand == showPopupChangeBrand)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.message, message) || other.message == message)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accessToken,refreshToken,wsToken,signature,info,showPopupChangeUsername,showPopupChangeBrand,sessionId,message,type);

@override
String toString() {
  return 'AuthDataModel(accessToken: $accessToken, refreshToken: $refreshToken, wsToken: $wsToken, signature: $signature, info: $info, showPopupChangeUsername: $showPopupChangeUsername, showPopupChangeBrand: $showPopupChangeBrand, sessionId: $sessionId, message: $message, type: $type)';
}

}

abstract mixin class _$AuthDataModelCopyWith<$Res> implements $AuthDataModelCopyWith<$Res> {
  factory _$AuthDataModelCopyWith(_AuthDataModel value, $Res Function(_AuthDataModel) _then) = __$AuthDataModelCopyWithImpl;
@override @useResult
$Res call({
 String? accessToken, String? refreshToken, String? wsToken, String? signature, UserInfoModel? info, bool? showPopupChangeUsername, bool? showPopupChangeBrand, String? sessionId, String? message, int? type
});

@override $UserInfoModelCopyWith<$Res>? get info;

}
class __$AuthDataModelCopyWithImpl<$Res>
    implements _$AuthDataModelCopyWith<$Res> {
  __$AuthDataModelCopyWithImpl(this._self, this._then);

  final _AuthDataModel _self;
  final $Res Function(_AuthDataModel) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? accessToken = freezed,Object? refreshToken = freezed,Object? wsToken = freezed,Object? signature = freezed,Object? info = freezed,Object? showPopupChangeUsername = freezed,Object? showPopupChangeBrand = freezed,Object? sessionId = freezed,Object? message = freezed,Object? type = freezed,}) {
  return _then(_AuthDataModel(
accessToken: freezed == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String?,refreshToken: freezed == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String?,wsToken: freezed == wsToken ? _self.wsToken : wsToken // ignore: cast_nullable_to_non_nullable
as String?,signature: freezed == signature ? _self.signature : signature // ignore: cast_nullable_to_non_nullable
as String?,info: freezed == info ? _self.info : info // ignore: cast_nullable_to_non_nullable
as UserInfoModel?,showPopupChangeUsername: freezed == showPopupChangeUsername ? _self.showPopupChangeUsername : showPopupChangeUsername // ignore: cast_nullable_to_non_nullable
as bool?,showPopupChangeBrand: freezed == showPopupChangeBrand ? _self.showPopupChangeBrand : showPopupChangeBrand // ignore: cast_nullable_to_non_nullable
as bool?,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

@override
@pragma('vm:prefer-inline')
$UserInfoModelCopyWith<$Res>? get info {
    if (_self.info == null) {
    return null;
  }

  return $UserInfoModelCopyWith<$Res>(_self.info!, (value) {
    return _then(_self.copyWith(info: value));
  });
}
}

mixin _$UserInfoModel {

 String? get visibleUserName; String? get displayName; int? get gold; int? get chip; int? get safe; String? get visibleUserId; String? get phone; String? get email; int? get vipPoint; int? get vip; String? get avatar; int? get gender; String? get birthDay; String? get brand;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserInfoModelCopyWith<UserInfoModel> get copyWith => _$UserInfoModelCopyWithImpl<UserInfoModel>(this as UserInfoModel, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserInfoModel&&(identical(other.visibleUserName, visibleUserName) || other.visibleUserName == visibleUserName)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.gold, gold) || other.gold == gold)&&(identical(other.chip, chip) || other.chip == chip)&&(identical(other.safe, safe) || other.safe == safe)&&(identical(other.visibleUserId, visibleUserId) || other.visibleUserId == visibleUserId)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.vipPoint, vipPoint) || other.vipPoint == vipPoint)&&(identical(other.vip, vip) || other.vip == vip)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.birthDay, birthDay) || other.birthDay == birthDay)&&(identical(other.brand, brand) || other.brand == brand));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,visibleUserName,displayName,gold,chip,safe,visibleUserId,phone,email,vipPoint,vip,avatar,gender,birthDay,brand);

@override
String toString() {
  return 'UserInfoModel(visibleUserName: $visibleUserName, displayName: $displayName, gold: $gold, chip: $chip, safe: $safe, visibleUserId: $visibleUserId, phone: $phone, email: $email, vipPoint: $vipPoint, vip: $vip, avatar: $avatar, gender: $gender, birthDay: $birthDay, brand: $brand)';
}

}

abstract mixin class $UserInfoModelCopyWith<$Res>  {
  factory $UserInfoModelCopyWith(UserInfoModel value, $Res Function(UserInfoModel) _then) = _$UserInfoModelCopyWithImpl;
@useResult
$Res call({
 String? visibleUserName, String? displayName, int? gold, int? chip, int? safe, String? visibleUserId, String? phone, String? email, int? vipPoint, int? vip, String? avatar, int? gender, String? birthDay, String? brand
});

}
class _$UserInfoModelCopyWithImpl<$Res>
    implements $UserInfoModelCopyWith<$Res> {
  _$UserInfoModelCopyWithImpl(this._self, this._then);

  final UserInfoModel _self;
  final $Res Function(UserInfoModel) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? visibleUserName = freezed,Object? displayName = freezed,Object? gold = freezed,Object? chip = freezed,Object? safe = freezed,Object? visibleUserId = freezed,Object? phone = freezed,Object? email = freezed,Object? vipPoint = freezed,Object? vip = freezed,Object? avatar = freezed,Object? gender = freezed,Object? birthDay = freezed,Object? brand = freezed,}) {
  return _then(_self.copyWith(
visibleUserName: freezed == visibleUserName ? _self.visibleUserName : visibleUserName // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,gold: freezed == gold ? _self.gold : gold // ignore: cast_nullable_to_non_nullable
as int?,chip: freezed == chip ? _self.chip : chip // ignore: cast_nullable_to_non_nullable
as int?,safe: freezed == safe ? _self.safe : safe // ignore: cast_nullable_to_non_nullable
as int?,visibleUserId: freezed == visibleUserId ? _self.visibleUserId : visibleUserId // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,vipPoint: freezed == vipPoint ? _self.vipPoint : vipPoint // ignore: cast_nullable_to_non_nullable
as int?,vip: freezed == vip ? _self.vip : vip // ignore: cast_nullable_to_non_nullable
as int?,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as int?,birthDay: freezed == birthDay ? _self.birthDay : birthDay // ignore: cast_nullable_to_non_nullable
as String?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}

extension UserInfoModelPatterns on UserInfoModel {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserInfoModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserInfoModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserInfoModel value)  $default,){
final _that = this;
switch (_that) {
case _UserInfoModel():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserInfoModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserInfoModel() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? visibleUserName,  String? displayName,  int? gold,  int? chip,  int? safe,  String? visibleUserId,  String? phone,  String? email,  int? vipPoint,  int? vip,  String? avatar,  int? gender,  String? birthDay,  String? brand)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserInfoModel() when $default != null:
return $default(_that.visibleUserName,_that.displayName,_that.gold,_that.chip,_that.safe,_that.visibleUserId,_that.phone,_that.email,_that.vipPoint,_that.vip,_that.avatar,_that.gender,_that.birthDay,_that.brand);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? visibleUserName,  String? displayName,  int? gold,  int? chip,  int? safe,  String? visibleUserId,  String? phone,  String? email,  int? vipPoint,  int? vip,  String? avatar,  int? gender,  String? birthDay,  String? brand)  $default,) {final _that = this;
switch (_that) {
case _UserInfoModel():
return $default(_that.visibleUserName,_that.displayName,_that.gold,_that.chip,_that.safe,_that.visibleUserId,_that.phone,_that.email,_that.vipPoint,_that.vip,_that.avatar,_that.gender,_that.birthDay,_that.brand);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? visibleUserName,  String? displayName,  int? gold,  int? chip,  int? safe,  String? visibleUserId,  String? phone,  String? email,  int? vipPoint,  int? vip,  String? avatar,  int? gender,  String? birthDay,  String? brand)?  $default,) {final _that = this;
switch (_that) {
case _UserInfoModel() when $default != null:
return $default(_that.visibleUserName,_that.displayName,_that.gold,_that.chip,_that.safe,_that.visibleUserId,_that.phone,_that.email,_that.vipPoint,_that.vip,_that.avatar,_that.gender,_that.birthDay,_that.brand);case _:
  return null;

}
}

}

@JsonSerializable()

class _UserInfoModel extends UserInfoModel {
  const _UserInfoModel({this.visibleUserName, this.displayName, this.gold, this.chip, this.safe, this.visibleUserId, this.phone, this.email, this.vipPoint, this.vip, this.avatar, this.gender, this.birthDay, this.brand}): super._();
  factory _UserInfoModel.fromJson(Map<String, dynamic> json) => _$UserInfoModelFromJson(json);

@override final  String? visibleUserName;
@override final  String? displayName;
@override final  int? gold;
@override final  int? chip;
@override final  int? safe;
@override final  String? visibleUserId;
@override final  String? phone;
@override final  String? email;
@override final  int? vipPoint;
@override final  int? vip;
@override final  String? avatar;
@override final  int? gender;
@override final  String? birthDay;
@override final  String? brand;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserInfoModelCopyWith<_UserInfoModel> get copyWith => __$UserInfoModelCopyWithImpl<_UserInfoModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserInfoModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserInfoModel&&(identical(other.visibleUserName, visibleUserName) || other.visibleUserName == visibleUserName)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.gold, gold) || other.gold == gold)&&(identical(other.chip, chip) || other.chip == chip)&&(identical(other.safe, safe) || other.safe == safe)&&(identical(other.visibleUserId, visibleUserId) || other.visibleUserId == visibleUserId)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.vipPoint, vipPoint) || other.vipPoint == vipPoint)&&(identical(other.vip, vip) || other.vip == vip)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.birthDay, birthDay) || other.birthDay == birthDay)&&(identical(other.brand, brand) || other.brand == brand));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,visibleUserName,displayName,gold,chip,safe,visibleUserId,phone,email,vipPoint,vip,avatar,gender,birthDay,brand);

@override
String toString() {
  return 'UserInfoModel(visibleUserName: $visibleUserName, displayName: $displayName, gold: $gold, chip: $chip, safe: $safe, visibleUserId: $visibleUserId, phone: $phone, email: $email, vipPoint: $vipPoint, vip: $vip, avatar: $avatar, gender: $gender, birthDay: $birthDay, brand: $brand)';
}

}

abstract mixin class _$UserInfoModelCopyWith<$Res> implements $UserInfoModelCopyWith<$Res> {
  factory _$UserInfoModelCopyWith(_UserInfoModel value, $Res Function(_UserInfoModel) _then) = __$UserInfoModelCopyWithImpl;
@override @useResult
$Res call({
 String? visibleUserName, String? displayName, int? gold, int? chip, int? safe, String? visibleUserId, String? phone, String? email, int? vipPoint, int? vip, String? avatar, int? gender, String? birthDay, String? brand
});

}
class __$UserInfoModelCopyWithImpl<$Res>
    implements _$UserInfoModelCopyWith<$Res> {
  __$UserInfoModelCopyWithImpl(this._self, this._then);

  final _UserInfoModel _self;
  final $Res Function(_UserInfoModel) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? visibleUserName = freezed,Object? displayName = freezed,Object? gold = freezed,Object? chip = freezed,Object? safe = freezed,Object? visibleUserId = freezed,Object? phone = freezed,Object? email = freezed,Object? vipPoint = freezed,Object? vip = freezed,Object? avatar = freezed,Object? gender = freezed,Object? birthDay = freezed,Object? brand = freezed,}) {
  return _then(_UserInfoModel(
visibleUserName: freezed == visibleUserName ? _self.visibleUserName : visibleUserName // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,gold: freezed == gold ? _self.gold : gold // ignore: cast_nullable_to_non_nullable
as int?,chip: freezed == chip ? _self.chip : chip // ignore: cast_nullable_to_non_nullable
as int?,safe: freezed == safe ? _self.safe : safe // ignore: cast_nullable_to_non_nullable
as int?,visibleUserId: freezed == visibleUserId ? _self.visibleUserId : visibleUserId // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,vipPoint: freezed == vipPoint ? _self.vipPoint : vipPoint // ignore: cast_nullable_to_non_nullable
as int?,vip: freezed == vip ? _self.vip : vip // ignore: cast_nullable_to_non_nullable
as int?,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as int?,birthDay: freezed == birthDay ? _self.birthDay : birthDay // ignore: cast_nullable_to_non_nullable
as String?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}

mixin _$LoginRequestModel {

 String get username; String get password;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginRequestModelCopyWith<LoginRequestModel> get copyWith => _$LoginRequestModelCopyWithImpl<LoginRequestModel>(this as LoginRequestModel, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginRequestModel&&(identical(other.username, username) || other.username == username)&&(identical(other.password, password) || other.password == password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,username,password);

@override
String toString() {
  return 'LoginRequestModel(username: $username, password: $password)';
}

}

abstract mixin class $LoginRequestModelCopyWith<$Res>  {
  factory $LoginRequestModelCopyWith(LoginRequestModel value, $Res Function(LoginRequestModel) _then) = _$LoginRequestModelCopyWithImpl;
@useResult
$Res call({
 String username, String password
});

}
class _$LoginRequestModelCopyWithImpl<$Res>
    implements $LoginRequestModelCopyWith<$Res> {
  _$LoginRequestModelCopyWithImpl(this._self, this._then);

  final LoginRequestModel _self;
  final $Res Function(LoginRequestModel) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? username = null,Object? password = null,}) {
  return _then(_self.copyWith(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}

extension LoginRequestModelPatterns on LoginRequestModel {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoginRequestModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoginRequestModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoginRequestModel value)  $default,){
final _that = this;
switch (_that) {
case _LoginRequestModel():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoginRequestModel value)?  $default,){
final _that = this;
switch (_that) {
case _LoginRequestModel() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String username,  String password)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoginRequestModel() when $default != null:
return $default(_that.username,_that.password);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String username,  String password)  $default,) {final _that = this;
switch (_that) {
case _LoginRequestModel():
return $default(_that.username,_that.password);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String username,  String password)?  $default,) {final _that = this;
switch (_that) {
case _LoginRequestModel() when $default != null:
return $default(_that.username,_that.password);case _:
  return null;

}
}

}

@JsonSerializable()

class _LoginRequestModel extends LoginRequestModel {
  const _LoginRequestModel({required this.username, required this.password}): super._();
  factory _LoginRequestModel.fromJson(Map<String, dynamic> json) => _$LoginRequestModelFromJson(json);

@override final  String username;
@override final  String password;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginRequestModelCopyWith<_LoginRequestModel> get copyWith => __$LoginRequestModelCopyWithImpl<_LoginRequestModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LoginRequestModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoginRequestModel&&(identical(other.username, username) || other.username == username)&&(identical(other.password, password) || other.password == password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,username,password);

@override
String toString() {
  return 'LoginRequestModel(username: $username, password: $password)';
}

}

abstract mixin class _$LoginRequestModelCopyWith<$Res> implements $LoginRequestModelCopyWith<$Res> {
  factory _$LoginRequestModelCopyWith(_LoginRequestModel value, $Res Function(_LoginRequestModel) _then) = __$LoginRequestModelCopyWithImpl;
@override @useResult
$Res call({
 String username, String password
});

}
class __$LoginRequestModelCopyWithImpl<$Res>
    implements _$LoginRequestModelCopyWith<$Res> {
  __$LoginRequestModelCopyWithImpl(this._self, this._then);

  final _LoginRequestModel _self;
  final $Res Function(_LoginRequestModel) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? username = null,Object? password = null,}) {
  return _then(_LoginRequestModel(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}

mixin _$RegisterRequestModel {

 String get username; String get password; String get displayName; String? get affId; String? get utmSource; String? get utmMedium; String? get utmCampaign; String? get utmContent; String? get utmTerm;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterRequestModelCopyWith<RegisterRequestModel> get copyWith => _$RegisterRequestModelCopyWithImpl<RegisterRequestModel>(this as RegisterRequestModel, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterRequestModel&&(identical(other.username, username) || other.username == username)&&(identical(other.password, password) || other.password == password)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.affId, affId) || other.affId == affId)&&(identical(other.utmSource, utmSource) || other.utmSource == utmSource)&&(identical(other.utmMedium, utmMedium) || other.utmMedium == utmMedium)&&(identical(other.utmCampaign, utmCampaign) || other.utmCampaign == utmCampaign)&&(identical(other.utmContent, utmContent) || other.utmContent == utmContent)&&(identical(other.utmTerm, utmTerm) || other.utmTerm == utmTerm));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,username,password,displayName,affId,utmSource,utmMedium,utmCampaign,utmContent,utmTerm);

@override
String toString() {
  return 'RegisterRequestModel(username: $username, password: $password, displayName: $displayName, affId: $affId, utmSource: $utmSource, utmMedium: $utmMedium, utmCampaign: $utmCampaign, utmContent: $utmContent, utmTerm: $utmTerm)';
}

}

abstract mixin class $RegisterRequestModelCopyWith<$Res>  {
  factory $RegisterRequestModelCopyWith(RegisterRequestModel value, $Res Function(RegisterRequestModel) _then) = _$RegisterRequestModelCopyWithImpl;
@useResult
$Res call({
 String username, String password, String displayName, String? affId, String? utmSource, String? utmMedium, String? utmCampaign, String? utmContent, String? utmTerm
});

}
class _$RegisterRequestModelCopyWithImpl<$Res>
    implements $RegisterRequestModelCopyWith<$Res> {
  _$RegisterRequestModelCopyWithImpl(this._self, this._then);

  final RegisterRequestModel _self;
  final $Res Function(RegisterRequestModel) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? username = null,Object? password = null,Object? displayName = null,Object? affId = freezed,Object? utmSource = freezed,Object? utmMedium = freezed,Object? utmCampaign = freezed,Object? utmContent = freezed,Object? utmTerm = freezed,}) {
  return _then(_self.copyWith(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,affId: freezed == affId ? _self.affId : affId // ignore: cast_nullable_to_non_nullable
as String?,utmSource: freezed == utmSource ? _self.utmSource : utmSource // ignore: cast_nullable_to_non_nullable
as String?,utmMedium: freezed == utmMedium ? _self.utmMedium : utmMedium // ignore: cast_nullable_to_non_nullable
as String?,utmCampaign: freezed == utmCampaign ? _self.utmCampaign : utmCampaign // ignore: cast_nullable_to_non_nullable
as String?,utmContent: freezed == utmContent ? _self.utmContent : utmContent // ignore: cast_nullable_to_non_nullable
as String?,utmTerm: freezed == utmTerm ? _self.utmTerm : utmTerm // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}

extension RegisterRequestModelPatterns on RegisterRequestModel {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegisterRequestModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegisterRequestModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegisterRequestModel value)  $default,){
final _that = this;
switch (_that) {
case _RegisterRequestModel():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegisterRequestModel value)?  $default,){
final _that = this;
switch (_that) {
case _RegisterRequestModel() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String username,  String password,  String displayName,  String? affId,  String? utmSource,  String? utmMedium,  String? utmCampaign,  String? utmContent,  String? utmTerm)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegisterRequestModel() when $default != null:
return $default(_that.username,_that.password,_that.displayName,_that.affId,_that.utmSource,_that.utmMedium,_that.utmCampaign,_that.utmContent,_that.utmTerm);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String username,  String password,  String displayName,  String? affId,  String? utmSource,  String? utmMedium,  String? utmCampaign,  String? utmContent,  String? utmTerm)  $default,) {final _that = this;
switch (_that) {
case _RegisterRequestModel():
return $default(_that.username,_that.password,_that.displayName,_that.affId,_that.utmSource,_that.utmMedium,_that.utmCampaign,_that.utmContent,_that.utmTerm);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String username,  String password,  String displayName,  String? affId,  String? utmSource,  String? utmMedium,  String? utmCampaign,  String? utmContent,  String? utmTerm)?  $default,) {final _that = this;
switch (_that) {
case _RegisterRequestModel() when $default != null:
return $default(_that.username,_that.password,_that.displayName,_that.affId,_that.utmSource,_that.utmMedium,_that.utmCampaign,_that.utmContent,_that.utmTerm);case _:
  return null;

}
}

}

@JsonSerializable()

class _RegisterRequestModel extends RegisterRequestModel {
  const _RegisterRequestModel({required this.username, required this.password, required this.displayName, this.affId, this.utmSource, this.utmMedium, this.utmCampaign, this.utmContent, this.utmTerm}): super._();
  factory _RegisterRequestModel.fromJson(Map<String, dynamic> json) => _$RegisterRequestModelFromJson(json);

@override final  String username;
@override final  String password;
@override final  String displayName;
@override final  String? affId;
@override final  String? utmSource;
@override final  String? utmMedium;
@override final  String? utmCampaign;
@override final  String? utmContent;
@override final  String? utmTerm;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisterRequestModelCopyWith<_RegisterRequestModel> get copyWith => __$RegisterRequestModelCopyWithImpl<_RegisterRequestModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RegisterRequestModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisterRequestModel&&(identical(other.username, username) || other.username == username)&&(identical(other.password, password) || other.password == password)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.affId, affId) || other.affId == affId)&&(identical(other.utmSource, utmSource) || other.utmSource == utmSource)&&(identical(other.utmMedium, utmMedium) || other.utmMedium == utmMedium)&&(identical(other.utmCampaign, utmCampaign) || other.utmCampaign == utmCampaign)&&(identical(other.utmContent, utmContent) || other.utmContent == utmContent)&&(identical(other.utmTerm, utmTerm) || other.utmTerm == utmTerm));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,username,password,displayName,affId,utmSource,utmMedium,utmCampaign,utmContent,utmTerm);

@override
String toString() {
  return 'RegisterRequestModel(username: $username, password: $password, displayName: $displayName, affId: $affId, utmSource: $utmSource, utmMedium: $utmMedium, utmCampaign: $utmCampaign, utmContent: $utmContent, utmTerm: $utmTerm)';
}

}

abstract mixin class _$RegisterRequestModelCopyWith<$Res> implements $RegisterRequestModelCopyWith<$Res> {
  factory _$RegisterRequestModelCopyWith(_RegisterRequestModel value, $Res Function(_RegisterRequestModel) _then) = __$RegisterRequestModelCopyWithImpl;
@override @useResult
$Res call({
 String username, String password, String displayName, String? affId, String? utmSource, String? utmMedium, String? utmCampaign, String? utmContent, String? utmTerm
});

}
class __$RegisterRequestModelCopyWithImpl<$Res>
    implements _$RegisterRequestModelCopyWith<$Res> {
  __$RegisterRequestModelCopyWithImpl(this._self, this._then);

  final _RegisterRequestModel _self;
  final $Res Function(_RegisterRequestModel) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? username = null,Object? password = null,Object? displayName = null,Object? affId = freezed,Object? utmSource = freezed,Object? utmMedium = freezed,Object? utmCampaign = freezed,Object? utmContent = freezed,Object? utmTerm = freezed,}) {
  return _then(_RegisterRequestModel(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,affId: freezed == affId ? _self.affId : affId // ignore: cast_nullable_to_non_nullable
as String?,utmSource: freezed == utmSource ? _self.utmSource : utmSource // ignore: cast_nullable_to_non_nullable
as String?,utmMedium: freezed == utmMedium ? _self.utmMedium : utmMedium // ignore: cast_nullable_to_non_nullable
as String?,utmCampaign: freezed == utmCampaign ? _self.utmCampaign : utmCampaign // ignore: cast_nullable_to_non_nullable
as String?,utmContent: freezed == utmContent ? _self.utmContent : utmContent // ignore: cast_nullable_to_non_nullable
as String?,utmTerm: freezed == utmTerm ? _self.utmTerm : utmTerm // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}

mixin _$OtpRequestModel {

 String get sessionId; String get otp; String get username; String get password;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OtpRequestModelCopyWith<OtpRequestModel> get copyWith => _$OtpRequestModelCopyWithImpl<OtpRequestModel>(this as OtpRequestModel, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OtpRequestModel&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.otp, otp) || other.otp == otp)&&(identical(other.username, username) || other.username == username)&&(identical(other.password, password) || other.password == password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sessionId,otp,username,password);

@override
String toString() {
  return 'OtpRequestModel(sessionId: $sessionId, otp: $otp, username: $username, password: $password)';
}

}

abstract mixin class $OtpRequestModelCopyWith<$Res>  {
  factory $OtpRequestModelCopyWith(OtpRequestModel value, $Res Function(OtpRequestModel) _then) = _$OtpRequestModelCopyWithImpl;
@useResult
$Res call({
 String sessionId, String otp, String username, String password
});

}
class _$OtpRequestModelCopyWithImpl<$Res>
    implements $OtpRequestModelCopyWith<$Res> {
  _$OtpRequestModelCopyWithImpl(this._self, this._then);

  final OtpRequestModel _self;
  final $Res Function(OtpRequestModel) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? sessionId = null,Object? otp = null,Object? username = null,Object? password = null,}) {
  return _then(_self.copyWith(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,otp: null == otp ? _self.otp : otp // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}

extension OtpRequestModelPatterns on OtpRequestModel {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OtpRequestModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OtpRequestModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OtpRequestModel value)  $default,){
final _that = this;
switch (_that) {
case _OtpRequestModel():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OtpRequestModel value)?  $default,){
final _that = this;
switch (_that) {
case _OtpRequestModel() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String sessionId,  String otp,  String username,  String password)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OtpRequestModel() when $default != null:
return $default(_that.sessionId,_that.otp,_that.username,_that.password);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String sessionId,  String otp,  String username,  String password)  $default,) {final _that = this;
switch (_that) {
case _OtpRequestModel():
return $default(_that.sessionId,_that.otp,_that.username,_that.password);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String sessionId,  String otp,  String username,  String password)?  $default,) {final _that = this;
switch (_that) {
case _OtpRequestModel() when $default != null:
return $default(_that.sessionId,_that.otp,_that.username,_that.password);case _:
  return null;

}
}

}

@JsonSerializable()

class _OtpRequestModel extends OtpRequestModel {
  const _OtpRequestModel({required this.sessionId, required this.otp, required this.username, required this.password}): super._();
  factory _OtpRequestModel.fromJson(Map<String, dynamic> json) => _$OtpRequestModelFromJson(json);

@override final  String sessionId;
@override final  String otp;
@override final  String username;
@override final  String password;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OtpRequestModelCopyWith<_OtpRequestModel> get copyWith => __$OtpRequestModelCopyWithImpl<_OtpRequestModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OtpRequestModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OtpRequestModel&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.otp, otp) || other.otp == otp)&&(identical(other.username, username) || other.username == username)&&(identical(other.password, password) || other.password == password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sessionId,otp,username,password);

@override
String toString() {
  return 'OtpRequestModel(sessionId: $sessionId, otp: $otp, username: $username, password: $password)';
}

}

abstract mixin class _$OtpRequestModelCopyWith<$Res> implements $OtpRequestModelCopyWith<$Res> {
  factory _$OtpRequestModelCopyWith(_OtpRequestModel value, $Res Function(_OtpRequestModel) _then) = __$OtpRequestModelCopyWithImpl;
@override @useResult
$Res call({
 String sessionId, String otp, String username, String password
});

}
class __$OtpRequestModelCopyWithImpl<$Res>
    implements _$OtpRequestModelCopyWith<$Res> {
  __$OtpRequestModelCopyWithImpl(this._self, this._then);

  final _OtpRequestModel _self;
  final $Res Function(_OtpRequestModel) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? sessionId = null,Object? otp = null,Object? username = null,Object? password = null,}) {
  return _then(_OtpRequestModel(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,otp: null == otp ? _self.otp : otp // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}

// dart format on
