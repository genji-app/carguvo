// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bet_slip_resell_notifier.dart';

// dart format off
T _$identity<T>(T value) => value;
mixin _$BetResellState {

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BetResellState);
}

@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BetResellState()';
}

}

class $BetResellStateCopyWith<$Res>  {
$BetResellStateCopyWith(BetResellState _, $Res Function(BetResellState) __);
}

extension BetResellStatePatterns on BetResellState {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Idle value)?  idle,TResult Function( _FetchingQuote value)?  fetchingQuote,TResult Function( _QuoteFetched value)?  quoteFetched,TResult Function( _Processing value)?  processing,TResult Function( _Success value)?  success,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Idle() when idle != null:
return idle(_that);case _FetchingQuote() when fetchingQuote != null:
return fetchingQuote(_that);case _QuoteFetched() when quoteFetched != null:
return quoteFetched(_that);case _Processing() when processing != null:
return processing(_that);case _Success() when success != null:
return success(_that);case _Error() when error != null:
return error(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Idle value)  idle,required TResult Function( _FetchingQuote value)  fetchingQuote,required TResult Function( _QuoteFetched value)  quoteFetched,required TResult Function( _Processing value)  processing,required TResult Function( _Success value)  success,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Idle():
return idle(_that);case _FetchingQuote():
return fetchingQuote(_that);case _QuoteFetched():
return quoteFetched(_that);case _Processing():
return processing(_that);case _Success():
return success(_that);case _Error():
return error(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Idle value)?  idle,TResult? Function( _FetchingQuote value)?  fetchingQuote,TResult? Function( _QuoteFetched value)?  quoteFetched,TResult? Function( _Processing value)?  processing,TResult? Function( _Success value)?  success,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Idle() when idle != null:
return idle(_that);case _FetchingQuote() when fetchingQuote != null:
return fetchingQuote(_that);case _QuoteFetched() when quoteFetched != null:
return quoteFetched(_that);case _Processing() when processing != null:
return processing(_that);case _Success() when success != null:
return success(_that);case _Error() when error != null:
return error(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function( BetSlip bet)?  fetchingQuote,TResult Function( BetSlip bet,  GetCashoutResponse quote)?  quoteFetched,TResult Function( BetSlip bet)?  processing,TResult Function( BetSlip bet,  CashoutResponse response)?  success,TResult Function( BetSlip bet,  String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Idle() when idle != null:
return idle();case _FetchingQuote() when fetchingQuote != null:
return fetchingQuote(_that.bet);case _QuoteFetched() when quoteFetched != null:
return quoteFetched(_that.bet,_that.quote);case _Processing() when processing != null:
return processing(_that.bet);case _Success() when success != null:
return success(_that.bet,_that.response);case _Error() when error != null:
return error(_that.bet,_that.message);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function( BetSlip bet)  fetchingQuote,required TResult Function( BetSlip bet,  GetCashoutResponse quote)  quoteFetched,required TResult Function( BetSlip bet)  processing,required TResult Function( BetSlip bet,  CashoutResponse response)  success,required TResult Function( BetSlip bet,  String message)  error,}) {final _that = this;
switch (_that) {
case _Idle():
return idle();case _FetchingQuote():
return fetchingQuote(_that.bet);case _QuoteFetched():
return quoteFetched(_that.bet,_that.quote);case _Processing():
return processing(_that.bet);case _Success():
return success(_that.bet,_that.response);case _Error():
return error(_that.bet,_that.message);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function( BetSlip bet)?  fetchingQuote,TResult? Function( BetSlip bet,  GetCashoutResponse quote)?  quoteFetched,TResult? Function( BetSlip bet)?  processing,TResult? Function( BetSlip bet,  CashoutResponse response)?  success,TResult? Function( BetSlip bet,  String message)?  error,}) {final _that = this;
switch (_that) {
case _Idle() when idle != null:
return idle();case _FetchingQuote() when fetchingQuote != null:
return fetchingQuote(_that.bet);case _QuoteFetched() when quoteFetched != null:
return quoteFetched(_that.bet,_that.quote);case _Processing() when processing != null:
return processing(_that.bet);case _Success() when success != null:
return success(_that.bet,_that.response);case _Error() when error != null:
return error(_that.bet,_that.message);case _:
  return null;

}
}

}

class _Idle implements BetResellState {
  const _Idle();
  
@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Idle);
}

@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BetResellState.idle()';
}

}

class _FetchingQuote implements BetResellState {
  const _FetchingQuote(this.bet);
  
 final  BetSlip bet;

@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FetchingQuoteCopyWith<_FetchingQuote> get copyWith => __$FetchingQuoteCopyWithImpl<_FetchingQuote>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FetchingQuote&&(identical(other.bet, bet) || other.bet == bet));
}

@override
int get hashCode => Object.hash(runtimeType,bet);

@override
String toString() {
  return 'BetResellState.fetchingQuote(bet: $bet)';
}

}

abstract mixin class _$FetchingQuoteCopyWith<$Res> implements $BetResellStateCopyWith<$Res> {
  factory _$FetchingQuoteCopyWith(_FetchingQuote value, $Res Function(_FetchingQuote) _then) = __$FetchingQuoteCopyWithImpl;
@useResult
$Res call({
 BetSlip bet
});

}
class __$FetchingQuoteCopyWithImpl<$Res>
    implements _$FetchingQuoteCopyWith<$Res> {
  __$FetchingQuoteCopyWithImpl(this._self, this._then);

  final _FetchingQuote _self;
  final $Res Function(_FetchingQuote) _then;

@pragma('vm:prefer-inline') $Res call({Object? bet = null,}) {
  return _then(_FetchingQuote(
null == bet ? _self.bet : bet // ignore: cast_nullable_to_non_nullable
as BetSlip,
  ));
}

}

