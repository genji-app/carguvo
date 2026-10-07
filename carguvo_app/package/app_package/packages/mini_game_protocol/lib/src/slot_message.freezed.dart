// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'slot_message.dart';

// dart format off
T _$identity<T>(T value) => value;
mixin _$SlotMessage {

 SlotGameId get game;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SlotMessageCopyWith<SlotMessage> get copyWith => _$SlotMessageCopyWithImpl<SlotMessage>(this as SlotMessage, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SlotMessage&&(identical(other.game, game) || other.game == game));
}

@override
int get hashCode => Object.hash(runtimeType,game);

@override
String toString() {
  return 'SlotMessage(game: $game)';
}

}

abstract mixin class $SlotMessageCopyWith<$Res>  {
  factory $SlotMessageCopyWith(SlotMessage value, $Res Function(SlotMessage) _then) = _$SlotMessageCopyWithImpl;
@useResult
$Res call({
 SlotGameId game
});

}
class _$SlotMessageCopyWithImpl<$Res>
    implements $SlotMessageCopyWith<$Res> {
  _$SlotMessageCopyWithImpl(this._self, this._then);

  final SlotMessage _self;
  final $Res Function(SlotMessage) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? game = null,}) {
  return _then(_self.copyWith(
game: null == game ? _self.game : game // ignore: cast_nullable_to_non_nullable
as SlotGameId,
  ));
}

}

extension SlotMessagePatterns on SlotMessage {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SlotSubscribeJackpot value)?  subscribeJackpot,TResult Function( SlotSpinResult value)?  spinResult,TResult Function( SlotUpdateJackpot value)?  updateJackpot,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SlotSubscribeJackpot() when subscribeJackpot != null:
return subscribeJackpot(_that);case SlotSpinResult() when spinResult != null:
return spinResult(_that);case SlotUpdateJackpot() when updateJackpot != null:
return updateJackpot(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SlotSubscribeJackpot value)  subscribeJackpot,required TResult Function( SlotSpinResult value)  spinResult,required TResult Function( SlotUpdateJackpot value)  updateJackpot,}){
final _that = this;
switch (_that) {
case SlotSubscribeJackpot():
return subscribeJackpot(_that);case SlotSpinResult():
return spinResult(_that);case SlotUpdateJackpot():
return updateJackpot(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SlotSubscribeJackpot value)?  subscribeJackpot,TResult? Function( SlotSpinResult value)?  spinResult,TResult? Function( SlotUpdateJackpot value)?  updateJackpot,}){
final _that = this;
switch (_that) {
case SlotSubscribeJackpot() when subscribeJackpot != null:
return subscribeJackpot(_that);case SlotSpinResult() when spinResult != null:
return spinResult(_that);case SlotUpdateJackpot() when updateJackpot != null:
return updateJackpot(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( SlotGameId game,  List<JackpotData> jackpots,  bool autoSpin,  int autoSpinBetting,  int autoSpinAid,  List<dynamic>? lines)?  subscribeJackpot,TResult Function( SlotGameId game,  String? errorMessage,  int? accountId,  int moneyExchange,  List<dynamic> symbols,  List<dynamic> rewards,  bool wonJackpot,  int? sessionId,  int? freeSpins)?  spinResult,TResult Function( SlotGameId game,  List<JackpotData> jackpots)?  updateJackpot,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SlotSubscribeJackpot() when subscribeJackpot != null:
return subscribeJackpot(_that.game,_that.jackpots,_that.autoSpin,_that.autoSpinBetting,_that.autoSpinAid,_that.lines);case SlotSpinResult() when spinResult != null:
return spinResult(_that.game,_that.errorMessage,_that.accountId,_that.moneyExchange,_that.symbols,_that.rewards,_that.wonJackpot,_that.sessionId,_that.freeSpins);case SlotUpdateJackpot() when updateJackpot != null:
return updateJackpot(_that.game,_that.jackpots);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( SlotGameId game,  List<JackpotData> jackpots,  bool autoSpin,  int autoSpinBetting,  int autoSpinAid,  List<dynamic>? lines)  subscribeJackpot,required TResult Function( SlotGameId game,  String? errorMessage,  int? accountId,  int moneyExchange,  List<dynamic> symbols,  List<dynamic> rewards,  bool wonJackpot,  int? sessionId,  int? freeSpins)  spinResult,required TResult Function( SlotGameId game,  List<JackpotData> jackpots)  updateJackpot,}) {final _that = this;
switch (_that) {
case SlotSubscribeJackpot():
return subscribeJackpot(_that.game,_that.jackpots,_that.autoSpin,_that.autoSpinBetting,_that.autoSpinAid,_that.lines);case SlotSpinResult():
return spinResult(_that.game,_that.errorMessage,_that.accountId,_that.moneyExchange,_that.symbols,_that.rewards,_that.wonJackpot,_that.sessionId,_that.freeSpins);case SlotUpdateJackpot():
return updateJackpot(_that.game,_that.jackpots);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( SlotGameId game,  List<JackpotData> jackpots,  bool autoSpin,  int autoSpinBetting,  int autoSpinAid,  List<dynamic>? lines)?  subscribeJackpot,TResult? Function( SlotGameId game,  String? errorMessage,  int? accountId,  int moneyExchange,  List<dynamic> symbols,  List<dynamic> rewards,  bool wonJackpot,  int? sessionId,  int? freeSpins)?  spinResult,TResult? Function( SlotGameId game,  List<JackpotData> jackpots)?  updateJackpot,}) {final _that = this;
switch (_that) {
case SlotSubscribeJackpot() when subscribeJackpot != null:
return subscribeJackpot(_that.game,_that.jackpots,_that.autoSpin,_that.autoSpinBetting,_that.autoSpinAid,_that.lines);case SlotSpinResult() when spinResult != null:
return spinResult(_that.game,_that.errorMessage,_that.accountId,_that.moneyExchange,_that.symbols,_that.rewards,_that.wonJackpot,_that.sessionId,_that.freeSpins);case SlotUpdateJackpot() when updateJackpot != null:
return updateJackpot(_that.game,_that.jackpots);case _:
  return null;

}
}

}

