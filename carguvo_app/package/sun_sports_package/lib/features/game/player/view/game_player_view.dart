import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/web_browser_detect/web_browser_detect.dart';
import 'package:sun_sports/features/game/game.dart';

class GamePlayerView extends ConsumerWidget {
  const GamePlayerView({
    required this.game,
    required this.webViewId,
    super.key,
  });

  final LobbyGame game;
  final String webViewId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ColoredBox(
      color: Colors.black,
      child: GamePlayerBackground(
        child: Stack(
          children: [
            _GameWebViewLayer(game: game, webViewId: webViewId),

            _StatusOverlay(game: game),
          ],
        ),
      ),
    );
  }
}

class _GameWebViewLayer extends ConsumerWidget {
  const _GameWebViewLayer({required this.game, required this.webViewId});

  final LobbyGame game;
  final String webViewId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shouldMount = ref.watch(
      gamePlayerProvider(game).select((s) => s.shouldMountWebView),
    );

    if (!shouldMount) {
      return const Positioned.fill(child: ColoredBox(color: Colors.black));
    }

    final gameUrl = ref.watch(
      gamePlayerProvider(game).select((s) => s.gameUrl),
    );
    final isNewTabOpened = ref.watch(
      gamePlayerProvider(game).select((s) {
        return s.maybeMap(
          playing: (s) => s.isNewTabOpened,
          orElse: () => false,
        );
      }),
    );
    final notifier = ref.read(gamePlayerProvider(game).notifier);

    return Positioned.fill(
      child: GamePlayerScaffold(
        showControls: game.showScaffoldControls,
        useSafeArea: game.useSafeArea,
        onGoBack: notifier.requestExit,
        child: _buildContent(context, gameUrl, isNewTabOpened, notifier),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    String? gameUrl,
    bool isNewTabOpened,
    GamePlayerNotifier notifier,
  ) {
    if (gameUrl == null) return const SizedBox.shrink();

    if (isFirefoxWeb && isWebPhoneBrowser && game.isProviderGame) {
      return GamePlayerNewTabPlaceholder(
        game: game,
        gameUrl: gameUrl,
        alreadyOpened: isNewTabOpened,
        onOpened: notifier.onNewTabOpened,
        onClose: notifier.requestExit,
      );
    }

    if (isIOSSafariWeb && game.openInNewTabOnIOSSafariWeb) {
      return GamePlayerNewTabPlaceholder(
        game: game,
        gameUrl: gameUrl,
        alreadyOpened: isNewTabOpened,
        onOpened: notifier.onNewTabOpened,
        onClose: notifier.requestExit,
      );
    }

    return GameRunnerView(
      key: ValueKey('runner-$webViewId'),
      game: game,
      gameUrl: gameUrl,
      webViewId: webViewId,
      controller: notifier.runnerController,
    );
  }
}

class _StatusOverlay extends ConsumerStatefulWidget {
  const _StatusOverlay({required this.game});

  final LobbyGame game;

  @override
  ConsumerState<_StatusOverlay> createState() => _StatusOverlayState();
}

class _StatusOverlayState extends ConsumerState<_StatusOverlay> {
  Timer? _settlingTimer;
  bool _settled = false;
  bool _fadeCompleted = false;

  @override
  void dispose() {
    _settlingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isExiting = ref.watch(
      gamePlayerProvider(widget.game).select((s) => s.isExiting),
    );
    final isReloadingAssets = ref.watch(
      gamePlayerProvider(widget.game).select((s) => s.isReloadingAssets),
    );
    final reloadFailed = ref.watch(
      gamePlayerProvider(widget.game).select((s) => s.reloadFailed),
    );
    final reloadProgress = ref.watch(
      gamePlayerProvider(widget.game).select((s) => s.reloadProgress),
    );
    final isPlaying = ref.watch(
      gamePlayerProvider(widget.game).select((s) => s.isPlaying),
    );
    final progress = ref.watch(
      gamePlayerProvider(widget.game).select((s) => s.estimatedProgress),
    );
    final failureState = ref.watch(
      gamePlayerProvider(
        widget.game,
      ).select((s) => s.maybeMap(failure: (f) => f, orElse: () => null)),
    );

    final notifier = ref.read(gamePlayerProvider(widget.game).notifier);

    final policy = ref
        .watch(gameOrientationResolverProvider)
        .resolve(context, widget.game);
    final currentOrientation = MediaQuery.orientationOf(context);
    final isStrictLandscape = policy.allowsLandscape && !policy.allowsPortrait;

    if (!isStrictLandscape) {
      _settled = true;
    } else if (currentOrientation != Orientation.landscape || isExiting) {
      _settlingTimer?.cancel();
      _settlingTimer = null;
      if (_settled) {
        _settled = false;
      }
    } else if (!_settled && _settlingTimer == null) {
      _settlingTimer = Timer(const Duration(milliseconds: 120), () {
        if (mounted) {
          setState(() => _settled = true);
        }
      });
    }

    final showOverlay = !isPlaying;
    if (showOverlay && _fadeCompleted) {
      _fadeCompleted = false;
    }

    final contentVisible = !isExiting && _settled;

    Widget content;
    if (failureState != null) {
      content = Center(
        key: const ValueKey('failure'),
        child: GamePlayerFailureView(
          failureState: failureState,
          onClose: notifier.requestExit,
          onRetry: notifier.retry,
        ),
      );
    } else if (_fadeCompleted && isPlaying) {
      content = const SizedBox.shrink(key: ValueKey('empty'));
    } else if (isExiting) {
      if (reloadFailed) {
        content = Center(
          key: const ValueKey('exit_reload_failed'),
          child: GamePlayerReloadFailureView(
            onRetry: notifier.retryExitReload,
            onForceExit: notifier.forceExit,
          ),
        );
      } else if (isReloadingAssets) {
        content = Center(
          key: const ValueKey('exit_reloading'),
          child: GamePlayerLoadingView(
            progress: reloadProgress,
            contentVisible: true,
          ),
        );
      } else {
        content = const SizedBox.shrink(key: ValueKey('exit_empty'));
      }
    } else {
      content = Center(
        key: const ValueKey('loading'),
        child: GamePlayerLoadingView(
          progress: progress,
          contentVisible: contentVisible,
        ),
      );
    }

    final fadeDuration = Duration(
      milliseconds: isExiting ? 188 : (showOverlay ? 288 : 388),
    );

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: !showOverlay,
        child: PointerInterceptor(
          intercepting: showOverlay,
          child: AnimatedOpacity(
            opacity: showOverlay ? 1.0 : 0.0,
            duration: fadeDuration,
            curve: isExiting ? Curves.easeInCubic : Curves.easeOutCubic,
            onEnd: () {
              if (mounted && !showOverlay && !_fadeCompleted) {
                setState(() => _fadeCompleted = true);
              }
            },
            child: ColoredBox(
              color: AppColorStyles.backgroundPrimary,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
