// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tren_duoi_message.dart';

// dart format off
T _$identity<T>(T value) => value;
mixin _$TrenDuoiMessage {

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrenDuoiMessage);
}

@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TrenDuoiMessage()';
}

}

class $TrenDuoiMessageCopyWith<$Res>  {
$TrenDuoiMessageCopyWith(TrenDuoiMessage _, $Res Function(TrenDuoiMessage) __);
}

extension TrenDuoiMessagePatterns on TrenDuoiMessage {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( TrenDuoiInfoGame value)?  infoGame,TResult Function( TrenDuoiStartGame value)?  startGame,TResult Function( TrenDuoiStartRound value)?  startRound,TResult Function( TrenDuoiStopGame value)?  stopGame,TResult Function( TrenDuoiUpdateJar value)?  updateJar,required TResult orElse(),}){
final _that = this;
switch (_that) {
case TrenDuoiInfoGame() when infoGame != null:
return infoGame(_that);case TrenDuoiStartGame() when startGame != null:
return startGame(_that);case TrenDuoiStartRound() when startRound != null:
return startRound(_that);case TrenDuoiStopGame() when stopGame != null:
return stopGame(_that);case TrenDuoiUpdateJar() when updateJar != null:
return updateJar(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( TrenDuoiInfoGame value)  infoGame,required TResult Function( TrenDuoiStartGame value)  startGame,required TResult Function( TrenDuoiStartRound value)  startRound,required TResult Function( TrenDuoiStopGame value)  stopGame,required TResult Function( TrenDuoiUpdateJar value)  updateJar,}){
final _that = this;
switch (_that) {
case TrenDuoiInfoGame():
return infoGame(_that);case TrenDuoiStartGame():
return startGame(_that);case TrenDuoiStartRound():
return startRound(_that);case TrenDuoiStopGame():
return stopGame(_that);case TrenDuoiUpdateJar():
return updateJar(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( TrenDuoiInfoGame value)?  infoGame,TResult? Function( TrenDuoiStartGame value)?  startGame,TResult? Function( TrenDuoiStartRound value)?  startRound,TResult? Function( TrenDuoiStopGame value)?  stopGame,TResult? Function( TrenDuoiUpdateJar value)?  updateJar,}){
final _that = this;
switch (_that) {
case TrenDuoiInfoGame() when infoGame != null:
return infoGame(_that);case TrenDuoiStartGame() when startGame != null:
return startGame(_that);case TrenDuoiStartRound() when startRound != null:
return startRound(_that);case TrenDuoiStopGame() when stopGame != null:
return stopGame(_that);case TrenDuoiUpdateJar() when updateJar != null:
return updateJar(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( List<JackpotData> jackpots,  int? sessionId,  int remainingTimeMs,  int up,  int down,  int credit,  int bet,  List<int> history,  bool hasSession)?  infoGame,TResult Function( String? errorMessage,  int? cardCode,  int? credit,  int? bet,  int? accountId,  int? sessionId,  int? up,  int? down)?  startGame,TResult Function( int cardCode,  int credit,  int bet,  int accountId,  int sessionId,  int up,  int down,  bool isFree,  bool isJackpot,  bool nextGame,  int jackpot)?  startRound,TResult Function( int credit)?  stopGame,TResult Function( List<JackpotData> jackpots)?  updateJar,required TResult orElse(),}) {final _that = this;
switch (_that) {
case TrenDuoiInfoGame() when infoGame != null:
return infoGame(_that.jackpots,_that.sessionId,_that.remainingTimeMs,_that.up,_that.down,_that.credit,_that.bet,_that.history,_that.hasSession);case TrenDuoiStartGame() when startGame != null:
return startGame(_that.errorMessage,_that.cardCode,_that.credit,_that.bet,_that.accountId,_that.sessionId,_that.up,_that.down);case TrenDuoiStartRound() when startRound != null:
return startRound(_that.cardCode,_that.credit,_that.bet,_that.accountId,_that.sessionId,_that.up,_that.down,_that.isFree,_that.isJackpot,_that.nextGame,_that.jackpot);case TrenDuoiStopGame() when stopGame != null:
return stopGame(_that.credit);case TrenDuoiUpdateJar() when updateJar != null:
return updateJar(_that.jackpots);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( List<JackpotData> jackpots,  int? sessionId,  int remainingTimeMs,  int up,  int down,  int credit,  int bet,  List<int> history,  bool hasSession)  infoGame,required TResult Function( String? errorMessage,  int? cardCode,  int? credit,  int? bet,  int? accountId,  int? sessionId,  int? up,  int? down)  startGame,required TResult Function( int cardCode,  int credit,  int bet,  int accountId,  int sessionId,  int up,  int down,  bool isFree,  bool isJackpot,  bool nextGame,  int jackpot)  startRound,required TResult Function( int credit)  stopGame,required TResult Function( List<JackpotData> jackpots)  updateJar,}) {final _that = this;
switch (_that) {
case TrenDuoiInfoGame():
return infoGame(_that.jackpots,_that.sessionId,_that.remainingTimeMs,_that.up,_that.down,_that.credit,_that.bet,_that.history,_that.hasSession);case TrenDuoiStartGame():
return startGame(_that.errorMessage,_that.cardCode,_that.credit,_that.bet,_that.accountId,_that.sessionId,_that.up,_that.down);case TrenDuoiStartRound():
return startRound(_that.cardCode,_that.credit,_that.bet,_that.accountId,_that.sessionId,_that.up,_that.down,_that.isFree,_that.isJackpot,_that.nextGame,_that.jackpot);case TrenDuoiStopGame():
return stopGame(_that.credit);case TrenDuoiUpdateJar():
return updateJar(_that.jackpots);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( List<JackpotData> jackpots,  int? sessionId,  int remainingTimeMs,  int up,  int down,  int credit,  int bet,  List<int> history,  bool hasSession)?  infoGame,TResult? Function( String? errorMessage,  int? cardCode,  int? credit,  int? bet,  int? accountId,  int? sessionId,  int? up,  int? down)?  startGame,TResult? Function( int cardCode,  int credit,  int bet,  int accountId,  int sessionId,  int up,  int down,  bool isFree,  bool isJackpot,  bool nextGame,  int jackpot)?  startRound,TResult? Function( int credit)?  stopGame,TResult? Function( List<JackpotData> jackpots)?  updateJar,}) {final _that = this;
switch (_that) {
case TrenDuoiInfoGame() when infoGame != null:
return infoGame(_that.jackpots,_that.sessionId,_that.remainingTimeMs,_that.up,_that.down,_that.credit,_that.bet,_that.history,_that.hasSession);case TrenDuoiStartGame() when startGame != null:
return startGame(_that.errorMessage,_that.cardCode,_that.credit,_that.bet,_that.accountId,_that.sessionId,_that.up,_that.down);case TrenDuoiStartRound() when startRound != null:
return startRound(_that.cardCode,_that.credit,_that.bet,_that.accountId,_that.sessionId,_that.up,_that.down,_that.isFree,_that.isJackpot,_that.nextGame,_that.jackpot);case TrenDuoiStopGame() when stopGame != null:
return stopGame(_that.credit);case TrenDuoiUpdateJar() when updateJar != null:
return updateJar(_that.jackpots);case _:
  return null;

}
}

}

class TrenDuoiInfoGame implements TrenDuoiMessage {
  const TrenDuoiInfoGame({required final  List<JackpotData> jackpots, this.sessionId, this.remainingTimeMs = -1, this.up = 0, this.down = 0, this.credit = 0, this.bet = 0, final  List<int> history = const <int>[], this.hasSession = false}): _jackpots = jackpots,_history = history;
  
 final  List<JackpotData> _jackpots;
 List<JackpotData> get jackpots {
  if (_jackpots is EqualUnmodifiableListView) return _jackpots;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_jackpots);
}

 final  int? sessionId;
@JsonKey() final  int remainingTimeMs;
@JsonKey() final  int up;
@JsonKey() final  int down;
@JsonKey() final  int credit;
@JsonKey() final  int bet;
 final  List<int> _history;
@JsonKey() List<int> get history {
  if (_history is EqualUnmodifiableListView) return _history;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_history);
}

@JsonKey() final  bool hasSession;

@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrenDuoiInfoGameCopyWith<TrenDuoiInfoGame> get copyWith => _$TrenDuoiInfoGameCopyWithImpl<TrenDuoiInfoGame>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrenDuoiInfoGame&&const DeepCollectionEquality().equals(other._jackpots, _jackpots)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.remainingTimeMs, remainingTimeMs) || other.remainingTimeMs == remainingTimeMs)&&(identical(other.up, up) || other.up == up)&&(identical(other.down, down) || other.down == down)&&(identical(other.credit, credit) || other.credit == credit)&&(identical(other.bet, bet) || other.bet == bet)&&const DeepCollectionEquality().equals(other._history, _history)&&(identical(other.hasSession, hasSession) || other.hasSession == hasSession));
}

