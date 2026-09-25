import 'dart:async';

import 'package:app_env/app_env.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fullscreen_guard/fullscreen_guard.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_socket/sport_socket.dart' as socket;
import 'package:sun_sports/core/constants/breakpoints.dart';
import 'package:sun_sports/core/network/sb_api_client.dart' show HttpException;
import 'package:sun_sports/core/network/sb_config_cache.dart';
import 'package:sun_sports/core/perf/perf.dart';
import 'package:sun_sports/providers/main_content_provider.dart';
import 'package:sun_sports/core/providers/live_chat_expanded_provider.dart';
import 'package:sun_sports/core/providers/platform_ui_provider.dart';
import 'package:sun_sports/features/sport/data/adapters/sport_socket_adapter.dart';
import 'package:sun_sports/features/sport/data/adapters/sport_socket_adapter_provider.dart';
import 'package:sun_sports/providers/infra_provider.dart';
import 'package:sun_sports/core/services/auth/sb_login.dart';
import 'package:sun_sports/core/services/auth/token_error_handler.dart';
import 'package:sun_sports/core/services/datasources/events_v2_remote_datasource.dart';
import 'package:sun_sports/core/services/maintenance/maintenance_service.dart';
import 'package:sun_sports/providers/app_init_provider.dart';
import 'package:sun_sports/router/auth_navigation.dart' show authOpenIntentional;
import 'package:sun_sports/providers/auth_provider.dart';

import 'package:sun_sports/core/services/providers/reconnect_coordinator.dart';
import 'package:sun_sports/providers/user_provider/user_provider.dart';
import 'package:sun_sports/core/services/storage/quick_guide_settings.dart';
import 'package:sun_sports/core/services/storage/search_onboarding_storage.dart';
import 'package:sun_sports/core/services/storage/sound_settings.dart';
import 'package:sun_sports/core/services/websocket/websocket_manager.dart';
import 'package:sun_sports/core/utils/app_logger.dart';
import 'package:sun_sports/core/utils/extensions/cached_manager.dart';
import 'package:sun_sports/core/utils/landing_auth/landing_auth_params.dart';
import 'package:sun_sports/core/utils/network_manager_listener.dart';
import 'package:sun_sports/core/utils/network_manger.dart';
import 'package:sun_sports/core/utils/platform_utils.dart';
import 'package:sun_sports/core/utils/sound_effects.dart';
import 'package:sun_sports/core/utils/styles/app_assets_data.dart';
import 'package:sun_sports/core/utils/web_shader_warmup.dart';
import 'package:sun_sports/features/auth/presentation/providers/auth_providers.dart';
import 'package:sun_sports/features/game/game.dart';

import 'package:sun_sports/features/auth/domain/state/auth_state.dart';
import 'package:sun_sports/features/download_app/presentation/providers/download_app_config_provider.dart';
import 'package:sun_sports/features/mini_game/auth/mini_game_auth_providers.dart';
import 'package:sun_sports/features/mini_game/presentation/mini_game_floating_overlay.dart';
import 'package:sun_sports/features/mini_game/socket/mini_game_socket_providers.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/providers/parlay_state_provider.dart';

import 'package:sun_sports/features/profile/deposit/data/storage/deposit_storage.dart';
import 'package:sun_sports/features/search/data/storage/casino_recent_games_storage.dart';
import 'package:sun_sports/features/search/data/storage/search_recent_storage.dart';
import 'package:sun_sports/router/router_location.dart';
import 'package:sun_sports/shared/layouts/shell_rive_loading.dart';
import 'package:sun_sports/shared/scroll/app_scroll_behavior.dart';
import 'package:sun_sports/shared/widgets/livestream/livestream_lifecycle.dart';
import 'package:sun_sports/shared/widgets/no_connection_screen.dart';
import 'package:sun_sports/shared/widgets/orientation/app_orientation_orchestrator.dart';
import 'package:sun_sports/shared/widgets/bundle_reload/bundle_reload_overlay.dart';
import 'package:sun_sports/shared/widgets/splash/splash_screen.dart';

