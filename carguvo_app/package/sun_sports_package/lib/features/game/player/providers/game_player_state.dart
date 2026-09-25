part of 'game_player_notifier.dart';

enum GamePlayerLoadingStage {
  settingUp,

  connecting,

  loadingAssets,

  readyToReveal,
}

@freezed
sealed class GamePlayerState with _$GamePlayerState {
  const GamePlayerState._();

  const factory GamePlayerState.initial() = GamePlayerInitialState;

  const factory GamePlayerState.loading({
    @Default(GamePlayerLoadingStage.settingUp) GamePlayerLoadingStage stage,
    @Default(0) int retryCount,
    String? gameUrl,
  }) = GamePlayerLoadingState;

  const factory GamePlayerState.playing({
    required String gameUrl,
    @Default(false) bool showWebView,
    @Default(false) bool isNewTabOpened,
  }) = GamePlayerPlayingState;

  const factory GamePlayerState.failure({
    required GamePlayerErrorType failureType,
    String? failureMessage,
    @Default(false) bool isRetryable,
    @Default(0) int retryCount,
    String? gameUrl,
  }) = GamePlayerFailureState;

  const factory GamePlayerState.exiting({
    @Default(false) bool showWebView,
    @Default(0.0) double reloadProgress,
    @Default(false) bool isReloadingAssets,
    @Default(false) bool reloadFailed,
  }) = GamePlayerExitingState;

  bool get canPop =>
      maybeMap(initial: (_) => true, failure: (_) => true, orElse: () => false);

  bool get hasFailure => maybeMap(failure: (_) => true, orElse: () => false);

  bool get isLoading => maybeMap(loading: (_) => true, orElse: () => false);

  bool get isPlaying => maybeMap(playing: (_) => true, orElse: () => false);

  bool get isOrientationReady => maybeMap(
    loading: (s) => s.stage != GamePlayerLoadingStage.settingUp,
    playing: (_) => true,
    exiting: (_) => true,
    orElse: () => false,
  );

  bool get showLoading => map(
    initial: (_) => false,
    loading: (_) => true,
    playing: (_) => false,
    failure: (_) => false,
    exiting: (_) => true,
  );

  GamePlayerErrorType? get failureType =>
      maybeMap(failure: (s) => s.failureType, orElse: () => null);

  bool get isExiting => maybeMap(exiting: (_) => true, orElse: () => false);

  double get reloadProgress =>
      maybeMap(exiting: (s) => s.reloadProgress, orElse: () => 0.0);

  bool get isReloadingAssets =>
      maybeMap(exiting: (s) => s.isReloadingAssets, orElse: () => false);

  bool get reloadFailed =>
      maybeMap(exiting: (s) => s.reloadFailed, orElse: () => false);

  String? get gameUrl => mapOrNull(
    loading: (s) => s.gameUrl,
    playing: (s) => s.gameUrl,
    failure: (s) => s.gameUrl,
  );

  int get retryCount => map(
    initial: (_) => 0,
    loading: (s) => s.retryCount,
    playing: (_) => 0,
    failure: (s) => s.retryCount,
    exiting: (_) => 0,
  );

  GamePlayerLoadingStage? get currentStage =>
      maybeMap(loading: (s) => s.stage, orElse: () => null);

  String? get failureMessage =>
      maybeMap(failure: (s) => s.failureMessage, orElse: () => null);

  bool get isRetryable =>
      maybeMap(failure: (s) => s.isRetryable, orElse: () => false);

  bool get shouldMountWebView => maybeMap(
    loading: (s) => s.gameUrl != null,
    playing: (_) => true,
    exiting: (s) => s.showWebView,
    orElse: () => false,
  );

  bool get showWebView => maybeMap(
    playing: (s) => s.showWebView,
    exiting: (s) => s.showWebView,
    orElse: () => false,
  );
}

extension GamePlayerStateProgress on GamePlayerState {
  double get estimatedProgress {
    return maybeMap(
      loading: (s) => switch (s.stage) {
        GamePlayerLoadingStage.settingUp => 0.1,
        GamePlayerLoadingStage.connecting => 0.4,
        GamePlayerLoadingStage.loadingAssets => 0.7,
        GamePlayerLoadingStage.readyToReveal => 1.0,
      },
      playing: (_) => 1.0,
      exiting: (s) => s.isReloadingAssets ? s.reloadProgress : 1.0,
      orElse: () => 0.0,
    );
  }
}