class SlotSubscribeJackpot implements SlotMessage {
  const SlotSubscribeJackpot({required this.game, required final  List<JackpotData> jackpots, this.autoSpin = false, this.autoSpinBetting = 0, this.autoSpinAid = 1, final  List<dynamic>? lines}): _jackpots = jackpots,_lines = lines;
  
@override final  SlotGameId game;
 final  List<JackpotData> _jackpots;
 List<JackpotData> get jackpots {
  if (_jackpots is EqualUnmodifiableListView) return _jackpots;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_jackpots);
}

@JsonKey() final  bool autoSpin;
@JsonKey() final  int autoSpinBetting;
@JsonKey() final  int autoSpinAid;
 final  List<dynamic>? _lines;
 List<dynamic>? get lines {
  final value = _lines;
  if (value == null) return null;
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SlotSubscribeJackpotCopyWith<SlotSubscribeJackpot> get copyWith => _$SlotSubscribeJackpotCopyWithImpl<SlotSubscribeJackpot>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SlotSubscribeJackpot&&(identical(other.game, game) || other.game == game)&&const DeepCollectionEquality().equals(other._jackpots, _jackpots)&&(identical(other.autoSpin, autoSpin) || other.autoSpin == autoSpin)&&(identical(other.autoSpinBetting, autoSpinBetting) || other.autoSpinBetting == autoSpinBetting)&&(identical(other.autoSpinAid, autoSpinAid) || other.autoSpinAid == autoSpinAid)&&const DeepCollectionEquality().equals(other._lines, _lines));
}

@override
int get hashCode => Object.hash(runtimeType,game,const DeepCollectionEquality().hash(_jackpots),autoSpin,autoSpinBetting,autoSpinAid,const DeepCollectionEquality().hash(_lines));