@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_jackpots),sessionId,remainingTimeMs,up,down,credit,bet,const DeepCollectionEquality().hash(_history),hasSession);

@override
String toString() {
  return 'TrenDuoiMessage.infoGame(jackpots: $jackpots, sessionId: $sessionId, remainingTimeMs: $remainingTimeMs, up: $up, down: $down, credit: $credit, bet: $bet, history: $history, hasSession: $hasSession)';
}

}

abstract mixin class $TrenDuoiInfoGameCopyWith<$Res> implements $TrenDuoiMessageCopyWith<$Res> {
  factory $TrenDuoiInfoGameCopyWith(TrenDuoiInfoGame value, $Res Function(TrenDuoiInfoGame) _then) = _$TrenDuoiInfoGameCopyWithImpl;
@useResult
$Res call({
 List<JackpotData> jackpots, int? sessionId, int remainingTimeMs, int up, int down, int credit, int bet, List<int> history, bool hasSession
});

}
class _$TrenDuoiInfoGameCopyWithImpl<$Res>
    implements $TrenDuoiInfoGameCopyWith<$Res> {
  _$TrenDuoiInfoGameCopyWithImpl(this._self, this._then);

  final TrenDuoiInfoGame _self;
  final $Res Function(TrenDuoiInfoGame) _then;

@pragma('vm:prefer-inline') $Res call({Object? jackpots = null,Object? sessionId = freezed,Object? remainingTimeMs = null,Object? up = null,Object? down = null,Object? credit = null,Object? bet = null,Object? history = null,Object? hasSession = null,}) {
  return _then(TrenDuoiInfoGame(
jackpots: null == jackpots ? _self._jackpots : jackpots // ignore: cast_nullable_to_non_nullable
as List<JackpotData>,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as int?,remainingTimeMs: null == remainingTimeMs ? _self.remainingTimeMs : remainingTimeMs // ignore: cast_nullable_to_non_nullable
as int,up: null == up ? _self.up : up // ignore: cast_nullable_to_non_nullable
as int,down: null == down ? _self.down : down // ignore: cast_nullable_to_non_nullable
as int,credit: null == credit ? _self.credit : credit // ignore: cast_nullable_to_non_nullable
as int,bet: null == bet ? _self.bet : bet // ignore: cast_nullable_to_non_nullable
as int,history: null == history ? _self._history : history // ignore: cast_nullable_to_non_nullable
as List<int>,hasSession: null == hasSession ? _self.hasSession : hasSession // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}

class TrenDuoiStartGame implements TrenDuoiMessage {
  const TrenDuoiStartGame({this.errorMessage, this.cardCode, this.credit, this.bet, this.accountId, this.sessionId, this.up, this.down});
  
 final  String? errorMessage;
 final  int? cardCode;
 final  int? credit;
 final  int? bet;
 final  int? accountId;
 final  int? sessionId;
 final  int? up;
 final  int? down;

@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrenDuoiStartGameCopyWith<TrenDuoiStartGame> get copyWith => _$TrenDuoiStartGameCopyWithImpl<TrenDuoiStartGame>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrenDuoiStartGame&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.cardCode, cardCode) || other.cardCode == cardCode)&&(identical(other.credit, credit) || other.credit == credit)&&(identical(other.bet, bet) || other.bet == bet)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.up, up) || other.up == up)&&(identical(other.down, down) || other.down == down));
}

