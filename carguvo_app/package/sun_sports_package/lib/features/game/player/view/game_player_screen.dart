import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fullscreen_guard/fullscreen_guard.dart';
import 'package:orientation_guard/orientation_guard.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/web_browser_detect/web_browser_detect.dart';
import 'package:sun_sports/features/game/game.dart';
import 'package:sun_sports/features/game/player/providers/asset_wipe_provider.dart';
import 'package:sun_sports/features/mini_game/presentation/mini_game_casino_link.dart';
import 'package:sun_sports/features/mini_game/presentation/mini_game_visibility_provider.dart';
import 'package:sun_sports/shared/widgets/livestream/livestream_overlay_blocker.dart';

class GamePlayerScreen extends ConsumerStatefulWidget {
  const GamePlayerScreen({
    required this.game,
    this.serverId,
    this.roomId,
    this.roomPassword,
    this.extraQueryParams,
    super.key,
  });

  final LobbyGame game;
  final int? serverId;
  final int? roomId;
  final String? roomPassword;
  final Map<String, String>? extraQueryParams;

  static Route<void> route({
    required LobbyGame game,
    int? serverId,
    int? roomId,
    String? roomPassword,
    Map<String, String>? extraQueryParams,
  }) {
    return PageRouteBuilder<void>(
      pageBuilder: (_, __, ___) => GamePlayerScreen(
        game: game,
        serverId: serverId,
        roomId: roomId,
        roomPassword: roomPassword,
        extraQueryParams: extraQueryParams,
      ),
      transitionDuration: Duration.zero,
      reverseTransitionDuration: const Duration(milliseconds: 288),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ColoredBox(
            color: AppColorStyles.backgroundPrimary,
            child: child,
          ),
        );
      },
    );
  }

  @override
  ConsumerState<GamePlayerScreen> createState() => _GamePlayerScreenState();
}

class _GamePlayerScreenState extends ConsumerState<GamePlayerScreen> {
  late final String _webViewId;
  bool _hasInitialized = false;
  bool _isExiting = false;
  StreamSubscription<GamePlayerEvent>? _eventSubscription;

  final ValueNotifier<bool> _isMismatched = ValueNotifier<bool>(false);
  bool _lastRawMismatch = false;
  Timer? _mismatchTimer;

  OrientationController? _capturedController;
  OrientationPolicy? _capturedPreviousPolicy;

  LobbyGame get game => widget.game;

  bool _livestreamBlocked = false;

