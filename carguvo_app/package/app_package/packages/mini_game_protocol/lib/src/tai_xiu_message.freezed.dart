// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tai_xiu_message.dart';

// dart format off
T _$identity<T>(T value) => value;
mixin _$TaiXiuMessage {

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaiXiuMessage);
}

@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TaiXiuMessage()';
}

}

class $TaiXiuMessageCopyWith<$Res>  {
$TaiXiuMessageCopyWith(TaiXiuMessage _, $Res Function(TaiXiuMessage) __);
}

extension TaiXiuMessagePatterns on TaiXiuMessage {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( TaiXiuSubscribeInfo value)?  subscribeInfo,TResult Function( TaiXiuBet value)?  bet,TResult Function( TaiXiuStartGame value)?  startGame,TResult Function( TaiXiuShowResult value)?  showResult,TResult Function( TaiXiuCalculateResultMoney value)?  calculateResultMoney,TResult Function( TaiXiuSessionAnalytic value)?  sessionAnalytic,TResult Function( TaiXiuUpdateBetInfo value)?  updateBetInfo,TResult Function( TaiXiuGetBetHistory value)?  getBetHistory,TResult Function( TaiXiuBetFree value)?  betFree,TResult Function( TaiXiuChat value)?  chat,required TResult orElse(),}){
final _that = this;
switch (_that) {
case TaiXiuSubscribeInfo() when subscribeInfo != null:
return subscribeInfo(_that);case TaiXiuBet() when bet != null:
return bet(_that);case TaiXiuStartGame() when startGame != null:
return startGame(_that);case TaiXiuShowResult() when showResult != null:
return showResult(_that);case TaiXiuCalculateResultMoney() when calculateResultMoney != null:
return calculateResultMoney(_that);case TaiXiuSessionAnalytic() when sessionAnalytic != null:
return sessionAnalytic(_that);case TaiXiuUpdateBetInfo() when updateBetInfo != null:
return updateBetInfo(_that);case TaiXiuGetBetHistory() when getBetHistory != null:
return getBetHistory(_that);case TaiXiuBetFree() when betFree != null:
return betFree(_that);case TaiXiuChat() when chat != null:
return chat(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( TaiXiuSubscribeInfo value)  subscribeInfo,required TResult Function( TaiXiuBet value)  bet,required TResult Function( TaiXiuStartGame value)  startGame,required TResult Function( TaiXiuShowResult value)  showResult,required TResult Function( TaiXiuCalculateResultMoney value)  calculateResultMoney,required TResult Function( TaiXiuSessionAnalytic value)  sessionAnalytic,required TResult Function( TaiXiuUpdateBetInfo value)  updateBetInfo,required TResult Function( TaiXiuGetBetHistory value)  getBetHistory,required TResult Function( TaiXiuBetFree value)  betFree,required TResult Function( TaiXiuChat value)  chat,}){
final _that = this;
switch (_that) {
case TaiXiuSubscribeInfo():
return subscribeInfo(_that);case TaiXiuBet():
return bet(_that);case TaiXiuStartGame():
return startGame(_that);case TaiXiuShowResult():
return showResult(_that);case TaiXiuCalculateResultMoney():
return calculateResultMoney(_that);case TaiXiuSessionAnalytic():
return sessionAnalytic(_that);case TaiXiuUpdateBetInfo():
return updateBetInfo(_that);case TaiXiuGetBetHistory():
return getBetHistory(_that);case TaiXiuBetFree():
return betFree(_that);case TaiXiuChat():
return chat(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( TaiXiuSubscribeInfo value)?  subscribeInfo,TResult? Function( TaiXiuBet value)?  bet,TResult? Function( TaiXiuStartGame value)?  startGame,TResult? Function( TaiXiuShowResult value)?  showResult,TResult? Function( TaiXiuCalculateResultMoney value)?  calculateResultMoney,TResult? Function( TaiXiuSessionAnalytic value)?  sessionAnalytic,TResult? Function( TaiXiuUpdateBetInfo value)?  updateBetInfo,TResult? Function( TaiXiuGetBetHistory value)?  getBetHistory,TResult? Function( TaiXiuBetFree value)?  betFree,TResult? Function( TaiXiuChat value)?  chat,}){
final _that = this;
switch (_that) {
case TaiXiuSubscribeInfo() when subscribeInfo != null:
return subscribeInfo(_that);case TaiXiuBet() when bet != null:
return bet(_that);case TaiXiuStartGame() when startGame != null:
return startGame(_that);case TaiXiuShowResult() when showResult != null:
return showResult(_that);case TaiXiuCalculateResultMoney() when calculateResultMoney != null:
return calculateResultMoney(_that);case TaiXiuSessionAnalytic() when sessionAnalytic != null:
return sessionAnalytic(_that);case TaiXiuUpdateBetInfo() when updateBetInfo != null:
return updateBetInfo(_that);case TaiXiuGetBetHistory() when getBetHistory != null:
return getBetHistory(_that);case TaiXiuBetFree() when betFree != null:
return betFree(_that);case TaiXiuChat() when chat != null:
return chat(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int sessionId,  int gameState,  double remainingTimeSec,  double timeForBettingSec,  double timeForPayingSec,  List<dynamic> history,  Map<String, dynamic> gameInfo,  List<dynamic> chatHistory,  int availableGold,  int availableChip,  int freeBetTimes,  int freeBetAmount,  bool enableEvent,  String? eventMessage,  String? eventUrl)?  subscribeInfo,TResult Function( int accountId,  int entryId,  int thisBet,  int totalEntryBet,  int totalUsers,  int availableBalance)?  bet,TResult Function( int sessionId)?  startGame,TResult Function( int d1,  int d2,  int d3)?  showResult,TResult Function( int gold,  int chip,  int goldExchange,  int chipExchange,  int availableGold,  int availableChip,  int goldRefund,  int chipRefund,  int goldBet,  int chipBet,  int goldBalanceBet,  int chipBalanceBet)?  calculateResultMoney,TResult Function( List<dynamic> betStats,  int sessionId,  int? d1,  int? d2,  int? d3,  int? startTime,  bool ended)?  sessionAnalytic,TResult Function( List<dynamic> betArr)?  updateBetInfo,TResult Function( List<dynamic> items,  int accountId)?  getBetHistory,TResult Function()?  betFree,TResult Function( Map<String, dynamic> entry)?  chat,required TResult orElse(),}) {final _that = this;
switch (_that) {
case TaiXiuSubscribeInfo() when subscribeInfo != null:
return subscribeInfo(_that.sessionId,_that.gameState,_that.remainingTimeSec,_that.timeForBettingSec,_that.timeForPayingSec,_that.history,_that.gameInfo,_that.chatHistory,_that.availableGold,_that.availableChip,_that.freeBetTimes,_that.freeBetAmount,_that.enableEvent,_that.eventMessage,_that.eventUrl);case TaiXiuBet() when bet != null:
return bet(_that.accountId,_that.entryId,_that.thisBet,_that.totalEntryBet,_that.totalUsers,_that.availableBalance);case TaiXiuStartGame() when startGame != null:
return startGame(_that.sessionId);case TaiXiuShowResult() when showResult != null:
return showResult(_that.d1,_that.d2,_that.d3);case TaiXiuCalculateResultMoney() when calculateResultMoney != null:
return calculateResultMoney(_that.gold,_that.chip,_that.goldExchange,_that.chipExchange,_that.availableGold,_that.availableChip,_that.goldRefund,_that.chipRefund,_that.goldBet,_that.chipBet,_that.goldBalanceBet,_that.chipBalanceBet);case TaiXiuSessionAnalytic() when sessionAnalytic != null:
return sessionAnalytic(_that.betStats,_that.sessionId,_that.d1,_that.d2,_that.d3,_that.startTime,_that.ended);case TaiXiuUpdateBetInfo() when updateBetInfo != null:
return updateBetInfo(_that.betArr);case TaiXiuGetBetHistory() when getBetHistory != null:
return getBetHistory(_that.items,_that.accountId);case TaiXiuBetFree() when betFree != null:
return betFree();case TaiXiuChat() when chat != null:
return chat(_that.entry);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int sessionId,  int gameState,  double remainingTimeSec,  double timeForBettingSec,  double timeForPayingSec,  List<dynamic> history,  Map<String, dynamic> gameInfo,  List<dynamic> chatHistory,  int availableGold,  int availableChip,  int freeBetTimes,  int freeBetAmount,  bool enableEvent,  String? eventMessage,  String? eventUrl)  subscribeInfo,required TResult Function( int accountId,  int entryId,  int thisBet,  int totalEntryBet,  int totalUsers,  int availableBalance)  bet,required TResult Function( int sessionId)  startGame,required TResult Function( int d1,  int d2,  int d3)  showResult,required TResult Function( int gold,  int chip,  int goldExchange,  int chipExchange,  int availableGold,  int availableChip,  int goldRefund,  int chipRefund,  int goldBet,  int chipBet,  int goldBalanceBet,  int chipBalanceBet)  calculateResultMoney,required TResult Function( List<dynamic> betStats,  int sessionId,  int? d1,  int? d2,  int? d3,  int? startTime,  bool ended)  sessionAnalytic,required TResult Function( List<dynamic> betArr)  updateBetInfo,required TResult Function( List<dynamic> items,  int accountId)  getBetHistory,required TResult Function()  betFree,required TResult Function( Map<String, dynamic> entry)  chat,}) {final _that = this;
switch (_that) {
case TaiXiuSubscribeInfo():
return subscribeInfo(_that.sessionId,_that.gameState,_that.remainingTimeSec,_that.timeForBettingSec,_that.timeForPayingSec,_that.history,_that.gameInfo,_that.chatHistory,_that.availableGold,_that.availableChip,_that.freeBetTimes,_that.freeBetAmount,_that.enableEvent,_that.eventMessage,_that.eventUrl);case TaiXiuBet():
return bet(_that.accountId,_that.entryId,_that.thisBet,_that.totalEntryBet,_that.totalUsers,_that.availableBalance);case TaiXiuStartGame():
return startGame(_that.sessionId);case TaiXiuShowResult():
return showResult(_that.d1,_that.d2,_that.d3);case TaiXiuCalculateResultMoney():
return calculateResultMoney(_that.gold,_that.chip,_that.goldExchange,_that.chipExchange,_that.availableGold,_that.availableChip,_that.goldRefund,_that.chipRefund,_that.goldBet,_that.chipBet,_that.goldBalanceBet,_that.chipBalanceBet);case TaiXiuSessionAnalytic():
return sessionAnalytic(_that.betStats,_that.sessionId,_that.d1,_that.d2,_that.d3,_that.startTime,_that.ended);case TaiXiuUpdateBetInfo():
return updateBetInfo(_that.betArr);case TaiXiuGetBetHistory():
return getBetHistory(_that.items,_that.accountId);case TaiXiuBetFree():
return betFree();case TaiXiuChat():
return chat(_that.entry);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int sessionId,  int gameState,  double remainingTimeSec,  double timeForBettingSec,  double timeForPayingSec,  List<dynamic> history,  Map<String, dynamic> gameInfo,  List<dynamic> chatHistory,  int availableGold,  int availableChip,  int freeBetTimes,  int freeBetAmount,  bool enableEvent,  String? eventMessage,  String? eventUrl)?  subscribeInfo,TResult? Function( int accountId,  int entryId,  int thisBet,  int totalEntryBet,  int totalUsers,  int availableBalance)?  bet,TResult? Function( int sessionId)?  startGame,TResult? Function( int d1,  int d2,  int d3)?  showResult,TResult? Function( int gold,  int chip,  int goldExchange,  int chipExchange,  int availableGold,  int availableChip,  int goldRefund,  int chipRefund,  int goldBet,  int chipBet,  int goldBalanceBet,  int chipBalanceBet)?  calculateResultMoney,TResult? Function( List<dynamic> betStats,  int sessionId,  int? d1,  int? d2,  int? d3,  int? startTime,  bool ended)?  sessionAnalytic,TResult? Function( List<dynamic> betArr)?  updateBetInfo,TResult? Function( List<dynamic> items,  int accountId)?  getBetHistory,TResult? Function()?  betFree,TResult? Function( Map<String, dynamic> entry)?  chat,}) {final _that = this;
switch (_that) {
case TaiXiuSubscribeInfo() when subscribeInfo != null:
return subscribeInfo(_that.sessionId,_that.gameState,_that.remainingTimeSec,_that.timeForBettingSec,_that.timeForPayingSec,_that.history,_that.gameInfo,_that.chatHistory,_that.availableGold,_that.availableChip,_that.freeBetTimes,_that.freeBetAmount,_that.enableEvent,_that.eventMessage,_that.eventUrl);case TaiXiuBet() when bet != null:
return bet(_that.accountId,_that.entryId,_that.thisBet,_that.totalEntryBet,_that.totalUsers,_that.availableBalance);case TaiXiuStartGame() when startGame != null:
return startGame(_that.sessionId);case TaiXiuShowResult() when showResult != null:
return showResult(_that.d1,_that.d2,_that.d3);case TaiXiuCalculateResultMoney() when calculateResultMoney != null:
return calculateResultMoney(_that.gold,_that.chip,_that.goldExchange,_that.chipExchange,_that.availableGold,_that.availableChip,_that.goldRefund,_that.chipRefund,_that.goldBet,_that.chipBet,_that.goldBalanceBet,_that.chipBalanceBet);case TaiXiuSessionAnalytic() when sessionAnalytic != null:
return sessionAnalytic(_that.betStats,_that.sessionId,_that.d1,_that.d2,_that.d3,_that.startTime,_that.ended);case TaiXiuUpdateBetInfo() when updateBetInfo != null:
return updateBetInfo(_that.betArr);case TaiXiuGetBetHistory() when getBetHistory != null:
return getBetHistory(_that.items,_that.accountId);case TaiXiuBetFree() when betFree != null:
return betFree();case TaiXiuChat() when chat != null:
return chat(_that.entry);case _:
  return null;

}
}

}

