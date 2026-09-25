// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_player_notifier.dart';

// dart format off
T _$identity<T>(T value) => value;
mixin _$GamePlayerState implements DiagnosticableTreeMixin {

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'GamePlayerState'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GamePlayerState);
}

@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'GamePlayerState()';
}

}

class $GamePlayerStateCopyWith<$Res>  {
$GamePlayerStateCopyWith(GamePlayerState _, $Res Function(GamePlayerState) __);
}

extension GamePlayerStatePatterns on GamePlayerState {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( GamePlayerInitialState value)?  initial,TResult Function( GamePlayerLoadingState value)?  loading,TResult Function( GamePlayerPlayingState value)?  playing,TResult Function( GamePlayerFailureState value)?  failure,TResult Function( GamePlayerExitingState value)?  exiting,required TResult orElse(),}){
final _that = this;
switch (_that) {
case GamePlayerInitialState() when initial != null:
return initial(_that);case GamePlayerLoadingState() when loading != null:
return loading(_that);case GamePlayerPlayingState() when playing != null:
return playing(_that);case GamePlayerFailureState() when failure != null:
return failure(_that);case GamePlayerExitingState() when exiting != null:
return exiting(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( GamePlayerInitialState value)  initial,required TResult Function( GamePlayerLoadingState value)  loading,required TResult Function( GamePlayerPlayingState value)  playing,required TResult Function( GamePlayerFailureState value)  failure,required TResult Function( GamePlayerExitingState value)  exiting,}){
final _that = this;
switch (_that) {
case GamePlayerInitialState():
return initial(_that);case GamePlayerLoadingState():
return loading(_that);case GamePlayerPlayingState():
return playing(_that);case GamePlayerFailureState():
return failure(_that);case GamePlayerExitingState():
return exiting(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( GamePlayerInitialState value)?  initial,TResult? Function( GamePlayerLoadingState value)?  loading,TResult? Function( GamePlayerPlayingState value)?  playing,TResult? Function( GamePlayerFailureState value)?  failure,TResult? Function( GamePlayerExitingState value)?  exiting,}){
final _that = this;
switch (_that) {
case GamePlayerInitialState() when initial != null:
return initial(_that);case GamePlayerLoadingState() when loading != null:
return loading(_that);case GamePlayerPlayingState() when playing != null:
return playing(_that);case GamePlayerFailureState() when failure != null:
return failure(_that);case GamePlayerExitingState() when exiting != null:
return exiting(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function( GamePlayerLoadingStage stage,  int retryCount,  String? gameUrl)?  loading,TResult Function( String gameUrl,  bool showWebView,  bool isNewTabOpened)?  playing,TResult Function( GamePlayerErrorType failureType,  String? failureMessage,  bool isRetryable,  int retryCount,  String? gameUrl)?  failure,TResult Function( bool showWebView,  double reloadProgress,  bool isReloadingAssets,  bool reloadFailed)?  exiting,required TResult orElse(),}) {final _that = this;
switch (_that) {
case GamePlayerInitialState() when initial != null:
return initial();case GamePlayerLoadingState() when loading != null:
return loading(_that.stage,_that.retryCount,_that.gameUrl);case GamePlayerPlayingState() when playing != null:
return playing(_that.gameUrl,_that.showWebView,_that.isNewTabOpened);case GamePlayerFailureState() when failure != null:
return failure(_that.failureType,_that.failureMessage,_that.isRetryable,_that.retryCount,_that.gameUrl);case GamePlayerExitingState() when exiting != null:
return exiting(_that.showWebView,_that.reloadProgress,_that.isReloadingAssets,_that.reloadFailed);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function( GamePlayerLoadingStage stage,  int retryCount,  String? gameUrl)  loading,required TResult Function( String gameUrl,  bool showWebView,  bool isNewTabOpened)  playing,required TResult Function( GamePlayerErrorType failureType,  String? failureMessage,  bool isRetryable,  int retryCount,  String? gameUrl)  failure,required TResult Function( bool showWebView,  double reloadProgress,  bool isReloadingAssets,  bool reloadFailed)  exiting,}) {final _that = this;
switch (_that) {
case GamePlayerInitialState():
return initial();case GamePlayerLoadingState():
return loading(_that.stage,_that.retryCount,_that.gameUrl);case GamePlayerPlayingState():
return playing(_that.gameUrl,_that.showWebView,_that.isNewTabOpened);case GamePlayerFailureState():
return failure(_that.failureType,_that.failureMessage,_that.isRetryable,_that.retryCount,_that.gameUrl);case GamePlayerExitingState():
return exiting(_that.showWebView,_that.reloadProgress,_that.isReloadingAssets,_that.reloadFailed);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function( GamePlayerLoadingStage stage,  int retryCount,  String? gameUrl)?  loading,TResult? Function( String gameUrl,  bool showWebView,  bool isNewTabOpened)?  playing,TResult? Function( GamePlayerErrorType failureType,  String? failureMessage,  bool isRetryable,  int retryCount,  String? gameUrl)?  failure,TResult? Function( bool showWebView,  double reloadProgress,  bool isReloadingAssets,  bool reloadFailed)?  exiting,}) {final _that = this;
switch (_that) {
case GamePlayerInitialState() when initial != null:
return initial();case GamePlayerLoadingState() when loading != null:
return loading(_that.stage,_that.retryCount,_that.gameUrl);case GamePlayerPlayingState() when playing != null:
return playing(_that.gameUrl,_that.showWebView,_that.isNewTabOpened);case GamePlayerFailureState() when failure != null:
return failure(_that.failureType,_that.failureMessage,_that.isRetryable,_that.retryCount,_that.gameUrl);case GamePlayerExitingState() when exiting != null:
return exiting(_that.showWebView,_that.reloadProgress,_that.isReloadingAssets,_that.reloadFailed);case _:
  return null;

}
}

}

class GamePlayerInitialState extends GamePlayerState with DiagnosticableTreeMixin {
  const GamePlayerInitialState(): super._();
  
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'GamePlayerState.initial'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GamePlayerInitialState);
}

@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'GamePlayerState.initial()';
}

}