@override
String toString() {
  return 'SlotMessage.subscribeJackpot(game: $game, jackpots: $jackpots, autoSpin: $autoSpin, autoSpinBetting: $autoSpinBetting, autoSpinAid: $autoSpinAid, lines: $lines)';
}

}

abstract mixin class $SlotSubscribeJackpotCopyWith<$Res> implements $SlotMessageCopyWith<$Res> {
  factory $SlotSubscribeJackpotCopyWith(SlotSubscribeJackpot value, $Res Function(SlotSubscribeJackpot) _then) = _$SlotSubscribeJackpotCopyWithImpl;
@override @useResult
$Res call({
 SlotGameId game, List<JackpotData> jackpots, bool autoSpin, int autoSpinBetting, int autoSpinAid, List<dynamic>? lines
});

}
class _$SlotSubscribeJackpotCopyWithImpl<$Res>
    implements $SlotSubscribeJackpotCopyWith<$Res> {
  _$SlotSubscribeJackpotCopyWithImpl(this._self, this._then);

  final SlotSubscribeJackpot _self;
  final $Res Function(SlotSubscribeJackpot) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? game = null,Object? jackpots = null,Object? autoSpin = null,Object? autoSpinBetting = null,Object? autoSpinAid = null,Object? lines = freezed,}) {
  return _then(SlotSubscribeJackpot(
game: null == game ? _self.game : game // ignore: cast_nullable_to_non_nullable
as SlotGameId,jackpots: null == jackpots ? _self._jackpots : jackpots // ignore: cast_nullable_to_non_nullable
as List<JackpotData>,autoSpin: null == autoSpin ? _self.autoSpin : autoSpin // ignore: cast_nullable_to_non_nullable
as bool,autoSpinBetting: null == autoSpinBetting ? _self.autoSpinBetting : autoSpinBetting // ignore: cast_nullable_to_non_nullable
as int,autoSpinAid: null == autoSpinAid ? _self.autoSpinAid : autoSpinAid // ignore: cast_nullable_to_non_nullable
as int,lines: freezed == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<dynamic>?,
  ));
}

}

class SlotSpinResult implements SlotMessage {
  const SlotSpinResult({required this.game, this.errorMessage, this.accountId, this.moneyExchange = 0, final  List<dynamic> symbols = const <dynamic>[], final  List<dynamic> rewards = const <dynamic>[], this.wonJackpot = false, this.sessionId, this.freeSpins}): _symbols = symbols,_rewards = rewards;
  
@override final  SlotGameId game;
 final  String? errorMessage;
 final  int? accountId;
@JsonKey() final  int moneyExchange;
 final  List<dynamic> _symbols;
@JsonKey() List<dynamic> get symbols {
  if (_symbols is EqualUnmodifiableListView) return _symbols;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_symbols);
}

 final  List<dynamic> _rewards;
@JsonKey() List<dynamic> get rewards {
  if (_rewards is EqualUnmodifiableListView) return _rewards;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rewards);
}

@JsonKey() final  bool wonJackpot;
 final  int? sessionId;
 final  int? freeSpins;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SlotSpinResultCopyWith<SlotSpinResult> get copyWith => _$SlotSpinResultCopyWithImpl<SlotSpinResult>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SlotSpinResult&&(identical(other.game, game) || other.game == game)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.moneyExchange, moneyExchange) || other.moneyExchange == moneyExchange)&&const DeepCollectionEquality().equals(other._symbols, _symbols)&&const DeepCollectionEquality().equals(other._rewards, _rewards)&&(identical(other.wonJackpot, wonJackpot) || other.wonJackpot == wonJackpot)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.freeSpins, freeSpins) || other.freeSpins == freeSpins));
}

@override
int get hashCode => Object.hash(runtimeType,game,errorMessage,accountId,moneyExchange,const DeepCollectionEquality().hash(_symbols),const DeepCollectionEquality().hash(_rewards),wonJackpot,sessionId,freeSpins);

@override
String toString() {
  return 'SlotMessage.spinResult(game: $game, errorMessage: $errorMessage, accountId: $accountId, moneyExchange: $moneyExchange, symbols: $symbols, rewards: $rewards, wonJackpot: $wonJackpot, sessionId: $sessionId, freeSpins: $freeSpins)';
}

}