class TaiXiuSubscribeInfo implements TaiXiuMessage {
  const TaiXiuSubscribeInfo({required this.sessionId, required this.gameState, required this.remainingTimeSec, required this.timeForBettingSec, required this.timeForPayingSec, required final  List<dynamic> history, required final  Map<String, dynamic> gameInfo, required final  List<dynamic> chatHistory, this.availableGold = 0, this.availableChip = 0, this.freeBetTimes = 0, this.freeBetAmount = 0, this.enableEvent = false, this.eventMessage, this.eventUrl}): _history = history,_gameInfo = gameInfo,_chatHistory = chatHistory;
  
 final  int sessionId;
 final  int gameState;
 final  double remainingTimeSec;
 final  double timeForBettingSec;
 final  double timeForPayingSec;
 final  List<dynamic> _history;
 List<dynamic> get history {
  if (_history is EqualUnmodifiableListView) return _history;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_history);
}

 final  Map<String, dynamic> _gameInfo;
 Map<String, dynamic> get gameInfo {
  if (_gameInfo is EqualUnmodifiableMapView) return _gameInfo;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_gameInfo);
}

 final  List<dynamic> _chatHistory;
 List<dynamic> get chatHistory {
  if (_chatHistory is EqualUnmodifiableListView) return _chatHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_chatHistory);
}

