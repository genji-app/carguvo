// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

// dart format off
T _$identity<T>(T value) => value;

mixin _$CardLastJoinData {

@JsonKey(name: 'username') String get username;@JsonKey(name: 'serverId', fromJson: _parseInt) int get serverId;@JsonKey(name: 'gameId', fromJson: _parseInt) int get gameId;@JsonKey(name: 'roomId', fromJson: _parseInt) int get roomId;@JsonKey(name: 'userCount', fromJson: _parseInt) int get userCount;@JsonKey(name: 'maxUser', fromJson: _parseInt) int get maxUser;@JsonKey(name: 'maxSlot', fromJson: _parseInt) int get maxSlot;@JsonKey(name: 'betting', fromJson: _parseNum) num get betting;@JsonKey(name: 'maxBet', fromJson: _parseNum) num get maxBet;@JsonKey(name: 'minMoney', fromJson: _parseNum) num get minMoney;@JsonKey(name: 'minMoneyBuyIn', fromJson: _parseNum) num get minMoneyBuyIn;@JsonKey(name: 'maxMoneyBuyIn', fromJson: _parseNum) num get maxMoneyBuyIn;@JsonKey(name: 'assetId', fromJson: _parseInt) int get assetId;@JsonKey(name: 'status', fromJson: _parseInt) int get status;@JsonKey(name: 'roomType', fromJson: _parseInt) int get roomType;@JsonKey(name: 'subGroupId', fromJson: _parseInt) int get subGroupId;@JsonKey(name: 'full', fromJson: _parseBool) bool get full;@JsonKey(name: 'playing', fromJson: _parseBool) bool get playing;@JsonKey(name: 'incognito', fromJson: _parseBool) bool get incognito;@JsonKey(name: 'huge', fromJson: _parseBool) bool get huge;@JsonKey(name: 'hasPassword', fromJson: _parseBool) bool get hasPassword;@JsonKey(name: 'password') String get password;@JsonKey(name: 'startTimeOfGame', fromJson: _parseInt) int get startTimeOfGame;@JsonKey(name: 'partial', fromJson: _parseBool) bool get partial;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardLastJoinDataCopyWith<CardLastJoinData> get copyWith => _$CardLastJoinDataCopyWithImpl<CardLastJoinData>(this as CardLastJoinData, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardLastJoinData&&(identical(other.username, username) || other.username == username)&&(identical(other.serverId, serverId) || other.serverId == serverId)&&(identical(other.gameId, gameId) || other.gameId == gameId)&&(identical(other.roomId, roomId) || other.roomId == roomId)&&(identical(other.userCount, userCount) || other.userCount == userCount)&&(identical(other.maxUser, maxUser) || other.maxUser == maxUser)&&(identical(other.maxSlot, maxSlot) || other.maxSlot == maxSlot)&&(identical(other.betting, betting) || other.betting == betting)&&(identical(other.maxBet, maxBet) || other.maxBet == maxBet)&&(identical(other.minMoney, minMoney) || other.minMoney == minMoney)&&(identical(other.minMoneyBuyIn, minMoneyBuyIn) || other.minMoneyBuyIn == minMoneyBuyIn)&&(identical(other.maxMoneyBuyIn, maxMoneyBuyIn) || other.maxMoneyBuyIn == maxMoneyBuyIn)&&(identical(other.assetId, assetId) || other.assetId == assetId)&&(identical(other.status, status) || other.status == status)&&(identical(other.roomType, roomType) || other.roomType == roomType)&&(identical(other.subGroupId, subGroupId) || other.subGroupId == subGroupId)&&(identical(other.full, full) || other.full == full)&&(identical(other.playing, playing) || other.playing == playing)&&(identical(other.incognito, incognito) || other.incognito == incognito)&&(identical(other.huge, huge) || other.huge == huge)&&(identical(other.hasPassword, hasPassword) || other.hasPassword == hasPassword)&&(identical(other.password, password) || other.password == password)&&(identical(other.startTimeOfGame, startTimeOfGame) || other.startTimeOfGame == startTimeOfGame)&&(identical(other.partial, partial) || other.partial == partial));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,username,serverId,gameId,roomId,userCount,maxUser,maxSlot,betting,maxBet,minMoney,minMoneyBuyIn,maxMoneyBuyIn,assetId,status,roomType,subGroupId,full,playing,incognito,huge,hasPassword,password,startTimeOfGame,partial]);

@override
String toString() {
  return 'CardLastJoinData(username: $username, serverId: $serverId, gameId: $gameId, roomId: $roomId, userCount: $userCount, maxUser: $maxUser, maxSlot: $maxSlot, betting: $betting, maxBet: $maxBet, minMoney: $minMoney, minMoneyBuyIn: $minMoneyBuyIn, maxMoneyBuyIn: $maxMoneyBuyIn, assetId: $assetId, status: $status, roomType: $roomType, subGroupId: $subGroupId, full: $full, playing: $playing, incognito: $incognito, huge: $huge, hasPassword: $hasPassword, password: $password, startTimeOfGame: $startTimeOfGame, partial: $partial)';
}

}

