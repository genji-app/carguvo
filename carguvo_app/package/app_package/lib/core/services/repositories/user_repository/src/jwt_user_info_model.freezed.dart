// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'jwt_user_info_model.dart';

// dart format off
T _$identity<T>(T value) => value;

mixin _$JwtUserInfoModel {

 String get userId; String get username; String get displayName; String get avatar; String get brand; int get customerId; int get platformId;@JsonKey(fromJson: _toNum) num get amount;
 int get gender;
@JsonKey(fromJson: _intToBool) bool get banned;@JsonKey(fromJson: _intToBool) bool get bot;@JsonKey(fromJson: _intToBool) bool get lockChat;@JsonKey(fromJson: _intToBool) bool get mute;@JsonKey(fromJson: _intToBool) bool get phoneVerified;@JsonKey(fromJson: _intToBool) bool get deposit;@JsonKey(fromJson: _intToBool) bool get verifiedBankAccount;@JsonKey(fromJson: _intToBool) bool get canViewStat;@JsonKey(fromJson: _intToBool) bool get isMerchant;@JsonKey(fromJson: _intToBool) bool get playEventLobby; List<dynamic> get lockGames;
@JsonKey(fromJson: _phoneToString) String? get phone; String? get affId; String? get ipAddress; int? get timestamp; int? get regTime;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JwtUserInfoModelCopyWith<JwtUserInfoModel> get copyWith => _$JwtUserInfoModelCopyWithImpl<JwtUserInfoModel>(this as JwtUserInfoModel, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JwtUserInfoModel&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.platformId, platformId) || other.platformId == platformId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.banned, banned) || other.banned == banned)&&(identical(other.bot, bot) || other.bot == bot)&&(identical(other.lockChat, lockChat) || other.lockChat == lockChat)&&(identical(other.mute, mute) || other.mute == mute)&&(identical(other.phoneVerified, phoneVerified) || other.phoneVerified == phoneVerified)&&(identical(other.deposit, deposit) || other.deposit == deposit)&&(identical(other.verifiedBankAccount, verifiedBankAccount) || other.verifiedBankAccount == verifiedBankAccount)&&(identical(other.canViewStat, canViewStat) || other.canViewStat == canViewStat)&&(identical(other.isMerchant, isMerchant) || other.isMerchant == isMerchant)&&(identical(other.playEventLobby, playEventLobby) || other.playEventLobby == playEventLobby)&&const DeepCollectionEquality().equals(other.lockGames, lockGames)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.affId, affId) || other.affId == affId)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.regTime, regTime) || other.regTime == regTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,userId,username,displayName,avatar,brand,customerId,platformId,amount,gender,banned,bot,lockChat,mute,phoneVerified,deposit,verifiedBankAccount,canViewStat,isMerchant,playEventLobby,const DeepCollectionEquality().hash(lockGames),phone,affId,ipAddress,timestamp,regTime]);

@override
String toString() {
  return 'JwtUserInfoModel(userId: $userId, username: $username, displayName: $displayName, avatar: $avatar, brand: $brand, customerId: $customerId, platformId: $platformId, amount: $amount, gender: $gender, banned: $banned, bot: $bot, lockChat: $lockChat, mute: $mute, phoneVerified: $phoneVerified, deposit: $deposit, verifiedBankAccount: $verifiedBankAccount, canViewStat: $canViewStat, isMerchant: $isMerchant, playEventLobby: $playEventLobby, lockGames: $lockGames, phone: $phone, affId: $affId, ipAddress: $ipAddress, timestamp: $timestamp, regTime: $regTime)';
}

}