@JsonKey() final  int availableGold;
@JsonKey() final  int availableChip;
@JsonKey() final  int freeBetTimes;
@JsonKey() final  int freeBetAmount;
@JsonKey() final  bool enableEvent;
 final  String? eventMessage;
 final  String? eventUrl;

@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaiXiuSubscribeInfoCopyWith<TaiXiuSubscribeInfo> get copyWith => _$TaiXiuSubscribeInfoCopyWithImpl<TaiXiuSubscribeInfo>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaiXiuSubscribeInfo&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.gameState, gameState) || other.gameState == gameState)&&(identical(other.remainingTimeSec, remainingTimeSec) || other.remainingTimeSec == remainingTimeSec)&&(identical(other.timeForBettingSec, timeForBettingSec) || other.timeForBettingSec == timeForBettingSec)&&(identical(other.timeForPayingSec, timeForPayingSec) || other.timeForPayingSec == timeForPayingSec)&&const DeepCollectionEquality().equals(other._history, _history)&&const DeepCollectionEquality().equals(other._gameInfo, _gameInfo)&&const DeepCollectionEquality().equals(other._chatHistory, _chatHistory)&&(identical(other.availableGold, availableGold) || other.availableGold == availableGold)&&(identical(other.availableChip, availableChip) || other.availableChip == availableChip)&&(identical(other.freeBetTimes, freeBetTimes) || other.freeBetTimes == freeBetTimes)&&(identical(other.freeBetAmount, freeBetAmount) || other.freeBetAmount == freeBetAmount)&&(identical(other.enableEvent, enableEvent) || other.enableEvent == enableEvent)&&(identical(other.eventMessage, eventMessage) || other.eventMessage == eventMessage)&&(identical(other.eventUrl, eventUrl) || other.eventUrl == eventUrl));
}