abstract mixin class $CardLastJoinDataCopyWith<$Res>  {
  factory $CardLastJoinDataCopyWith(CardLastJoinData value, $Res Function(CardLastJoinData) _then) = _$CardLastJoinDataCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'username') String username,@JsonKey(name: 'serverId', fromJson: _parseInt) int serverId,@JsonKey(name: 'gameId', fromJson: _parseInt) int gameId,@JsonKey(name: 'roomId', fromJson: _parseInt) int roomId,@JsonKey(name: 'userCount', fromJson: _parseInt) int userCount,@JsonKey(name: 'maxUser', fromJson: _parseInt) int maxUser,@JsonKey(name: 'maxSlot', fromJson: _parseInt) int maxSlot,@JsonKey(name: 'betting', fromJson: _parseNum) num betting,@JsonKey(name: 'maxBet', fromJson: _parseNum) num maxBet,@JsonKey(name: 'minMoney', fromJson: _parseNum) num minMoney,@JsonKey(name: 'minMoneyBuyIn', fromJson: _parseNum) num minMoneyBuyIn,@JsonKey(name: 'maxMoneyBuyIn', fromJson: _parseNum) num maxMoneyBuyIn,@JsonKey(name: 'assetId', fromJson: _parseInt) int assetId,@JsonKey(name: 'status', fromJson: _parseInt) int status,@JsonKey(name: 'roomType', fromJson: _parseInt) int roomType,@JsonKey(name: 'subGroupId', fromJson: _parseInt) int subGroupId,@JsonKey(name: 'full', fromJson: _parseBool) bool full,@JsonKey(name: 'playing', fromJson: _parseBool) bool playing,@JsonKey(name: 'incognito', fromJson: _parseBool) bool incognito,@JsonKey(name: 'huge', fromJson: _parseBool) bool huge,@JsonKey(name: 'hasPassword', fromJson: _parseBool) bool hasPassword,@JsonKey(name: 'password') String password,@JsonKey(name: 'startTimeOfGame', fromJson: _parseInt) int startTimeOfGame,@JsonKey(name: 'partial', fromJson: _parseBool) bool partial
});

}
class _$CardLastJoinDataCopyWithImpl<$Res>
    implements $CardLastJoinDataCopyWith<$Res> {
  _$CardLastJoinDataCopyWithImpl(this._self, this._then);

  final CardLastJoinData _self;
  final $Res Function(CardLastJoinData) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? username = null,Object? serverId = null,Object? gameId = null,Object? roomId = null,Object? userCount = null,Object? maxUser = null,Object? maxSlot = null,Object? betting = null,Object? maxBet = null,Object? minMoney = null,Object? minMoneyBuyIn = null,Object? maxMoneyBuyIn = null,Object? assetId = null,Object? status = null,Object? roomType = null,Object? subGroupId = null,Object? full = null,Object? playing = null,Object? incognito = null,Object? huge = null,Object? hasPassword = null,Object? password = null,Object? startTimeOfGame = null,Object? partial = null,}) {
  return _then(_self.copyWith(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,serverId: null == serverId ? _self.serverId : serverId // ignore: cast_nullable_to_non_nullable
as int,gameId: null == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as int,roomId: null == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as int,userCount: null == userCount ? _self.userCount : userCount // ignore: cast_nullable_to_non_nullable
as int,maxUser: null == maxUser ? _self.maxUser : maxUser // ignore: cast_nullable_to_non_nullable
as int,maxSlot: null == maxSlot ? _self.maxSlot : maxSlot // ignore: cast_nullable_to_non_nullable
as int,betting: null == betting ? _self.betting : betting // ignore: cast_nullable_to_non_nullable
as num,maxBet: null == maxBet ? _self.maxBet : maxBet // ignore: cast_nullable_to_non_nullable
as num,minMoney: null == minMoney ? _self.minMoney : minMoney // ignore: cast_nullable_to_non_nullable
as num,minMoneyBuyIn: null == minMoneyBuyIn ? _self.minMoneyBuyIn : minMoneyBuyIn // ignore: cast_nullable_to_non_nullable
as num,maxMoneyBuyIn: null == maxMoneyBuyIn ? _self.maxMoneyBuyIn : maxMoneyBuyIn // ignore: cast_nullable_to_non_nullable
as num,assetId: null == assetId ? _self.assetId : assetId // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,roomType: null == roomType ? _self.roomType : roomType // ignore: cast_nullable_to_non_nullable
as int,subGroupId: null == subGroupId ? _self.subGroupId : subGroupId // ignore: cast_nullable_to_non_nullable
as int,full: null == full ? _self.full : full // ignore: cast_nullable_to_non_nullable
as bool,playing: null == playing ? _self.playing : playing // ignore: cast_nullable_to_non_nullable
as bool,incognito: null == incognito ? _self.incognito : incognito // ignore: cast_nullable_to_non_nullable
as bool,huge: null == huge ? _self.huge : huge // ignore: cast_nullable_to_non_nullable
as bool,hasPassword: null == hasPassword ? _self.hasPassword : hasPassword // ignore: cast_nullable_to_non_nullable
as bool,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,startTimeOfGame: null == startTimeOfGame ? _self.startTimeOfGame : startTimeOfGame // ignore: cast_nullable_to_non_nullable
as int,partial: null == partial ? _self.partial : partial // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}

extension CardLastJoinDataPatterns on CardLastJoinData {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CardLastJoinData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CardLastJoinData() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CardLastJoinData value)  $default,){
final _that = this;
switch (_that) {
case _CardLastJoinData():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CardLastJoinData value)?  $default,){
final _that = this;
switch (_that) {
case _CardLastJoinData() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'username')  String username, @JsonKey(name: 'serverId', fromJson: _parseInt)  int serverId, @JsonKey(name: 'gameId', fromJson: _parseInt)  int gameId, @JsonKey(name: 'roomId', fromJson: _parseInt)  int roomId, @JsonKey(name: 'userCount', fromJson: _parseInt)  int userCount, @JsonKey(name: 'maxUser', fromJson: _parseInt)  int maxUser, @JsonKey(name: 'maxSlot', fromJson: _parseInt)  int maxSlot, @JsonKey(name: 'betting', fromJson: _parseNum)  num betting, @JsonKey(name: 'maxBet', fromJson: _parseNum)  num maxBet, @JsonKey(name: 'minMoney', fromJson: _parseNum)  num minMoney, @JsonKey(name: 'minMoneyBuyIn', fromJson: _parseNum)  num minMoneyBuyIn, @JsonKey(name: 'maxMoneyBuyIn', fromJson: _parseNum)  num maxMoneyBuyIn, @JsonKey(name: 'assetId', fromJson: _parseInt)  int assetId, @JsonKey(name: 'status', fromJson: _parseInt)  int status, @JsonKey(name: 'roomType', fromJson: _parseInt)  int roomType, @JsonKey(name: 'subGroupId', fromJson: _parseInt)  int subGroupId, @JsonKey(name: 'full', fromJson: _parseBool)  bool full, @JsonKey(name: 'playing', fromJson: _parseBool)  bool playing, @JsonKey(name: 'incognito', fromJson: _parseBool)  bool incognito, @JsonKey(name: 'huge', fromJson: _parseBool)  bool huge, @JsonKey(name: 'hasPassword', fromJson: _parseBool)  bool hasPassword, @JsonKey(name: 'password')  String password, @JsonKey(name: 'startTimeOfGame', fromJson: _parseInt)  int startTimeOfGame, @JsonKey(name: 'partial', fromJson: _parseBool)  bool partial)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CardLastJoinData() when $default != null:
return $default(_that.username,_that.serverId,_that.gameId,_that.roomId,_that.userCount,_that.maxUser,_that.maxSlot,_that.betting,_that.maxBet,_that.minMoney,_that.minMoneyBuyIn,_that.maxMoneyBuyIn,_that.assetId,_that.status,_that.roomType,_that.subGroupId,_that.full,_that.playing,_that.incognito,_that.huge,_that.hasPassword,_that.password,_that.startTimeOfGame,_that.partial);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'username')  String username, @JsonKey(name: 'serverId', fromJson: _parseInt)  int serverId, @JsonKey(name: 'gameId', fromJson: _parseInt)  int gameId, @JsonKey(name: 'roomId', fromJson: _parseInt)  int roomId, @JsonKey(name: 'userCount', fromJson: _parseInt)  int userCount, @JsonKey(name: 'maxUser', fromJson: _parseInt)  int maxUser, @JsonKey(name: 'maxSlot', fromJson: _parseInt)  int maxSlot, @JsonKey(name: 'betting', fromJson: _parseNum)  num betting, @JsonKey(name: 'maxBet', fromJson: _parseNum)  num maxBet, @JsonKey(name: 'minMoney', fromJson: _parseNum)  num minMoney, @JsonKey(name: 'minMoneyBuyIn', fromJson: _parseNum)  num minMoneyBuyIn, @JsonKey(name: 'maxMoneyBuyIn', fromJson: _parseNum)  num maxMoneyBuyIn, @JsonKey(name: 'assetId', fromJson: _parseInt)  int assetId, @JsonKey(name: 'status', fromJson: _parseInt)  int status, @JsonKey(name: 'roomType', fromJson: _parseInt)  int roomType, @JsonKey(name: 'subGroupId', fromJson: _parseInt)  int subGroupId, @JsonKey(name: 'full', fromJson: _parseBool)  bool full, @JsonKey(name: 'playing', fromJson: _parseBool)  bool playing, @JsonKey(name: 'incognito', fromJson: _parseBool)  bool incognito, @JsonKey(name: 'huge', fromJson: _parseBool)  bool huge, @JsonKey(name: 'hasPassword', fromJson: _parseBool)  bool hasPassword, @JsonKey(name: 'password')  String password, @JsonKey(name: 'startTimeOfGame', fromJson: _parseInt)  int startTimeOfGame, @JsonKey(name: 'partial', fromJson: _parseBool)  bool partial)  $default,) {final _that = this;
switch (_that) {
case _CardLastJoinData():
return $default(_that.username,_that.serverId,_that.gameId,_that.roomId,_that.userCount,_that.maxUser,_that.maxSlot,_that.betting,_that.maxBet,_that.minMoney,_that.minMoneyBuyIn,_that.maxMoneyBuyIn,_that.assetId,_that.status,_that.roomType,_that.subGroupId,_that.full,_that.playing,_that.incognito,_that.huge,_that.hasPassword,_that.password,_that.startTimeOfGame,_that.partial);case _:
  throw StateError('Unexpected subclass');

}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'username')  String username, @JsonKey(name: 'serverId', fromJson: _parseInt)  int serverId, @JsonKey(name: 'gameId', fromJson: _parseInt)  int gameId, @JsonKey(name: 'roomId', fromJson: _parseInt)  int roomId, @JsonKey(name: 'userCount', fromJson: _parseInt)  int userCount, @JsonKey(name: 'maxUser', fromJson: _parseInt)  int maxUser, @JsonKey(name: 'maxSlot', fromJson: _parseInt)  int maxSlot, @JsonKey(name: 'betting', fromJson: _parseNum)  num betting, @JsonKey(name: 'maxBet', fromJson: _parseNum)  num maxBet, @JsonKey(name: 'minMoney', fromJson: _parseNum)  num minMoney, @JsonKey(name: 'minMoneyBuyIn', fromJson: _parseNum)  num minMoneyBuyIn, @JsonKey(name: 'maxMoneyBuyIn', fromJson: _parseNum)  num maxMoneyBuyIn, @JsonKey(name: 'assetId', fromJson: _parseInt)  int assetId, @JsonKey(name: 'status', fromJson: _parseInt)  int status, @JsonKey(name: 'roomType', fromJson: _parseInt)  int roomType, @JsonKey(name: 'subGroupId', fromJson: _parseInt)  int subGroupId, @JsonKey(name: 'full', fromJson: _parseBool)  bool full, @JsonKey(name: 'playing', fromJson: _parseBool)  bool playing, @JsonKey(name: 'incognito', fromJson: _parseBool)  bool incognito, @JsonKey(name: 'huge', fromJson: _parseBool)  bool huge, @JsonKey(name: 'hasPassword', fromJson: _parseBool)  bool hasPassword, @JsonKey(name: 'password')  String password, @JsonKey(name: 'startTimeOfGame', fromJson: _parseInt)  int startTimeOfGame, @JsonKey(name: 'partial', fromJson: _parseBool)  bool partial)?  $default,) {final _that = this;
switch (_that) {
case _CardLastJoinData() when $default != null:
return $default(_that.username,_that.serverId,_that.gameId,_that.roomId,_that.userCount,_that.maxUser,_that.maxSlot,_that.betting,_that.maxBet,_that.minMoney,_that.minMoneyBuyIn,_that.maxMoneyBuyIn,_that.assetId,_that.status,_that.roomType,_that.subGroupId,_that.full,_that.playing,_that.incognito,_that.huge,_that.hasPassword,_that.password,_that.startTimeOfGame,_that.partial);case _:
  return null;

}
}

}