class GamePlayerLoadingState extends GamePlayerState with DiagnosticableTreeMixin {
  const GamePlayerLoadingState({this.stage = GamePlayerLoadingStage.settingUp, this.retryCount = 0, this.gameUrl}): super._();
  
@JsonKey() final  GamePlayerLoadingStage stage;
@JsonKey() final  int retryCount;
 final  String? gameUrl;

@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GamePlayerLoadingStateCopyWith<GamePlayerLoadingState> get copyWith => _$GamePlayerLoadingStateCopyWithImpl<GamePlayerLoadingState>(this, _$identity);

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'GamePlayerState.loading'))
    ..add(DiagnosticsProperty('stage', stage))..add(DiagnosticsProperty('retryCount', retryCount))..add(DiagnosticsProperty('gameUrl', gameUrl));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GamePlayerLoadingState&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.retryCount, retryCount) || other.retryCount == retryCount)&&(identical(other.gameUrl, gameUrl) || other.gameUrl == gameUrl));
}

@override
int get hashCode => Object.hash(runtimeType,stage,retryCount,gameUrl);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'GamePlayerState.loading(stage: $stage, retryCount: $retryCount, gameUrl: $gameUrl)';
}

}

abstract mixin class $GamePlayerLoadingStateCopyWith<$Res> implements $GamePlayerStateCopyWith<$Res> {
  factory $GamePlayerLoadingStateCopyWith(GamePlayerLoadingState value, $Res Function(GamePlayerLoadingState) _then) = _$GamePlayerLoadingStateCopyWithImpl;
@useResult
$Res call({
 GamePlayerLoadingStage stage, int retryCount, String? gameUrl
});

}
class _$GamePlayerLoadingStateCopyWithImpl<$Res>
    implements $GamePlayerLoadingStateCopyWith<$Res> {
  _$GamePlayerLoadingStateCopyWithImpl(this._self, this._then);

  final GamePlayerLoadingState _self;
  final $Res Function(GamePlayerLoadingState) _then;

@pragma('vm:prefer-inline') $Res call({Object? stage = null,Object? retryCount = null,Object? gameUrl = freezed,}) {
  return _then(GamePlayerLoadingState(
stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as GamePlayerLoadingStage,retryCount: null == retryCount ? _self.retryCount : retryCount // ignore: cast_nullable_to_non_nullable
as int,gameUrl: freezed == gameUrl ? _self.gameUrl : gameUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}

class GamePlayerPlayingState extends GamePlayerState with DiagnosticableTreeMixin {
  const GamePlayerPlayingState({required this.gameUrl, this.showWebView = false, this.isNewTabOpened = false}): super._();
  
 final  String gameUrl;
@JsonKey() final  bool showWebView;
@JsonKey() final  bool isNewTabOpened;

@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GamePlayerPlayingStateCopyWith<GamePlayerPlayingState> get copyWith => _$GamePlayerPlayingStateCopyWithImpl<GamePlayerPlayingState>(this, _$identity);

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'GamePlayerState.playing'))
    ..add(DiagnosticsProperty('gameUrl', gameUrl))..add(DiagnosticsProperty('showWebView', showWebView))..add(DiagnosticsProperty('isNewTabOpened', isNewTabOpened));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GamePlayerPlayingState&&(identical(other.gameUrl, gameUrl) || other.gameUrl == gameUrl)&&(identical(other.showWebView, showWebView) || other.showWebView == showWebView)&&(identical(other.isNewTabOpened, isNewTabOpened) || other.isNewTabOpened == isNewTabOpened));
}

