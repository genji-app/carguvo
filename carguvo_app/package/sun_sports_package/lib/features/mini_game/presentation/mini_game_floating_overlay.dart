import 'dart:async';

import 'package:floating_draggable_widget/floating_draggable_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import 'package:sun_sports/providers/app_init_provider.dart';
import 'package:sun_sports/providers/auth_provider.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/utils/app_logger.dart';
import 'package:sun_sports/core/utils/bundle_manager.dart';
import 'package:sun_sports/core/utils/extensions/rive_helper.dart';
import 'package:sun_sports/core/utils/styles/app_rive.dart';
import 'package:sun_sports/mini/component/mini_loading_gate.dart';
import 'package:sun_sports/mini/diamond/diamond_screen.dart';
import 'package:sun_sports/mini/dragon_ball/dragon_ball_screen.dart';
import 'package:sun_sports/mini/minipoker/minipoker_screen.dart';
import 'package:sun_sports/mini/tx/tai_xiu_screen.dart';
import 'package:sun_sports/mini/tx_lanscape/tai_xiu_landscape_screen.dart';
import 'package:sun_sports/mini/up_down/up_down_screen.dart';
import 'package:sun_sports/shared/layouts/shell_top_block.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:sun_sports/shared/widgets/livestream/livestream_overlay_blocker.dart';
import 'package:sun_sports/shared/widgets/loading/s88_loading.dart';
import 'package:sun_sports/shared/widgets/scrim/iframe_safe_scrim.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';

import 'package:sun_sports/features/mini_game/mini_game_lobby.dart';
import 'package:sun_sports/features/mini_game/socket/mini_game_socket_providers.dart';
import 'package:sun_sports/features/mini_game/socket/mini_game_socket_state.dart';
import 'package:sun_sports/features/mini_game/presentation/mini_game_casino_link.dart';
import 'package:sun_sports/features/game/player/game_player_experiments.dart';
import 'package:sun_sports/features/mini_game/presentation/casino_dom_fab/casino_dom_fab.dart';
import 'package:sun_sports/features/mini_game/presentation/mini_game_expanded_provider.dart';
import 'package:sun_sports/features/mini_game/presentation/mini_game_orientation.dart';
import 'package:sun_sports/features/mini_game/presentation/mini_game_expand_request.dart';
import 'package:sun_sports/features/mini_game/presentation/mini_game_minimized_hit_provider.dart';
import 'package:sun_sports/features/mini_game/presentation/mini_game_visibility_provider.dart';
import 'package:sun_sports/features/mini_game/presentation/widgets/mini_game_casino_back_button.dart';
import 'package:sun_sports/features/mini_game/presentation/widgets/mini_game_fab.dart';
import 'package:sun_sports/features/mini_game/presentation/widgets/mini_game_menu_panel.dart';
import 'package:sun_sports/features/mini_game/presentation/widgets/mini_game_selection.dart';
import 'mini_game_open_trace.dart';

export 'package:sun_sports/features/mini_game/presentation/widgets/mini_game_selection.dart';

final openMiniGamesProvider = StateProvider<List<MiniGameSelection>>(
  (ref) => const [],
);

final miniGameMenuOpenProvider = StateProvider<bool>((ref) => false);

final miniGameMenuAnchorProvider = StateProvider<Offset?>((ref) => null);

void toggleMiniGameLobbyFromNav(WidgetRef ref) {
  final open = ref.read(miniGameMenuOpenProvider);
  if (open) {
    ref.read(miniGameMenuOpenProvider.notifier).state = false;
    return;
  }
  MiniGameOpenTrace.tap();
  ref.read(miniGameMenuAnchorProvider.notifier).state = null;
  ref.read(miniGameMenuOpenProvider.notifier).state = true;
}

final miniGameFabPosProvider = StateProvider<Offset?>((ref) => null);

final miniGameSocketEverAuthedProvider = StateProvider<bool>((ref) => false);

class MiniGameFloatingOverlay extends ConsumerStatefulWidget {
  final Widget child;
  final void Function(MiniGameSelection game)? onGameSelected;

  const MiniGameFloatingOverlay({
    required this.child,
    super.key,
    this.onGameSelected,
  });