@JsonSerializable()

class _CardLastJoinData implements CardLastJoinData {
  const _CardLastJoinData({@JsonKey(name: 'username') this.username = '', @JsonKey(name: 'serverId', fromJson: _parseInt) this.serverId = 0, @JsonKey(name: 'gameId', fromJson: _parseInt) this.gameId = 0, @JsonKey(name: 'roomId', fromJson: _parseInt) this.roomId = -1, @JsonKey(name: 'userCount', fromJson: _parseInt) this.userCount = 0, @JsonKey(name: 'maxUser', fromJson: _parseInt) this.maxUser = 0, @JsonKey(name: 'maxSlot', fromJson: _parseInt) this.maxSlot = 0, @JsonKey(name: 'betting', fromJson: _parseNum) this.betting = 0, @JsonKey(name: 'maxBet', fromJson: _parseNum) this.maxBet = 0, @JsonKey(name: 'minMoney', fromJson: _parseNum) this.minMoney = 0, @JsonKey(name: 'minMoneyBuyIn', fromJson: _parseNum) this.minMoneyBuyIn = 0, @JsonKey(name: 'maxMoneyBuyIn', fromJson: _parseNum) this.maxMoneyBuyIn = 0, @JsonKey(name: 'assetId', fromJson: _parseInt) this.assetId = 0, @JsonKey(name: 'status', fromJson: _parseInt) this.status = 0, @JsonKey(name: 'roomType', fromJson: _parseInt) this.roomType = 0, @JsonKey(name: 'subGroupId', fromJson: _parseInt) this.subGroupId = 0, @JsonKey(name: 'full', fromJson: _parseBool) this.full = false, @JsonKey(name: 'playing', fromJson: _parseBool) this.playing = false, @JsonKey(name: 'incognito', fromJson: _parseBool) this.incognito = false, @JsonKey(name: 'huge', fromJson: _parseBool) this.huge = false, @JsonKey(name: 'hasPassword', fromJson: _parseBool) this.hasPassword = false, @JsonKey(name: 'password') this.password = '', @JsonKey(name: 'startTimeOfGame', fromJson: _parseInt) this.startTimeOfGame = 0, @JsonKey(name: 'partial', fromJson: _parseBool) this.partial = false});
  factory _CardLastJoinData.fromJson(Map<String, dynamic> json) => _$CardLastJoinDataFromJson(json);

@override@JsonKey(name: 'username') final  String username;
@override@JsonKey(name: 'serverId', fromJson: _parseInt) final  int serverId;
@override@JsonKey(name: 'gameId', fromJson: _parseInt) final  int gameId;
@override@JsonKey(name: 'roomId', fromJson: _parseInt) final  int roomId;
@override@JsonKey(name: 'userCount', fromJson: _parseInt) final  int userCount;
@override@JsonKey(name: 'maxUser', fromJson: _parseInt) final  int maxUser;
@override@JsonKey(name: 'maxSlot', fromJson: _parseInt) final  int maxSlot;
@override@JsonKey(name: 'betting', fromJson: _parseNum) final  num betting;
@override@JsonKey(name: 'maxBet', fromJson: _parseNum) final  num maxBet;
@override@JsonKey(name: 'minMoney', fromJson: _parseNum) final  num minMoney;
@override@JsonKey(name: 'minMoneyBuyIn', fromJson: _parseNum) final  num minMoneyBuyIn;
@override@JsonKey(name: 'maxMoneyBuyIn', fromJson: _parseNum) final  num maxMoneyBuyIn;
@override@JsonKey(name: 'assetId', fromJson: _parseInt) final  int assetId;
@override@JsonKey(name: 'status', fromJson: _parseInt) final  int status;
@override@JsonKey(name: 'roomType', fromJson: _parseInt) final  int roomType;
@override@JsonKey(name: 'subGroupId', fromJson: _parseInt) final  int subGroupId;
@override@JsonKey(name: 'full', fromJson: _parseBool) final  bool full;
@override@JsonKey(name: 'playing', fromJson: _parseBool) final  bool playing;
@override@JsonKey(name: 'incognito', fromJson: _parseBool) final  bool incognito;
@override@JsonKey(name: 'huge', fromJson: _parseBool) final  bool huge;
@override@JsonKey(name: 'hasPassword', fromJson: _parseBool) final  bool hasPassword;
@override@JsonKey(name: 'password') final  String password;
@override@JsonKey(name: 'startTimeOfGame', fromJson: _parseInt) final  int startTimeOfGame;
@override@JsonKey(name: 'partial', fromJson: _parseBool) final  bool partial;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardLastJoinDataCopyWith<_CardLastJoinData> get copyWith => __$CardLastJoinDataCopyWithImpl<_CardLastJoinData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CardLastJoinDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CardLastJoinData&&(identical(other.username, username) || other.username == username)&&(identical(other.serverId, serverId) || other.serverId == serverId)&&(identical(other.gameId, gameId) || other.gameId == gameId)&&(identical(other.roomId, roomId) || other.roomId == roomId)&&(identical(other.userCount, userCount) || other.userCount == userCount)&&(identical(other.maxUser, maxUser) || other.maxUser == maxUser)&&(identical(other.maxSlot, maxSlot) || other.maxSlot == maxSlot)&&(identical(other.betting, betting) || other.betting == betting)&&(identical(other.maxBet, maxBet) || other.maxBet == maxBet)&&(identical(other.minMoney, minMoney) || other.minMoney == minMoney)&&(identical(other.minMoneyBuyIn, minMoneyBuyIn) || other.minMoneyBuyIn == minMoneyBuyIn)&&(identical(other.maxMoneyBuyIn, maxMoneyBuyIn) || other.maxMoneyBuyIn == maxMoneyBuyIn)&&(identical(other.assetId, assetId) || other.assetId == assetId)&&(identical(other.status, status) || other.status == status)&&(identical(other.roomType, roomType) || other.roomType == roomType)&&(identical(other.subGroupId, subGroupId) || other.subGroupId == subGroupId)&&(identical(other.full, full) || other.full == full)&&(identical(other.playing, playing) || other.playing == playing)&&(identical(other.incognito, incognito) || other.incognito == incognito)&&(identical(other.huge, huge) || other.huge == huge)&&(identical(other.hasPassword, hasPassword) || other.hasPassword == hasPassword)&&(identical(other.password, password) || other.password == password)&&(identical(other.startTimeOfGame, startTimeOfGame) || other.startTimeOfGame == startTimeOfGame)&&(identical(other.partial, partial) || other.partial == partial));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,username,serverId,gameId,roomId,userCount,maxUser,maxSlot,betting,maxBet,minMoney,minMoneyBuyIn,maxMoneyBuyIn,assetId,status,roomType,subGroupId,full,playing,incognito,huge,hasPassword,password,startTimeOfGame,partial]);