import 'package:sun_sports/router/app_router.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
  StreamSubscription<socket.ConnectionStateEvent>? _connectionSubscription;
  StreamSubscription<socket.ProcessorMetrics>? _metricsSubscription;
  StreamSubscription<String>? _forceLogoutSubscription;

  StreamSubscription<void>? _sessionReadySubscription;

  StreamSubscription<SportSocketUpdate>? _balanceRefreshSubscription;
  Timer? _settleBalanceRefreshTimer;

  StreamSubscription<NetworkManagerEvent>? _networkRestoredSubscription;

  int _lastDroppedTotal = 0;
  int _lastParseErrorsTotal = 0;
  DateTime? _lastSocketHealthWarnAt;

  bool _isInitialized = false;

  bool _initInFlight = false;

  DateTime? _backgroundedAt;

  DateTime? _miniGameBackgroundedAt;

  bool _miniGameRecoverInFlight = false;

  DateTime? _sportSocketBackgroundedAt;

  DateTime? _balanceBackgroundedAt;

  Timer? _resumeDataHealTimer;
  Timer? _resumeDataHealRetryTimer;

  Timer? _freezeWatchdogTimer;
  DateTime? _freezeWatchdogLastTick;
  static const _freezeWatchdogPeriod = Duration(seconds: 30);

  static const _freezeWatchdogGapThreshold = Duration(seconds: 90);

  Timer? _logoutStuckTimer;

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  GoRouter? _router;

  GoRouter get _goRouter => _router ??= AppRouter.createInstance(
    _navigatorKey,
    isLoggedIn: () => ref.read(isAuthenticatedProvider),
  );

  @override
  void initState() {
    super.initState();
    FrameMonitor.start();
    PerfProbe.maybeRun(_navigatorKey);
    WidgetsBinding.instance.addObserver(this);
    NetworkManager.instance.startListening();
    _listenNetworkRestoredForBalance();
    _freezeWatchdogLastTick = DateTime.now();
    _freezeWatchdogTimer = Timer.periodic(
      _freezeWatchdogPeriod,
      (_) => _onFreezeWatchdogTick(),
    );
    AppInitRetry.register(() => _initApp(showLoading: false));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        _isInitialized = true;
        _initApp();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AppInitRetry.unregister();
    if (kDebugMode) {
      debugPrint('🧹 [App] Disposing subscriptions...');
    }

    _connectionSubscription?.cancel();
    _networkRestoredSubscription?.cancel();
    _networkRestoredSubscription = null;
    _metricsSubscription?.cancel();
    _forceLogoutSubscription?.cancel();
    _sessionReadySubscription?.cancel();
    _balanceRefreshSubscription?.cancel();
    _settleBalanceRefreshTimer?.cancel();
    _freezeWatchdogTimer?.cancel();
    _freezeWatchdogTimer = null;
    _logoutStuckTimer?.cancel();
    _logoutStuckTimer = null;
    _resumeDataHealTimer?.cancel();
    _resumeDataHealTimer = null;
    _resumeDataHealRetryTimer?.cancel();
    _resumeDataHealRetryTimer = null;

    _connectionSubscription = null;
    _metricsSubscription = null;
    _forceLogoutSubscription = null;
    _sessionReadySubscription = null;
    _balanceRefreshSubscription = null;
    _settleBalanceRefreshTimer = null;

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _handleAudioLifecycle(state);
    _handleChatReconnectOnLifecycle(state);
    _handleMiniGameReconnectOnLifecycle(state);
    _handleSportSocketReconnectOnLifecycle(state);
    _handleBalanceRefreshOnLifecycle(state);
    _propagateLivestreamTabVisibility(state);
  }

  void _handleBalanceRefreshOnLifecycle(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.inactive) {
      _balanceBackgroundedAt ??= DateTime.now();
      return;
    }
    if (state != AppLifecycleState.resumed) return;

    final awayFor = _balanceBackgroundedAt == null
        ? Duration.zero
        : DateTime.now().difference(_balanceBackgroundedAt!);
    _balanceBackgroundedAt = null;
    if (awayFor < const Duration(seconds: 2)) return;

    if (!ref.read(userProvider).isLoggedIn) return;

    if (kDebugMode) {
      debugPrint(
        '[Balance] resumed after ${awayFor.inSeconds}s — refreshing user balance',
      );
    }

    // ignore: unawaited_futures
    ref.read(userProvider.notifier).refreshBalanceThrottled();
  }

  void _handleAudioLifecycle(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        SoundEffects.instance.release();
      case AppLifecycleState.inactive:
      case AppLifecycleState.resumed:
        break;
    }
  }

  void _onFreezeWatchdogTick() {
    final now = DateTime.now();
    final last = _freezeWatchdogLastTick;
    _freezeWatchdogLastTick = now;
    if (last == null) return;

    final gap = now.difference(last);
    if (gap < _freezeWatchdogGapThreshold) return;

    final ls = WidgetsBinding.instance.lifecycleState;
    if (ls != null && ls != AppLifecycleState.resumed) return;

    if (kDebugMode) {
      debugPrint(
        '[reconnectWS] [App] freeze watchdog: gap ${gap.inSeconds}s mà không có '
        'lifecycle event → chạy recovery như resumed',
      );
    }

    final syntheticBackgroundedAt = now.subtract(gap);
    _backgroundedAt ??= syntheticBackgroundedAt;
    _miniGameBackgroundedAt ??= syntheticBackgroundedAt;
    _sportSocketBackgroundedAt ??= syntheticBackgroundedAt;
    _balanceBackgroundedAt ??= syntheticBackgroundedAt;
    _handleChatReconnectOnLifecycle(AppLifecycleState.resumed);
    _handleMiniGameReconnectOnLifecycle(AppLifecycleState.resumed);
    _handleSportSocketReconnectOnLifecycle(AppLifecycleState.resumed);
    _handleBalanceRefreshOnLifecycle(AppLifecycleState.resumed);
  }

  void _handleSportSocketReconnectOnLifecycle(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _sportSocketBackgroundedAt = DateTime.now();
      _resumeDataHealTimer?.cancel();
      _resumeDataHealRetryTimer?.cancel();
      return;
    }
    if (state != AppLifecycleState.resumed) return;

    final awayFor = _sportSocketBackgroundedAt == null
        ? Duration.zero
        : DateTime.now().difference(_sportSocketBackgroundedAt!);
    _sportSocketBackgroundedAt = null;

    if (awayFor < const Duration(seconds: 2)) return;

    final adapter = ref.read(sportSocketAdapterProvider);
    if (!adapter.isInitialized) return;

    if (kDebugMode) {
      debugPrint(
        '[reconnectWS] [App] resumed after ${awayFor.inSeconds}s — sport '
        'socket ensureConnectionAlive() (state=${adapter.connectionState})',
      );
    }
    unawaited(
      adapter.ensureConnectionAlive().catchError((Object e, StackTrace st) {
        AppLoggers.websocket.e(
          '[reconnectWS] sport socket ensureConnectionAlive failed',
          error: e,
          stackTrace: st,
        );
      }),
    );

    if (awayFor >= const Duration(seconds: 30)) {
      if (kDebugMode) {
        debugPrint(
          '[reconnectWS] [App] away ${awayFor.inSeconds}s ≥ 30s — schedule '
          'reconnect-refresh (REST repopulate) at +1.5s and +8s',
        );
      }
      _resumeDataHealTimer?.cancel();
      _resumeDataHealRetryTimer?.cancel();
      _resumeDataHealTimer = Timer(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        ref.read(reconnectCoordinatorProvider).forceReconnectRefresh();
      });
      _resumeDataHealRetryTimer = Timer(const Duration(seconds: 8), () {
        if (!mounted) return;
        ref.read(reconnectCoordinatorProvider).forceReconnectRefresh();
      });
    }
  }

  void _propagateLivestreamTabVisibility(AppLifecycleState state) {
    final oldValue = livestreamTabHiddenNotifier.value;
    final hasListeners = livestreamTabHiddenNotifier.hasListeners;
    bool? newValue;
    switch (state) {
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        newValue = true;
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.resumed:
        newValue = false;
        break;
      case AppLifecycleState.detached:
        break;
    }
    debugPrint(
      '[Lifecycle] state=$state '
      'oldValue=$oldValue → newValue=$newValue '
      'hasListeners=$hasListeners '
      'identityHash=${identityHashCode(livestreamTabHiddenNotifier)}',
    );
    if (newValue != null) {
      livestreamTabHiddenNotifier.value = newValue;
    }
  }

  void _handleChatReconnectOnLifecycle(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _backgroundedAt = DateTime.now();

      return;
    }
    if (state != AppLifecycleState.resumed) return;

    final awayFor = _backgroundedAt == null
        ? Duration.zero
        : DateTime.now().difference(_backgroundedAt!);
    _backgroundedAt = null;

    if (awayFor < const Duration(seconds: 2)) return;

    if (!ref.read(isAuthenticatedProvider)) return;

    final chat = WebSocketManager.instance.chat;
    final healthy = chat.isConnected && chat.isLoggedIn;

    final longIdle = awayFor >= const Duration(minutes: 5);

    if (longIdle || !healthy) {
      if (kDebugMode) {
        debugPrint(
          '[reconnectWS] [App] resumed after ${awayFor.inSeconds}s — chat '
          'connected=${chat.isConnected} loggedIn=${chat.isLoggedIn} '
          '(longIdle=$longIdle) → chat.recover()',
        );
      }
      chat.recover('app resumed after ${awayFor.inSeconds}s');
    } else {
      if (awayFor >= const Duration(seconds: 5)) {
        chat.probeWithHistory();
      }
      if (awayFor >= const Duration(seconds: 60)) {
        if (kDebugMode) {
          debugPrint(
            '[reconnectWS] [App] resumed after ${awayFor.inSeconds}s — chat '
            'healthy → proactive sb token refresh',
          );
        }
        unawaited(
          TokenErrorHandler.instance.handleTokenError(closeGameOnFail: false),
        );
      } else if (kDebugMode) {
        debugPrint(
          '[reconnectWS] [App] resumed after ${awayFor.inSeconds}s — chat '
          'healthy, no refresh needed',
        );
      }
    }
  }

  void _handleMiniGameReconnectOnLifecycle(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _miniGameBackgroundedAt = DateTime.now();
      return;
    }
    if (state != AppLifecycleState.resumed) return;

    final awayFor = _miniGameBackgroundedAt == null
        ? Duration.zero
        : DateTime.now().difference(_miniGameBackgroundedAt!);
    _miniGameBackgroundedAt = null;

    if (awayFor < const Duration(seconds: 2)) return;

    if (!ref.read(isAuthenticatedProvider)) return;
    if (!ref.read(isAppReadyProvider)) return;

    unawaited(_recoverMiniGameSocket(awayFor));
  }

  Future<void> _recoverMiniGameSocket(Duration awayFor) async {
    if (_miniGameRecoverInFlight) return;
    _miniGameRecoverInFlight = true;
    try {
      final client = await ref.read(miniGameSocketClientProvider.future);

      if (awayFor >= const Duration(seconds: 60)) {
        await TokenErrorHandler.instance.handleTokenError(
          closeGameOnFail: false,
        );
      }

      final freshAuth = await ref.read(miniGameAuthServiceProvider).read();

      if (kDebugMode) {
        debugPrint(
          '[reconnectWS] [App] resumed after ${awayFor.inSeconds}s — '
          'mini game socket recover()',
        );
      }
      await client.recover(freshAuth);
    } catch (e, st) {
      AppLoggers.websocket.e(
        '[reconnectWS] mini game recover failed',
        error: e,
        stackTrace: st,
      );
    } finally {
      _miniGameRecoverInFlight = false;
    }
  }

  @override
  Future<bool> didPopRoute() async {
    if (!PlatformUtils.isAndroid) return false;

    final showSplash = ref.read(splashProvider);
    if (showSplash) return false;

    final isAuthenticated = ref.read(isAuthenticatedProvider);
    if (!isAuthenticated) return false;

    final ctx = _navigatorKey.currentContext;
    if (ctx == null || !ctx.mounted) return false;
    await _handleShellBack(ctx);
    return true;
  }

  Future<void> _handleShellBack(BuildContext context) async {
    final current = ref.read(mainContentProvider);
    final notifier = ref.read(mainContentProvider.notifier);

    switch (current) {
      case MainContentType.betDetail:
        notifier.goBackFromBetDetail();
        break;
      case MainContentType.tournaments:
      case MainContentType.leagueDetail:
        final prev = ref.read(previousContentProvider);
        notifier.switchTo(prev ?? MainContentType.home);
        ref.read(previousContentProvider.notifier).state = null;
        break;
      case MainContentType.sportDetail:
        notifier.goToSport();
        break;
      case MainContentType.home:
      case MainContentType.sport:
      case MainContentType.casino:
      case MainContentType.live:
      case MainContentType.upcoming:
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final showSplash = ref.watch(splashProvider);
    final platformUiController = ref.watch(platformUiControllerProvider);

    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final appInitState = ref.watch(appInitProvider);

    ref.listen<bool>(isAuthenticatedProvider, (previous, next) {
      if (previous == true && next == false) {
        ref.read(userProvider.notifier).clear();
        ref.read(parlayStateProvider.notifier).clearAllSingleBets();
        ref.read(parlayStateProvider.notifier).clearAllComboBets();
        ref.read(gameLastJoinProvider.notifier).clear();
        ref.read(liveChatExpandedProvider.notifier).state = false;
        _logoutStuckTimer?.cancel();
        _logoutStuckTimer = Timer(const Duration(seconds: 2), () {
          if (!mounted || ref.read(isAuthenticatedProvider)) return;
          final nav = _navigatorKey.currentState;
          if (nav == null || !nav.canPop()) return;
          final location = currentRouterLocation(_router);
          if ((location?.startsWith('/auth') ?? false) ||
              authOpenIntentional) {
            return;
          }
          AppLoggers.auth.w('[logout] stray route after logout — popping');
          try {
            nav.popUntil((route) => route.isFirst);
          } catch (_) {
          }
        });
      } else if (next == true) {
        ref.invalidate(miniGameAuthProvider);
        ref.invalidate(miniGameSocketClientProvider);

        unawaited(
          ref
              .read(gameLastJoinProvider.notifier)
              .checkLastJoin(force: true)
              .catchError((Object e) {
                if (kDebugMode) {
                  debugPrint('⚠️ Game last-join check failed: $e');
                }
              }),
        );
      }
    });

    final darkTheme = ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF11100F),
    );
    final lightTheme = ThemeData.light().copyWith(
      scaffoldBackgroundColor: const Color(0xFF11100F),
    );

    Widget buildBaseApp(BuildContext context, Widget child) {
      return AppOrientationOrchestrator(
        key: const ValueKey('app_orientation'),
        child: Stack(
          fit: StackFit.expand,
          children: [child, const BundleReloadOverlay()],
        ),
      );
    }

    final Widget appTree = PlatformUiGuard(
      controller: platformUiController,
      initialConfig: showSplash
          ? const PlatformUiConfig.splash(debugLabel: 'App: Splash')
          : const PlatformUiConfig.branded(),
      child: Builder(
        builder: (context) => FullscreenGuard(
          platformUiController: PlatformUiGuard.of(context),
          child: Builder(
            builder: (context) {
              if (showSplash) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  scrollBehavior: const AppScrollBehavior(),
                  theme: lightTheme,
                  darkTheme: darkTheme,
                  home: const SplashScreen(),
                );
              }

              if (!isAuthenticated) {
                if (appInitState.isNoConnection) {
                  return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    scrollBehavior: const AppScrollBehavior(),
                    theme: lightTheme,
                    darkTheme: darkTheme,
                    home: NoConnectionScreen(
                      onRetry: () => _initApp(showLoading: false),
                    ),
                  );
                }
                if (!appInitState.isReady) {
                  return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    scrollBehavior: const AppScrollBehavior(),
                    theme: lightTheme,
                    darkTheme: darkTheme,
                    home: const ShellRiveLoading(),
                  );
                }
                return MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  scrollBehavior: const AppScrollBehavior(),
                  theme: lightTheme,
                  darkTheme: darkTheme,
                  builder: (context, child) => buildBaseApp(
                    context,
                    NetworkManagerListener(
                      navigatorKey: _navigatorKey,
                      onReconnected: null,
                      child: child ?? const SizedBox.shrink(),
                    ),
                  ),
                  routerConfig: _goRouter,
                );
              }

              ref.read(reconnectCoordinatorProvider);
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                scrollBehavior: const AppScrollBehavior(),
                theme: lightTheme,
                darkTheme: darkTheme,
                builder: (context, child) => buildBaseApp(
                  context,
                  MiniGameFloatingOverlay(
                    child: NetworkManagerListener(
                      navigatorKey: _navigatorKey,
                      onReconnected: null,
                      child: child ?? const SizedBox.shrink(),
                    ),
                  ),
                ),
                routerConfig: _goRouter,
              );
            },
          ),
        ),
      ),
    );

    final shell = WebShaderWarmUp(child: GameAssetScope(child: appTree));
    return PerfFlags.trace ? PerfStressChip(child: shell) : shell;

  }

  Future<void> _initApp({
    bool showLoading = true,
    bool isTransientRetry = false,
  }) async {
    if (_initInFlight) return;
    _initInFlight = true;
    StartupTrace.start('init.total');
    var retryTransient = false;
    if (showLoading) ref.read(appInitProvider.notifier).startInitializing();

    try {
      final results = await Future.wait([
        StartupTrace.time('init.configChain', SbLogin.initConfigOnly),
        DepositStorage.init().catchError((_) {}),
        SearchRecentStorage.init().catchError((_) {}),
        SbConfigCache.init().catchError((_) {}),
        CasinoRecentGamesStorage.init().catchError((_) {}),
        SoundSettings.instance.init().catchError((_) {}),
        QuickGuideSettings.instance.init().catchError((_) {}),
        SearchOnboardingStorage.instance.init().catchError((_) {}),
      ]);

      final configReady = results[0] as bool;

      try {
        AssetsCacheManager.getCacheManager();
        if (kDebugMode) {
          debugPrint('✅ AssetsCacheManager initialized successfully');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️  Warning: AssetsCacheManager init failed: $e');
        }
      }

      try {
        AssetsCacheManager.registerAssets(AppAssetsData.all);
        if (kDebugMode) {
          debugPrint(
            '✅ Registered ${AppAssetsData.all.length} assets for versioning',
          );
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️  Warning: Assets registration failed: $e');
        }
      }

      unawaited(
        ref
            .read(downloadAppConfigProvider.notifier)
            .load()
            .catchError((Object _) {}),
      );

      if (!configReady) {
        final hasNetwork = await NetworkManager.instance.checkIsConnected();
        if (!hasNetwork) {
          ref.read(appInitProvider.notifier).setNoConnection();
          return;
        }

        AppLoggers.auth.w(
          'Config init failed but network OK → degrade to GUEST '
          '(auth config sẽ lazy-retry khi login)',
        );
        try {
          await SbLogin.ensureServerSettings();
          await _initSportSocketAdapter();
        } catch (e, st) {
          AppLoggers.auth.e('Guest degrade init failed', error: e, stackTrace: st);
        }
        ref.read(appInitProvider.notifier).setReady();
        return;
      }

      unawaited(
        ref.read(lobbyConfigReadyProvider.future).catchError((Object e) {
          if (kDebugMode) debugPrint('⚠️ Nạp lobby game config lỗi: $e');
          return false;
        }),
      );

      AppSession.bindGold(
        () => (ref.read(userProvider).user?.balance ?? 0).toInt(),
      );

      unawaited(SoundEffects.instance.prepare().catchError((Object _) {}));

      final landingCreds = LandingAuthSession.consume();
      debugPrint(
        '🔑 [App] Landing block: creds=${landingCreds != null ? "có (${landingCreds.username})" : "null"}',
      );
      if (landingCreds != null) {
        if (await SbLogin.hasValidTokens()) {
          debugPrint(
            '🔑 [App] Landing: phát hiện session cũ → logout + clear trước khi login account mới',
          );
          await _logoutBeforeLandingLogin();
        }
        final loggedIn = await _autoLoginFromLanding(landingCreds);
        if (loggedIn) {
          _setupForceLogoutListener();
          _setupSessionReadyListener();
          await _initSportSocketAdapter();
          ref.read(appInitProvider.notifier).setReady();
          unawaited(
            ref.read(lobbyConfigReadyProvider.future).catchError((Object e) {
              if (kDebugMode) debugPrint('⚠️ Game preload failed: $e');
              return false;
            }),
          );
          return;

        }
        debugPrint('⚠️ [App] Landing auto-login failed → fallback to login');
      }

      final hasTokens = await SbLogin.hasValidTokens();
      if (!hasTokens) {

        await StartupTrace.time(
          'init.ensureServerSettings',
          SbLogin.ensureServerSettings,
        );

        await _initSportSocketAdapter();

        ref.read(appInitProvider.notifier).setReady();
        return;
      }

      await StartupTrace.time(
        'init.connect',
        () => SbLogin.connect(isReconnect: true),
      );

      ref.read(authProvider.notifier).syncFromSbLogin();

      _setupForceLogoutListener();
      _setupSessionReadyListener();

      await _initSportSocketAdapter();

      ref.read(appInitProvider.notifier).setReady();

      unawaited(
        ref.read(lobbyConfigReadyProvider.future).catchError((Object e) {
          if (kDebugMode) debugPrint('⚠️ Game preload failed: $e');
          return false;
        }),
      );

    } catch (e, stackTrace) {
      AppLoggers.auth.e('App init failed', error: e, stackTrace: stackTrace);

      final noNetwork = !await NetworkManager.instance.checkIsConnected();
      final isTransientNetwork =
          e is HttpException && e.statusCode == 0;
      final isAuthError =
          e is HttpException && (e.statusCode == 401 || e.statusCode == 403);

      if (!isAuthError && noNetwork) {
        ref.read(appInitProvider.notifier).setNoConnection();
      } else if (!isAuthError && isTransientNetwork) {
        if (!isTransientRetry) {
          retryTransient = true;
        } else {
          AppLoggers.auth.w(
            'Init transient-fail x2 nhưng mạng online → degrade GUEST (giữ token)',
          );
          try {
            await SbLogin.ensureServerSettings();
            await _initSportSocketAdapter();
          } catch (e2, st2) {
            AppLoggers.auth.e(
              'Guest degrade init failed',
              error: e2,
              stackTrace: st2,
            );
          }
          ref.read(authProvider.notifier).syncFromSbLogin();
          _setupForceLogoutListener();
          _setupSessionReadyListener();
          ref.read(appInitProvider.notifier).setReady();
        }
      } else {
        await ref.read(authProvider.notifier).logout();
        ref.read(appInitProvider.notifier).setReady();
      }
    } finally {
      _initInFlight = false;
      StartupTrace.end('init.total');
    }

    if (retryTransient) {
      await Future<void>.delayed(const Duration(seconds: 2));
      return _initApp(showLoading: showLoading, isTransientRetry: true);
    }
  }

  Future<void> _logoutBeforeLandingLogin() async {
    try {
      await ref.read(authNotifierProvider.notifier).logout();
    } catch (e) {
      debugPrint('⚠️ [App] Landing pre-logout error (bỏ qua): $e');
    }
    final ok = await SbLogin.initConfigOnly();
    debugPrint('🔑 [App] Landing re-init config sau logout: $ok');
  }

  Future<bool> _autoLoginFromLanding(LandingCredentials creds) async {
    try {
      debugPrint('🔑 [App] Landing auto-login for "${creds.username}"...');
      final authNotifier = ref.read(authNotifierProvider.notifier);
      await authNotifier.login(
        creds.username,
        creds.password,
        source: 'landing',
      );
      return ref
          .read(authNotifierProvider)
          .maybeWhen(
            authenticated: (_) {
              debugPrint('✅ [App] Landing auto-login authenticated');
              ref.read(authProvider.notifier).syncFromSbLogin();
              return true;
            },
            otpRequired: (_, message, __, ___) {
              debugPrint(
                '🔑 [App] Landing login cần OTP → fallback. ($message)',
              );
              return false;
            },
            error: (message, _) {
              debugPrint('❌ [App] Landing login error từ server: $message');
              return false;
            },
            orElse: () {
              debugPrint(
                '⚠️ [App] Landing login state không xác định → fallback',
              );
              return false;
            },
          );
    } catch (e) {
      debugPrint('❌ [App] Landing auto-login exception: $e');
      return false;
    }
  }

  Future<void> _initSportSocketAdapter() async {
    if (MaintenanceService.instance.isUnderMaintenance) {
      AppLoggers.auth.w('SB đang bảo trì → bỏ qua init SportSocketAdapter');
      return;
    }

    if (kDebugMode) {
      debugPrint('🚀 [App] Initializing SportSocketAdapter...');
    }

    try {
      final adapter = ref.read(sportSocketAdapterProvider);
      final repository = ref.read(sportRepositoryProvider);
      final v2DataSource = ref.read(eventsV2RemoteDataSourceProvider);
      final storage = ref.read(sportStorageProvider);

      final int sportId = await storage.getSportId();

      final view = WidgetsBinding.instance.platformDispatcher.views.first;
      final logicalWidth = view.physicalSize.width / view.devicePixelRatio;
      final bool isDesktopLayout = logicalWidth >= Breakpoints.desktop;

      await StartupTrace.time(
        'init.sportSocket',
        () => adapter.initialize(
          repository: repository,
          v2DataSource: v2DataSource,
          sportId: sportId,
          fetchInitialData: isDesktopLayout,
        ),
      );

      _setupAdapterListeners(adapter);

      if (kDebugMode) {
        debugPrint(
          '✅ [App] SportSocketAdapter initialized - sportId: $sportId',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [App] SportSocketAdapter init failed: $e');
      }
    }
  }

  void _setupForceLogoutListener() {
    _forceLogoutSubscription?.cancel();

    _forceLogoutSubscription = SbLogin.forceLogoutStream.listen(
      (reason) {
        if (!mounted) return;

        if (kDebugMode) {
          debugPrint('🚫 [App] Force logout: $reason');
        }

        try {
          _navigatorKey.currentState?.popUntil((route) => route.isFirst);
        } catch (e) {
          AppLoggers.auth.w('[force-logout] pre-logout pop threw: $e');
        }

        ref.read(authProvider.notifier).logout();
      },
      onError: (Object e) {
        if (kDebugMode) {
          debugPrint('❌ [App] forceLogoutStream error: $e');
        }
      },
      cancelOnError: false,
    );

    if (kDebugMode) {
      debugPrint('🎧 [App] Force logout listener setup complete');
    }
  }

  void _setupSessionReadyListener() {
    _sessionReadySubscription?.cancel();
    _sessionReadySubscription = SbLogin.sessionReadyStream.listen(
      (_) {
        if (!mounted) return;
        if (!ref.read(authProvider).isAuthenticated) {
          AppLoggers.auth.w(
            '[session-ready] ignored — arrived while unauthenticated '
            '(late background retry after logout?)',
          );
          return;
        }
        if (kDebugMode) {
          debugPrint('✅ [App] Session ready (sb token nền OK) → sync auth');
        }
        ref.read(authProvider.notifier).syncFromSbLogin();
      },
      onError: (Object e) {
        if (kDebugMode) {
          debugPrint('❌ [App] sessionReadyStream error: $e');
        }
      },
      cancelOnError: false,
    );
  }

  void _setupAdapterListeners(SportSocketAdapter adapter) {

    _connectionSubscription?.cancel();
    _metricsSubscription?.cancel();
    _balanceRefreshSubscription?.cancel();

    _connectionSubscription = adapter.onConnectionChanged.listen(
      (event) {
        if (!mounted) return;

        if (kDebugMode) {
          debugPrint(
            '🔌 [App] Connection: ${event.previousState} → ${event.currentState}',
          );
        }
      },
      onError: (Object e) {
        if (kDebugMode) {
          debugPrint('❌ [App] onConnectionChanged error: $e');
        }
      },
      cancelOnError: false,
    );

    _metricsSubscription = adapter.onMetrics.listen((metrics) {
      if (!mounted) return;

      const pendingWarnThreshold = 5000;
      final dropped = metrics.droppedTotal + metrics.pendingQueueDropped;
      final droppedDelta = dropped - _lastDroppedTotal;
      final parseErrDelta = metrics.parseErrorsTotal - _lastParseErrorsTotal;
      _lastDroppedTotal = dropped;
      _lastParseErrorsTotal = metrics.parseErrorsTotal;

      final unhealthy =
          metrics.pendingQueueSize > pendingWarnThreshold ||
          droppedDelta > 0 ||
          parseErrDelta > 0;
      if (unhealthy) {
        final now = DateTime.now();
        final throttled =
            _lastSocketHealthWarnAt != null &&
            now.difference(_lastSocketHealthWarnAt!) <
                const Duration(seconds: 60);
        if (!throttled) {
          _lastSocketHealthWarnAt = now;
          AppLoggers.websocket.w(
            '⚠️ Socket health: pending=${metrics.pendingQueueSize}'
            '/$pendingWarnThreshold, dropped(+$droppedDelta), '
            'parseErr(+$parseErrDelta), '
            'processed=${metrics.processedPerSecond}/s',
          );
        }
      }

      if (kDebugMode && metrics.processedTotal % 500 == 0) {
        debugPrint(
          '📊 [Metrics] Processed: ${metrics.processedPerSecond}/s, '
          'Pending: ${metrics.pendingQueueSize}',
        );
      }
    });

    _balanceRefreshSubscription = adapter.onUpdate.listen(
      (update) {
        if (!mounted) return;
        if (update.removedEventIds.isEmpty && update.addedEventIds.isEmpty) {
          return;
        }
        _scheduleSettleBalanceRefresh();
      },
      onError: (Object e) {
        if (kDebugMode) {
          debugPrint('❌ [App] balance refresh onUpdate error: $e');
        }
      },
      cancelOnError: false,
    );

    if (kDebugMode) {
      debugPrint('🎧 [App] Adapter listeners setup complete');
    }
  }

  void _listenNetworkRestoredForBalance() {
    _networkRestoredSubscription = NetworkManager.instance.stream.listen((
      event,
    ) {
      if (!mounted) return;
      if (event != NetworkManagerEvent.connectionRestored) return;
      // ignore: unawaited_futures
      ref.read(userProvider.notifier).refreshBalanceThrottled();
    });
  }

  void _scheduleSettleBalanceRefresh() {
    if (_settleBalanceRefreshTimer != null) return;
    if (!ref.read(userProvider).isLoggedIn) return;

    ref.read(userProvider.notifier).refreshBalance();
    _settleBalanceRefreshTimer = Timer(const Duration(seconds: 30), () {
      _settleBalanceRefreshTimer = null;
      if (!mounted) return;
      if (!ref.read(userProvider).isLoggedIn) return;
      ref.read(userProvider.notifier).refreshBalance();
    });
  }
}
