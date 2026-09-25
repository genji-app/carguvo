import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/constants/app_version.dart';
import 'package:sun_sports/core/perf/perf.dart';
import 'package:sun_sports/core/services/storage/intro_storage.dart';
import 'package:sun_sports/core/services/auth/sb_login.dart';
import 'package:sun_sports/core/services/bundle_config_service.dart';
import 'package:sun_sports/core/services/config/sb_config.dart';
import 'package:sun_sports/core/services/provider_game/lobby_game_config_loader.dart';
import 'package:sun_sports/providers/app_init_provider.dart';
import 'package:sun_sports/core/utils/bundle_defines.dart';
import 'package:sun_sports/core/utils/bundle_manager.dart';
import 'package:sun_sports/core/utils/network_manger.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_videos.dart';
import 'package:sun_sports/core/utils/video_cache_manager.dart';
import 'package:sun_sports/shared/widgets/splash/splash_web_video_rotator.dart';
import 'package:video_player/video_player.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/no_connection_screen.dart';
import 'package:sun_sports/shared/widgets/splash/splash_network_banner.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

enum _VideoState { loading, playing, finished, failed }

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _logoSrcReady = false;

  double _preloadProgress = 0.0;
  bool _preloadDone = false;
  bool _progressReachedFull = false;

  double _realProgress = 0.0;

  double _creepAnchor = 0.0;
  final Stopwatch _creepStopwatch = Stopwatch();
  Timer? _creepTimer;

  VideoPlayerController? _videoController;
  _VideoState _videoState = _VideoState.loading;
  bool _orientationLocked = false;

  bool _noConnection = false;
  StreamSubscription<NetworkManagerEvent>? _networkSub;

  bool _showReconnectedBanner = false;
  Timer? _reconnectedBannerTimer;

  bool _restarting = false;

  bool _pendingRestart = false;

  static const Duration _reconnectedBannerDuration = Duration(seconds: 3);

  int _logoReloadToken = 0;

  int _preloadRunId = 0;

  static const Duration _tipInterval = Duration(seconds: 3);

  static const Duration _bundleAttemptTimeout = Duration(seconds: 180);

  static const int _maxBundleAttemptsPerRound = 5;

  static const Duration _roundRetryDelay = Duration(seconds: 5);

  static const Duration _brandConfigTimeout = Duration(seconds: 15);

  static const Duration _lobbyConfigBudget = Duration(seconds: 5);

  Timer? _roundRetryTimer;

  static Duration _bundleBackoff(int attempt) {
    final ms = 2000 * (1 << (attempt - 1).clamp(0, 3));
    return Duration(milliseconds: math.min(ms, 15000));
  }

  static const double _creepCeiling = 0.999;

  static const double _creepTau = 10.0;

  static const Duration _creepTick = Duration(milliseconds: 120);

  late final List<({String text, List<String> highlights})> _shuffledTips;

  int _tipIndex = 0;
  Timer? _tipTimer;

  @override
  void initState() {
    super.initState();
    _shuffledTips = List.of(_tips)..shuffle();
    _tipTimer = Timer.periodic(_tipInterval, (_) {
      if (!mounted) return;
      setState(() => _tipIndex = (_tipIndex + 1) % _shuffledTips.length);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      debugPrint('[Splash] initState postFrame: starting preload + force video=finished (intro disabled)');
      _lockPortraitIfPhone();
      setState(() => _videoState = _VideoState.finished);

      await NetworkManager.instance.startListening();
      if (!mounted) return;
      _networkSub = NetworkManager.instance.stream.listen(_onNetworkEvent);
      final connectedAtStart = await NetworkManager.instance.checkIsConnected();
      if (!mounted) return;
      if (!connectedAtStart) {
        debugPrint('[Splash] offline at start → banner "Không kết nối mạng"');
        _enterNoConnection();
        return;
      }
      if (!mounted) return;
      unawaited(_startPreload());
      unawaited(_fetchLogoConfig());
      _maybeNavigate();
    });
  }

  @override
  void dispose() {
    _brandConfigSub?.cancel();
    _networkSub?.cancel();
    _networkSub = null;
    _tipTimer?.cancel();
    _reconnectedBannerTimer?.cancel();
    _roundRetryTimer?.cancel();
    _creepTimer?.cancel();
    _creepStopwatch.stop();
    _videoController?.removeListener(_onVideoTick);
    _videoController?.dispose();
    _videoController = null;
    resetWebVideoElement();
    if (_orientationLocked) {
      _orientationLocked = false;
      SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    super.dispose();
  }

  void _onNetworkEvent(NetworkManagerEvent event) {
    if (!mounted || _preloadDone) return;
    switch (event) {
      case NetworkManagerEvent.connectionLost:
        debugPrint('[Splash] connectionLost while preloading → stop + banner');
        _enterNoConnection();
        break;
      case NetworkManagerEvent.connectionRestored:
        debugPrint('[Splash] connectionRestored → banner "Đã kết nối" + restart');
        _onConnectionRestored();
        break;
    }
  }

  void _enterNoConnection() {
    if (!mounted || _preloadDone) return;
    _preloadRunId++;
    _creepTimer?.cancel();
    _creepStopwatch.stop();
    _reconnectedBannerTimer?.cancel();
    if (!_noConnection || _showReconnectedBanner) {
      setState(() {
        _noConnection = true;
        _showReconnectedBanner = false;
      });
    }
    _scheduleRoundRetry();
  }

  void _onPreloadRoundFailed() {
    if (!mounted || _preloadDone) return;
    debugPrint(
      '[Splash] preload round FAILED (vẫn "có mạng" theo interface) → '
          'banner + hẹn thử lại sau $_roundRetryDelay',
    );
    _creepTimer?.cancel();
    _creepStopwatch.stop();
    _reconnectedBannerTimer?.cancel();
    if (!_noConnection || _showReconnectedBanner) {
      setState(() {
        _noConnection = true;
        _showReconnectedBanner = false;
      });
    }
    _scheduleRoundRetry();
  }

  void _scheduleRoundRetry() {
    _roundRetryTimer?.cancel();
    _roundRetryTimer = Timer(_roundRetryDelay, () {
      if (!mounted || _preloadDone) return;
      unawaited(_restartAfterReconnect());
    });
  }

  void _flipToReconnectedBanner() {
    _reconnectedBannerTimer?.cancel();
    setState(() {
      _noConnection = false;
      _showReconnectedBanner = true;
    });
    _reconnectedBannerTimer = Timer(_reconnectedBannerDuration, () {
      if (!mounted) return;
      setState(() => _showReconnectedBanner = false);
    });
  }

  void _onConnectionRestored() {
    if (!_noConnection) return;
    _flipToReconnectedBanner();
    unawaited(_restartAfterReconnect());
  }

  void _resetForRestartRound() {
    _realProgress = 0;
    _creepAnchor = 0;
    _progressReachedFull = false;
    setState(() {
      _preloadProgress = 0;
    });
  }

  Future<void> _restartAfterReconnect() async {
    if (_restarting) {
      _pendingRestart = true;
      return;
    }
    _restarting = true;
    _roundRetryTimer?.cancel();
    try {
      do {
        _pendingRestart = false;
        if (_preloadDone) return;
        final connected = await NetworkManager.instance.checkIsConnected();
        if (!mounted) return;
        if (!connected) {
          _enterNoConnection();
          return;
        }
        debugPrint('[Splash] restart preload after reconnect');
        _resetForRestartRound();
        setState(() => _logoReloadToken++);
        unawaited(_fetchLogoConfig());
        await _startPreload();
        if (!mounted) return;
      } while (_pendingRestart);
    } finally {
      _restarting = false;
    }
  }

  Future<void> _startPreload() async {
    final runId = ++_preloadRunId;
    StartupTrace.start('splash.preload');
    _startCreep();

    if (!await _ensureBrandConfig(runId)) {
      if (mounted && runId == _preloadRunId) _onPreloadRoundFailed();
      return;
    }

    final bundleManager = BundleManager.instance;
    const criticalBundles = <String>[
      BundleDefines.main,
      BundleDefines.dynamic,
      BundleDefines.mini,
    ];
    const requiredBundles = criticalBundles;
    debugPrint('[Splash] _startPreload: begin, requiredBundles=$requiredBundles');

    final bundleProgress = <String, double>{
      for (final key in requiredBundles) key: 0.0,
    };

    void onProgress() {
      if (!mounted) return;
      final total = requiredBundles.fold<double>(
        0,
            (sum, key) => sum + (bundleProgress[key] ?? 0.0),
      );
      final real = total / requiredBundles.length;
      if (real <= _realProgress) return;
      _realProgress = real;
      _creepAnchor = math.max(_preloadProgress, _realProgress);
      _creepStopwatch
        ..reset()
        ..start();
      final next = math.max(_realProgress, _preloadProgress);
      if (next > _preloadProgress) {
        setState(() => _preloadProgress = next);
      }
      debugPrint(
        '[Splash] onProgress: real=${_realProgress.toStringAsFixed(3)} '
            'preloadProgress=${_preloadProgress.toStringAsFixed(3)} '
            'creepAnchor=${_creepAnchor.toStringAsFixed(3)}',
      );
    }

    final listeners = <String, void Function()>{};
    for (final key in requiredBundles) {
      void listener() {
        final value = bundleManager.progressFor(key).value.clamp(0.0, 1.0);
        final prev = bundleProgress[key] ?? 0.0;
        if (value <= prev) return;
        bundleProgress[key] = value;
        onProgress();
      }

      listeners[key] = listener;
      bundleManager.progressFor(key).addListener(listener);
    }

    try {
      await StartupTrace.time(
        'splash.globalConfig',
        () => bundleManager
            .loadGlobalConfig()
            .timeout(const Duration(seconds: 15)),
      );
    } catch (_) {
      debugPrint('[Splash] loadGlobalConfig failed, using fallback URLs');
    }

    Future<bool> load(String bundleKey) => StartupTrace.time(
          'splash.bundle.$bundleKey',
          () async {
            final ok = await _loadRequiredBundleWithRetry(bundleManager, bundleKey, runId);
            if (!ok || bundleKey != BundleDefines.dynamic) return ok;
            if (!mounted || runId != _preloadRunId) return ok;
            final configOk = await LobbyGameConfigLoader.load()
                .timeout(_lobbyConfigBudget, onTimeout: () => false);
            debugPrint('[Splash] lobbyGameConfig tu bundle dynamic: ok=$configOk');
            return ok;
          },
        );

    final criticalDone = Future.wait(criticalBundles.map(load));

    late List<bool> results;
    try {
      results = await criticalDone;
    } finally {
      for (final entry in listeners.entries) {
        bundleManager.progressFor(entry.key).removeListener(entry.value);
      }
    }

    if (!mounted || runId != _preloadRunId) return;

    if (results.contains(false)) {
      _onPreloadRoundFailed();
      return;
    }

    debugPrint('[Splash] _startPreload: ALL $criticalBundles completed');
    StartupTrace.end('splash.preload');
    _creepTimer?.cancel();
    _creepStopwatch.stop();
    if (_noConnection) _flipToReconnectedBanner();
    setState(() {
      _realProgress = 1.0;
      _preloadProgress = 1.0;
      _preloadDone = true;
    });
    debugPrint('[Splash] preload DONE → _preloadDone=true, calling _maybeNavigate');
    _maybeNavigate();
  }

  Future<bool> _ensureBrandConfig(int runId) async {
    if (SbConfig.rsDomain.isNotEmpty) return true;

    debugPrint('[Splash] rsDomain RỖNG → nạp lại brand config trước khi preload');
    try {
      await SbLogin.loadBrandConfigOnly().timeout(_brandConfigTimeout);
    } catch (e) {
      debugPrint('[Splash] loadBrandConfigOnly failed: $e');
    }
    if (!mounted || runId != _preloadRunId) return false;

    if (SbConfig.rsDomain.isEmpty) {
      debugPrint(
        '[Splash] rsDomain VẪN rỗng → bỏ vòng luôn, khỏi đốt 5 lượt bundle '
            'chắc chắn fail tức thì',
      );
      return false;
    }

    debugPrint('[Splash] brand config OK, rsDomain=${SbConfig.rsDomain}');
    BundleConfigService.instance.reset();
    unawaited(AppInitRetry.run());
    return true;
  }

  void _startCreep() {
    _creepAnchor = _preloadProgress;
    _creepStopwatch
      ..reset()
      ..start();
    _creepTimer?.cancel();
    _creepTimer = Timer.periodic(_creepTick, (_) => _tickCreep());
  }

  void _tickCreep() {
    if (!mounted) return;
    if (_preloadDone) {
      _creepTimer?.cancel();
      return;
    }
    final t = _creepStopwatch.elapsedMilliseconds / 1000.0;
    final creep =
        _creepAnchor + (_creepCeiling - _creepAnchor) * (1 - math.exp(-t / _creepTau));
    final next = math.min(math.max(_realProgress, creep), _creepCeiling);
    if (next > _preloadProgress) {
      setState(() => _preloadProgress = next);
    }
  }

  Future<bool> _loadRequiredBundleWithRetry(
      BundleManager bundleManager,
      String bundleKey,
      int runId,
      ) async {
    var attempt = 0;

    while (mounted && runId == _preloadRunId) {
      attempt++;
      debugPrint('[Splash] bundle $bundleKey: starting load (attempt=$attempt)');
      final done = Completer<bool>();

      void onFinish(String _, bool success) {
        debugPrint('[Splash] bundle $bundleKey onBundleFinish: success=$success (attempt=$attempt)');
        if (!done.isCompleted) done.complete(success);
      }

      final loadFuture = attempt == 1
          ? bundleManager.loadBundle(
        bundleKey,
        onBundleFinish: onFinish,
      )
          : bundleManager.retryBundle(
        bundleKey,
        onBundleFinish: onFinish,
      );

      unawaited(loadFuture.catchError((Object _, StackTrace __) {}));

      final success = await done.future.timeout(
        _bundleAttemptTimeout,
        onTimeout: () {
          if (runId != _preloadRunId) {
            debugPrint('[Splash] bundle $bundleKey: stale attempt timed out → bỏ qua');
            return false;
          }
          if (_preloadDone) {
            debugPrint(
              '[Splash] bundle $bundleKey: timeout SAU khi splash đã xong → '
                  'nhường quyền cho cổng lobby, không cancel',
            );
            return false;
          }
          debugPrint(
            '[Splash] bundle $bundleKey: attempt $attempt TIMED OUT after '
                '$_bundleAttemptTimeout → cancel + retry',
          );
          bundleManager.cancelBundle(bundleKey);
          return false;
        },
      );

      if (success) {
        debugPrint('[Splash] bundle $bundleKey: SUCCESS (attempt=$attempt)');
        return true;
      }

      if (!mounted || runId != _preloadRunId) return false;

      final connected = await NetworkManager.instance.checkIsConnected();
      if (!mounted || runId != _preloadRunId) return false;
      if (!connected) {
        debugPrint('[Splash] bundle $bundleKey failed + OFFLINE → bỏ vòng');
        return false;
      }

      if (attempt >= _maxBundleAttemptsPerRound) {
        debugPrint(
          '[Splash] bundle $bundleKey: hết $_maxBundleAttemptsPerRound lượt '
              'mà vẫn lỗi → kết thúc vòng',
        );
        return false;
      }

      final backoff = _bundleBackoff(attempt);
      debugPrint('[Splash] bundle $bundleKey failed (attempt=$attempt), retry sau $backoff');
      await Future<void>.delayed(backoff);
    }
    return false;
  }

  // ignore: unused_element  // Tạm tắt intro — giữ lại để dễ bật lại sau.
  Future<void> _startVideo() async {
    _lockLandscapeIfPhone();
    try {
      final controller = await _buildController();
      if (controller == null) {
        debugPrint('[Splash] video controller null → fallback');
        _onVideoFailed();
        return;
      }
      _videoController = controller;

      debugPrint('[Splash] video.initialize() start');
      await controller.initialize();
      debugPrint(
        '[Splash] video.initialize() done. '
            'size=${controller.value.size}, '
            'duration=${controller.value.duration}',
      );
      if (!mounted) {
        controller.dispose();
        _videoController = null;
        return;
      }

      await controller.setVolume(kIsWeb ? 0 : 1);
      await controller.setLooping(false);
      controller.addListener(_onVideoTick);

      setState(() => _videoState = _VideoState.playing);
      await controller.play();
      debugPrint('[Splash] video.play() returned');
      if (kIsWeb) {
        rotateWebVideoElement(onSkip: _skip, onSoundToggle: _onSoundToggle);
      }
    } catch (e, st) {
      debugPrint('[Splash] video failed: $e\n$st');
      _onVideoFailed();
    }
  }

  Future<VideoPlayerController?> _buildController() async {
    final url =
        BundleManager.instance.lookupResource(AppVideos.iconBTI)?.url ??
            AppVideos.iconBTI;
    debugPrint('[Splash] video url=$url kIsWeb=$kIsWeb');
    if (kIsWeb) {
      return VideoPlayerController.networkUrl(Uri.parse(url));
    }
    final bundleFile = await BundleManager.instance.getLocalFile(url);
    if (bundleFile != null && await bundleFile.exists()) {
      return VideoPlayerController.file(bundleFile);
    }
    final file = await VideoCacheManager.instance.getOrDownload(url);
    if (file == null) return null;
    return VideoPlayerController.file(file);
  }

  void _onVideoTick() {
    final c = _videoController;
    if (c == null) return;
    final v = c.value;
    if (v.hasError) {
      debugPrint('[Splash] video error: ${v.errorDescription}');
      c.removeListener(_onVideoTick);
      _onVideoFailed();
      return;
    }
    if (v.duration > Duration.zero &&
        v.position >= v.duration &&
        !v.isPlaying) {
      c.removeListener(_onVideoTick);
      if (mounted) {
        setState(() => _videoState = _VideoState.finished);
        _markIntroShown();
        resetWebVideoElement();
        _maybeNavigate();
      }
    }
  }

  void _onVideoFailed() {
    if (!mounted) return;
    setState(() => _videoState = _VideoState.failed);
    resetWebVideoElement();
    _maybeNavigate();
  }

  StreamSubscription<void>? _brandConfigSub;

  String get _cdnBase {
    final base = SbConfig.rsDomain;
    if (base.isEmpty) return '';
    return base.endsWith('/') ? base : '$base/';
  }

  Future<void> _fetchLogoConfig() async {
    final cdnBase = _cdnBase;
    if (cdnBase.isEmpty) {
      debugPrint('[Splash] _fetchLogoConfig: rsDomain empty, will retry on brandConfigLoaded event');
      _brandConfigSub?.cancel();
      _brandConfigSub = SbConfig.onBrandConfigLoaded.listen((_) {
        _brandConfigSub?.cancel();
        _brandConfigSub = null;
        _fetchLogoConfig();
      });
      return;
    }
    try {
      final configUrl = '${cdnBase}logo/logoconfig.json?t=${DateTime.now().millisecondsSinceEpoch}';
      final response = await http.get(Uri.parse(configUrl));
      if (response.statusCode == 200) {
        final config = jsonDecode(response.body) as Map<String, dynamic>;
        final logoFile = config['logo'] as String?;
        if (logoFile != null && logoFile.isNotEmpty) {
          AppImages.logoUrl = '${cdnBase}logo/$logoFile';
          if (mounted) setState(() => _logoSrcReady = true);
          return;
        }
      }
    } catch (e) {
      debugPrint('[Splash] _fetchLogoConfig failed: $e');
    }
    AppImages.logoUrl = '${cdnBase}logo/${AppImages.logoS88Home}';
    if (mounted) setState(() => _logoSrcReady = true);
  }

  bool get _isPhone => MediaQuery.sizeOf(context).shortestSide < 600;

  void _lockLandscapeIfPhone() {
    if (kIsWeb || !_isPhone) return;
    _orientationLocked = true;
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _lockPortraitIfPhone() {
    if (kIsWeb || !_isPhone) return;
    _orientationLocked = true;
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void _skip() {
    if (_videoState == _VideoState.finished ||
        _videoState == _VideoState.failed) {
      return;
    }
    final c = _videoController;
    c?.removeListener(_onVideoTick);
    c?.pause();
    if (mounted) setState(() => _videoState = _VideoState.finished);
    _markIntroShown();
    resetWebVideoElement();
    _maybeNavigate();
  }

  void _markIntroShown() {
    IntroStorage.instance.markShownToday();
  }

  void _onSoundToggle(bool muted) {
    _videoController?.setVolume(muted ? 0 : 1);
  }

  void _maybeNavigate() {
    debugPrint(
      '[Splash] _maybeNavigate: preloadDone=$_preloadDone, '
          'progressReachedFull=$_progressReachedFull, videoState=$_videoState',
    );
    if (!_preloadDone) {
      debugPrint('[Splash]   -> blocked: preload NOT done');
      return;
    }
    if (!_progressReachedFull) {
      debugPrint('[Splash]   -> blocked: progress bar onEnd not fired yet (waiting for 100%)');
      return;
    }
    if (_videoState != _VideoState.finished &&
        _videoState != _VideoState.failed) {
      debugPrint('[Splash]   -> blocked: video state=$_videoState (not finished/failed)');
      return;
    }
    if (ref.read(appInitProvider).isInitializing) {
      StartupTrace.start('splash.waitInit');
      debugPrint('[Splash]   -> blocked: app init chưa xong (initializing)');
      return;
    }
    debugPrint('[Splash]   -> ALL CONDITIONS MET → complete() (dismiss splash)');
    StartupTrace.end('splash.waitInit');
    StartupTrace.mark('splash.dismiss');
    if (PerfFlags.trace) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => StartupTrace.finish('shell.firstFrame'),
      );
    }
    ref.read(splashProvider.notifier).complete();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AppInitState>(appInitProvider, (previous, next) {
      if (!next.isInitializing) {
        _maybeNavigate();
      }
    });

    final c = _videoController;
    final showVideo =
        _videoState == _VideoState.playing &&
            c != null &&
            c.value.isInitialized;

    final webVideoMode = showVideo && kIsWeb;

    if (_noConnection) {
      return PopScope(
        canPop: false,
        child: NoConnectionScreen(onRetry: _restartAfterReconnect),
      );
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColorStyles.backgroundSecondary,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: _buildSplashContent(),
            ),
            if (showVideo) _buildVideoLayer(c),
            if (showVideo && !webVideoMode) _buildSkipButton(context),
            if (_showReconnectedBanner)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Material(
                  elevation: 4,
                  child: SplashNetworkBanner.online(),
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    'Versions: v${AppVersion.code}',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.labelXXSmall(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkipButton(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isMobileOrTablet = size.shortestSide < 900;

    return Positioned(
      top: isMobileOrTablet ? null : 24,
      bottom: isMobileOrTablet ? 24 : null,
      right: 24,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: SoundTap.wrap(_skip),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Text(
              'Bỏ qua',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoLayer(VideoPlayerController c) {
    if (kIsWeb) {
      return Positioned.fill(
        child: ColoredBox(
          color: Colors.black,
          child: VideoPlayer(c),
        ),
      );
    }
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: c.value.size.width,
            height: c.value.size.height,
            child: VideoPlayer(c),
          ),
        ),
      ),
    );
  }

  Widget _buildSplashContent() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLogo(),
          const SizedBox(height: 56),
          _buildLoading(),
          const SizedBox(height: 56),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: SizedBox(
              height: 48,
              child: Align(
                alignment: Alignment.topCenter,
                child: _buildTipCarousel(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    if (!_logoSrcReady) {
      return const SizedBox(width: 200, height: 200);
    }

    return SizedBox(
      width: 200,
      height: 200,
      child: KeyedSubtree(
        key: ValueKey('splash-logo-$_logoReloadToken-${AppImages.logoUrl}'),
        child: ImageHelper.load(
          path: AppImages.logoUrl,
          width: 200,
          height: 200,
          fit: BoxFit.contain,
          errorWidget: const ColoredBox(
            color: AppColorStyles.backgroundSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildProgress(),
      ],
    );
  }

  Widget _buildTipCarousel() {
    final tip = _shuffledTips[_tipIndex];
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      switchInCurve: Curves.linear,
      switchOutCurve: Curves.linear,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      transitionBuilder: (child, animation) {
        final incoming = child.key == ValueKey<int>(_tipIndex);
        final beginOffset =
            incoming ? const Offset(0, 0.6) : const Offset(0, -0.6);

        final opacity = animation.drive(
          CurveTween(
            curve: incoming
                ? const Interval(0.4, 1, curve: Curves.easeOut)
                : const Interval(0.6, 1, curve: Curves.easeIn),
          ),
        );
        final position = animation.drive(
          Tween<Offset>(begin: beginOffset, end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeOutCubic)),
        );

        return ClipRect(
          child: FadeTransition(
            opacity: opacity,
            child: SlideTransition(
              position: position,
              child: child,
            ),
          ),
        );
      },
      child: _buildHighlightedText(
        tip.text,
        tip.highlights,
        key: ValueKey<int>(_tipIndex),
      ),
    );
  }

  Widget _buildHighlightedText(
      String text,
      List<String> highlights, {
        Key? key,
      }) {
    final base = AppTextStyles.paragraphMedium(
      color: AppColorStyles.contentSecondary,
    );
    final hl = base.copyWith(color: AppColors.yellow500);

    final ranges = <(int, int)>[];
    for (final raw in highlights) {
      final needle = raw.trim();
      if (needle.isEmpty) continue;
      int from = 0;
      int idx;
      while ((idx = text.indexOf(needle, from)) != -1) {
        ranges.add((idx, idx + needle.length));
        from = idx + needle.length;
      }
    }
    ranges.sort((a, b) => a.$1.compareTo(b.$1));

    final spans = <TextSpan>[];
    int cursor = 0;
    for (final (start, end) in ranges) {
      if (start < cursor) continue;
      if (start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, start)));
      }
      spans.add(TextSpan(text: text.substring(start, end), style: hl));
      cursor = end;
    }
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor)));
    }

    return RichText(
      key: key,
      textAlign: TextAlign.center,
      text: TextSpan(style: base, children: spans),
    );
  }

  Widget _buildProgress() {
    const double barWidth = 200;
    const double barHeight = 6;
    final BorderRadius radius = BorderRadius.circular(1000);

    return Container(
      width: barWidth,
      height: barHeight,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundQuaternary,
        borderRadius: radius,
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(
          begin: 0,
          end: _preloadProgress.clamp(0.0, 1.0),
        ),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        onEnd: () {
          if (_preloadProgress >= 1.0 && !_progressReachedFull) {
            _progressReachedFull = true;
            StartupTrace.mark('splash.progressFull');
            debugPrint('[Splash] progress bar reached 100% (Tween onEnd) → _progressReachedFull=true');
            _maybeNavigate();
          }
        },
        builder: (context, value, _) {
          return FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value <= 0 ? 0.0001 : value,
            heightFactor: 1,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF644202), AppColors.yellow600],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static const List<({String text, List<String> highlights})> _tips = [
    (
    text: 'Tải 1.1.1.1 để truy cập sun88.win',
    highlights: ['1.1.1.1'],
    ),
    (
    text: 'Vào Cược của tôi để quản lý cược đơn và cược xiên',
    highlights: ['Cược của tôi'],
    ),
    (
    text: 'Sun88 thương hiệu cá cược thể thao của Sunwin',
    highlights: ['Sun88', 'Sunwin'],
    ),
    (
    text: 'Kèo được chọn sẽ tự động vào giỏ kèo',
    highlights: ['giỏ kèo'],
    ),
    (
    text:
    'Nạp tiền siêu tốc, chọn phương thức yêu thích và tiền vào tài '
        'khoản chỉ trong vài giây',
    highlights: ['Nạp tiền siêu tốc,'],
    ),
    (
    text: 'Tích hợp game casino của sunwin và các nhà cung cấp nổi tiếng',
    highlights: ['game casino'],
    ),
    (
    text: 'Xác minh tài khoản sớm để các lệnh rút tiền được duyệt nhanh hơn',
    highlights: ['Xác minh tài khoản'],
    ),
    (
    text: 'Thêm giải đấu/trận đấu vào mục yêu thích để không bỏ lỡ kèo hay',
    highlights: ['mục yêu thích'],
    ),
    (
    text: 'Cá nhân hóa trải nghiệm với trang sports chỉ dành riêng cho bạn',
    highlights: ['Cá nhân hóa'],
    ),
    (
    text:
    'Tỷ lệ cược được cập nhật liên tục theo thời gian thực, bám sát '
        'diễn biến trận đấu',
    highlights: ['cập nhật liên tục'],
    ),
    (
    text:
    'Đa dạng loại kèo: tài xỉu, chấp, xiên... với mức tỷ lệ hấp dẫn '
        'cho mọi lựa chọn',
    highlights: ['Đa dạng loại kèo:'],
    ),
  ];
}

class SplashNotifier extends StateNotifier<bool> {
  SplashNotifier() : super(true);

  void complete() {
    state = false;
  }

  void reset() {
    state = true;
  }
}

final splashProvider = StateNotifierProvider<SplashNotifier, bool>(
      (ref) => SplashNotifier(),
);