  @override
  ConsumerState<MiniGameFloatingOverlay> createState() =>
      _MiniGameFloatingOverlayState();
}

class _MiniGameFloatingOverlayState
    extends ConsumerState<MiniGameFloatingOverlay> {
  final GlobalKey _fabKey = GlobalKey();

  static const double _kBottomNavHeight = 56;

  static const double _kFabDefaultRight = 0;

  static const double _kChatTop = ShellTopMetrics.header;

  static const double _kFabArtTopInset = 8;

  static double _fabDefaultTop(BuildContext context) =>
      _kChatTop - _kFabArtTopInset * MiniGameFab.scaleFor(context);

  static double _mobileDefaultTop(BuildContext context) =>
      _fabDefaultTop(context) + MediaQuery.paddingOf(context).top;

  static const double _kDesktopDefaultLeft = 40;
  static const double _kDesktopDefaultBottom = 104;

  MiniGameSelection? _preloadingGame;

  bool _preloadFailed = false;

  bool _preloadFromLobby = false;

  static const int _kMaxPreloadAttempts = 4;

  static const Duration _kPreloadAttemptTimeout = Duration(seconds: 12);

  BuildContext? _toastContext;

  void _warmMenuAssets() {
  }

  void _openMenuFromFab() {
    MiniGameOpenTrace.tap();
    final ctx = _fabKey.currentContext;
    final box = ctx?.findRenderObject();
    Offset? center;
    if (box is RenderBox && box.attached) {
      final topLeft = box.localToGlobal(Offset.zero);
      center = topLeft + Offset(box.size.width / 2, box.size.height / 2);
    }
    ref.read(miniGameMenuAnchorProvider.notifier).state = center;
    ref.read(miniGameMenuOpenProvider.notifier).state = true;
  }

  void _openMenuFromDomFab() {
    if (!mounted) return;
    ref.read(miniGameMenuAnchorProvider.notifier).state = null;
    ref.read(miniGameMenuOpenProvider.notifier).state = true;
  }

  void _closeMenu() {
    if (!ref.read(miniGameMenuOpenProvider)) return;
    ref.read(miniGameMenuOpenProvider.notifier).state = false;
  }

  void _requestMinimizeExpandedGames() {
    if (!mounted) return;
    for (final game in ref.read(miniGameExpandedProvider)) {
      final tick = ref.read(miniGameMinimizeRequestProvider(game).notifier);
      tick.state = tick.state + 1;
    }
  }

  void _requestCasinoBack() {
    final tick = ref.read(casinoBackRequestProvider.notifier);
    tick.state = tick.state + 1;
  }

  void _onGameSelected(MiniGameSelection game) {
    if (kDebugMode) {
      debugPrint('[MiniGameFloatingOverlay] selected: ${game.name}');
    }

    final handler = widget.onGameSelected;
    if (handler != null) {
      _closeMenu();
      handler(game);
      return;
    }

    if (ref.read(openMiniGamesProvider).contains(game)) {
      _closeMenu();
      final tick = ref.read(miniGameExpandRequestProvider(game).notifier);
      tick.state = tick.state + 1;
      if (!_isGameAssetsReady(game)) {
        _openGameWithLoading(game);
        return;
      }
      _bringGameToTop(game);
      return;
    }

    if (kIsWeb &&
        !ResponsiveBuilder.isDesktop(context) &&
        ref.read(openMiniGamesProvider).isNotEmpty) {
      _closeMenu();
      final toastCtx = _toastContext;
      if (toastCtx != null && toastCtx.mounted) {
        AppToast.show(
          toastCtx,
          type: AppToastType.generic,
          message: I18n.miniGameOnlyOneAtATime,
        );
      }
      return;
    }

    if (_isGameAssetsReady(game)) {
      _closeMenu();
      _bringGameToTop(game);
      return;
    }

    _openGameWithLoading(game);
  }

  bool _isGameAssetsReady(MiniGameSelection game) =>
      BundleManager.instance.isBundleComplete(game.bundleKey);

  List<String> _riveNamesFor(MiniGameSelection game) => switch (game) {
        MiniGameSelection.taiXiu => AppRive.remoteUrlsForPreloadTaiXiu,
        MiniGameSelection.trenDuoi => AppRive.remoteUrlsForPreloadUpDown,
        MiniGameSelection.miniPoker => AppRive.remoteUrlsForPreloadMiniPoker,
        MiniGameSelection.dragonBall => AppRive.remoteUrlsForPreloadDragonBall,
        MiniGameSelection.kimCuong => const <String>[],
      };

  Future<bool> _preloadGameAssets(MiniGameSelection game) async {
    final bundleKey = game.bundleKey;
    final riveNames = _riveNamesFor(game);

    final needsDeepReload = BundleManager.instance.isBundleLoaded(bundleKey) &&
        !BundleManager.instance.isBundleComplete(bundleKey);

    for (var attempt = 0; attempt < _kMaxPreloadAttempts; attempt++) {
      if (attempt > 0) {
        await Future<void>.delayed(Duration(milliseconds: 800 * attempt));
        if (!mounted || _preloadingGame != game) return false;
      }
      try {
        final ok = await _preloadAttempt(
          bundleKey,
          riveNames,
          force: attempt > 0 || needsDeepReload,
        ).timeout(_kPreloadAttemptTimeout);
        if (ok) return true;
      } catch (_) {
      }
    }
    return false;
  }

  Future<bool> _preloadAttempt(
    String bundleKey,
    List<String> riveNames, {
    required bool force,
  }) async {
    if (force) {
      await BundleManager.instance.reloadBundleDeep(bundleKey);
    } else {
      await BundleManager.instance.loadBundle(bundleKey);
    }
    final packOk = BundleManager.instance.isBundleComplete(bundleKey);
    final riveOk = await RiveHelper.warmAllStrict(riveNames);
    return packOk && riveOk;
  }

  Future<void> _openGameWithLoading(MiniGameSelection game) async {
    if (_preloadingGame != null) return;
    _preloadFromLobby = ref.read(miniGameMenuOpenProvider);
    setState(() {
      _preloadingGame = game;
      _preloadFailed = false;
    });
    pushLivestreamOverlayBlock();
    await _runPreloadRound(game, holdMin: true);
  }

  Future<void> _runPreloadRound(
    MiniGameSelection game, {
    required bool holdMin,
  }) async {
    final minHold =
        holdMin ? Future<void>.delayed(kMiniGameMinLoading) : Future<void>.value();
    bool ok;
    try {
      ok = await _preloadGameAssets(game);
    } catch (_) {
      ok = false;
    }
    await minHold;
    if (!mounted) return;
    if (_preloadingGame != game) return;

    _closeMenu();
    if (ok) {
      popLivestreamOverlayBlock();
      setState(() {
        _preloadingGame = null;
        _preloadFailed = false;
      });
      _bringGameToTop(game);
    } else {
      setState(() => _preloadFailed = true);
    }
  }

  void _retryPreload() {
    final game = _preloadingGame;
    if (game == null || !_preloadFailed) return;
    if (_preloadFromLobby) {
      ref.read(miniGameMenuOpenProvider.notifier).state = true;
    }
    setState(() => _preloadFailed = false);
    _runPreloadRound(game, holdMin: false);
  }

  void _cancelPreload() {
    if (_preloadingGame == null) return;
    popLivestreamOverlayBlock();
    setState(() {
      _preloadingGame = null;
      _preloadFailed = false;
    });
  }

  void _bringGameToTop(MiniGameSelection game) {
    if (!ref.read(miniGameVisibilityProvider)) return;
    final current = ref.read(openMiniGamesProvider);
    if (current.isNotEmpty && current.last == game) return;
    final next = [...current.where((g) => g != game), game];
    AppLoggers.ui.i('[MiniGameStack] bringToTop $game: $current → $next');
    ref.read(openMiniGamesProvider.notifier).state = next;
  }

  void _closeGame(MiniGameSelection game) {
    final current = ref.read(openMiniGamesProvider);
    if (!current.contains(game)) return;
    final next = current.where((g) => g != game).toList();
    AppLoggers.ui.i('[MiniGameStack] close $game: $current → $next');
    ref.read(openMiniGamesProvider.notifier).state = next;
  }

  // ignore: unused_element
  void _releaseBundleAfterClose(MiniGameSelection game) {
    if (!kIsWeb || ResponsiveBuilder.isDesktop(context)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (ref.read(openMiniGamesProvider).contains(game)) return;
      if (_preloadingGame == game) return;
      AppLoggers.ui.i('[MiniGameStack] releaseBundle ${game.bundleKey}');
      unawaited(BundleManager.instance.releaseBundle(
        game.bundleKey,
        releaseRive: false,
      ));
    });
  }

  void _closeAllGames(String reason) {
    final current = ref.read(openMiniGamesProvider);
    if (current.isEmpty) return;
    AppLoggers.ui.i('[MiniGameStack] closeAll ($reason): $current → []');
    ref.read(openMiniGamesProvider.notifier).state = const [];
  }

  Widget _buildFabSubtree({required bool casinoBackVisible}) {
    return MiniGameOrientationBuilder(
      builder: (context, turns) => MiniGameRotated(
        quarterTurns: turns,
        swapMediaQuery: false,
        child: Stack(
          children: [
            MiniGameFab(key: _fabKey, onTap: _openMenuFromFab),
            if (casinoBackVisible) ...[
              Positioned(
                top: 0,
                child: MiniGameCasinoBackButton(onTap: _requestCasinoBack),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final isReady = ref.watch(isAppReadyProvider);
    final isVisible = ref.watch(miniGameVisibilityProvider);

    ref.listen<bool>(miniGameVisibilityProvider, (prev, next) {
      if (!next &&
          (ref.read(miniGameMenuOpenProvider) ||
              ref.read(openMiniGamesProvider).isNotEmpty)) {
        _closeMenu();
        _closeAllGames('visibility_hide');
      }
    });

    ref.listen<bool>(casinoGameOpenProvider, (prev, next) {
      if (next &&
          prev != true &&
          kIsWeb &&
          !ResponsiveBuilder.isDesktop(context)) {
        AppLoggers.ui.i('[MiniGameStack] casino open → imageCache.clear()');
        PaintingBinding.instance.imageCache.clear();
      }
    });

    ref.listen<bool>(isAuthenticatedProvider, (prev, next) {
      if (prev == true && !next) {
        _closeMenu();
        _closeAllGames('logout');
        ref.read(miniGameSocketEverAuthedProvider.notifier).state = false;
      }
    });

    ref.listen<List<MiniGameSelection>>(openMiniGamesProvider, (prev, next) {
      final before = prev?.toSet() ?? <MiniGameSelection>{};
      final after = next.toSet();
      var cur = ref.read(miniGameExpandedProvider);
      for (final g in after.difference(before)) {
        cur = {...cur, g};
      }
      for (final g in before.difference(after)) {
        cur = {...cur}..remove(g);
      }
      ref.read(miniGameExpandedProvider.notifier).state = cur;
    });

    ref.listen<bool>(miniGameMenuOpenProvider, (prev, next) {
      if (next && prev != true) _warmMenuAssets();
    });

    ref.listen<MiniGameSelection?>(requestOpenMiniGameProvider, (prev, next) {
      if (next == null) return;
      ref.read(requestOpenMiniGameProvider.notifier).state = null;
      _onGameSelected(next);
    });

    final nativeHiddenKeepAlive = !kIsWeb && !isVisible;
    if (!isAuthenticated || !isReady || (!isVisible && kIsWeb)) {
      return widget.child;
    }

    ref.watch(miniGameLobbyProvider);

    ref.listen<AsyncValue<MiniGameSocketState>>(miniGameSocketStateProvider, (
      prev,
      next,
    ) {
      if (next.valueOrNull is SocketAuthenticated &&
          !ref.read(miniGameSocketEverAuthedProvider)) {
        ref.read(miniGameSocketEverAuthedProvider.notifier).state = true;
      }
    });
    final socketAuthedNow =
        ref.watch(miniGameSocketStateProvider).valueOrNull
            is SocketAuthenticated;
    if (!ref.watch(miniGameSocketEverAuthedProvider) && !socketAuthedNow) {
      return widget.child;
    }

    final openGames = ref.watch(openMiniGamesProvider);
    final menuOpen = ref.watch(miniGameMenuOpenProvider);
    if (menuOpen) MiniGameOpenTrace.mark('overlay build');

    final isDesktop = ResponsiveBuilder.isDesktop(context);
    final fabSize = MiniGameFab.sizeFor(context);
    final savedPos = ref.watch(miniGameFabPosProvider);
    final desktopDefaultDy =
        MediaQuery.of(context).size.height -
        _kDesktopDefaultBottom -
        fabSize;
    final mobileDefaultDx =
        MediaQuery.of(context).size.width -
        _kFabDefaultRight -
        fabSize;
    final mobileDefaultDy = _mobileDefaultTop(context);

    final casinoOpen = ref.watch(casinoGameOpenProvider);
    final hideFabForCasino = casinoOpen;

    final hideFabForBottomNav = !isDesktop;

    final hideFab = hideFabForCasino || hideFabForBottomNav;

    final casinoBackVisible =
        ref.watch(casinoBackButtonVisibleProvider) && !hideFab;
    const casinoBackSlot = MiniGameCasinoBackButton.size + 8;

    final casinoBodyLevel = ref.watch(casinoGameBodyLevelProvider);
    final casinoEmbedActive = kIsWeb &&
        embedGameOnMobileWeb &&
        casinoOpen &&
        casinoBodyLevel &&
        !isDesktop;
    final expandedGames = ref.watch(miniGameExpandedProvider);
    final miniInteracting = menuOpen || expandedGames.isNotEmpty;

    final minimizedHits = ref
        .watch(miniGameMinimizedHitsProvider)
        .values
        .where(
          (h) =>
              openGames.contains(h.game) && !expandedGames.contains(h.game),
        )
        .toList(growable: false);

    final fabSlotHeight =
        fabSize + (casinoBackVisible ? casinoBackSlot : 0);

    if (casinoEmbedActive) {
      CasinoDomFab.instance
        ..enterCasinoEmbed()
        ..setInteractive(interactive: miniInteracting);
      if (miniInteracting || hideFab) {
        CasinoDomFab.instance.hideHitArea();
      } else {
        CasinoDomFab.instance.showHitArea(
          left: savedPos?.dx ?? mobileDefaultDx,
          top: savedPos?.dy ?? mobileDefaultDy,
          width: fabSize,
          height: fabSize,
          dragClampHeight: fabSlotHeight,
          excludeRects: [for (final h in minimizedHits) h.rect],
          onTap: _openMenuFromDomFab,
          onDrag: (l, t) => ref.read(miniGameFabPosProvider.notifier).state =
              Offset(l, t),
        );
      }
      if (expandedGames.isEmpty) {
        CasinoDomFab.instance.stopToolbarWatch();
      } else {
        CasinoDomFab.instance.startToolbarWatch(
          onToolbarShown: _requestMinimizeExpandedGames,
        );
      }
    } else {
      CasinoDomFab.instance.exitCasinoEmbed();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        FloatingDraggableWidget(
          backgroundColor: casinoEmbedActive ? Colors.transparent : null,
          resizeToAvoidBottomInset: false,
          disablePositionAnimation: casinoEmbedActive,
          floatingWidgetWidth: fabSize,
          floatingWidgetHeight: fabSlotHeight,
          dx:
              savedPos?.dx ??
              (isDesktop ? _kDesktopDefaultLeft : mobileDefaultDx),
          dy:
              savedPos?.dy ??
              (isDesktop ? desktopDefaultDy : mobileDefaultDy),
          right: 12,
          bottom:
              _kBottomNavHeight + 12 + MediaQuery.of(context).padding.bottom,
          dragActivationDelay: const Duration(milliseconds: 150),
          onDragEvent: (left, top) =>
              ref.read(miniGameFabPosProvider.notifier).state = Offset(
                left,
                top,
              ),
          floatingWidget: kIsWeb
              ? (menuOpen || hideFab
                  ? const SizedBox.shrink()
                  : PointerInterceptor(
                      intercepting: true,
                      child: _buildFabSubtree(
                        casinoBackVisible: casinoBackVisible,
                      ),
                    ))
              : Offstage(
                  offstage: menuOpen || nativeHiddenKeepAlive || hideFab,
                  child: _buildFabSubtree(
                    casinoBackVisible: casinoBackVisible,
                  ),
                ),
          mainScreenWidget: embedGameOnMobileWeb
              ? Offstage(offstage: casinoEmbedActive, child: widget.child)
              : widget.child,
        ),
        if (menuOpen)
          Positioned.fill(
            child: MiniGameOrientationBuilder(
              builder: (context, turns) => MiniGameRotated(
                quarterTurns: turns,
                child: _MiniGameMenuOverlay(
                  anchor: ref.read(miniGameMenuAnchorProvider),
                  onDismiss: _closeMenu,
                  onGameSelected: _onGameSelected,
                  loadingGame: _preloadingGame,
                ),
              ),
            ),
          ),
        for (final game in openGames) _buildGameLayer(game),
        if (_preloadingGame != null)
          Positioned.fill(
            child: Stack(
              fit: StackFit.expand,
              children: [
                IframeSafeScrim(
                  color: menuOpen
                      ? const Color(0x33000000)
                      : const Color(0xB3000000),
                ),
                MiniGameOrientationBuilder(
                  builder: (context, turns) => MiniGameRotated(
                    quarterTurns: turns,
                    child: _preloadFailed
                        ? _MiniGamePreloadError(
                            onRetry: _retryPreload,
                            onClose: _cancelPreload,
                          )
                        : const S88Loading(
                            indicatorSize: 120,
                            backgroundColor: Colors.transparent,
                          ),
                  ),
                ),
              ],
            ),
          ),
        Positioned.fill(
          child: MiniGameOrientationBuilder(
            builder: (context, turns) => MiniGameRotated(
              quarterTurns: turns,
              child: Overlay(
                initialEntries: [
                  OverlayEntry(
                    builder: (entryContext) {
                      _toastContext = entryContext;
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _rotatedLayer({required Key key, required Widget content}) {
    return Positioned.fill(
      key: key,
      child: MiniGameOrientationBuilder(
        builder: (context, turns) =>
            MiniGameRotated(quarterTurns: turns, child: content),
      ),
    );
  }

  Widget _buildGameLayer(MiniGameSelection game) {
    switch (game) {
      case MiniGameSelection.taiXiu:
        return _rotatedLayer(
          key: const ValueKey('mg_overlay_taixiu'),
          content: Overlay(
            initialEntries: [
              OverlayEntry(
                builder: (entryContext) {
                  final size = MediaQuery.sizeOf(entryContext);
                  final useLandscape = size.width > size.height;
                  return useLandscape
                      ? TaiXiuLandscapeScreen(
                          onClose: () => _closeGame(MiniGameSelection.taiXiu),
                        )
                      : TaiXiuScreen(
                          onClose: () => _closeGame(MiniGameSelection.taiXiu),
                        );
                },
              ),
            ],
          ),
        );
      case MiniGameSelection.trenDuoi:
        return _rotatedLayer(
          key: const ValueKey('mg_overlay_trenduoi'),
          content: Overlay(
            initialEntries: [
              OverlayEntry(
                builder: (_) => UpDownScreen(
                  onClose: () => _closeGame(MiniGameSelection.trenDuoi),
                ),
              ),
            ],
          ),
        );
      case MiniGameSelection.miniPoker:
        return _rotatedLayer(
          key: const ValueKey('mg_overlay_minipoker'),
          content: Overlay(
            initialEntries: [
              OverlayEntry(
                builder: (_) => MinipokerScreen(
                  onClose: () => _closeGame(MiniGameSelection.miniPoker),
                ),
              ),
            ],
          ),
        );
      case MiniGameSelection.dragonBall:
        return _rotatedLayer(
          key: const ValueKey('mg_overlay_dragonball'),
          content: Overlay(
            initialEntries: [
              OverlayEntry(
                builder: (_) => DragonBallScreen(
                  onClose: () => _closeGame(MiniGameSelection.dragonBall),
                ),
              ),
            ],
          ),
        );
      case MiniGameSelection.kimCuong:
        return _rotatedLayer(
          key: const ValueKey('mg_overlay_kimcuong'),
          content: Overlay(
            initialEntries: [
              OverlayEntry(
                builder: (_) => DiamondScreen(
                  onClose: () => _closeGame(MiniGameSelection.kimCuong),
                ),
              ),
            ],
          ),
        );
    }
  }
}

class _MiniGameMenuOverlay extends StatefulWidget {
  final Offset? anchor;
  final VoidCallback onDismiss;
  final void Function(MiniGameSelection game) onGameSelected;

  final MiniGameSelection? loadingGame;

  const _MiniGameMenuOverlay({
    required this.onDismiss,
    required this.onGameSelected,
    this.anchor,
    this.loadingGame,
  });

  @override
  State<_MiniGameMenuOverlay> createState() => _MiniGameMenuOverlayState();
}

class _MiniGameMenuOverlayState extends State<_MiniGameMenuOverlay>
    with SingleTickerProviderStateMixin {
  static const double _kBottomGap = 40;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    reverseDuration: const Duration(milliseconds: 150),
  );
  late final Animation<double> _scale = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutBack,
    reverseCurve: Curves.easeIn,
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
    reverseCurve: Curves.easeIn,
  );

  bool _dismissing = false;

  @override
  void initState() {
    super.initState();
    MiniGameOpenTrace.mark('menu initState');
    pushLivestreamOverlayBlock();
    RiveHelper.warm(AppRive.mnlobbytx);
    RiveHelper.warm(AppRive.mnBadgeTx);
    _controller.forward();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => MiniGameOpenTrace.mark('lobby đã vẽ xong', last: true),
    );
  }

  @override
  void dispose() {
    popLivestreamOverlayBlock();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (_dismissing) return;
    _dismissing = true;
    try {
      await _controller.reverse();
    } finally {
      if (mounted) widget.onDismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenW = constraints.maxWidth;
        final screenH = constraints.maxHeight;
        final safeBottom = MediaQuery.of(context).padding.bottom;

        final scaleToFit = ((screenW - 24) / MiniGameMenuPanel.designWidth)
            .clamp(0.0, 1.0);
        final panelW = MiniGameMenuPanel.designWidth * scaleToFit;
        final panelH = MiniGameMenuPanel.designHeight * scaleToFit;
        final panelLeft = (screenW - panelW) / 2;
        final panelTop = screenH - safeBottom - _kBottomGap - panelH;

        final anchor = widget.anchor;
        final origin = anchor == null
            ? Alignment.center
            : Alignment(
                (((anchor.dx - panelLeft) / panelW) * 2 - 1).clamp(-1.0, 1.0),
                (((anchor.dy - panelTop) / panelH) * 2 - 1).clamp(-1.0, 1.0),
              );

        return Stack(
          children: [
            Positioned.fill(
              child: IframeSafeScrim(
                color: const Color(0xA0000000),
                onTap: widget.loadingGame == null ? _dismiss : null,
                fade: _fade,
              ),
            ),
            Positioned(
              left: panelLeft,
              top: panelTop,
              width: panelW,
              height: panelH,
              child: FadeTransition(
                opacity: _fade,
                child: AnimatedBuilder(
                  animation: _scale,
                  builder: (context, child) => Transform.scale(
                    scale: 0.3 + 0.7 * _scale.value,
                    alignment: origin,
                    child: child,
                  ),
                  child: PointerInterceptor(
                    intercepting: kIsWeb,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {},
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: MiniGameMenuPanel(
                          onGameSelected: widget.onGameSelected,
                          loadingGame: widget.loadingGame,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MiniGamePreloadError extends StatelessWidget {
  const _MiniGamePreloadError({
    required this.onRetry,
    required this.onClose,
  });

  final VoidCallback onRetry;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFF252423),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x1FFFFFFF), width: 0.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                    const Icon(
                      Icons.wifi_off_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Không tải được dữ liệu trò chơi.\n'
                      'Vui lòng kiểm tra kết nối rồi thử lại.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: onClose,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white70,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          child: const Text('Đóng'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: onRetry,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF5C518),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text(
                            I18n.txtRetry,
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                        ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