@override
int get hashCode => Object.hash(runtimeType,sessionId,gameState,remainingTimeSec,timeForBettingSec,timeForPayingSec,const DeepCollectionEquality().hash(_history),const DeepCollectionEquality().hash(_gameInfo),const DeepCollectionEquality().hash(_chatHistory),availableGold,availableChip,freeBetTimes,freeBetAmount,enableEvent,eventMessage,eventUrl);

@override
String toString() {
  return 'TaiXiuMessage.subscribeInfo(sessionId: $sessionId, gameState: $gameState, remainingTimeSec: $remainingTimeSec, timeForBettingSec: $timeForBettingSec, timeForPayingSec: $timeForPayingSec, history: $history, gameInfo: $gameInfo, chatHistory: $chatHistory, availableGold: $availableGold, availableChip: $availableChip, freeBetTimes: $freeBetTimes, freeBetAmount: $freeBetAmount, enableEvent: $enableEvent, eventMessage: $eventMessage, eventUrl: $eventUrl)';
}

}

abstract mixin class $TaiXiuSubscribeInfoCopyWith<$Res> implements $TaiXiuMessageCopyWith<$Res> {
  factory $TaiXiuSubscribeInfoCopyWith(TaiXiuSubscribeInfo value, $Res Function(TaiXiuSubscribeInfo) _then) = _$TaiXiuSubscribeInfoCopyWithImpl;
@useResult
$Res call({
 int sessionId, int gameState, double remainingTimeSec, double timeForBettingSec, double timeForPayingSec, List<dynamic> history, Map<String, dynamic> gameInfo, List<dynamic> chatHistory, int availableGold, int availableChip, int freeBetTimes, int freeBetAmount, bool enableEvent, String? eventMessage, String? eventUrl
});

}
class _$TaiXiuSubscribeInfoCopyWithImpl<$Res>
    implements $TaiXiuSubscribeInfoCopyWith<$Res> {
  _$TaiXiuSubscribeInfoCopyWithImpl(this._self, this._then);

  final TaiXiuSubscribeInfo _self;
  final $Res Function(TaiXiuSubscribeInfo) _then;

@pragma('vm:prefer-inline') $Res call({Object? sessionId = null,Object? gameState = null,Object? remainingTimeSec = null,Object? timeForBettingSec = null,Object? timeForPayingSec = null,Object? history = null,Object? gameInfo = null,Object? chatHistory = null,Object? availableGold = null,Object? availableChip = null,Object? freeBetTimes = null,Object? freeBetAmount = null,Object? enableEvent = null,Object? eventMessage = freezed,Object? eventUrl = freezed,}) {
  return _then(TaiXiuSubscribeInfo(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as int,gameState: null == gameState ? _self.gameState : gameState // ignore: cast_nullable_to_non_nullable
as int,remainingTimeSec: null == remainingTimeSec ? _self.remainingTimeSec : remainingTimeSec // ignore: cast_nullable_to_non_nullable
as double,timeForBettingSec: null == timeForBettingSec ? _self.timeForBettingSec : timeForBettingSec // ignore: cast_nullable_to_non_nullable
as double,timeForPayingSec: null == timeForPayingSec ? _self.timeForPayingSec : timeForPayingSec // ignore: cast_nullable_to_non_nullable
as double,history: null == history ? _self._history : history // ignore: cast_nullable_to_non_nullable
as List<dynamic>,gameInfo: null == gameInfo ? _self._gameInfo : gameInfo // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,chatHistory: null == chatHistory ? _self._chatHistory : chatHistory // ignore: cast_nullable_to_non_nullable
as List<dynamic>,availableGold: null == availableGold ? _self.availableGold : availableGold // ignore: cast_nullable_to_non_nullable
as int,availableChip: null == availableChip ? _self.availableChip : availableChip // ignore: cast_nullable_to_non_nullable
as int,freeBetTimes: null == freeBetTimes ? _self.freeBetTimes : freeBetTimes // ignore: cast_nullable_to_non_nullable
as int,freeBetAmount: null == freeBetAmount ? _self.freeBetAmount : freeBetAmount // ignore: cast_nullable_to_non_nullable
as int,enableEvent: null == enableEvent ? _self.enableEvent : enableEvent // ignore: cast_nullable_to_non_nullable
as bool,eventMessage: freezed == eventMessage ? _self.eventMessage : eventMessage // ignore: cast_nullable_to_non_nullable
as String?,eventUrl: freezed == eventUrl ? _self.eventUrl : eventUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}

class TaiXiuBet implements TaiXiuMessage {
  const TaiXiuBet({required this.accountId, required this.entryId, required this.thisBet, required this.totalEntryBet, required this.totalUsers, this.availableBalance = 0});
  
 final  int accountId;
 final  int entryId;
 final  int thisBet;
 final  int totalEntryBet;
 final  int totalUsers;
@JsonKey() final  int availableBalance;

@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaiXiuBetCopyWith<TaiXiuBet> get copyWith => _$TaiXiuBetCopyWithImpl<TaiXiuBet>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaiXiuBet&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.entryId, entryId) || other.entryId == entryId)&&(identical(other.thisBet, thisBet) || other.thisBet == thisBet)&&(identical(other.totalEntryBet, totalEntryBet) || other.totalEntryBet == totalEntryBet)&&(identical(other.totalUsers, totalUsers) || other.totalUsers == totalUsers)&&(identical(other.availableBalance, availableBalance) || other.availableBalance == availableBalance));
}