@override
int get hashCode => Object.hash(runtimeType,gameUrl,showWebView,isNewTabOpened);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'GamePlayerState.playing(gameUrl: $gameUrl, showWebView: $showWebView, isNewTabOpened: $isNewTabOpened)';
}

}

abstract mixin class $GamePlayerPlayingStateCopyWith<$Res> implements $GamePlayerStateCopyWith<$Res> {
  factory $GamePlayerPlayingStateCopyWith(GamePlayerPlayingState value, $Res Function(GamePlayerPlayingState) _then) = _$GamePlayerPlayingStateCopyWithImpl;
@useResult
$Res call({
 String gameUrl, bool showWebView, bool isNewTabOpened
});

}
class _$GamePlayerPlayingStateCopyWithImpl<$Res>
    implements $GamePlayerPlayingStateCopyWith<$Res> {
  _$GamePlayerPlayingStateCopyWithImpl(this._self, this._then);

  final GamePlayerPlayingState _self;
  final $Res Function(GamePlayerPlayingState) _then;

@pragma('vm:prefer-inline') $Res call({Object? gameUrl = null,Object? showWebView = null,Object? isNewTabOpened = null,}) {
  return _then(GamePlayerPlayingState(
gameUrl: null == gameUrl ? _self.gameUrl : gameUrl // ignore: cast_nullable_to_non_nullable
as String,showWebView: null == showWebView ? _self.showWebView : showWebView // ignore: cast_nullable_to_non_nullable
as bool,isNewTabOpened: null == isNewTabOpened ? _self.isNewTabOpened : isNewTabOpened // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}

class GamePlayerFailureState extends GamePlayerState with DiagnosticableTreeMixin {
  const GamePlayerFailureState({required this.failureType, this.failureMessage, this.isRetryable = false, this.retryCount = 0, this.gameUrl}): super._();
  
 final  GamePlayerErrorType failureType;
 final  String? failureMessage;
@JsonKey() final  bool isRetryable;
@JsonKey() final  int retryCount;
 final  String? gameUrl;

@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GamePlayerFailureStateCopyWith<GamePlayerFailureState> get copyWith => _$GamePlayerFailureStateCopyWithImpl<GamePlayerFailureState>(this, _$identity);

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'GamePlayerState.failure'))
    ..add(DiagnosticsProperty('failureType', failureType))..add(DiagnosticsProperty('failureMessage', failureMessage))..add(DiagnosticsProperty('isRetryable', isRetryable))..add(DiagnosticsProperty('retryCount', retryCount))..add(DiagnosticsProperty('gameUrl', gameUrl));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GamePlayerFailureState&&(identical(other.failureType, failureType) || other.failureType == failureType)&&(identical(other.failureMessage, failureMessage) || other.failureMessage == failureMessage)&&(identical(other.isRetryable, isRetryable) || other.isRetryable == isRetryable)&&(identical(other.retryCount, retryCount) || other.retryCount == retryCount)&&(identical(other.gameUrl, gameUrl) || other.gameUrl == gameUrl));
}

@override
int get hashCode => Object.hash(runtimeType,failureType,failureMessage,isRetryable,retryCount,gameUrl);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'GamePlayerState.failure(failureType: $failureType, failureMessage: $failureMessage, isRetryable: $isRetryable, retryCount: $retryCount, gameUrl: $gameUrl)';
}

}