@override
String toString() {
  return 'CardLastJoinData(username: $username, serverId: $serverId, gameId: $gameId, roomId: $roomId, userCount: $userCount, maxUser: $maxUser, maxSlot: $maxSlot, betting: $betting, maxBet: $maxBet, minMoney: $minMoney, minMoneyBuyIn: $minMoneyBuyIn, maxMoneyBuyIn: $maxMoneyBuyIn, assetId: $assetId, status: $status, roomType: $roomType, subGroupId: $subGroupId, full: $full, playing: $playing, incognito: $incognito, huge: $huge, hasPassword: $hasPassword, password: $password, startTimeOfGame: $startTimeOfGame, partial: $partial)';
}

}

abstract mixin class _$CardLastJoinDataCopyWith<$Res> implements $CardLastJoinDataCopyWith<$Res> {
  factory _$CardLastJoinDataCopyWith(_CardLastJoinData value, $Res Function(_CardLastJoinData) _then) = __$CardLastJoinDataCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'username') String username,@JsonKey(name: 'serverId', fromJson: _parseInt) int serverId,@JsonKey(name: 'gameId', fromJson: _parseInt) int gameId,@JsonKey(name: 'roomId', fromJson: _parseInt) int roomId,@JsonKey(name: 'userCount', fromJson: _parseInt) int userCount,@JsonKey(name: 'maxUser', fromJson: _parseInt) int maxUser,@JsonKey(name: 'maxSlot', fromJson: _parseInt) int maxSlot,@JsonKey(name: 'betting', fromJson: _parseNum) num betting,@JsonKey(name: 'maxBet', fromJson: _parseNum) num maxBet,@JsonKey(name: 'minMoney', fromJson: _parseNum) num minMoney,@JsonKey(name: 'minMoneyBuyIn', fromJson: _parseNum) num minMoneyBuyIn,@JsonKey(name: 'maxMoneyBuyIn', fromJson: _parseNum) num maxMoneyBuyIn,@JsonKey(name: 'assetId', fromJson: _parseInt) int assetId,@JsonKey(name: 'status', fromJson: _parseInt) int status,@JsonKey(name: 'roomType', fromJson: _parseInt) int roomType,@JsonKey(name: 'subGroupId', fromJson: _parseInt) int subGroupId,@JsonKey(name: 'full', fromJson: _parseBool) bool full,@JsonKey(name: 'playing', fromJson: _parseBool) bool playing,@JsonKey(name: 'incognito', fromJson: _parseBool) bool incognito,@JsonKey(name: 'huge', fromJson: _parseBool) bool huge,@JsonKey(name: 'hasPassword', fromJson: _parseBool) bool hasPassword,@JsonKey(name: 'password') String password,@JsonKey(name: 'startTimeOfGame', fromJson: _parseInt) int startTimeOfGame,@JsonKey(name: 'partial', fromJson: _parseBool) bool partial
});

}
class __$CardLastJoinDataCopyWithImpl<$Res>
    implements _$CardLastJoinDataCopyWith<$Res> {
  __$CardLastJoinDataCopyWithImpl(this._self, this._then);

  final _CardLastJoinData _self;
  final $Res Function(_CardLastJoinData) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? username = null,Object? serverId = null,Object? gameId = null,Object? roomId = null,Object? userCount = null,Object? maxUser = null,Object? maxSlot = null,Object? betting = null,Object? maxBet = null,Object? minMoney = null,Object? minMoneyBuyIn = null,Object? maxMoneyBuyIn = null,Object? assetId = null,Object? status = null,Object? roomType = null,Object? subGroupId = null,Object? full = null,Object? playing = null,Object? incognito = null,Object? huge = null,Object? hasPassword = null,Object? password = null,Object? startTimeOfGame = null,Object? partial = null,}) {
  return _then(_CardLastJoinData(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,serverId: null == serverId ? _self.serverId : serverId // ignore: cast_nullable_to_non_nullable
as int,gameId: null == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as int,roomId: null == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as int,userCount: null == userCount ? _self.userCount : userCount // ignore: cast_nullable_to_non_nullable
as int,maxUser: null == maxUser ? _self.maxUser : maxUser // ignore: cast_nullable_to_non_nullable
as int,maxSlot: null == maxSlot ? _self.maxSlot : maxSlot // ignore: cast_nullable_to_non_nullable
as int,betting: null == betting ? _self.betting : betting // ignore: cast_nullable_to_non_nullable
as num,maxBet: null == maxBet ? _self.maxBet : maxBet // ignore: cast_nullable_to_non_nullable
as num,minMoney: null == minMoney ? _self.minMoney : minMoney // ignore: cast_nullable_to_non_nullable
as num,minMoneyBuyIn: null == minMoneyBuyIn ? _self.minMoneyBuyIn : minMoneyBuyIn // ignore: cast_nullable_to_non_nullable
as num,maxMoneyBuyIn: null == maxMoneyBuyIn ? _self.maxMoneyBuyIn : maxMoneyBuyIn // ignore: cast_nullable_to_non_nullable
as num,assetId: null == assetId ? _self.assetId : assetId // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,roomType: null == roomType ? _self.roomType : roomType // ignore: cast_nullable_to_non_nullable
as int,subGroupId: null == subGroupId ? _self.subGroupId : subGroupId // ignore: cast_nullable_to_non_nullable
as int,full: null == full ? _self.full : full // ignore: cast_nullable_to_non_nullable
as bool,playing: null == playing ? _self.playing : playing // ignore: cast_nullable_to_non_nullable
as bool,incognito: null == incognito ? _self.incognito : incognito // ignore: cast_nullable_to_non_nullable
as bool,huge: null == huge ? _self.huge : huge // ignore: cast_nullable_to_non_nullable
as bool,hasPassword: null == hasPassword ? _self.hasPassword : hasPassword // ignore: cast_nullable_to_non_nullable
as bool,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,startTimeOfGame: null == startTimeOfGame ? _self.startTimeOfGame : startTimeOfGame // ignore: cast_nullable_to_non_nullable
as int,partial: null == partial ? _self.partial : partial // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}

mixin _$GameApiResponse<T> {

 String get message; int get code; int get status; Object? get data;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameApiResponseCopyWith<T, GameApiResponse<T>> get copyWith => _$GameApiResponseCopyWithImpl<T, GameApiResponse<T>>(this as GameApiResponse<T>, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameApiResponse<T>&&(identical(other.message, message) || other.message == message)&&(identical(other.code, code) || other.code == code)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.data, data));
}

@override
int get hashCode => Object.hash(runtimeType,message,code,status,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'GameApiResponse<$T>(message: $message, code: $code, status: $status, data: $data)';
}

}

abstract mixin class $GameApiResponseCopyWith<T,$Res>  {
  factory $GameApiResponseCopyWith(GameApiResponse<T> value, $Res Function(GameApiResponse<T>) _then) = _$GameApiResponseCopyWithImpl;
@useResult
$Res call({
 String message, int code, int status
});

}
class _$GameApiResponseCopyWithImpl<T,$Res>
    implements $GameApiResponseCopyWith<T, $Res> {
  _$GameApiResponseCopyWithImpl(this._self, this._then);

  final GameApiResponse<T> _self;
  final $Res Function(GameApiResponse<T>) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? message = null,Object? code = null,Object? status = null,}) {
  return _then(_self.copyWith(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}

extension GameApiResponsePatterns<T> on GameApiResponse<T> {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( GameApiSuccessResponse<T> value)?  success,TResult Function( GameApiFailureResponse<T> value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case GameApiSuccessResponse() when success != null:
return success(_that);case GameApiFailureResponse() when failure != null:
return failure(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( GameApiSuccessResponse<T> value)  success,required TResult Function( GameApiFailureResponse<T> value)  failure,}){
final _that = this;
switch (_that) {
case GameApiSuccessResponse():
return success(_that);case GameApiFailureResponse():
return failure(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( GameApiSuccessResponse<T> value)?  success,TResult? Function( GameApiFailureResponse<T> value)?  failure,}){
final _that = this;
switch (_that) {
case GameApiSuccessResponse() when success != null:
return success(_that);case GameApiFailureResponse() when failure != null:
return failure(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String message,  int code,  int status,  T data)?  success,TResult Function( String message,  int code,  int status,  Object? data)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case GameApiSuccessResponse() when success != null:
return success(_that.message,_that.code,_that.status,_that.data);case GameApiFailureResponse() when failure != null:
return failure(_that.message,_that.code,_that.status,_that.data);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String message,  int code,  int status,  T data)  success,required TResult Function( String message,  int code,  int status,  Object? data)  failure,}) {final _that = this;
switch (_that) {
case GameApiSuccessResponse():
return success(_that.message,_that.code,_that.status,_that.data);case GameApiFailureResponse():
return failure(_that.message,_that.code,_that.status,_that.data);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String message,  int code,  int status,  T data)?  success,TResult? Function( String message,  int code,  int status,  Object? data)?  failure,}) {final _that = this;
switch (_that) {
case GameApiSuccessResponse() when success != null:
return success(_that.message,_that.code,_that.status,_that.data);case GameApiFailureResponse() when failure != null:
return failure(_that.message,_that.code,_that.status,_that.data);case _:
  return null;

}
}

}

class GameApiSuccessResponse<T> implements GameApiResponse<T> {
  const GameApiSuccessResponse({required this.message, required this.code, required this.status, required this.data});
  
@override final  String message;
@override final  int code;
@override final  int status;
@override final  T data;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameApiSuccessResponseCopyWith<T, GameApiSuccessResponse<T>> get copyWith => _$GameApiSuccessResponseCopyWithImpl<T, GameApiSuccessResponse<T>>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameApiSuccessResponse<T>&&(identical(other.message, message) || other.message == message)&&(identical(other.code, code) || other.code == code)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.data, data));
}