@override
int get hashCode => Object.hash(runtimeType,accountId,entryId,thisBet,totalEntryBet,totalUsers,availableBalance);

@override
String toString() {
  return 'TaiXiuMessage.bet(accountId: $accountId, entryId: $entryId, thisBet: $thisBet, totalEntryBet: $totalEntryBet, totalUsers: $totalUsers, availableBalance: $availableBalance)';
}

}

abstract mixin class $TaiXiuBetCopyWith<$Res> implements $TaiXiuMessageCopyWith<$Res> {
  factory $TaiXiuBetCopyWith(TaiXiuBet value, $Res Function(TaiXiuBet) _then) = _$TaiXiuBetCopyWithImpl;
@useResult
$Res call({
 int accountId, int entryId, int thisBet, int totalEntryBet, int totalUsers, int availableBalance
});

}
class _$TaiXiuBetCopyWithImpl<$Res>
    implements $TaiXiuBetCopyWith<$Res> {
  _$TaiXiuBetCopyWithImpl(this._self, this._then);

  final TaiXiuBet _self;
  final $Res Function(TaiXiuBet) _then;

@pragma('vm:prefer-inline') $Res call({Object? accountId = null,Object? entryId = null,Object? thisBet = null,Object? totalEntryBet = null,Object? totalUsers = null,Object? availableBalance = null,}) {
  return _then(TaiXiuBet(
accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as int,entryId: null == entryId ? _self.entryId : entryId // ignore: cast_nullable_to_non_nullable
as int,thisBet: null == thisBet ? _self.thisBet : thisBet // ignore: cast_nullable_to_non_nullable
as int,totalEntryBet: null == totalEntryBet ? _self.totalEntryBet : totalEntryBet // ignore: cast_nullable_to_non_nullable
as int,totalUsers: null == totalUsers ? _self.totalUsers : totalUsers // ignore: cast_nullable_to_non_nullable
as int,availableBalance: null == availableBalance ? _self.availableBalance : availableBalance // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}

class TaiXiuStartGame implements TaiXiuMessage {
  const TaiXiuStartGame({required this.sessionId});
  
 final  int sessionId;

@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaiXiuStartGameCopyWith<TaiXiuStartGame> get copyWith => _$TaiXiuStartGameCopyWithImpl<TaiXiuStartGame>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaiXiuStartGame&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId));
}

@override
int get hashCode => Object.hash(runtimeType,sessionId);

@override
String toString() {
  return 'TaiXiuMessage.startGame(sessionId: $sessionId)';
}

}

abstract mixin class $TaiXiuStartGameCopyWith<$Res> implements $TaiXiuMessageCopyWith<$Res> {
  factory $TaiXiuStartGameCopyWith(TaiXiuStartGame value, $Res Function(TaiXiuStartGame) _then) = _$TaiXiuStartGameCopyWithImpl;
@useResult
$Res call({
 int sessionId
});

}
class _$TaiXiuStartGameCopyWithImpl<$Res>
    implements $TaiXiuStartGameCopyWith<$Res> {
  _$TaiXiuStartGameCopyWithImpl(this._self, this._then);

  final TaiXiuStartGame _self;
  final $Res Function(TaiXiuStartGame) _then;

@pragma('vm:prefer-inline') $Res call({Object? sessionId = null,}) {
  return _then(TaiXiuStartGame(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}

class TaiXiuShowResult implements TaiXiuMessage {
  const TaiXiuShowResult({required this.d1, required this.d2, required this.d3});
  
 final  int d1;
 final  int d2;
 final  int d3;

@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaiXiuShowResultCopyWith<TaiXiuShowResult> get copyWith => _$TaiXiuShowResultCopyWithImpl<TaiXiuShowResult>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaiXiuShowResult&&(identical(other.d1, d1) || other.d1 == d1)&&(identical(other.d2, d2) || other.d2 == d2)&&(identical(other.d3, d3) || other.d3 == d3));
}

@override
int get hashCode => Object.hash(runtimeType,d1,d2,d3);

@override
String toString() {
  return 'TaiXiuMessage.showResult(d1: $d1, d2: $d2, d3: $d3)';
}

}

abstract mixin class $TaiXiuShowResultCopyWith<$Res> implements $TaiXiuMessageCopyWith<$Res> {
  factory $TaiXiuShowResultCopyWith(TaiXiuShowResult value, $Res Function(TaiXiuShowResult) _then) = _$TaiXiuShowResultCopyWithImpl;
@useResult
$Res call({
 int d1, int d2, int d3
});

}
class _$TaiXiuShowResultCopyWithImpl<$Res>
    implements $TaiXiuShowResultCopyWith<$Res> {
  _$TaiXiuShowResultCopyWithImpl(this._self, this._then);

  final TaiXiuShowResult _self;
  final $Res Function(TaiXiuShowResult) _then;

@pragma('vm:prefer-inline') $Res call({Object? d1 = null,Object? d2 = null,Object? d3 = null,}) {
  return _then(TaiXiuShowResult(
d1: null == d1 ? _self.d1 : d1 // ignore: cast_nullable_to_non_nullable
as int,d2: null == d2 ? _self.d2 : d2 // ignore: cast_nullable_to_non_nullable
as int,d3: null == d3 ? _self.d3 : d3 // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}

class TaiXiuCalculateResultMoney implements TaiXiuMessage {
  const TaiXiuCalculateResultMoney({this.gold = 0, this.chip = 0, this.goldExchange = 0, this.chipExchange = 0, this.availableGold = 0, this.availableChip = 0, this.goldRefund = 0, this.chipRefund = 0, this.goldBet = 0, this.chipBet = 0, this.goldBalanceBet = 0, this.chipBalanceBet = 0});
  
@JsonKey() final  int gold;
@JsonKey() final  int chip;
@JsonKey() final  int goldExchange;
@JsonKey() final  int chipExchange;
@JsonKey() final  int availableGold;
@JsonKey() final  int availableChip;
@JsonKey() final  int goldRefund;
@JsonKey() final  int chipRefund;
@JsonKey() final  int goldBet;
@JsonKey() final  int chipBet;
@JsonKey() final  int goldBalanceBet;
@JsonKey() final  int chipBalanceBet;

@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaiXiuCalculateResultMoneyCopyWith<TaiXiuCalculateResultMoney> get copyWith => _$TaiXiuCalculateResultMoneyCopyWithImpl<TaiXiuCalculateResultMoney>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaiXiuCalculateResultMoney&&(identical(other.gold, gold) || other.gold == gold)&&(identical(other.chip, chip) || other.chip == chip)&&(identical(other.goldExchange, goldExchange) || other.goldExchange == goldExchange)&&(identical(other.chipExchange, chipExchange) || other.chipExchange == chipExchange)&&(identical(other.availableGold, availableGold) || other.availableGold == availableGold)&&(identical(other.availableChip, availableChip) || other.availableChip == availableChip)&&(identical(other.goldRefund, goldRefund) || other.goldRefund == goldRefund)&&(identical(other.chipRefund, chipRefund) || other.chipRefund == chipRefund)&&(identical(other.goldBet, goldBet) || other.goldBet == goldBet)&&(identical(other.chipBet, chipBet) || other.chipBet == chipBet)&&(identical(other.goldBalanceBet, goldBalanceBet) || other.goldBalanceBet == goldBalanceBet)&&(identical(other.chipBalanceBet, chipBalanceBet) || other.chipBalanceBet == chipBalanceBet));
}

@override
int get hashCode => Object.hash(runtimeType,gold,chip,goldExchange,chipExchange,availableGold,availableChip,goldRefund,chipRefund,goldBet,chipBet,goldBalanceBet,chipBalanceBet);

@override
String toString() {
  return 'TaiXiuMessage.calculateResultMoney(gold: $gold, chip: $chip, goldExchange: $goldExchange, chipExchange: $chipExchange, availableGold: $availableGold, availableChip: $availableChip, goldRefund: $goldRefund, chipRefund: $chipRefund, goldBet: $goldBet, chipBet: $chipBet, goldBalanceBet: $goldBalanceBet, chipBalanceBet: $chipBalanceBet)';
}

}

abstract mixin class $TaiXiuCalculateResultMoneyCopyWith<$Res> implements $TaiXiuMessageCopyWith<$Res> {
  factory $TaiXiuCalculateResultMoneyCopyWith(TaiXiuCalculateResultMoney value, $Res Function(TaiXiuCalculateResultMoney) _then) = _$TaiXiuCalculateResultMoneyCopyWithImpl;
@useResult
$Res call({
 int gold, int chip, int goldExchange, int chipExchange, int availableGold, int availableChip, int goldRefund, int chipRefund, int goldBet, int chipBet, int goldBalanceBet, int chipBalanceBet
});

}
class _$TaiXiuCalculateResultMoneyCopyWithImpl<$Res>
    implements $TaiXiuCalculateResultMoneyCopyWith<$Res> {
  _$TaiXiuCalculateResultMoneyCopyWithImpl(this._self, this._then);

  final TaiXiuCalculateResultMoney _self;
  final $Res Function(TaiXiuCalculateResultMoney) _then;

@pragma('vm:prefer-inline') $Res call({Object? gold = null,Object? chip = null,Object? goldExchange = null,Object? chipExchange = null,Object? availableGold = null,Object? availableChip = null,Object? goldRefund = null,Object? chipRefund = null,Object? goldBet = null,Object? chipBet = null,Object? goldBalanceBet = null,Object? chipBalanceBet = null,}) {
  return _then(TaiXiuCalculateResultMoney(
gold: null == gold ? _self.gold : gold // ignore: cast_nullable_to_non_nullable
as int,chip: null == chip ? _self.chip : chip // ignore: cast_nullable_to_non_nullable
as int,goldExchange: null == goldExchange ? _self.goldExchange : goldExchange // ignore: cast_nullable_to_non_nullable
as int,chipExchange: null == chipExchange ? _self.chipExchange : chipExchange // ignore: cast_nullable_to_non_nullable
as int,availableGold: null == availableGold ? _self.availableGold : availableGold // ignore: cast_nullable_to_non_nullable
as int,availableChip: null == availableChip ? _self.availableChip : availableChip // ignore: cast_nullable_to_non_nullable
as int,goldRefund: null == goldRefund ? _self.goldRefund : goldRefund // ignore: cast_nullable_to_non_nullable
as int,chipRefund: null == chipRefund ? _self.chipRefund : chipRefund // ignore: cast_nullable_to_non_nullable
as int,goldBet: null == goldBet ? _self.goldBet : goldBet // ignore: cast_nullable_to_non_nullable
as int,chipBet: null == chipBet ? _self.chipBet : chipBet // ignore: cast_nullable_to_non_nullable
as int,goldBalanceBet: null == goldBalanceBet ? _self.goldBalanceBet : goldBalanceBet // ignore: cast_nullable_to_non_nullable
as int,chipBalanceBet: null == chipBalanceBet ? _self.chipBalanceBet : chipBalanceBet // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}

class TaiXiuSessionAnalytic implements TaiXiuMessage {
  const TaiXiuSessionAnalytic({required final  List<dynamic> betStats, required this.sessionId, this.d1, this.d2, this.d3, this.startTime, this.ended = false}): _betStats = betStats;
  
 final  List<dynamic> _betStats;
 List<dynamic> get betStats {
  if (_betStats is EqualUnmodifiableListView) return _betStats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_betStats);
}

 final  int sessionId;
 final  int? d1;
 final  int? d2;
 final  int? d3;
 final  int? startTime;
@JsonKey() final  bool ended;

@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaiXiuSessionAnalyticCopyWith<TaiXiuSessionAnalytic> get copyWith => _$TaiXiuSessionAnalyticCopyWithImpl<TaiXiuSessionAnalytic>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaiXiuSessionAnalytic&&const DeepCollectionEquality().equals(other._betStats, _betStats)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.d1, d1) || other.d1 == d1)&&(identical(other.d2, d2) || other.d2 == d2)&&(identical(other.d3, d3) || other.d3 == d3)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.ended, ended) || other.ended == ended));
}

@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_betStats),sessionId,d1,d2,d3,startTime,ended);

