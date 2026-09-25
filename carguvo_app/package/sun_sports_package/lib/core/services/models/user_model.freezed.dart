// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// dart format off
T _$identity<T>(T value) => value;

mixin _$UserModel {

@JsonKey(name: 'uid') String get uid;@JsonKey(name: 'displayName') String get displayName;@JsonKey(name: 'cust_login') String get custLogin;@JsonKey(name: 'cust_id') String get custId;@JsonKey(name: 'balance', fromJson: _parseBalance) double get balance;@JsonKey(name: 'currency') String get currency;@JsonKey(name: 'status') String get status;@JsonKey(name: 'email') String? get email;@JsonKey(name: 'phone') String? get phone;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserModelCopyWith<UserModel> get copyWith => _$UserModelCopyWithImpl<UserModel>(this as UserModel, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.custLogin, custLogin) || other.custLogin == custLogin)&&(identical(other.custId, custId) || other.custId == custId)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,displayName,custLogin,custId,balance,currency,status,email,phone);

@override
String toString() {
  return 'UserModel(uid: $uid, displayName: $displayName, custLogin: $custLogin, custId: $custId, balance: $balance, currency: $currency, status: $status, email: $email, phone: $phone)';
}

}

abstract mixin class $UserModelCopyWith<$Res>  {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) _then) = _$UserModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'displayName') String displayName,@JsonKey(name: 'cust_login') String custLogin,@JsonKey(name: 'cust_id') String custId,@JsonKey(name: 'balance', fromJson: _parseBalance) double balance,@JsonKey(name: 'currency') String currency,@JsonKey(name: 'status') String status,@JsonKey(name: 'email') String? email,@JsonKey(name: 'phone') String? phone
});

}
class _$UserModelCopyWithImpl<$Res>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._self, this._then);

  final UserModel _self;
  final $Res Function(UserModel) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? displayName = null,Object? custLogin = null,Object? custId = null,Object? balance = null,Object? currency = null,Object? status = null,Object? email = freezed,Object? phone = freezed,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,custLogin: null == custLogin ? _self.custLogin : custLogin // ignore: cast_nullable_to_non_nullable
as String,custId: null == custId ? _self.custId : custId // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}

extension UserModelPatterns on UserModel {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserModel value)  $default,){
final _that = this;
switch (_that) {
case _UserModel():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'displayName')  String displayName, @JsonKey(name: 'cust_login')  String custLogin, @JsonKey(name: 'cust_id')  String custId, @JsonKey(name: 'balance', fromJson: _parseBalance)  double balance, @JsonKey(name: 'currency')  String currency, @JsonKey(name: 'status')  String status, @JsonKey(name: 'email')  String? email, @JsonKey(name: 'phone')  String? phone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.uid,_that.displayName,_that.custLogin,_that.custId,_that.balance,_that.currency,_that.status,_that.email,_that.phone);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'displayName')  String displayName, @JsonKey(name: 'cust_login')  String custLogin, @JsonKey(name: 'cust_id')  String custId, @JsonKey(name: 'balance', fromJson: _parseBalance)  double balance, @JsonKey(name: 'currency')  String currency, @JsonKey(name: 'status')  String status, @JsonKey(name: 'email')  String? email, @JsonKey(name: 'phone')  String? phone)  $default,) {final _that = this;
switch (_that) {
case _UserModel():
return $default(_that.uid,_that.displayName,_that.custLogin,_that.custId,_that.balance,_that.currency,_that.status,_that.email,_that.phone);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'displayName')  String displayName, @JsonKey(name: 'cust_login')  String custLogin, @JsonKey(name: 'cust_id')  String custId, @JsonKey(name: 'balance', fromJson: _parseBalance)  double balance, @JsonKey(name: 'currency')  String currency, @JsonKey(name: 'status')  String status, @JsonKey(name: 'email')  String? email, @JsonKey(name: 'phone')  String? phone)?  $default,) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.uid,_that.displayName,_that.custLogin,_that.custId,_that.balance,_that.currency,_that.status,_that.email,_that.phone);case _:
  return null;

}
}

}

@JsonSerializable()

class _UserModel extends UserModel {
  const _UserModel({@JsonKey(name: 'uid') required this.uid, @JsonKey(name: 'displayName') required this.displayName, @JsonKey(name: 'cust_login') required this.custLogin, @JsonKey(name: 'cust_id') required this.custId, @JsonKey(name: 'balance', fromJson: _parseBalance) required this.balance, @JsonKey(name: 'currency') this.currency = 'VND', @JsonKey(name: 'status') this.status = 'Active', @JsonKey(name: 'email') this.email, @JsonKey(name: 'phone') this.phone}): super._();
  factory _UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

@override@JsonKey(name: 'uid') final  String uid;
@override@JsonKey(name: 'displayName') final  String displayName;
@override@JsonKey(name: 'cust_login') final  String custLogin;
@override@JsonKey(name: 'cust_id') final  String custId;
@override@JsonKey(name: 'balance', fromJson: _parseBalance) final  double balance;
@override@JsonKey(name: 'currency') final  String currency;
@override@JsonKey(name: 'status') final  String status;
@override@JsonKey(name: 'email') final  String? email;
@override@JsonKey(name: 'phone') final  String? phone;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserModelCopyWith<_UserModel> get copyWith => __$UserModelCopyWithImpl<_UserModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.custLogin, custLogin) || other.custLogin == custLogin)&&(identical(other.custId, custId) || other.custId == custId)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,displayName,custLogin,custId,balance,currency,status,email,phone);

@override
String toString() {
  return 'UserModel(uid: $uid, displayName: $displayName, custLogin: $custLogin, custId: $custId, balance: $balance, currency: $currency, status: $status, email: $email, phone: $phone)';
}

}

abstract mixin class _$UserModelCopyWith<$Res> implements $UserModelCopyWith<$Res> {
  factory _$UserModelCopyWith(_UserModel value, $Res Function(_UserModel) _then) = __$UserModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'displayName') String displayName,@JsonKey(name: 'cust_login') String custLogin,@JsonKey(name: 'cust_id') String custId,@JsonKey(name: 'balance', fromJson: _parseBalance) double balance,@JsonKey(name: 'currency') String currency,@JsonKey(name: 'status') String status,@JsonKey(name: 'email') String? email,@JsonKey(name: 'phone') String? phone
});

}
class __$UserModelCopyWithImpl<$Res>
    implements _$UserModelCopyWith<$Res> {
  __$UserModelCopyWithImpl(this._self, this._then);

  final _UserModel _self;
  final $Res Function(_UserModel) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? displayName = null,Object? custLogin = null,Object? custId = null,Object? balance = null,Object? currency = null,Object? status = null,Object? email = freezed,Object? phone = freezed,}) {
  return _then(_UserModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,custLogin: null == custLogin ? _self.custLogin : custLogin // ignore: cast_nullable_to_non_nullable
as String,custId: null == custId ? _self.custId : custId // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}

// dart format on