@override
int get hashCode => Object.hash(runtimeType,message,code,status,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'GameApiResponse<$T>.success(message: $message, code: $code, status: $status, data: $data)';
}

}

abstract mixin class $GameApiSuccessResponseCopyWith<T,$Res> implements $GameApiResponseCopyWith<T, $Res> {
  factory $GameApiSuccessResponseCopyWith(GameApiSuccessResponse<T> value, $Res Function(GameApiSuccessResponse<T>) _then) = _$GameApiSuccessResponseCopyWithImpl;
@override @useResult
$Res call({
 String message, int code, int status, T data
});

}
class _$GameApiSuccessResponseCopyWithImpl<T,$Res>
    implements $GameApiSuccessResponseCopyWith<T, $Res> {
  _$GameApiSuccessResponseCopyWithImpl(this._self, this._then);

  final GameApiSuccessResponse<T> _self;
  final $Res Function(GameApiSuccessResponse<T>) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? code = null,Object? status = null,Object? data = freezed,}) {
  return _then(GameApiSuccessResponse<T>(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T,
  ));
}

}

class GameApiFailureResponse<T> implements GameApiResponse<T> {
  const GameApiFailureResponse({required this.message, required this.code, required this.status, this.data});
  
@override final  String message;
@override final  int code;
@override final  int status;
@override final  Object? data;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameApiFailureResponseCopyWith<T, GameApiFailureResponse<T>> get copyWith => _$GameApiFailureResponseCopyWithImpl<T, GameApiFailureResponse<T>>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameApiFailureResponse<T>&&(identical(other.message, message) || other.message == message)&&(identical(other.code, code) || other.code == code)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.data, data));
}

@override
int get hashCode => Object.hash(runtimeType,message,code,status,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'GameApiResponse<$T>.failure(message: $message, code: $code, status: $status, data: $data)';
}

}

abstract mixin class $GameApiFailureResponseCopyWith<T,$Res> implements $GameApiResponseCopyWith<T, $Res> {
  factory $GameApiFailureResponseCopyWith(GameApiFailureResponse<T> value, $Res Function(GameApiFailureResponse<T>) _then) = _$GameApiFailureResponseCopyWithImpl;
@override @useResult
$Res call({
 String message, int code, int status, Object? data
});

}
class _$GameApiFailureResponseCopyWithImpl<T,$Res>
    implements $GameApiFailureResponseCopyWith<T, $Res> {
  _$GameApiFailureResponseCopyWithImpl(this._self, this._then);

  final GameApiFailureResponse<T> _self;
  final $Res Function(GameApiFailureResponse<T>) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? code = null,Object? status = null,Object? data = freezed,}) {
  return _then(GameApiFailureResponse<T>(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,data: freezed == data ? _self.data : data ,
  ));
}

}

mixin _$GameUrlData {

 String get url;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameUrlDataCopyWith<GameUrlData> get copyWith => _$GameUrlDataCopyWithImpl<GameUrlData>(this as GameUrlData, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameUrlData&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url);

@override
String toString() {
  return 'GameUrlData(url: $url)';
}

}

abstract mixin class $GameUrlDataCopyWith<$Res>  {
  factory $GameUrlDataCopyWith(GameUrlData value, $Res Function(GameUrlData) _then) = _$GameUrlDataCopyWithImpl;
@useResult
$Res call({
 String url
});

}
class _$GameUrlDataCopyWithImpl<$Res>
    implements $GameUrlDataCopyWith<$Res> {
  _$GameUrlDataCopyWithImpl(this._self, this._then);

  final GameUrlData _self;
  final $Res Function(GameUrlData) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? url = null,}) {
  return _then(_self.copyWith(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}

extension GameUrlDataPatterns on GameUrlData {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GameUrlData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GameUrlData() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GameUrlData value)  $default,){
final _that = this;
switch (_that) {
case _GameUrlData():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GameUrlData value)?  $default,){
final _that = this;
switch (_that) {
case _GameUrlData() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameUrlData() when $default != null:
return $default(_that.url);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url)  $default,) {final _that = this;
switch (_that) {
case _GameUrlData():
return $default(_that.url);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url)?  $default,) {final _that = this;
switch (_that) {
case _GameUrlData() when $default != null:
return $default(_that.url);case _:
  return null;

}
}

}

@JsonSerializable()

class _GameUrlData implements GameUrlData {
  const _GameUrlData({required this.url});
  factory _GameUrlData.fromJson(Map<String, dynamic> json) => _$GameUrlDataFromJson(json);

@override final  String url;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameUrlDataCopyWith<_GameUrlData> get copyWith => __$GameUrlDataCopyWithImpl<_GameUrlData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GameUrlDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameUrlData&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url);

@override
String toString() {
  return 'GameUrlData(url: $url)';
}

}

abstract mixin class _$GameUrlDataCopyWith<$Res> implements $GameUrlDataCopyWith<$Res> {
  factory _$GameUrlDataCopyWith(_GameUrlData value, $Res Function(_GameUrlData) _then) = __$GameUrlDataCopyWithImpl;
@override @useResult
$Res call({
 String url
});

}
class __$GameUrlDataCopyWithImpl<$Res>
    implements _$GameUrlDataCopyWith<$Res> {
  __$GameUrlDataCopyWithImpl(this._self, this._then);

  final _GameUrlData _self;
  final $Res Function(_GameUrlData) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? url = null,}) {
  return _then(_GameUrlData(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}

mixin _$GetGameUrlRequest {

 String get providerId; String get productId; String get gameCode; String? get lang; bool? get isMobileLogin;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetGameUrlRequestCopyWith<GetGameUrlRequest> get copyWith => _$GetGameUrlRequestCopyWithImpl<GetGameUrlRequest>(this as GetGameUrlRequest, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetGameUrlRequest&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.gameCode, gameCode) || other.gameCode == gameCode)&&(identical(other.lang, lang) || other.lang == lang)&&(identical(other.isMobileLogin, isMobileLogin) || other.isMobileLogin == isMobileLogin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,providerId,productId,gameCode,lang,isMobileLogin);

@override
String toString() {
  return 'GetGameUrlRequest(providerId: $providerId, productId: $productId, gameCode: $gameCode, lang: $lang, isMobileLogin: $isMobileLogin)';
}

}

abstract mixin class $GetGameUrlRequestCopyWith<$Res>  {
  factory $GetGameUrlRequestCopyWith(GetGameUrlRequest value, $Res Function(GetGameUrlRequest) _then) = _$GetGameUrlRequestCopyWithImpl;
@useResult
$Res call({
 String providerId, String productId, String gameCode, String? lang, bool? isMobileLogin
});

}
class _$GetGameUrlRequestCopyWithImpl<$Res>
    implements $GetGameUrlRequestCopyWith<$Res> {
  _$GetGameUrlRequestCopyWithImpl(this._self, this._then);

  final GetGameUrlRequest _self;
  final $Res Function(GetGameUrlRequest) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? providerId = null,Object? productId = null,Object? gameCode = null,Object? lang = freezed,Object? isMobileLogin = freezed,}) {
  return _then(_self.copyWith(
providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,gameCode: null == gameCode ? _self.gameCode : gameCode // ignore: cast_nullable_to_non_nullable
as String,lang: freezed == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as String?,isMobileLogin: freezed == isMobileLogin ? _self.isMobileLogin : isMobileLogin // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}

extension GetGameUrlRequestPatterns on GetGameUrlRequest {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GetGameUrlRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GetGameUrlRequest() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GetGameUrlRequest value)  $default,){
final _that = this;
switch (_that) {
case _GetGameUrlRequest():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GetGameUrlRequest value)?  $default,){
final _that = this;
switch (_that) {
case _GetGameUrlRequest() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String providerId,  String productId,  String gameCode,  String? lang,  bool? isMobileLogin)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GetGameUrlRequest() when $default != null:
return $default(_that.providerId,_that.productId,_that.gameCode,_that.lang,_that.isMobileLogin);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String providerId,  String productId,  String gameCode,  String? lang,  bool? isMobileLogin)  $default,) {final _that = this;
switch (_that) {
case _GetGameUrlRequest():
return $default(_that.providerId,_that.productId,_that.gameCode,_that.lang,_that.isMobileLogin);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String providerId,  String productId,  String gameCode,  String? lang,  bool? isMobileLogin)?  $default,) {final _that = this;
switch (_that) {
case _GetGameUrlRequest() when $default != null:
return $default(_that.providerId,_that.productId,_that.gameCode,_that.lang,_that.isMobileLogin);case _:
  return null;

}
}

}