@override
String toString() {
  return 'TaiXiuMessage.sessionAnalytic(betStats: $betStats, sessionId: $sessionId, d1: $d1, d2: $d2, d3: $d3, startTime: $startTime, ended: $ended)';
}

}

abstract mixin class $TaiXiuSessionAnalyticCopyWith<$Res> implements $TaiXiuMessageCopyWith<$Res> {
  factory $TaiXiuSessionAnalyticCopyWith(TaiXiuSessionAnalytic value, $Res Function(TaiXiuSessionAnalytic) _then) = _$TaiXiuSessionAnalyticCopyWithImpl;
@useResult
$Res call({
 List<dynamic> betStats, int sessionId, int? d1, int? d2, int? d3, int? startTime, bool ended
});

}
class _$TaiXiuSessionAnalyticCopyWithImpl<$Res>
    implements $TaiXiuSessionAnalyticCopyWith<$Res> {
  _$TaiXiuSessionAnalyticCopyWithImpl(this._self, this._then);

  final TaiXiuSessionAnalytic _self;
  final $Res Function(TaiXiuSessionAnalytic) _then;

@pragma('vm:prefer-inline') $Res call({Object? betStats = null,Object? sessionId = null,Object? d1 = freezed,Object? d2 = freezed,Object? d3 = freezed,Object? startTime = freezed,Object? ended = null,}) {
  return _then(TaiXiuSessionAnalytic(
betStats: null == betStats ? _self._betStats : betStats // ignore: cast_nullable_to_non_nullable
as List<dynamic>,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as int,d1: freezed == d1 ? _self.d1 : d1 // ignore: cast_nullable_to_non_nullable
as int?,d2: freezed == d2 ? _self.d2 : d2 // ignore: cast_nullable_to_non_nullable
as int?,d3: freezed == d3 ? _self.d3 : d3 // ignore: cast_nullable_to_non_nullable
as int?,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as int?,ended: null == ended ? _self.ended : ended // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}

class TaiXiuUpdateBetInfo implements TaiXiuMessage {
  const TaiXiuUpdateBetInfo({required final  List<dynamic> betArr}): _betArr = betArr;
  
 final  List<dynamic> _betArr;
 List<dynamic> get betArr {
  if (_betArr is EqualUnmodifiableListView) return _betArr;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_betArr);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaiXiuUpdateBetInfoCopyWith<TaiXiuUpdateBetInfo> get copyWith => _$TaiXiuUpdateBetInfoCopyWithImpl<TaiXiuUpdateBetInfo>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaiXiuUpdateBetInfo&&const DeepCollectionEquality().equals(other._betArr, _betArr));
}

@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_betArr));

@override
String toString() {
  return 'TaiXiuMessage.updateBetInfo(betArr: $betArr)';
}

}