  @override
  void initState() {
    super.initState();
    _webViewId =
        'game-webview-${game.gameCode.hashCode}-${DateTime.now().millisecondsSinceEpoch}';

    pushLivestreamOverlayBlock();
    _livestreamBlocked = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(casinoGameOpenProvider.notifier).state = true;
      ref.read(casinoGameBodyLevelProvider.notifier).state = game.isSunGame;
    });

    _eventSubscription = ref
        .read(gamePlayerProvider(game).notifier)
        .events
        .listen(_handleEvent);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_hasInitialized) {
      _hasInitialized = true;

      _capturedController = OrientationScope.of(context);
      _capturedPreviousPolicy = OrientationScope.maybePolicyOf(context);

      debugPrint(
        '[GamePlayerScreen] Captured previousPolicy: ${_capturedPreviousPolicy?.debugLabel}',
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final policy = ref
            .read(gameOrientationResolverProvider)
            .resolve(context, game);

        debugPrint(
          '[GamePlayerScreen] initializePlayer called: game=${game.gameCode}, serverId=${widget.serverId}, roomId=${widget.roomId}',
        );

        ref
            .read(gamePlayerProvider(game).notifier)
            .initializePlayer(
              orientationController: _capturedController!,
              fullscreenGuard: FullscreenGuard.of(context),
              previousPolicy: _capturedPreviousPolicy,
              gamePolicy: policy,
              serverId: widget.serverId,
              roomId: widget.roomId,
              roomPassword: widget.roomPassword,
              extraQueryParams: widget.extraQueryParams,
            );
      });
    }
  }

  @override
  void dispose() {
    if (_livestreamBlocked) {
      popLivestreamOverlayBlock();
      _livestreamBlocked = false;
    }
    _mismatchTimer?.cancel();
    _isMismatched.dispose();
    _eventSubscription?.cancel();
    super.dispose();
  }

  void _handleEvent(GamePlayerEvent event) {
    switch (event) {
      case GamePlayerExitEvent():
        if (mounted && !_isExiting) {
          _isExiting = true;
          ref.read(assetWipeControllerProvider).beginReloadGate();
          final navigator = Navigator.of(context);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) navigator.pop();
          });
        }
    }
  }

  @visibleForTesting
  void handleMismatch(bool mismatched) {
    if (!mounted) return;
    _lastRawMismatch = mismatched;
    _syncMismatchState();
  }

  void _syncMismatchState() {
    _mismatchTimer?.cancel();
    if (!mounted) return;
    final state = ref.read(gamePlayerProvider(game));

    final bool shouldHideMismatch = state.maybeMap(
      initial: (_) => true,
      exiting: (_) => true,
      orElse: () => false,
    );

    if (_lastRawMismatch) {
      if (shouldHideMismatch) {
        _isMismatched.value = false;
        return;
      }

      if (_isMismatched.value) return;

      _mismatchTimer = Timer(const Duration(seconds: 1), () {
        if (mounted) _isMismatched.value = true;
      });
    } else {
      _isMismatched.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final OrientationPolicy policy = ref
        .watch(gameOrientationResolverProvider)
        .resolve(context, game);

    final notifier = ref.read(gamePlayerProvider(game).notifier);
    final canPop = ref.watch(gamePlayerProvider(game).select((s) => s.canPop));

    final currentOrientation = MediaQuery.orientationOf(context);
    final isOrientationSettled =
        !policy.allowsLandscape ||
        policy.allowsPortrait ||
        currentOrientation == Orientation.landscape;

    ref.listen(
      gamePlayerProvider(game).select(
        (s) => (
          isPlaying: s.isPlaying,
          isExiting: s.isExiting,
          hasFailure: s.hasFailure,
        ),
      ),
      (prev, next) {
        if (next.isExiting) {
          if (prev?.isExiting != true) {
            ref.read(casinoBackButtonVisibleProvider.notifier).state = false;
            ref.read(miniGameVisibilityProvider.notifier).hide();
          }
          return;
        }
        ref.read(casinoBackButtonVisibleProvider.notifier).state = false;
        if ((next.isPlaying || next.hasFailure) && isOrientationSettled) {
          ref.read(miniGameVisibilityProvider.notifier).show();
        }
      },
    );

    final playerState = ref.watch(
      gamePlayerProvider(game).select(
        (s) => (
          isPlaying: s.isPlaying,
          isExiting: s.isExiting,
          hasFailure: s.hasFailure,
        ),
      ),
    );
    if (!playerState.isExiting &&
        (playerState.isPlaying || playerState.hasFailure) &&
        isOrientationSettled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (!ref.read(miniGameVisibilityProvider)) {
          ref.read(miniGameVisibilityProvider.notifier).show();
        }
      });
    }

    ref.listen(casinoBackRequestProvider, (prev, next) {
      if (prev != null && next != prev) notifier.requestExit();
    });

    ref.listen(
      gamePlayerProvider(game).select(
        (s) => s.maybeMap(
          initial: (_) => true,
          exiting: (_) => true,
          orElse: () => false,
        ),
      ),
      (_, __) => _syncMismatchState(),
    );

    return Scaffold(
      resizeToAvoidBottomInset:
          false,
      backgroundColor: AppColorStyles.backgroundPrimary,
      body: PopScope(
        canPop: _isExiting || canPop,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          notifier.requestExit();
        },
        child: OrientationGuard(
          policy: policy,
          blockOnMismatch: false,
          onMismatchChanged: handleMismatch,
          child: Stack(
            children: [
              KeyboardAwareGameView(
                child: GamePlayerView(game: game, webViewId: _webViewId),
              ),

              if (kIsWeb && !(game.isSunGame && isWebPhoneBrowser))
                ValueListenableBuilder<bool>(
                  valueListenable: _isMismatched,
                  builder: (_, isMismatch, __) => AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isMismatch
                        ? GamePlayerOrientationNotice(
                            key: const ValueKey('mismatch-overlay'),
                            policy: policy,
                          )
                        : const SizedBox.shrink(),
                  ),
                ),

            ],
          ),
        ),
      ),
    );
  }
}