@JsonSerializable()

class _GetGameUrlRequest extends GetGameUrlRequest {
  const _GetGameUrlRequest({required this.providerId, required this.productId, required this.gameCode, this.lang, this.isMobileLogin}): super._();
  factory _GetGameUrlRequest.fromJson(Map<String, dynamic> json) => _$GetGameUrlRequestFromJson(json);

@override final  String providerId;
@override final  String productId;
@override final  String gameCode;
@override final  String? lang;
@override final  bool? isMobileLogin;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetGameUrlRequestCopyWith<_GetGameUrlRequest> get copyWith => __$GetGameUrlRequestCopyWithImpl<_GetGameUrlRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GetGameUrlRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetGameUrlRequest&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.gameCode, gameCode) || other.gameCode == gameCode)&&(identical(other.lang, lang) || other.lang == lang)&&(identical(other.isMobileLogin, isMobileLogin) || other.isMobileLogin == isMobileLogin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,providerId,productId,gameCode,lang,isMobileLogin);

@override
String toString() {
  return 'GetGameUrlRequest(providerId: $providerId, productId: $productId, gameCode: $gameCode, lang: $lang, isMobileLogin: $isMobileLogin)';
}

}

abstract mixin class _$GetGameUrlRequestCopyWith<$Res> implements $GetGameUrlRequestCopyWith<$Res> {
  factory _$GetGameUrlRequestCopyWith(_GetGameUrlRequest value, $Res Function(_GetGameUrlRequest) _then) = __$GetGameUrlRequestCopyWithImpl;
@override @useResult
$Res call({
 String providerId, String productId, String gameCode, String? lang, bool? isMobileLogin
});

}
class __$GetGameUrlRequestCopyWithImpl<$Res>
    implements _$GetGameUrlRequestCopyWith<$Res> {
  __$GetGameUrlRequestCopyWithImpl(this._self, this._then);

  final _GetGameUrlRequest _self;
  final $Res Function(_GetGameUrlRequest) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? providerId = null,Object? productId = null,Object? gameCode = null,Object? lang = freezed,Object? isMobileLogin = freezed,}) {
  return _then(_GetGameUrlRequest(
providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,gameCode: null == gameCode ? _self.gameCode : gameCode // ignore: cast_nullable_to_non_nullable
as String,lang: freezed == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as String?,isMobileLogin: freezed == isMobileLogin ? _self.isMobileLogin : isMobileLogin // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}

mixin _$JackpotEntry {

@JsonKey(name: 'gameId', fromJson: _parseInt) int get gameId;
@JsonKey(name: 'gameName') String get gameName;
@JsonKey(name: 'balance', fromJson: _parseNum) num get balance;
@JsonKey(name: 'betting', fromJson: _parseNum) num get betting;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JackpotEntryCopyWith<JackpotEntry> get copyWith => _$JackpotEntryCopyWithImpl<JackpotEntry>(this as JackpotEntry, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JackpotEntry&&(identical(other.gameId, gameId) || other.gameId == gameId)&&(identical(other.gameName, gameName) || other.gameName == gameName)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.betting, betting) || other.betting == betting));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,gameId,gameName,balance,betting);

@override
String toString() {
  return 'JackpotEntry(gameId: $gameId, gameName: $gameName, balance: $balance, betting: $betting)';
}

}

abstract mixin class $JackpotEntryCopyWith<$Res>  {
  factory $JackpotEntryCopyWith(JackpotEntry value, $Res Function(JackpotEntry) _then) = _$JackpotEntryCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'gameId', fromJson: _parseInt) int gameId,@JsonKey(name: 'gameName') String gameName,@JsonKey(name: 'balance', fromJson: _parseNum) num balance,@JsonKey(name: 'betting', fromJson: _parseNum) num betting
});

}
class _$JackpotEntryCopyWithImpl<$Res>
    implements $JackpotEntryCopyWith<$Res> {
  _$JackpotEntryCopyWithImpl(this._self, this._then);

  final JackpotEntry _self;
  final $Res Function(JackpotEntry) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? gameId = null,Object? gameName = null,Object? balance = null,Object? betting = null,}) {
  return _then(_self.copyWith(
gameId: null == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as int,gameName: null == gameName ? _self.gameName : gameName // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as num,betting: null == betting ? _self.betting : betting // ignore: cast_nullable_to_non_nullable
as num,
  ));
}

}

extension JackpotEntryPatterns on JackpotEntry {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JackpotEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JackpotEntry() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JackpotEntry value)  $default,){
final _that = this;
switch (_that) {
case _JackpotEntry():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JackpotEntry value)?  $default,){
final _that = this;
switch (_that) {
case _JackpotEntry() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'gameId', fromJson: _parseInt)  int gameId, @JsonKey(name: 'gameName')  String gameName, @JsonKey(name: 'balance', fromJson: _parseNum)  num balance, @JsonKey(name: 'betting', fromJson: _parseNum)  num betting)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JackpotEntry() when $default != null:
return $default(_that.gameId,_that.gameName,_that.balance,_that.betting);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'gameId', fromJson: _parseInt)  int gameId, @JsonKey(name: 'gameName')  String gameName, @JsonKey(name: 'balance', fromJson: _parseNum)  num balance, @JsonKey(name: 'betting', fromJson: _parseNum)  num betting)  $default,) {final _that = this;
switch (_that) {
case _JackpotEntry():
return $default(_that.gameId,_that.gameName,_that.balance,_that.betting);case _:
  throw StateError('Unexpected subclass');

}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'gameId', fromJson: _parseInt)  int gameId, @JsonKey(name: 'gameName')  String gameName, @JsonKey(name: 'balance', fromJson: _parseNum)  num balance, @JsonKey(name: 'betting', fromJson: _parseNum)  num betting)?  $default,) {final _that = this;
switch (_that) {
case _JackpotEntry() when $default != null:
return $default(_that.gameId,_that.gameName,_that.balance,_that.betting);case _:
  return null;

}
}

}

@JsonSerializable()

class _JackpotEntry implements JackpotEntry {
  const _JackpotEntry({@JsonKey(name: 'gameId', fromJson: _parseInt) this.gameId = 0, @JsonKey(name: 'gameName') this.gameName = '', @JsonKey(name: 'balance', fromJson: _parseNum) this.balance = 0, @JsonKey(name: 'betting', fromJson: _parseNum) this.betting = 0});
  factory _JackpotEntry.fromJson(Map<String, dynamic> json) => _$JackpotEntryFromJson(json);

@override@JsonKey(name: 'gameId', fromJson: _parseInt) final  int gameId;
@override@JsonKey(name: 'gameName') final  String gameName;
@override@JsonKey(name: 'balance', fromJson: _parseNum) final  num balance;
@override@JsonKey(name: 'betting', fromJson: _parseNum) final  num betting;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JackpotEntryCopyWith<_JackpotEntry> get copyWith => __$JackpotEntryCopyWithImpl<_JackpotEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$JackpotEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _JackpotEntry&&(identical(other.gameId, gameId) || other.gameId == gameId)&&(identical(other.gameName, gameName) || other.gameName == gameName)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.betting, betting) || other.betting == betting));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,gameId,gameName,balance,betting);