abstract mixin class $JwtUserInfoModelCopyWith<$Res>  {
  factory $JwtUserInfoModelCopyWith(JwtUserInfoModel value, $Res Function(JwtUserInfoModel) _then) = _$JwtUserInfoModelCopyWithImpl;
@useResult
$Res call({
 String userId, String username, String displayName, String avatar, String brand, int customerId, int platformId,@JsonKey(fromJson: _toNum) num amount, int gender,@JsonKey(fromJson: _intToBool) bool banned,@JsonKey(fromJson: _intToBool) bool bot,@JsonKey(fromJson: _intToBool) bool lockChat,@JsonKey(fromJson: _intToBool) bool mute,@JsonKey(fromJson: _intToBool) bool phoneVerified,@JsonKey(fromJson: _intToBool) bool deposit,@JsonKey(fromJson: _intToBool) bool verifiedBankAccount,@JsonKey(fromJson: _intToBool) bool canViewStat,@JsonKey(fromJson: _intToBool) bool isMerchant,@JsonKey(fromJson: _intToBool) bool playEventLobby, List<dynamic> lockGames,@JsonKey(fromJson: _phoneToString) String? phone, String? affId, String? ipAddress, int? timestamp, int? regTime
});

}
class _$JwtUserInfoModelCopyWithImpl<$Res>
    implements $JwtUserInfoModelCopyWith<$Res> {
  _$JwtUserInfoModelCopyWithImpl(this._self, this._then);

  final JwtUserInfoModel _self;
  final $Res Function(JwtUserInfoModel) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? username = null,Object? displayName = null,Object? avatar = null,Object? brand = null,Object? customerId = null,Object? platformId = null,Object? amount = null,Object? gender = null,Object? banned = null,Object? bot = null,Object? lockChat = null,Object? mute = null,Object? phoneVerified = null,Object? deposit = null,Object? verifiedBankAccount = null,Object? canViewStat = null,Object? isMerchant = null,Object? playEventLobby = null,Object? lockGames = null,Object? phone = freezed,Object? affId = freezed,Object? ipAddress = freezed,Object? timestamp = freezed,Object? regTime = freezed,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatar: null == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int,platformId: null == platformId ? _self.platformId : platformId // ignore: cast_nullable_to_non_nullable
as int,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as num,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as int,banned: null == banned ? _self.banned : banned // ignore: cast_nullable_to_non_nullable
as bool,bot: null == bot ? _self.bot : bot // ignore: cast_nullable_to_non_nullable
as bool,lockChat: null == lockChat ? _self.lockChat : lockChat // ignore: cast_nullable_to_non_nullable
as bool,mute: null == mute ? _self.mute : mute // ignore: cast_nullable_to_non_nullable
as bool,phoneVerified: null == phoneVerified ? _self.phoneVerified : phoneVerified // ignore: cast_nullable_to_non_nullable
as bool,deposit: null == deposit ? _self.deposit : deposit // ignore: cast_nullable_to_non_nullable
as bool,verifiedBankAccount: null == verifiedBankAccount ? _self.verifiedBankAccount : verifiedBankAccount // ignore: cast_nullable_to_non_nullable
as bool,canViewStat: null == canViewStat ? _self.canViewStat : canViewStat // ignore: cast_nullable_to_non_nullable
as bool,isMerchant: null == isMerchant ? _self.isMerchant : isMerchant // ignore: cast_nullable_to_non_nullable
as bool,playEventLobby: null == playEventLobby ? _self.playEventLobby : playEventLobby // ignore: cast_nullable_to_non_nullable
as bool,lockGames: null == lockGames ? _self.lockGames : lockGames // ignore: cast_nullable_to_non_nullable
as List<dynamic>,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,affId: freezed == affId ? _self.affId : affId // ignore: cast_nullable_to_non_nullable
as String?,ipAddress: freezed == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String?,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as int?,regTime: freezed == regTime ? _self.regTime : regTime // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}

extension JwtUserInfoModelPatterns on JwtUserInfoModel {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JwtUserInfoModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JwtUserInfoModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JwtUserInfoModel value)  $default,){
final _that = this;
switch (_that) {
case _JwtUserInfoModel():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JwtUserInfoModel value)?  $default,){
final _that = this;
switch (_that) {
case _JwtUserInfoModel() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String username,  String displayName,  String avatar,  String brand,  int customerId,  int platformId, @JsonKey(fromJson: _toNum)  num amount,  int gender, @JsonKey(fromJson: _intToBool)  bool banned, @JsonKey(fromJson: _intToBool)  bool bot, @JsonKey(fromJson: _intToBool)  bool lockChat, @JsonKey(fromJson: _intToBool)  bool mute, @JsonKey(fromJson: _intToBool)  bool phoneVerified, @JsonKey(fromJson: _intToBool)  bool deposit, @JsonKey(fromJson: _intToBool)  bool verifiedBankAccount, @JsonKey(fromJson: _intToBool)  bool canViewStat, @JsonKey(fromJson: _intToBool)  bool isMerchant, @JsonKey(fromJson: _intToBool)  bool playEventLobby,  List<dynamic> lockGames, @JsonKey(fromJson: _phoneToString)  String? phone,  String? affId,  String? ipAddress,  int? timestamp,  int? regTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JwtUserInfoModel() when $default != null:
return $default(_that.userId,_that.username,_that.displayName,_that.avatar,_that.brand,_that.customerId,_that.platformId,_that.amount,_that.gender,_that.banned,_that.bot,_that.lockChat,_that.mute,_that.phoneVerified,_that.deposit,_that.verifiedBankAccount,_that.canViewStat,_that.isMerchant,_that.playEventLobby,_that.lockGames,_that.phone,_that.affId,_that.ipAddress,_that.timestamp,_that.regTime);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String username,  String displayName,  String avatar,  String brand,  int customerId,  int platformId, @JsonKey(fromJson: _toNum)  num amount,  int gender, @JsonKey(fromJson: _intToBool)  bool banned, @JsonKey(fromJson: _intToBool)  bool bot, @JsonKey(fromJson: _intToBool)  bool lockChat, @JsonKey(fromJson: _intToBool)  bool mute, @JsonKey(fromJson: _intToBool)  bool phoneVerified, @JsonKey(fromJson: _intToBool)  bool deposit, @JsonKey(fromJson: _intToBool)  bool verifiedBankAccount, @JsonKey(fromJson: _intToBool)  bool canViewStat, @JsonKey(fromJson: _intToBool)  bool isMerchant, @JsonKey(fromJson: _intToBool)  bool playEventLobby,  List<dynamic> lockGames, @JsonKey(fromJson: _phoneToString)  String? phone,  String? affId,  String? ipAddress,  int? timestamp,  int? regTime)  $default,) {final _that = this;
switch (_that) {
case _JwtUserInfoModel():
return $default(_that.userId,_that.username,_that.displayName,_that.avatar,_that.brand,_that.customerId,_that.platformId,_that.amount,_that.gender,_that.banned,_that.bot,_that.lockChat,_that.mute,_that.phoneVerified,_that.deposit,_that.verifiedBankAccount,_that.canViewStat,_that.isMerchant,_that.playEventLobby,_that.lockGames,_that.phone,_that.affId,_that.ipAddress,_that.timestamp,_that.regTime);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String username,  String displayName,  String avatar,  String brand,  int customerId,  int platformId, @JsonKey(fromJson: _toNum)  num amount,  int gender, @JsonKey(fromJson: _intToBool)  bool banned, @JsonKey(fromJson: _intToBool)  bool bot, @JsonKey(fromJson: _intToBool)  bool lockChat, @JsonKey(fromJson: _intToBool)  bool mute, @JsonKey(fromJson: _intToBool)  bool phoneVerified, @JsonKey(fromJson: _intToBool)  bool deposit, @JsonKey(fromJson: _intToBool)  bool verifiedBankAccount, @JsonKey(fromJson: _intToBool)  bool canViewStat, @JsonKey(fromJson: _intToBool)  bool isMerchant, @JsonKey(fromJson: _intToBool)  bool playEventLobby,  List<dynamic> lockGames, @JsonKey(fromJson: _phoneToString)  String? phone,  String? affId,  String? ipAddress,  int? timestamp,  int? regTime)?  $default,) {final _that = this;
switch (_that) {
case _JwtUserInfoModel() when $default != null:
return $default(_that.userId,_that.username,_that.displayName,_that.avatar,_that.brand,_that.customerId,_that.platformId,_that.amount,_that.gender,_that.banned,_that.bot,_that.lockChat,_that.mute,_that.phoneVerified,_that.deposit,_that.verifiedBankAccount,_that.canViewStat,_that.isMerchant,_that.playEventLobby,_that.lockGames,_that.phone,_that.affId,_that.ipAddress,_that.timestamp,_that.regTime);case _:
  return null;

}
}

}

