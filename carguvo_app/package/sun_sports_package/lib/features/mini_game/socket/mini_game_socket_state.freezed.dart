// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mini_game_socket_state.dart';

// dart format off
T _$identity<T>(T value) => value;
mixin _$MiniGameSocketState {

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MiniGameSocketState);
}

@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MiniGameSocketState()';
}

}

class $MiniGameSocketStateCopyWith<$Res>  {
$MiniGameSocketStateCopyWith(MiniGameSocketState _, $Res Function(MiniGameSocketState) __);
}

extension MiniGameSocketStatePatterns on MiniGameSocketState {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SocketDisconnected value)?  disconnected,TResult Function( SocketConnecting value)?  connecting,TResult Function( SocketConnected value)?  connected,TResult Function( SocketAuthenticated value)?  authenticated,TResult Function( SocketReconnecting value)?  reconnecting,TResult Function( SocketFailed value)?  failed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SocketDisconnected() when disconnected != null:
return disconnected(_that);case SocketConnecting() when connecting != null:
return connecting(_that);case SocketConnected() when connected != null:
return connected(_that);case SocketAuthenticated() when authenticated != null:
return authenticated(_that);case SocketReconnecting() when reconnecting != null:
return reconnecting(_that);case SocketFailed() when failed != null:
return failed(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SocketDisconnected value)  disconnected,required TResult Function( SocketConnecting value)  connecting,required TResult Function( SocketConnected value)  connected,required TResult Function( SocketAuthenticated value)  authenticated,required TResult Function( SocketReconnecting value)  reconnecting,required TResult Function( SocketFailed value)  failed,}){
final _that = this;
switch (_that) {
case SocketDisconnected():
return disconnected(_that);case SocketConnecting():
return connecting(_that);case SocketConnected():
return connected(_that);case SocketAuthenticated():
return authenticated(_that);case SocketReconnecting():
return reconnecting(_that);case SocketFailed():
return failed(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SocketDisconnected value)?  disconnected,TResult? Function( SocketConnecting value)?  connecting,TResult? Function( SocketConnected value)?  connected,TResult? Function( SocketAuthenticated value)?  authenticated,TResult? Function( SocketReconnecting value)?  reconnecting,TResult? Function( SocketFailed value)?  failed,}){
final _that = this;
switch (_that) {
case SocketDisconnected() when disconnected != null:
return disconnected(_that);case SocketConnecting() when connecting != null:
return connecting(_that);case SocketConnected() when connected != null:
return connected(_that);case SocketAuthenticated() when authenticated != null:
return authenticated(_that);case SocketReconnecting() when reconnecting != null:
return reconnecting(_that);case SocketFailed() when failed != null:
return failed(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  disconnected,TResult Function()?  connecting,TResult Function()?  connected,TResult Function()?  authenticated,TResult Function( int attempt)?  reconnecting,TResult Function( String reason)?  failed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SocketDisconnected() when disconnected != null:
return disconnected();case SocketConnecting() when connecting != null:
return connecting();case SocketConnected() when connected != null:
return connected();case SocketAuthenticated() when authenticated != null:
return authenticated();case SocketReconnecting() when reconnecting != null:
return reconnecting(_that.attempt);case SocketFailed() when failed != null:
return failed(_that.reason);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  disconnected,required TResult Function()  connecting,required TResult Function()  connected,required TResult Function()  authenticated,required TResult Function( int attempt)  reconnecting,required TResult Function( String reason)  failed,}) {final _that = this;
switch (_that) {
case SocketDisconnected():
return disconnected();case SocketConnecting():
return connecting();case SocketConnected():
return connected();case SocketAuthenticated():
return authenticated();case SocketReconnecting():
return reconnecting(_that.attempt);case SocketFailed():
return failed(_that.reason);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  disconnected,TResult? Function()?  connecting,TResult? Function()?  connected,TResult? Function()?  authenticated,TResult? Function( int attempt)?  reconnecting,TResult? Function( String reason)?  failed,}) {final _that = this;
switch (_that) {
case SocketDisconnected() when disconnected != null:
return disconnected();case SocketConnecting() when connecting != null:
return connecting();case SocketConnected() when connected != null:
return connected();case SocketAuthenticated() when authenticated != null:
return authenticated();case SocketReconnecting() when reconnecting != null:
return reconnecting(_that.attempt);case SocketFailed() when failed != null:
return failed(_that.reason);case _:
  return null;

}
}

}

class SocketDisconnected implements MiniGameSocketState {
  const SocketDisconnected();
  
@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SocketDisconnected);
}

@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MiniGameSocketState.disconnected()';
}

}

class SocketConnecting implements MiniGameSocketState {
  const SocketConnecting();
  
@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SocketConnecting);
}

@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MiniGameSocketState.connecting()';
}

}

class SocketConnected implements MiniGameSocketState {
  const SocketConnected();
  
@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SocketConnected);
}

@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MiniGameSocketState.connected()';
}

}

class SocketAuthenticated implements MiniGameSocketState {
  const SocketAuthenticated();
  
@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SocketAuthenticated);
}

@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MiniGameSocketState.authenticated()';
}

}

class SocketReconnecting implements MiniGameSocketState {
  const SocketReconnecting(this.attempt);
  
 final  int attempt;

@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SocketReconnectingCopyWith<SocketReconnecting> get copyWith => _$SocketReconnectingCopyWithImpl<SocketReconnecting>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SocketReconnecting&&(identical(other.attempt, attempt) || other.attempt == attempt));
}

@override
int get hashCode => Object.hash(runtimeType,attempt);

@override
String toString() {
  return 'MiniGameSocketState.reconnecting(attempt: $attempt)';
}

}

abstract mixin class $SocketReconnectingCopyWith<$Res> implements $MiniGameSocketStateCopyWith<$Res> {
  factory $SocketReconnectingCopyWith(SocketReconnecting value, $Res Function(SocketReconnecting) _then) = _$SocketReconnectingCopyWithImpl;
@useResult
$Res call({
 int attempt
});

}
class _$SocketReconnectingCopyWithImpl<$Res>
    implements $SocketReconnectingCopyWith<$Res> {
  _$SocketReconnectingCopyWithImpl(this._self, this._then);

  final SocketReconnecting _self;
  final $Res Function(SocketReconnecting) _then;

@pragma('vm:prefer-inline') $Res call({Object? attempt = null,}) {
  return _then(SocketReconnecting(
null == attempt ? _self.attempt : attempt // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}

class SocketFailed implements MiniGameSocketState {
  const SocketFailed(this.reason);
  
 final  String reason;

@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SocketFailedCopyWith<SocketFailed> get copyWith => _$SocketFailedCopyWithImpl<SocketFailed>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SocketFailed&&(identical(other.reason, reason) || other.reason == reason));
}

@override
int get hashCode => Object.hash(runtimeType,reason);

@override
String toString() {
  return 'MiniGameSocketState.failed(reason: $reason)';
}

}

abstract mixin class $SocketFailedCopyWith<$Res> implements $MiniGameSocketStateCopyWith<$Res> {
  factory $SocketFailedCopyWith(SocketFailed value, $Res Function(SocketFailed) _then) = _$SocketFailedCopyWithImpl;
@useResult
$Res call({
 String reason
});

}
class _$SocketFailedCopyWithImpl<$Res>
    implements $SocketFailedCopyWith<$Res> {
  _$SocketFailedCopyWithImpl(this._self, this._then);

  final SocketFailed _self;
  final $Res Function(SocketFailed) _then;

@pragma('vm:prefer-inline') $Res call({Object? reason = null,}) {
  return _then(SocketFailed(
null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}

// dart format on