@override
String toString() {
  return 'JackpotEntry(gameId: $gameId, gameName: $gameName, balance: $balance, betting: $betting)';
}

}

abstract mixin class _$JackpotEntryCopyWith<$Res> implements $JackpotEntryCopyWith<$Res> {
  factory _$JackpotEntryCopyWith(_JackpotEntry value, $Res Function(_JackpotEntry) _then) = __$JackpotEntryCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'gameId', fromJson: _parseInt) int gameId,@JsonKey(name: 'gameName') String gameName,@JsonKey(name: 'balance', fromJson: _parseNum) num balance,@JsonKey(name: 'betting', fromJson: _parseNum) num betting
});

}
class __$JackpotEntryCopyWithImpl<$Res>
    implements _$JackpotEntryCopyWith<$Res> {
  __$JackpotEntryCopyWithImpl(this._self, this._then);

  final _JackpotEntry _self;
  final $Res Function(_JackpotEntry) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? gameId = null,Object? gameName = null,Object? balance = null,Object? betting = null,}) {
  return _then(_JackpotEntry(
gameId: null == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as int,gameName: null == gameName ? _self.gameName : gameName // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as num,betting: null == betting ? _self.betting : betting // ignore: cast_nullable_to_non_nullable
as num,
  ));
}

}

mixin _$ProviderGames {

@JsonKey(name: 'providerId') String get providerId;@JsonKey(name: 'providerName') String get providerName;@JsonKey(name: 'gameList') List<Game> get gameList;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProviderGamesCopyWith<ProviderGames> get copyWith => _$ProviderGamesCopyWithImpl<ProviderGames>(this as ProviderGames, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProviderGames&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.providerName, providerName) || other.providerName == providerName)&&const DeepCollectionEquality().equals(other.gameList, gameList));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,providerId,providerName,const DeepCollectionEquality().hash(gameList));

@override
String toString() {
  return 'ProviderGames(providerId: $providerId, providerName: $providerName, gameList: $gameList)';
}

}

abstract mixin class $ProviderGamesCopyWith<$Res>  {
  factory $ProviderGamesCopyWith(ProviderGames value, $Res Function(ProviderGames) _then) = _$ProviderGamesCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'providerId') String providerId,@JsonKey(name: 'providerName') String providerName,@JsonKey(name: 'gameList') List<Game> gameList
});

}
class _$ProviderGamesCopyWithImpl<$Res>
    implements $ProviderGamesCopyWith<$Res> {
  _$ProviderGamesCopyWithImpl(this._self, this._then);

  final ProviderGames _self;
  final $Res Function(ProviderGames) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? providerId = null,Object? providerName = null,Object? gameList = null,}) {
  return _then(_self.copyWith(
providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String,providerName: null == providerName ? _self.providerName : providerName // ignore: cast_nullable_to_non_nullable
as String,gameList: null == gameList ? _self.gameList : gameList // ignore: cast_nullable_to_non_nullable
as List<Game>,
  ));
}

}

extension ProviderGamesPatterns on ProviderGames {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProviderGames value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProviderGames() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProviderGames value)  $default,){
final _that = this;
switch (_that) {
case _ProviderGames():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProviderGames value)?  $default,){
final _that = this;
switch (_that) {
case _ProviderGames() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'providerId')  String providerId, @JsonKey(name: 'providerName')  String providerName, @JsonKey(name: 'gameList')  List<Game> gameList)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProviderGames() when $default != null:
return $default(_that.providerId,_that.providerName,_that.gameList);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'providerId')  String providerId, @JsonKey(name: 'providerName')  String providerName, @JsonKey(name: 'gameList')  List<Game> gameList)  $default,) {final _that = this;
switch (_that) {
case _ProviderGames():
return $default(_that.providerId,_that.providerName,_that.gameList);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'providerId')  String providerId, @JsonKey(name: 'providerName')  String providerName, @JsonKey(name: 'gameList')  List<Game> gameList)?  $default,) {final _that = this;
switch (_that) {
case _ProviderGames() when $default != null:
return $default(_that.providerId,_that.providerName,_that.gameList);case _:
  return null;

}
}

}

@JsonSerializable()

class _ProviderGames implements ProviderGames {
  const _ProviderGames({@JsonKey(name: 'providerId') required this.providerId, @JsonKey(name: 'providerName') required this.providerName, @JsonKey(name: 'gameList') final  List<Game> gameList = const []}): _gameList = gameList;
  factory _ProviderGames.fromJson(Map<String, dynamic> json) => _$ProviderGamesFromJson(json);

@override@JsonKey(name: 'providerId') final  String providerId;
@override@JsonKey(name: 'providerName') final  String providerName;
 final  List<Game> _gameList;
@override@JsonKey(name: 'gameList') List<Game> get gameList {
  if (_gameList is EqualUnmodifiableListView) return _gameList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_gameList);
}

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProviderGamesCopyWith<_ProviderGames> get copyWith => __$ProviderGamesCopyWithImpl<_ProviderGames>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProviderGamesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProviderGames&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.providerName, providerName) || other.providerName == providerName)&&const DeepCollectionEquality().equals(other._gameList, _gameList));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,providerId,providerName,const DeepCollectionEquality().hash(_gameList));

@override
String toString() {
  return 'ProviderGames(providerId: $providerId, providerName: $providerName, gameList: $gameList)';
}

}

abstract mixin class _$ProviderGamesCopyWith<$Res> implements $ProviderGamesCopyWith<$Res> {
  factory _$ProviderGamesCopyWith(_ProviderGames value, $Res Function(_ProviderGames) _then) = __$ProviderGamesCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'providerId') String providerId,@JsonKey(name: 'providerName') String providerName,@JsonKey(name: 'gameList') List<Game> gameList
});

}
class __$ProviderGamesCopyWithImpl<$Res>
    implements _$ProviderGamesCopyWith<$Res> {
  __$ProviderGamesCopyWithImpl(this._self, this._then);

  final _ProviderGames _self;
  final $Res Function(_ProviderGames) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? providerId = null,Object? providerName = null,Object? gameList = null,}) {
  return _then(_ProviderGames(
providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String,providerName: null == providerName ? _self.providerName : providerName // ignore: cast_nullable_to_non_nullable
as String,gameList: null == gameList ? _self._gameList : gameList // ignore: cast_nullable_to_non_nullable
as List<Game>,
  ));
}

}

mixin _$Game {

@JsonKey(name: 'productId') String get productId;@JsonKey(name: 'gameCode') String get gameCode;@JsonKey(name: 'gameName') String get gameName;@JsonKey(name: 'lang') String get lang;@JsonKey(name: 'lobbyUrl') String get lobbyUrl;@JsonKey(name: 'cashierUrl') String get cashierUrl;@JsonKey(name: 'gameType', fromJson: GameType.fromJson, toJson: GameType.toJson) GameType get gameType;@JsonKey(name: 'mobileLogin') bool get mobileLogin;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameCopyWith<Game> get copyWith => _$GameCopyWithImpl<Game>(this as Game, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Game&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.gameCode, gameCode) || other.gameCode == gameCode)&&(identical(other.gameName, gameName) || other.gameName == gameName)&&(identical(other.lang, lang) || other.lang == lang)&&(identical(other.lobbyUrl, lobbyUrl) || other.lobbyUrl == lobbyUrl)&&(identical(other.cashierUrl, cashierUrl) || other.cashierUrl == cashierUrl)&&(identical(other.gameType, gameType) || other.gameType == gameType)&&(identical(other.mobileLogin, mobileLogin) || other.mobileLogin == mobileLogin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,gameCode,gameName,lang,lobbyUrl,cashierUrl,gameType,mobileLogin);

@override
String toString() {
  return 'Game(productId: $productId, gameCode: $gameCode, gameName: $gameName, lang: $lang, lobbyUrl: $lobbyUrl, cashierUrl: $cashierUrl, gameType: $gameType, mobileLogin: $mobileLogin)';
}

}