abstract mixin class $SlotSpinResultCopyWith<$Res> implements $SlotMessageCopyWith<$Res> {
  factory $SlotSpinResultCopyWith(SlotSpinResult value, $Res Function(SlotSpinResult) _then) = _$SlotSpinResultCopyWithImpl;
@override @useResult
$Res call({
 SlotGameId game, String? errorMessage, int? accountId, int moneyExchange, List<dynamic> symbols, List<dynamic> rewards, bool wonJackpot, int? sessionId, int? freeSpins
});

}
class _$SlotSpinResultCopyWithImpl<$Res>
    implements $SlotSpinResultCopyWith<$Res> {
  _$SlotSpinResultCopyWithImpl(this._self, this._then);

  final SlotSpinResult _self;
  final $Res Function(SlotSpinResult) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? game = null,Object? errorMessage = freezed,Object? accountId = freezed,Object? moneyExchange = null,Object? symbols = null,Object? rewards = null,Object? wonJackpot = null,Object? sessionId = freezed,Object? freeSpins = freezed,}) {
  return _then(SlotSpinResult(
game: null == game ? _self.game : game // ignore: cast_nullable_to_non_nullable
as SlotGameId,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as int?,moneyExchange: null == moneyExchange ? _self.moneyExchange : moneyExchange // ignore: cast_nullable_to_non_nullable
as int,symbols: null == symbols ? _self._symbols : symbols // ignore: cast_nullable_to_non_nullable
as List<dynamic>,rewards: null == rewards ? _self._rewards : rewards // ignore: cast_nullable_to_non_nullable
as List<dynamic>,wonJackpot: null == wonJackpot ? _self.wonJackpot : wonJackpot // ignore: cast_nullable_to_non_nullable
as bool,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as int?,freeSpins: freezed == freeSpins ? _self.freeSpins : freeSpins // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}

class SlotUpdateJackpot implements SlotMessage {
  const SlotUpdateJackpot({required this.game, required final  List<JackpotData> jackpots}): _jackpots = jackpots;
  
@override final  SlotGameId game;
 final  List<JackpotData> _jackpots;
 List<JackpotData> get jackpots {
  if (_jackpots is EqualUnmodifiableListView) return _jackpots;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_jackpots);
}

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SlotUpdateJackpotCopyWith<SlotUpdateJackpot> get copyWith => _$SlotUpdateJackpotCopyWithImpl<SlotUpdateJackpot>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SlotUpdateJackpot&&(identical(other.game, game) || other.game == game)&&const DeepCollectionEquality().equals(other._jackpots, _jackpots));
}

@override
int get hashCode => Object.hash(runtimeType,game,const DeepCollectionEquality().hash(_jackpots));

@override
String toString() {
  return 'SlotMessage.updateJackpot(game: $game, jackpots: $jackpots)';
}

}

abstract mixin class $SlotUpdateJackpotCopyWith<$Res> implements $SlotMessageCopyWith<$Res> {
  factory $SlotUpdateJackpotCopyWith(SlotUpdateJackpot value, $Res Function(SlotUpdateJackpot) _then) = _$SlotUpdateJackpotCopyWithImpl;
@override @useResult
$Res call({
 SlotGameId game, List<JackpotData> jackpots
});

}
class _$SlotUpdateJackpotCopyWithImpl<$Res>
    implements $SlotUpdateJackpotCopyWith<$Res> {
  _$SlotUpdateJackpotCopyWithImpl(this._self, this._then);

  final SlotUpdateJackpot _self;
  final $Res Function(SlotUpdateJackpot) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? game = null,Object? jackpots = null,}) {
  return _then(SlotUpdateJackpot(
game: null == game ? _self.game : game // ignore: cast_nullable_to_non_nullable
as SlotGameId,jackpots: null == jackpots ? _self._jackpots : jackpots // ignore: cast_nullable_to_non_nullable
as List<JackpotData>,
  ));
}

}

// dart format on