class _QuoteFetched implements BetResellState {
  const _QuoteFetched({required this.bet, required this.quote});
  
 final  BetSlip bet;
 final  GetCashoutResponse quote;

@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuoteFetchedCopyWith<_QuoteFetched> get copyWith => __$QuoteFetchedCopyWithImpl<_QuoteFetched>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuoteFetched&&(identical(other.bet, bet) || other.bet == bet)&&(identical(other.quote, quote) || other.quote == quote));
}

@override
int get hashCode => Object.hash(runtimeType,bet,quote);

@override
String toString() {
  return 'BetResellState.quoteFetched(bet: $bet, quote: $quote)';
}

}

abstract mixin class _$QuoteFetchedCopyWith<$Res> implements $BetResellStateCopyWith<$Res> {
  factory _$QuoteFetchedCopyWith(_QuoteFetched value, $Res Function(_QuoteFetched) _then) = __$QuoteFetchedCopyWithImpl;
@useResult
$Res call({
 BetSlip bet, GetCashoutResponse quote
});

}
class __$QuoteFetchedCopyWithImpl<$Res>
    implements _$QuoteFetchedCopyWith<$Res> {
  __$QuoteFetchedCopyWithImpl(this._self, this._then);

  final _QuoteFetched _self;
  final $Res Function(_QuoteFetched) _then;

@pragma('vm:prefer-inline') $Res call({Object? bet = null,Object? quote = null,}) {
  return _then(_QuoteFetched(
bet: null == bet ? _self.bet : bet // ignore: cast_nullable_to_non_nullable
as BetSlip,quote: null == quote ? _self.quote : quote // ignore: cast_nullable_to_non_nullable
as GetCashoutResponse,
  ));
}

}

class _Processing implements BetResellState {
  const _Processing(this.bet);
  
 final  BetSlip bet;

@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProcessingCopyWith<_Processing> get copyWith => __$ProcessingCopyWithImpl<_Processing>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Processing&&(identical(other.bet, bet) || other.bet == bet));
}

@override
int get hashCode => Object.hash(runtimeType,bet);

@override
String toString() {
  return 'BetResellState.processing(bet: $bet)';
}

}

abstract mixin class _$ProcessingCopyWith<$Res> implements $BetResellStateCopyWith<$Res> {
  factory _$ProcessingCopyWith(_Processing value, $Res Function(_Processing) _then) = __$ProcessingCopyWithImpl;
@useResult
$Res call({
 BetSlip bet
});

}
class __$ProcessingCopyWithImpl<$Res>
    implements _$ProcessingCopyWith<$Res> {
  __$ProcessingCopyWithImpl(this._self, this._then);

  final _Processing _self;
  final $Res Function(_Processing) _then;

@pragma('vm:prefer-inline') $Res call({Object? bet = null,}) {
  return _then(_Processing(
null == bet ? _self.bet : bet // ignore: cast_nullable_to_non_nullable
as BetSlip,
  ));
}

}

class _Success implements BetResellState {
  const _Success(this.bet, this.response);
  
 final  BetSlip bet;
 final  CashoutResponse response;

@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SuccessCopyWith<_Success> get copyWith => __$SuccessCopyWithImpl<_Success>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Success&&(identical(other.bet, bet) || other.bet == bet)&&(identical(other.response, response) || other.response == response));
}

@override
int get hashCode => Object.hash(runtimeType,bet,response);

@override
String toString() {
  return 'BetResellState.success(bet: $bet, response: $response)';
}

}

abstract mixin class _$SuccessCopyWith<$Res> implements $BetResellStateCopyWith<$Res> {
  factory _$SuccessCopyWith(_Success value, $Res Function(_Success) _then) = __$SuccessCopyWithImpl;
@useResult
$Res call({
 BetSlip bet, CashoutResponse response
});

}
class __$SuccessCopyWithImpl<$Res>
    implements _$SuccessCopyWith<$Res> {
  __$SuccessCopyWithImpl(this._self, this._then);

  final _Success _self;
  final $Res Function(_Success) _then;

@pragma('vm:prefer-inline') $Res call({Object? bet = null,Object? response = null,}) {
  return _then(_Success(
null == bet ? _self.bet : bet // ignore: cast_nullable_to_non_nullable
as BetSlip,null == response ? _self.response : response // ignore: cast_nullable_to_non_nullable
as CashoutResponse,
  ));
}

}

class _Error implements BetResellState {
  const _Error(this.bet, this.message);
  
 final  BetSlip bet;
 final  String message;

@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorCopyWith<_Error> get copyWith => __$ErrorCopyWithImpl<_Error>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error&&(identical(other.bet, bet) || other.bet == bet)&&(identical(other.message, message) || other.message == message));
}

@override
int get hashCode => Object.hash(runtimeType,bet,message);

@override
String toString() {
  return 'BetResellState.error(bet: $bet, message: $message)';
}

}

abstract mixin class _$ErrorCopyWith<$Res> implements $BetResellStateCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) = __$ErrorCopyWithImpl;
@useResult
$Res call({
 BetSlip bet, String message
});

}
class __$ErrorCopyWithImpl<$Res>
    implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error _self;
  final $Res Function(_Error) _then;

@pragma('vm:prefer-inline') $Res call({Object? bet = null,Object? message = null,}) {
  return _then(_Error(
null == bet ? _self.bet : bet // ignore: cast_nullable_to_non_nullable
as BetSlip,null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}

// dart format on