abstract mixin class $TaiXiuUpdateBetInfoCopyWith<$Res> implements $TaiXiuMessageCopyWith<$Res> {
  factory $TaiXiuUpdateBetInfoCopyWith(TaiXiuUpdateBetInfo value, $Res Function(TaiXiuUpdateBetInfo) _then) = _$TaiXiuUpdateBetInfoCopyWithImpl;
@useResult
$Res call({
 List<dynamic> betArr
});

}
class _$TaiXiuUpdateBetInfoCopyWithImpl<$Res>
    implements $TaiXiuUpdateBetInfoCopyWith<$Res> {
  _$TaiXiuUpdateBetInfoCopyWithImpl(this._self, this._then);

  final TaiXiuUpdateBetInfo _self;
  final $Res Function(TaiXiuUpdateBetInfo) _then;

@pragma('vm:prefer-inline') $Res call({Object? betArr = null,}) {
  return _then(TaiXiuUpdateBetInfo(
betArr: null == betArr ? _self._betArr : betArr // ignore: cast_nullable_to_non_nullable
as List<dynamic>,
  ));
}

}

class TaiXiuGetBetHistory implements TaiXiuMessage {
  const TaiXiuGetBetHistory({required final  List<dynamic> items, required this.accountId}): _items = items;
  