@override
int get hashCode => Object.hash(runtimeType,errorMessage,cardCode,credit,bet,accountId,sessionId,up,down);

@override
String toString() {
  return 'TrenDuoiMessage.startGame(errorMessage: $errorMessage, cardCode: $cardCode, credit: $credit, bet: $bet, accountId: $accountId, sessionId: $sessionId, up: $up, down: $down)';
}

}

abstract mixin class $TrenDuoiStartGameCopyWith<$Res> implements $TrenDuoiMessageCopyWith<$Res> {
  factory $TrenDuoiStartGameCopyWith(TrenDuoiStartGame value, $Res Function(TrenDuoiStartGame) _then) = _$TrenDuoiStartGameCopyWithImpl;
@useResult
$Res call({
 String? errorMessage, int? cardCode, int? credit, int? bet, int? accountId, int? sessionId, int? up, int? down
});

}
class _$TrenDuoiStartGameCopyWithImpl<$Res>
    implements $TrenDuoiStartGameCopyWith<$Res> {
  _$TrenDuoiStartGameCopyWithImpl(this._self, this._then);

  final TrenDuoiStartGame _self;
  final $Res Function(TrenDuoiStartGame) _then;

@pragma('vm:prefer-inline') $Res call({Object? errorMessage = freezed,Object? cardCode = freezed,Object? credit = freezed,Object? bet = freezed,Object? accountId = freezed,Object? sessionId = freezed,Object? up = freezed,Object? down = freezed,}) {
  return _then(TrenDuoiStartGame(
errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,cardCode: freezed == cardCode ? _self.cardCode : cardCode // ignore: cast_nullable_to_non_nullable
as int?,credit: freezed == credit ? _self.credit : credit // ignore: cast_nullable_to_non_nullable
as int?,bet: freezed == bet ? _self.bet : bet // ignore: cast_nullable_to_non_nullable
as int?,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as int?,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as int?,up: freezed == up ? _self.up : up // ignore: cast_nullable_to_non_nullable
as int?,down: freezed == down ? _self.down : down // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}

class TrenDuoiStartRound implements TrenDuoiMessage {
  const TrenDuoiStartRound({required this.cardCode, required this.credit, required this.bet, required this.accountId, required this.sessionId, required this.up, required this.down, required this.isFree, required this.isJackpot, required this.nextGame, this.jackpot = 0});
  
 final  int cardCode;
 final  int credit;
 final  int bet;
 final  int accountId;
 final  int sessionId;
 final  int up;
 final  int down;
 final  bool isFree;
 final  bool isJackpot;
 final  bool nextGame;
@JsonKey() final  int jackpot;

@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrenDuoiStartRoundCopyWith<TrenDuoiStartRound> get copyWith => _$TrenDuoiStartRoundCopyWithImpl<TrenDuoiStartRound>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrenDuoiStartRound&&(identical(other.cardCode, cardCode) || other.cardCode == cardCode)&&(identical(other.credit, credit) || other.credit == credit)&&(identical(other.bet, bet) || other.bet == bet)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.up, up) || other.up == up)&&(identical(other.down, down) || other.down == down)&&(identical(other.isFree, isFree) || other.isFree == isFree)&&(identical(other.isJackpot, isJackpot) || other.isJackpot == isJackpot)&&(identical(other.nextGame, nextGame) || other.nextGame == nextGame)&&(identical(other.jackpot, jackpot) || other.jackpot == jackpot));
}

@override
int get hashCode => Object.hash(runtimeType,cardCode,credit,bet,accountId,sessionId,up,down,isFree,isJackpot,nextGame,jackpot);

@override
String toString() {
  return 'TrenDuoiMessage.startRound(cardCode: $cardCode, credit: $credit, bet: $bet, accountId: $accountId, sessionId: $sessionId, up: $up, down: $down, isFree: $isFree, isJackpot: $isJackpot, nextGame: $nextGame, jackpot: $jackpot)';
}

}