@JsonSerializable()

class _JwtUserInfoModel extends JwtUserInfoModel {
  const _JwtUserInfoModel({required this.userId, required this.username, required this.displayName, required this.avatar, required this.brand, required this.customerId, required this.platformId, @JsonKey(fromJson: _toNum) this.amount = 0, this.gender = 0, @JsonKey(fromJson: _intToBool) this.banned = false, @JsonKey(fromJson: _intToBool) this.bot = false, @JsonKey(fromJson: _intToBool) this.lockChat = false, @JsonKey(fromJson: _intToBool) this.mute = false, @JsonKey(fromJson: _intToBool) this.phoneVerified = false, @JsonKey(fromJson: _intToBool) this.deposit = false, @JsonKey(fromJson: _intToBool) this.verifiedBankAccount = false, @JsonKey(fromJson: _intToBool) this.canViewStat = false, @JsonKey(fromJson: _intToBool) this.isMerchant = false, @JsonKey(fromJson: _intToBool) this.playEventLobby = false, final  List<dynamic> lockGames = const [], @JsonKey(fromJson: _phoneToString) this.phone, this.affId, this.ipAddress, this.timestamp, this.regTime}): _lockGames = lockGames,super._();
  factory _JwtUserInfoModel.fromJson(Map<String, dynamic> json) => _$JwtUserInfoModelFromJson(json);

@override final  String userId;
@override final  String username;
@override final  String displayName;
@override final  String avatar;
@override final  String brand;
@override final  int customerId;
@override final  int platformId;
@override@JsonKey(fromJson: _toNum) final  num amount;
@override@JsonKey() final  int gender;
@override@JsonKey(fromJson: _intToBool) final  bool banned;
@override@JsonKey(fromJson: _intToBool) final  bool bot;
@override@JsonKey(fromJson: _intToBool) final  bool lockChat;
@override@JsonKey(fromJson: _intToBool) final  bool mute;
@override@JsonKey(fromJson: _intToBool) final  bool phoneVerified;
@override@JsonKey(fromJson: _intToBool) final  bool deposit;
@override@JsonKey(fromJson: _intToBool) final  bool verifiedBankAccount;
@override@JsonKey(fromJson: _intToBool) final  bool canViewStat;
@override@JsonKey(fromJson: _intToBool) final  bool isMerchant;
@override@JsonKey(fromJson: _intToBool) final  bool playEventLobby;
 final  List<dynamic> _lockGames;
@override@JsonKey() List<dynamic> get lockGames {
  if (_lockGames is EqualUnmodifiableListView) return _lockGames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lockGames);
}