abstract mixin class $GameCopyWith<$Res>  {
  factory $GameCopyWith(Game value, $Res Function(Game) _then) = _$GameCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'productId') String productId,@JsonKey(name: 'gameCode') String gameCode,@JsonKey(name: 'gameName') String gameName,@JsonKey(name: 'lang') String lang,@JsonKey(name: 'lobbyUrl') String lobbyUrl,@JsonKey(name: 'cashierUrl') String cashierUrl,@JsonKey(name: 'gameType', fromJson: GameType.fromJson, toJson: GameType.toJson) GameType gameType,@JsonKey(name: 'mobileLogin') bool mobileLogin
});

}
class _$GameCopyWithImpl<$Res>
    implements $GameCopyWith<$Res> {
  _$GameCopyWithImpl(this._self, this._then);

  final Game _self;
  final $Res Function(Game) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? gameCode = null,Object? gameName = null,Object? lang = null,Object? lobbyUrl = null,Object? cashierUrl = null,Object? gameType = null,Object? mobileLogin = null,}) {
  return _then(_self.copyWith(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,gameCode: null == gameCode ? _self.gameCode : gameCode // ignore: cast_nullable_to_non_nullable
as String,gameName: null == gameName ? _self.gameName : gameName // ignore: cast_nullable_to_non_nullable
as String,lang: null == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as String,lobbyUrl: null == lobbyUrl ? _self.lobbyUrl : lobbyUrl // ignore: cast_nullable_to_non_nullable
as String,cashierUrl: null == cashierUrl ? _self.cashierUrl : cashierUrl // ignore: cast_nullable_to_non_nullable
as String,gameType: null == gameType ? _self.gameType : gameType // ignore: cast_nullable_to_non_nullable
as GameType,mobileLogin: null == mobileLogin ? _self.mobileLogin : mobileLogin // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}

extension GamePatterns on Game {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Game value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Game() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Game value)  $default,){
final _that = this;
switch (_that) {
case _Game():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Game value)?  $default,){
final _that = this;
switch (_that) {
case _Game() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'productId')  String productId, @JsonKey(name: 'gameCode')  String gameCode, @JsonKey(name: 'gameName')  String gameName, @JsonKey(name: 'lang')  String lang, @JsonKey(name: 'lobbyUrl')  String lobbyUrl, @JsonKey(name: 'cashierUrl')  String cashierUrl, @JsonKey(name: 'gameType', fromJson: GameType.fromJson, toJson: GameType.toJson)  GameType gameType, @JsonKey(name: 'mobileLogin')  bool mobileLogin)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Game() when $default != null:
return $default(_that.productId,_that.gameCode,_that.gameName,_that.lang,_that.lobbyUrl,_that.cashierUrl,_that.gameType,_that.mobileLogin);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'productId')  String productId, @JsonKey(name: 'gameCode')  String gameCode, @JsonKey(name: 'gameName')  String gameName, @JsonKey(name: 'lang')  String lang, @JsonKey(name: 'lobbyUrl')  String lobbyUrl, @JsonKey(name: 'cashierUrl')  String cashierUrl, @JsonKey(name: 'gameType', fromJson: GameType.fromJson, toJson: GameType.toJson)  GameType gameType, @JsonKey(name: 'mobileLogin')  bool mobileLogin)  $default,) {final _that = this;
switch (_that) {
case _Game():
return $default(_that.productId,_that.gameCode,_that.gameName,_that.lang,_that.lobbyUrl,_that.cashierUrl,_that.gameType,_that.mobileLogin);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'productId')  String productId, @JsonKey(name: 'gameCode')  String gameCode, @JsonKey(name: 'gameName')  String gameName, @JsonKey(name: 'lang')  String lang, @JsonKey(name: 'lobbyUrl')  String lobbyUrl, @JsonKey(name: 'cashierUrl')  String cashierUrl, @JsonKey(name: 'gameType', fromJson: GameType.fromJson, toJson: GameType.toJson)  GameType gameType, @JsonKey(name: 'mobileLogin')  bool mobileLogin)?  $default,) {final _that = this;
switch (_that) {
case _Game() when $default != null:
return $default(_that.productId,_that.gameCode,_that.gameName,_that.lang,_that.lobbyUrl,_that.cashierUrl,_that.gameType,_that.mobileLogin);case _:
  return null;

}
}

}

@JsonSerializable()

class _Game implements Game {
  const _Game({@JsonKey(name: 'productId') required this.productId, @JsonKey(name: 'gameCode') required this.gameCode, @JsonKey(name: 'gameName') required this.gameName, @JsonKey(name: 'lang') required this.lang, @JsonKey(name: 'lobbyUrl') required this.lobbyUrl, @JsonKey(name: 'cashierUrl') required this.cashierUrl, @JsonKey(name: 'gameType', fromJson: GameType.fromJson, toJson: GameType.toJson) required this.gameType, @JsonKey(name: 'mobileLogin') this.mobileLogin = false});
  factory _Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);

@override@JsonKey(name: 'productId') final  String productId;
@override@JsonKey(name: 'gameCode') final  String gameCode;
@override@JsonKey(name: 'gameName') final  String gameName;
@override@JsonKey(name: 'lang') final  String lang;
@override@JsonKey(name: 'lobbyUrl') final  String lobbyUrl;
@override@JsonKey(name: 'cashierUrl') final  String cashierUrl;
@override@JsonKey(name: 'gameType', fromJson: GameType.fromJson, toJson: GameType.toJson) final  GameType gameType;
@override@JsonKey(name: 'mobileLogin') final  bool mobileLogin;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameCopyWith<_Game> get copyWith => __$GameCopyWithImpl<_Game>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GameToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Game&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.gameCode, gameCode) || other.gameCode == gameCode)&&(identical(other.gameName, gameName) || other.gameName == gameName)&&(identical(other.lang, lang) || other.lang == lang)&&(identical(other.lobbyUrl, lobbyUrl) || other.lobbyUrl == lobbyUrl)&&(identical(other.cashierUrl, cashierUrl) || other.cashierUrl == cashierUrl)&&(identical(other.gameType, gameType) || other.gameType == gameType)&&(identical(other.mobileLogin, mobileLogin) || other.mobileLogin == mobileLogin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,gameCode,gameName,lang,lobbyUrl,cashierUrl,gameType,mobileLogin);

@override
String toString() {
  return 'Game(productId: $productId, gameCode: $gameCode, gameName: $gameName, lang: $lang, lobbyUrl: $lobbyUrl, cashierUrl: $cashierUrl, gameType: $gameType, mobileLogin: $mobileLogin)';
}

}

abstract mixin class _$GameCopyWith<$Res> implements $GameCopyWith<$Res> {
  factory _$GameCopyWith(_Game value, $Res Function(_Game) _then) = __$GameCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'productId') String productId,@JsonKey(name: 'gameCode') String gameCode,@JsonKey(name: 'gameName') String gameName,@JsonKey(name: 'lang') String lang,@JsonKey(name: 'lobbyUrl') String lobbyUrl,@JsonKey(name: 'cashierUrl') String cashierUrl,@JsonKey(name: 'gameType', fromJson: GameType.fromJson, toJson: GameType.toJson) GameType gameType,@JsonKey(name: 'mobileLogin') bool mobileLogin
});

}
class __$GameCopyWithImpl<$Res>
    implements _$GameCopyWith<$Res> {
  __$GameCopyWithImpl(this._self, this._then);

  final _Game _self;
  final $Res Function(_Game) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? gameCode = null,Object? gameName = null,Object? lang = null,Object? lobbyUrl = null,Object? cashierUrl = null,Object? gameType = null,Object? mobileLogin = null,}) {
  return _then(_Game(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,gameCode: null == gameCode ? _self.gameCode : gameCode // ignore: cast_nullable_to_non_nullable
as String,gameName: null == gameName ? _self.gameName : gameName // ignore: cast_nullable_to_non_nullable
as String,lang: null == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as String,lobbyUrl: null == lobbyUrl ? _self.lobbyUrl : lobbyUrl // ignore: cast_nullable_to_non_nullable
as String,cashierUrl: null == cashierUrl ? _self.cashierUrl : cashierUrl // ignore: cast_nullable_to_non_nullable
as String,gameType: null == gameType ? _self.gameType : gameType // ignore: cast_nullable_to_non_nullable
as GameType,mobileLogin: null == mobileLogin ? _self.mobileLogin : mobileLogin // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}

// dart format on
