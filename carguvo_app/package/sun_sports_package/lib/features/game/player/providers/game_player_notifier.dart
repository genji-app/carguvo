import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fullscreen_guard/fullscreen_guard.dart';
import 'package:orientation_guard/orientation_guard.dart';
import 'package:sun_sports/core/env/app_env.dart';
import 'package:sun_sports/core/services/auth/token_manager.dart';
import 'package:sun_sports/core/utils/extensions/log_helper.dart';
import 'package:sun_sports/core/utils/safe_state_notifier.dart';
import 'package:sun_sports/core/utils/web_browser_detect/web_browser_detect.dart';
import 'package:sun_sports/features/game/game.dart';

part 'game_player_error.dart';
part 'game_player_event.dart';
part 'game_player_notifier.freezed.dart';
part 'game_player_state.dart';

class GamePlayerNotifier extends StateNotifier<GamePlayerState>
    with LoggerMixin, SafeStateNotifierMixin<GamePlayerState> {
  GamePlayerNotifier({
    required LobbyGame game,
    required ProviderGameManager manager,
    required GameLauncher gameLauncher,
    required WakelockController wakelockController,
    this.assetReloader,
    this.onRefreshBalance,
    this.finishLoadDelay = const Duration(milliseconds: 555),
    this.strictOrientationApply = false,
    this.bypassCooldownWait = false,
  }) : _game = game,
       _manager = manager,
       _gameLauncher = gameLauncher,
       _wakelockController = wakelockController,
       super(const GamePlayerState.initial()) {
    logInfo('GamePlayerNotifier created for ${game.gameName}');
    _runnerEventSub = _runnerController.events.listen(_handleRunnerEvent);
  }

  final LobbyGame _game;
  final ProviderGameManager _manager;
  final GameLauncher _gameLauncher;
  final WakelockController _wakelockController;

  final AssetReloader? assetReloader;

  final VoidCallback? onRefreshBalance;

  final bool strictOrientationApply;

  final bool bypassCooldownWait;

  OrientationController? _orientationController;
  OrientationPolicy? _previousPolicy;
  FullscreenGuardController? _fullscreenGuard;
  int? _serverId;
  int? _roomId;
  String? _roomPassword;
  Map<String, String>? _extraQueryParams;

  final _eventsController = StreamController<GamePlayerEvent>.broadcast();

  Stream<GamePlayerEvent> get events => _eventsController.stream;

  final Duration finishLoadDelay;

  static const _loadTimeout = Duration(seconds: 30);

  static const _maxRetryCount = 3;

  static const _entryDelay = Duration(milliseconds: 388);

  static const _exitDelay = Duration(milliseconds: 388);

  static const _revealDelay = Duration(milliseconds: 388);

  static const _stageOrder = [
    GamePlayerLoadingStage.settingUp,
    GamePlayerLoadingStage.connecting,
    GamePlayerLoadingStage.loadingAssets,
    GamePlayerLoadingStage.readyToReveal,
  ];

  Timer? _timeoutTimer;

  Timer? _finishLoadTimer;

  Timer? _revealTimer;
  Timer? _fallbackLoadTimer;

  final _runnerController = GameRunnerController();
  StreamSubscription<GameRunnerEvent>? _runnerEventSub;

  bool get _isDisposed => isDisposed;

  @override
  GamePlayerState get state => super.state;

  @override
  String get logTag => 'GamePlayer';

  GameRunnerController get runnerController => _runnerController;

  void _cancelAllTimers() {
    _timeoutTimer?.cancel();
    _finishLoadTimer?.cancel();
    _revealTimer?.cancel();
    _fallbackLoadTimer?.cancel();
  }

  void _handleRunnerEvent(GameRunnerEvent event) {
    switch (event) {
      case RunnerLoadStarted():
        _onLoadStart();
      case RunnerLoadStopped():
        _onLoadStop();
      case RunnerErrorOccurred(:final message):
        _handleRunnerError(message);
      case RunnerLogEmitted(
        :final prefix,
        :final level,
        :final message,
        :final error,
        :final stackTrace,
      ):
        _logRunnerMessage(
          prefix,
          level,
          message,
          error: error,
          stackTrace: stackTrace,
        );
      case RunnerHostMessageReceived(:final hostEvent):
        _handleHostMessage(hostEvent);
    }
  }

  void _handleHostMessage(GameHostEvent hostEvent) {
    if (hostEvent.isCloseWebView) requestExit();
  }

  void _transitionToLoading(GamePlayerLoadingStage newStage) {
    if (_isDisposed) return;

    if (state.isPlaying || state.isExiting) {
      logDebug('Ignoring $newStage: state is ${state.runtimeType}');
      return;
    }

    final currentIdx = _stageOrder.indexOf(
      state.currentStage ?? GamePlayerLoadingStage.settingUp,
    );
    final newIdx = _stageOrder.indexOf(newStage);
    if (newIdx < currentIdx) {
      logInfo(
        'Ignoring stage regression: '
        '${state.currentStage?.name} → ${newStage.name}',
      );
      return;
    }

    state = GamePlayerState.loading(
      stage: newStage,
      retryCount: state.retryCount,
      gameUrl: state.gameUrl,
    );
  }

  bool _isInitCalled = false;

  Future<void> initializePlayer({
    required OrientationController orientationController,
    required FullscreenGuardController fullscreenGuard,
    required OrientationPolicy? previousPolicy,
    required OrientationPolicy gamePolicy,
    bool? isMobileLogin,
    int? serverId,
    int? roomId,
    String? roomPassword,
    Map<String, String>? extraQueryParams,
  }) async {
    if (_isInitCalled || _isDisposed) return;
    _isInitCalled = true;

    _serverId = serverId;
    _roomId = roomId;
    _roomPassword = roomPassword;
    _extraQueryParams = extraQueryParams;

    _wakelockController.enable();

    _orientationController = orientationController;
    _previousPolicy = previousPolicy;
    _fullscreenGuard = fullscreenGuard;

    _transitionToLoading(GamePlayerLoadingStage.settingUp);

    if (!kIsWeb) {
      await _fullscreenGuard?.request(
        const FullscreenGateRequest(tag: 'game_player'),
      );
    }

    await Future<void>.delayed(_entryDelay);

    final isOrientationOk = await _applyOrientation(
      orientationController,
      gamePolicy,
    );
    if (!isOrientationOk) {
      state = GamePlayerState.failure(
        failureType: const GamePlayerErrorType.orientationSetupFailed(),
        isRetryable: false,
        retryCount: state.retryCount,
      );
      return;
    }

    _transitionToLoading(GamePlayerLoadingStage.connecting);

    await _setupSessionGuard();

    await loadGameUrl(isMobileLogin: isMobileLogin);
  }

  Future<void> loadGameUrl({bool? isMobileLogin}) async {
    if (_isDisposed) return;

    logInfo(
      'Fetching game URL: '
      'provider=${_game.providerId}, '
      'product=${_game.productId}, '
      'game=${_game.gameCode}, '
      'serverId=$_serverId, '
      'roomId=$_roomId, '
      'roomPassword=$_roomPassword',
    );

    _transitionToLoading(GamePlayerLoadingStage.connecting);

    try {
      final result = await _manager.gameUrlOf(
        _game,
        accessToken: await TokenManager.getAccessToken() ?? '',
        refreshToken: await TokenManager.getRefreshToken() ?? '',
        returnStrategy: _resolveReturnStrategy(),
        serverId: _serverId,
        roomId: _roomId,
        roomPassword: _roomPassword,
        extraQueryParams: _extraQueryParams,
        baseUrlTransformer:
            AppEnv.isPreRelease ? AppEnv.injectPreReleasePath : null,
      );

      if (_isDisposed) return;

      if (result is! LobbyGameUrlReady) {
        _applyGameUrlFailure(result);
        return;
      }
      final url = result.url;

      logInfo('Game URL fetched successfully: $url');

      if (_handleWebRedirect(url)) return;

      state = GamePlayerState.loading(
        stage: state.currentStage == GamePlayerLoadingStage.loadingAssets
            ? GamePlayerLoadingStage.loadingAssets
            : GamePlayerLoadingStage.connecting,
        gameUrl: url,
        retryCount: state.retryCount,
      );

      _startTimeoutTimer();
      _startFallbackLoadTimer(Uri.tryParse(url));
    } catch (e, stackTrace) {
      _handleLoadGameUrlError(e, stackTrace);
    }
  }

  Future<void> requestExit() async {
    if (state.isExiting || _isDisposed) return;

    logInfo('Requesting smooth exit for game: ${_game.gameName}');

    _cancelAllTimers();

    final wasPlaying = state.isPlaying;

    if (wasPlaying) {
      state = const GamePlayerState.exiting(showWebView: true);
      await Future<void>.delayed(const Duration(milliseconds: 188));
      if (_isDisposed) return;
    }

    state = const GamePlayerState.exiting(showWebView: false);

    await _fullscreenGuard?.clear();

    if (_orientationController != null) {
      await _orientationController!.restore(_previousPolicy);
    }
    await Future<void>.delayed(_exitDelay);
    if (_isDisposed) return;

    if (assetReloader != null) {
      state = const GamePlayerState.exiting(
        showWebView: false,
        isReloadingAssets: true,
        reloadProgress: 0.0,
      );

      var success = await assetReloader!.reload(
        onProgress: (progress) {
          if (!_isDisposed && state.isExiting) {
            state = (state as GamePlayerExitingState).copyWith(
              reloadProgress: progress,
            );
          }
        },
      );

      if (_isDisposed) return;

      if (!success) {
        logInfo('Asset reload failed, attempting 1 silent auto-retry...');
        await Future<void>.delayed(const Duration(seconds: 1));
        if (_isDisposed) return;

        success = await assetReloader!.retry(
          onProgress: (progress) {
            if (!_isDisposed && state.isExiting) {
              state = (state as GamePlayerExitingState).copyWith(
                reloadProgress: progress,
              );
            }
          },
        );
        if (_isDisposed) return;
      }

      if (!success) {
        logError('Asset reload failed during exit for game: ${_game.gameName}');
        state = const GamePlayerState.exiting(
          showWebView: false,
          isReloadingAssets: false,
          reloadFailed: true,
        );
        return;
      }

      state = const GamePlayerState.exiting(
        showWebView: false,
        isReloadingAssets: false,
        reloadProgress: 1.0,
      );
    }

    await _completeExitSequence();
  }

  Future<void> retryExitReload() async {
    if (!state.isExiting || _isDisposed) return;
    if (assetReloader == null) return;

    logInfo('Retrying asset reload on exit for game: ${_game.gameName}');
    state = const GamePlayerState.exiting(
      showWebView: false,
      isReloadingAssets: true,
      reloadFailed: false,
      reloadProgress: 0.0,
    );

    final success = await assetReloader!.retry(
      onProgress: (progress) {
        if (!_isDisposed && state.isExiting) {
          state = (state as GamePlayerExitingState).copyWith(
            reloadProgress: progress,
          );
        }
      },
    );

    if (_isDisposed) return;

    if (!success) {
      logError(
        'Asset reload retry failed during exit for game: ${_game.gameName}',
      );
      state = const GamePlayerState.exiting(
        showWebView: false,
        isReloadingAssets: false,
        reloadFailed: true,
      );
      return;
    }

    state = const GamePlayerState.exiting(
      showWebView: false,
      isReloadingAssets: false,
      reloadProgress: 1.0,
    );

    await _completeExitSequence();
  }

  Future<void> forceExit() async {
    if (!state.isExiting || _isDisposed) return;

    logInfo('User chose force exit back to lobby for ${_game.gameName}');
    unawaited(assetReloader?.retry());
    await _completeExitSequence();
  }

  Future<void> _completeExitSequence() async {
    if (_isDisposed) return;

    _cancelAllTimers();

    try {
      onRefreshBalance?.call();
    } catch (e, st) {
      logError('Failed to trigger balance refresh on exit', e, st);
    }

    _eventsController.add(const GamePlayerExitEvent());
  }

  void _handleLoadGameUrlError(Object e, StackTrace stackTrace) {
    if (_isDisposed) return;

    logError('Lấy URL game lỗi ngoài dự kiến', e, stackTrace);
    _setFailure(
      GamePlayerErrorType.unknown('$e'),
      message: '$e',
      isRetryable: true,
    );
  }

  void _applyGameUrlFailure(LobbyGameUrl result) {
    if (_isDisposed) return;

    switch (result) {
      case LobbyGameUrlReady():
        return;

      case LobbyGameUrlNative(:final gameBundle):
        logInfo('Game native, mở bằng bundle $gameBundle');
        _setFailure(
          const GamePlayerErrorType.unavailable(),
          message: 'Game này mở bằng bundle $gameBundle',
        );

      case LobbyGameUrlBlocked(:final status):
        logWarning('Game ${_game.ref} bị chặn: ${status.name}');
        _setFailure(switch (status) {
          SunGameStatus.maintenance => const GamePlayerErrorType.maintenance(),
          SunGameStatus.comingSoon => const GamePlayerErrorType.comingSoon(),
          _ => const GamePlayerErrorType.unavailable(),
        });

      case LobbyGameUrlUnavailable(:final reason):
        logError('Không lấy được URL game ${_game.ref}: $reason');
        _setFailure(
          const GamePlayerErrorType.launchFailed(null),
          isRetryable: true,
        );
    }
  }

  void _setFailure(
    GamePlayerErrorType failureType, {
    String? message,
    bool isRetryable = false,
  }) {
    state = GamePlayerState.failure(
      failureType: failureType,
      failureMessage: message,
      isRetryable: isRetryable,
      retryCount: state.retryCount,
      gameUrl: state.gameUrl,
    );
  }

  @override
  void dispose() {
    logInfo('Disposing GamePlayerNotifier for ${_game.gameName}');
    _wakelockController.disable();
    _fullscreenGuard?.clear();
    _cancelAllTimers();
    _runnerEventSub?.cancel();
    _runnerController.dispose();
    _eventsController.close();
    super.dispose();
  }

  void retry() {
    if (_isDisposed) return;

    final nextRetryCount = state.retryCount + 1;
    logInfo('Retrying game URL request (attempt $nextRetryCount)');

    if (nextRetryCount >= GamePlayerNotifier._maxRetryCount) {
      logError('Max retry count ($nextRetryCount) reached. Stopping retries.');
      state = GamePlayerState.failure(
        failureType:
            state.failureType ?? const GamePlayerErrorType.serverError(),
        isRetryable: false,
        retryCount: nextRetryCount,
        gameUrl: state.gameUrl,
      );
      return;
    }

    state = GamePlayerState.loading(
      stage: GamePlayerLoadingStage.connecting,
      retryCount: nextRetryCount,
      gameUrl: state.gameUrl,
    );
    loadGameUrl();
  }

  void _logRunnerMessage(
    String prefix,
    String level,
    String message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    final fullMessage = '[$prefix] $message';
    switch (level) {
      case 'error':
        logError(fullMessage, error, stackTrace);
      case 'warning':
        logWarning(fullMessage, error, stackTrace);
      case 'info':
        logInfo(fullMessage, error, stackTrace);
      default:
        logDebug(fullMessage, error, stackTrace);
    }
  }

  void _startTimeoutTimer() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(GamePlayerNotifier._loadTimeout, () {
      if (!_isDisposed && state.isLoading) {
        logError(
          'WebView load timeout after ${GamePlayerNotifier._loadTimeout.inSeconds}s '
          '(stage: ${state.currentStage?.name ?? state.runtimeType})',
        );
        _handleError(failureType: const GamePlayerErrorType.loadTimeout());
      }
    });
  }

  void _startFallbackLoadTimer([Uri? url]) {
    _fallbackLoadTimer?.cancel();
    if (kIsWeb) {
      _fallbackLoadTimer = Timer(const Duration(seconds: 10), () {
        if (!_isDisposed && state.isLoading) {
          logWarning(
            'Web failsafe triggered: onLoadStop was not called after 10s. Forcing play stage.',
          );
          _onLoadStop(url);
        }
      });
    }
  }

  void _onLoadStart([Uri? url]) {
    if (_isDisposed || state.isExiting) return;

    if (state.isPlaying && state.showWebView) {
      logInfo('Already playing, ignoring onLoadStart');
      return;
    }

    if (state.hasFailure) return;

    final isInRevealPhase =
        (_finishLoadTimer?.isActive ?? false) ||
        (_revealTimer?.isActive ?? false);
    if (isInRevealPhase) {
      logInfo(
        'Page reloaded during reveal phase (stage: ${state.currentStage?.name}), '
        'resetting to loadingAssets.',
      );
      _cancelAllTimers();
      state = GamePlayerState.loading(
        stage: GamePlayerLoadingStage.loadingAssets,
        gameUrl: state.gameUrl,
        retryCount: state.retryCount,
      );
      _startTimeoutTimer();
      _startFallbackLoadTimer(url);
      return;
    }

    logInfo(
      'WebView started loading: $url '
      '(stage: ${state.currentStage?.name ?? state.runtimeType})',
    );
    _cancelAllTimers();

    if (state.currentStage != GamePlayerLoadingStage.loadingAssets) {
      state = GamePlayerState.loading(
        stage: GamePlayerLoadingStage.loadingAssets,
        gameUrl: state.gameUrl,
        retryCount: state.retryCount,
      );
    }

    _startTimeoutTimer();
    _startFallbackLoadTimer(url);
  }

  void _onLoadStop([Uri? url]) {
    if (_isDisposed || state.isExiting) return;

    if (state.isPlaying && state.showWebView) {
      logInfo('Already playing, ignoring onLoadStop');
      return;
    }

    if (state.hasFailure) {
      logInfo('Already failed, ignoring onLoadStop');
      return;
    }

    if (_finishLoadTimer?.isActive ?? false) {
      logInfo('Finish timer active, ignoring duplicate onLoadStop');
      return;
    }

    logInfo(
      'WebView finished loading: $url '
      '(stage: ${state.currentStage?.name ?? state.runtimeType})',
    );
    _cancelAllTimers();

    logInfo('Phase 1 — finishLoadTimer: ${finishLoadDelay.inMilliseconds}ms');
    _finishLoadTimer = Timer(finishLoadDelay, () {
      if (_isDisposed || state.hasFailure) return;

      _transitionToLoading(GamePlayerLoadingStage.readyToReveal);

      logInfo('Phase 2 — revealTimer: ${_revealDelay.inMilliseconds}ms');
      _revealTimer = Timer(_revealDelay, () {
        if (_isDisposed) return;

        final gameUrl = state.gameUrl;
        if (gameUrl != null) {
          logInfo(
            'Revealing game — total: '
            '${finishLoadDelay.inMilliseconds + _revealDelay.inMilliseconds}ms',
          );
          state = GamePlayerState.playing(
            gameUrl: gameUrl,
            showWebView: true,
            isNewTabOpened: state.maybeMap(
              playing: (s) => s.isNewTabOpened,
              orElse: () => false,
            ),
          );
        } else {
          logError('revealTimer fired but gameUrl is null');
          _handleError(failureType: const GamePlayerErrorType.missingGameUrl());
        }
      });
    });
  }

  void onNewTabOpened() {
    logInfo('Game opened in new tab');
    _finishLoadTimer?.cancel();
    if (_isDisposed) return;

    final gameUrl = state.gameUrl;

    if (gameUrl != null) {
      state = GamePlayerState.playing(
        gameUrl: gameUrl,
        showWebView: true,
        isNewTabOpened: true,
      );
    }
    _onLoadStop();
  }

  void _handleRunnerError(String message) {
    final httpMatch = RegExp(r'^HTTP (\d{3})').firstMatch(message);

    if (httpMatch != null) {
      final code = int.parse(httpMatch.group(1)!);
      _handleError(
        failureType: GamePlayerErrorType.httpError(code),
        isRetryable: code >= 500,
      );
    } else {
      _handleError(failureType: GamePlayerErrorType.unknown(message));
    }
  }

  void _handleError({
    required GamePlayerErrorType failureType,
    bool isRetryable = true,
  }) {
    if (_isDisposed) return;

    logError('WebView Error: $failureType');
    _cancelAllTimers();

    state = GamePlayerState.failure(
      failureType: failureType,
      failureMessage: failureType is GamePlayerUnknownError
          ? failureType.message
          : null,
      isRetryable: isRetryable,
      retryCount: state.retryCount,
      gameUrl: state.gameUrl,
    );
  }

  Future<bool> _applyOrientation(
    OrientationController controller,
    OrientationPolicy policy,
  ) async {
    try {
      await controller.apply(policy);
      return true;
    } catch (e, st) {
      if (strictOrientationApply) {
        logError(
          'Fatal: orientation apply failed for ${policy.debugLabel}',
          e,
          st,
        );
        return false;
      }
      logError('Non-fatal: orientation apply failed, continuing', e, st);
      return true;
    }
  }

  Future<void> _setupSessionGuard() async {
    try {
      if (_game.requiresSessionGuard) {
        if (!bypassCooldownWait) {
          final remaining = _gameLauncher.remainingCooldown(_game.providerId);
          if (remaining > Duration.zero) {
            logInfo(
              'Cooldown active. Waiting ${remaining.inSeconds}s before starting session.',
            );
            await Future<void>.delayed(remaining);
            if (_isDisposed) return;
          }
        }
        _gameLauncher.onSessionStarted(_game.providerId);
      }
    } catch (e, st) {
      logError('Session guard check failed (non-fatal)', e, st);
    }
  }

  SunReturnStrategy? _resolveReturnStrategy() {
    if (!kIsWeb) return null;

    if (embedGameOnMobileWeb) return null;

    final isMobileWebNonSafari = isWebPhoneBrowser && !isIOSSafariWeb;
    if (isIOSSafariWeb && _game.redirectOnIOSSafariWeb) {
      return const SunReturnStrategy.home();
    } else if (isMobileWebNonSafari && _game.redirectOnMobileWeb) {
      return const SunReturnStrategy.home();
    }
    return null;
  }

  bool _handleWebRedirect(String url) {
    if (!kIsWeb) return false;

    if (embedGameOnMobileWeb) return false;

    final isMobileWebNonSafari = isWebPhoneBrowser && !isIOSSafariWeb;
    if (isIOSSafariWeb && _game.redirectOnIOSSafariWeb) {
      logInfo('Redirecting current tab to game URL: $url');
      redirectToUrl(url);
      return true;
    }
    if (isMobileWebNonSafari && _game.redirectOnMobileWeb) {
      logInfo('Redirecting mobile web tab to game URL: $url');
      redirectToUrl(url);
      return true;
    }
    return false;
  }
}