@override@JsonKey(fromJson: _phoneToString) final  String? phone;
@override final  String? affId;
@override final  String? ipAddress;
@override final  int? timestamp;
@override final  int? regTime;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JwtUserInfoModelCopyWith<_JwtUserInfoModel> get copyWith => __$JwtUserInfoModelCopyWithImpl<_JwtUserInfoModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$JwtUserInfoModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _JwtUserInfoModel&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.platformId, platformId) || other.platformId == platformId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.banned, banned) || other.banned == banned)&&(identical(other.bot, bot) || other.bot == bot)&&(identical(other.lockChat, lockChat) || other.lockChat == lockChat)&&(identical(other.mute, mute) || other.mute == mute)&&(identical(other.phoneVerified, phoneVerified) || other.phoneVerified == phoneVerified)&&(identical(other.deposit, deposit) || other.deposit == deposit)&&(identical(other.verifiedBankAccount, verifiedBankAccount) || other.verifiedBankAccount == verifiedBankAccount)&&(identical(other.canViewStat, canViewStat) || other.canViewStat == canViewStat)&&(identical(other.isMerchant, isMerchant) || other.isMerchant == isMerchant)&&(identical(other.playEventLobby, playEventLobby) || other.playEventLobby == playEventLobby)&&const DeepCollectionEquality().equals(other._lockGames, _lockGames)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.affId, affId) || other.affId == affId)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.regTime, regTime) || other.regTime == regTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,userId,username,displayName,avatar,brand,customerId,platformId,amount,gender,banned,bot,lockChat,mute,phoneVerified,deposit,verifiedBankAccount,canViewStat,isMerchant,playEventLobby,const DeepCollectionEquality().hash(_lockGames),phone,affId,ipAddress,timestamp,regTime]);

@override
String toString() {
  return 'JwtUserInfoModel(userId: $userId, username: $username, displayName: $displayName, avatar: $avatar, brand: $brand, customerId: $customerId, platformId: $platformId, amount: $amount, gender: $gender, banned: $banned, bot: $bot, lockChat: $lockChat, mute: $mute, phoneVerified: $phoneVerified, deposit: $deposit, verifiedBankAccount: $verifiedBankAccount, canViewStat: $canViewStat, isMerchant: $isMerchant, playEventLobby: $playEventLobby, lockGames: $lockGames, phone: $phone, affId: $affId, ipAddress: $ipAddress, timestamp: $timestamp, regTime: $regTime)';
}

}