abstract mixin class $TrenDuoiStartRoundCopyWith<$Res> implements $TrenDuoiMessageCopyWith<$Res> {
  factory $TrenDuoiStartRoundCopyWith(TrenDuoiStartRound value, $Res Function(TrenDuoiStartRound) _then) = _$TrenDuoiStartRoundCopyWithImpl;
@useResult
$Res call({
 int cardCode, int credit, int bet, int accountId, int sessionId, int up, int down, bool isFree, bool isJackpot, bool nextGame, int jackpot
});

}
class _$TrenDuoiStartRoundCopyWithImpl<$Res>
    implements $TrenDuoiStartRoundCopyWith<$Res> {
  _$TrenDuoiStartRoundCopyWithImpl(this._self, this._then);

  final TrenDuoiStartRound _self;
  final $Res Function(TrenDuoiStartRound) _then;

@pragma('vm:prefer-inline') $Res call({Object? cardCode = null,Object? credit = null,Object? bet = null,Object? accountId = null,Object? sessionId = null,Object? up = null,Object? down = null,Object? isFree = null,Object? isJackpot = null,Object? nextGame = null,Object? jackpot = null,}) {
  return _then(TrenDuoiStartRound(
cardCode: null == cardCode ? _self.cardCode : cardCode // ignore: cast_nullable_to_non_nullable
as int,credit: null == credit ? _self.credit : credit // ignore: cast_nullable_to_non_nullable
as int,bet: null == bet ? _self.bet : bet // ignore: cast_nullable_to_non_nullable
as int,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as int,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as int,up: null == up ? _self.up : up // ignore: cast_nullable_to_non_nullable
as int,down: null == down ? _self.down : down // ignore: cast_nullable_to_non_nullable
as int,isFree: null == isFree ? _self.isFree : isFree // ignore: cast_nullable_to_non_nullable
as bool,isJackpot: null == isJackpot ? _self.isJackpot : isJackpot // ignore: cast_nullable_to_non_nullable
as bool,nextGame: null == nextGame ? _self.nextGame : nextGame // ignore: cast_nullable_to_non_nullable
as bool,jackpot: null == jackpot ? _self.jackpot : jackpot // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}

class TrenDuoiStopGame implements TrenDuoiMessage {
  const TrenDuoiStopGame({required this.credit});
  
 final  int credit;

@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrenDuoiStopGameCopyWith<TrenDuoiStopGame> get copyWith => _$TrenDuoiStopGameCopyWithImpl<TrenDuoiStopGame>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrenDuoiStopGame&&(identical(other.credit, credit) || other.credit == credit));
}

@override
int get hashCode => Object.hash(runtimeType,credit);

@override
String toString() {
  return 'TrenDuoiMessage.stopGame(credit: $credit)';
}

}

abstract mixin class $TrenDuoiStopGameCopyWith<$Res> implements $TrenDuoiMessageCopyWith<$Res> {
  factory $TrenDuoiStopGameCopyWith(TrenDuoiStopGame value, $Res Function(TrenDuoiStopGame) _then) = _$TrenDuoiStopGameCopyWithImpl;
@useResult
$Res call({
 int credit
});

}
class _$TrenDuoiStopGameCopyWithImpl<$Res>
    implements $TrenDuoiStopGameCopyWith<$Res> {
  _$TrenDuoiStopGameCopyWithImpl(this._self, this._then);

  final TrenDuoiStopGame _self;
  final $Res Function(TrenDuoiStopGame) _then;

@pragma('vm:prefer-inline') $Res call({Object? credit = null,}) {
  return _then(TrenDuoiStopGame(
credit: null == credit ? _self.credit : credit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}

class TrenDuoiUpdateJar implements TrenDuoiMessage {
  const TrenDuoiUpdateJar({required final  List<JackpotData> jackpots}): _jackpots = jackpots;
  
 final  List<JackpotData> _jackpots;
 List<JackpotData> get jackpots {
  if (_jackpots is EqualUnmodifiableListView) return _jackpots;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_jackpots);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrenDuoiUpdateJarCopyWith<TrenDuoiUpdateJar> get copyWith => _$TrenDuoiUpdateJarCopyWithImpl<TrenDuoiUpdateJar>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrenDuoiUpdateJar&&const DeepCollectionEquality().equals(other._jackpots, _jackpots));
}

@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_jackpots));

@override
String toString() {
  return 'TrenDuoiMessage.updateJar(jackpots: $jackpots)';
}

}

abstract mixin class $TrenDuoiUpdateJarCopyWith<$Res> implements $TrenDuoiMessageCopyWith<$Res> {
  factory $TrenDuoiUpdateJarCopyWith(TrenDuoiUpdateJar value, $Res Function(TrenDuoiUpdateJar) _then) = _$TrenDuoiUpdateJarCopyWithImpl;
@useResult
$Res call({
 List<JackpotData> jackpots
});

}
class _$TrenDuoiUpdateJarCopyWithImpl<$Res>
    implements $TrenDuoiUpdateJarCopyWith<$Res> {
  _$TrenDuoiUpdateJarCopyWithImpl(this._self, this._then);

  final TrenDuoiUpdateJar _self;
  final $Res Function(TrenDuoiUpdateJar) _then;

@pragma('vm:prefer-inline') $Res call({Object? jackpots = null,}) {
  return _then(TrenDuoiUpdateJar(
jackpots: null == jackpots ? _self._jackpots : jackpots // ignore: cast_nullable_to_non_nullable
as List<JackpotData>,
  ));
}

}

// dart format on