abstract mixin class $GamePlayerFailureStateCopyWith<$Res> implements $GamePlayerStateCopyWith<$Res> {
  factory $GamePlayerFailureStateCopyWith(GamePlayerFailureState value, $Res Function(GamePlayerFailureState) _then) = _$GamePlayerFailureStateCopyWithImpl;
@useResult
$Res call({
 GamePlayerErrorType failureType, String? failureMessage, bool isRetryable, int retryCount, String? gameUrl
});

}
class _$GamePlayerFailureStateCopyWithImpl<$Res>
    implements $GamePlayerFailureStateCopyWith<$Res> {
  _$GamePlayerFailureStateCopyWithImpl(this._self, this._then);

  final GamePlayerFailureState _self;
  final $Res Function(GamePlayerFailureState) _then;

@pragma('vm:prefer-inline') $Res call({Object? failureType = null,Object? failureMessage = freezed,Object? isRetryable = null,Object? retryCount = null,Object? gameUrl = freezed,}) {
  return _then(GamePlayerFailureState(
failureType: null == failureType ? _self.failureType : failureType // ignore: cast_nullable_to_non_nullable
as GamePlayerErrorType,failureMessage: freezed == failureMessage ? _self.failureMessage : failureMessage // ignore: cast_nullable_to_non_nullable
as String?,isRetryable: null == isRetryable ? _self.isRetryable : isRetryable // ignore: cast_nullable_to_non_nullable
as bool,retryCount: null == retryCount ? _self.retryCount : retryCount // ignore: cast_nullable_to_non_nullable
as int,gameUrl: freezed == gameUrl ? _self.gameUrl : gameUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}

class GamePlayerExitingState extends GamePlayerState with DiagnosticableTreeMixin {
  const GamePlayerExitingState({this.showWebView = false, this.reloadProgress = 0.0, this.isReloadingAssets = false, this.reloadFailed = false}): super._();
  
@JsonKey() final  bool showWebView;
@JsonKey() final  double reloadProgress;
@JsonKey() final  bool isReloadingAssets;
@JsonKey() final  bool reloadFailed;

@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GamePlayerExitingStateCopyWith<GamePlayerExitingState> get copyWith => _$GamePlayerExitingStateCopyWithImpl<GamePlayerExitingState>(this, _$identity);

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'GamePlayerState.exiting'))
    ..add(DiagnosticsProperty('showWebView', showWebView))..add(DiagnosticsProperty('reloadProgress', reloadProgress))..add(DiagnosticsProperty('isReloadingAssets', isReloadingAssets))..add(DiagnosticsProperty('reloadFailed', reloadFailed));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GamePlayerExitingState&&(identical(other.showWebView, showWebView) || other.showWebView == showWebView)&&(identical(other.reloadProgress, reloadProgress) || other.reloadProgress == reloadProgress)&&(identical(other.isReloadingAssets, isReloadingAssets) || other.isReloadingAssets == isReloadingAssets)&&(identical(other.reloadFailed, reloadFailed) || other.reloadFailed == reloadFailed));
}

@override
int get hashCode => Object.hash(runtimeType,showWebView,reloadProgress,isReloadingAssets,reloadFailed);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'GamePlayerState.exiting(showWebView: $showWebView, reloadProgress: $reloadProgress, isReloadingAssets: $isReloadingAssets, reloadFailed: $reloadFailed)';
}

}

abstract mixin class $GamePlayerExitingStateCopyWith<$Res> implements $GamePlayerStateCopyWith<$Res> {
  factory $GamePlayerExitingStateCopyWith(GamePlayerExitingState value, $Res Function(GamePlayerExitingState) _then) = _$GamePlayerExitingStateCopyWithImpl;
@useResult
$Res call({
 bool showWebView, double reloadProgress, bool isReloadingAssets, bool reloadFailed
});

}
class _$GamePlayerExitingStateCopyWithImpl<$Res>
    implements $GamePlayerExitingStateCopyWith<$Res> {
  _$GamePlayerExitingStateCopyWithImpl(this._self, this._then);

  final GamePlayerExitingState _self;
  final $Res Function(GamePlayerExitingState) _then;

@pragma('vm:prefer-inline') $Res call({Object? showWebView = null,Object? reloadProgress = null,Object? isReloadingAssets = null,Object? reloadFailed = null,}) {
  return _then(GamePlayerExitingState(
showWebView: null == showWebView ? _self.showWebView : showWebView // ignore: cast_nullable_to_non_nullable
as bool,reloadProgress: null == reloadProgress ? _self.reloadProgress : reloadProgress // ignore: cast_nullable_to_non_nullable
as double,isReloadingAssets: null == isReloadingAssets ? _self.isReloadingAssets : isReloadingAssets // ignore: cast_nullable_to_non_nullable
as bool,reloadFailed: null == reloadFailed ? _self.reloadFailed : reloadFailed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}

// dart format on