abstract mixin class _$JwtUserInfoModelCopyWith<$Res> implements $JwtUserInfoModelCopyWith<$Res> {
  factory _$JwtUserInfoModelCopyWith(_JwtUserInfoModel value, $Res Function(_JwtUserInfoModel) _then) = __$JwtUserInfoModelCopyWithImpl;
@override @useResult
$Res call({
 String userId, String username, String displayName, String avatar, String brand, int customerId, int platformId,@JsonKey(fromJson: _toNum) num amount, int gender,@JsonKey(fromJson: _intToBool) bool banned,@JsonKey(fromJson: _intToBool) bool bot,@JsonKey(fromJson: _intToBool) bool lockChat,@JsonKey(fromJson: _intToBool) bool mute,@JsonKey(fromJson: _intToBool) bool phoneVerified,@JsonKey(fromJson: _intToBool) bool deposit,@JsonKey(fromJson: _intToBool) bool verifiedBankAccount,@JsonKey(fromJson: _intToBool) bool canViewStat,@JsonKey(fromJson: _intToBool) bool isMerchant,@JsonKey(fromJson: _intToBool) bool playEventLobby, List<dynamic> lockGames,@JsonKey(fromJson: _phoneToString) String? phone, String? affId, String? ipAddress, int? timestamp, int? regTime
});

}
class __$JwtUserInfoModelCopyWithImpl<$Res>
    implements _$JwtUserInfoModelCopyWith<$Res> {
  __$JwtUserInfoModelCopyWithImpl(this._self, this._then);

  final _JwtUserInfoModel _self;
  final $Res Function(_JwtUserInfoModel) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? username = null,Object? displayName = null,Object? avatar = null,Object? brand = null,Object? customerId = null,Object? platformId = null,Object? amount = null,Object? gender = null,Object? banned = null,Object? bot = null,Object? lockChat = null,Object? mute = null,Object? phoneVerified = null,Object? deposit = null,Object? verifiedBankAccount = null,Object? canViewStat = null,Object? isMerchant = null,Object? playEventLobby = null,Object? lockGames = null,Object? phone = freezed,Object? affId = freezed,Object? ipAddress = freezed,Object? timestamp = freezed,Object? regTime = freezed,}) {
  return _then(_JwtUserInfoModel(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatar: null == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int,platformId: null == platformId ? _self.platformId : platformId // ignore: cast_nullable_to_non_nullable
as int,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as num,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as int,banned: null == banned ? _self.banned : banned // ignore: cast_nullable_to_non_nullable
as bool,bot: null == bot ? _self.bot : bot // ignore: cast_nullable_to_non_nullable
as bool,lockChat: null == lockChat ? _self.lockChat : lockChat // ignore: cast_nullable_to_non_nullable
as bool,mute: null == mute ? _self.mute : mute // ignore: cast_nullable_to_non_nullable
as bool,phoneVerified: null == phoneVerified ? _self.phoneVerified : phoneVerified // ignore: cast_nullable_to_non_nullable
as bool,deposit: null == deposit ? _self.deposit : deposit // ignore: cast_nullable_to_non_nullable
as bool,verifiedBankAccount: null == verifiedBankAccount ? _self.verifiedBankAccount : verifiedBankAccount // ignore: cast_nullable_to_non_nullable
as bool,canViewStat: null == canViewStat ? _self.canViewStat : canViewStat // ignore: cast_nullable_to_non_nullable
as bool,isMerchant: null == isMerchant ? _self.isMerchant : isMerchant // ignore: cast_nullable_to_non_nullable
as bool,playEventLobby: null == playEventLobby ? _self.playEventLobby : playEventLobby // ignore: cast_nullable_to_non_nullable
as bool,lockGames: null == lockGames ? _self._lockGames : lockGames // ignore: cast_nullable_to_non_nullable
as List<dynamic>,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,affId: freezed == affId ? _self.affId : affId // ignore: cast_nullable_to_non_nullable
as String?,ipAddress: freezed == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String?,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as int?,regTime: freezed == regTime ? _self.regTime : regTime // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}

// dart format on