 final  List<dynamic> _items;
 List<dynamic> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

 final  int accountId;

@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaiXiuGetBetHistoryCopyWith<TaiXiuGetBetHistory> get copyWith => _$TaiXiuGetBetHistoryCopyWithImpl<TaiXiuGetBetHistory>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaiXiuGetBetHistory&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.accountId, accountId) || other.accountId == accountId));
}

@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),accountId);

@override
String toString() {
  return 'TaiXiuMessage.getBetHistory(items: $items, accountId: $accountId)';
}

}

abstract mixin class $TaiXiuGetBetHistoryCopyWith<$Res> implements $TaiXiuMessageCopyWith<$Res> {
  factory $TaiXiuGetBetHistoryCopyWith(TaiXiuGetBetHistory value, $Res Function(TaiXiuGetBetHistory) _then) = _$TaiXiuGetBetHistoryCopyWithImpl;
@useResult
$Res call({
 List<dynamic> items, int accountId
});

}
class _$TaiXiuGetBetHistoryCopyWithImpl<$Res>
    implements $TaiXiuGetBetHistoryCopyWith<$Res> {
  _$TaiXiuGetBetHistoryCopyWithImpl(this._self, this._then);

  final TaiXiuGetBetHistory _self;
  final $Res Function(TaiXiuGetBetHistory) _then;

@pragma('vm:prefer-inline') $Res call({Object? items = null,Object? accountId = null,}) {
  return _then(TaiXiuGetBetHistory(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<dynamic>,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}

class TaiXiuBetFree implements TaiXiuMessage {
  const TaiXiuBetFree();
  
@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaiXiuBetFree);
}

@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TaiXiuMessage.betFree()';
}

}

class TaiXiuChat implements TaiXiuMessage {
  const TaiXiuChat({required final  Map<String, dynamic> entry}): _entry = entry;
  
 final  Map<String, dynamic> _entry;
 Map<String, dynamic> get entry {
  if (_entry is EqualUnmodifiableMapView) return _entry;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_entry);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaiXiuChatCopyWith<TaiXiuChat> get copyWith => _$TaiXiuChatCopyWithImpl<TaiXiuChat>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaiXiuChat&&const DeepCollectionEquality().equals(other._entry, _entry));
}

@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_entry));

@override
String toString() {
  return 'TaiXiuMessage.chat(entry: $entry)';
}

}

abstract mixin class $TaiXiuChatCopyWith<$Res> implements $TaiXiuMessageCopyWith<$Res> {
  factory $TaiXiuChatCopyWith(TaiXiuChat value, $Res Function(TaiXiuChat) _then) = _$TaiXiuChatCopyWithImpl;
@useResult
$Res call({
 Map<String, dynamic> entry
});

}
class _$TaiXiuChatCopyWithImpl<$Res>
    implements $TaiXiuChatCopyWith<$Res> {
  _$TaiXiuChatCopyWithImpl(this._self, this._then);

  final TaiXiuChat _self;
  final $Res Function(TaiXiuChat) _then;

@pragma('vm:prefer-inline') $Res call({Object? entry = null,}) {
  return _then(TaiXiuChat(
entry: null == entry ? _self._entry : entry // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}

// dart format on
