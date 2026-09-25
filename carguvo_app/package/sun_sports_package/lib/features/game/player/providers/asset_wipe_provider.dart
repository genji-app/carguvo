import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/utils/app_logger.dart';
import 'package:sun_sports/core/utils/bundle_defines.dart';
import 'package:sun_sports/core/utils/bundle_manager.dart';
import 'package:provider_game_manager/provider_game_manager.dart';
import 'package:sun_sports/features/game/player/providers/asset_reloader.dart';

enum AssetWipePhase {
  normal,

  suspended,

  reloading,
}

final assetWipePhaseProvider = StateProvider<AssetWipePhase>(
  (ref) => AssetWipePhase.normal,
);

final assetWipeProgressProvider = StateProvider<double>((ref) => 0.0);

final assetWipeFailedProvider = StateProvider<bool>((ref) => false);

final assetWipeControllerProvider = Provider<AssetWipeController>(
  (ref) => AssetWipeController(ref),
);

class AssetWipeController implements AssetReloader {
  AssetWipeController(this._ref);

  final Ref _ref;

  static const List<String> _wipedBundles = [
    BundleDefines.main,
    BundleDefines.dynamic,
  ];

  static const Duration _reloadTimeout = Duration(seconds: 45);

  bool _reloading = false;

  AssetWipePhase get phase => _ref.read(assetWipePhaseProvider);

  set _phase(AssetWipePhase value) =>
      _ref.read(assetWipePhaseProvider.notifier).state = value;

  static bool enabled = true;

  bool shouldWipeFor(LobbyGame game) => enabled;

  Future<void> suspendForGame() async {
    if (phase != AssetWipePhase.normal) return;
    _phase = AssetWipePhase.suspended;

    final cache = PaintingBinding.instance.imageCache;
    final beforeCacheBytes = cache.currentSizeBytes;
    final beforeCacheCount = cache.currentSize;
    final beforeLiveCount = cache.liveImageCount;
    final beforeAtlasBytes = _wipedBundles.fold<int>(
      0,
      (sum, key) => sum + BundleManager.instance.atlasBytesOf(key),
    );

    BundleManager.setSuspendedBundles(_wipedBundles.toSet());

    await WidgetsBinding.instance.endOfFrame;
    await WidgetsBinding.instance.endOfFrame;

    if (phase != AssetWipePhase.suspended) return;

    for (final key in _wipedBundles) {
      await BundleManager.instance.releaseBundle(key, releaseRive: false);
    }

    cache
      ..clear()
      ..clearLiveImages();

    _trace(
      '[AssetWipe] suspended: atlas ${_mb(beforeAtlasBytes)} → '
      '${_mb(_wipedBundles.fold<int>(0, (s, k) => s + BundleManager.instance.atlasBytesOf(k)))}, '
      'imageCache ${_mb(beforeCacheBytes)} → ${_mb(cache.currentSizeBytes)} '
      '(entries $beforeCacheCount→${cache.currentSize}, '
      'live $beforeLiveCount→${cache.liveImageCount})',
    );
  }

  static String _mb(int bytes) =>
      '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';

  static bool traceInRelease = false;

  static String? lastTrace;

  static void _trace(String message, {bool isError = false}) {
    if (isError) {
      AppLoggers.ui.e(message);
    } else {
      AppLoggers.ui.w(message);
    }
    lastTrace = message;
    if (!kDebugMode && traceInRelease) {
      // ignore: avoid_print
      print(message);
    }
  }

  void beginReloadGate() {
    if (phase != AssetWipePhase.suspended) return;
    _ref.read(assetWipeFailedProvider.notifier).state = false;
    _ref.read(assetWipeProgressProvider.notifier).state = 0.0;
    _phase = AssetWipePhase.reloading;
  }

  void onGamePlayerDisposed() {
    if (phase == AssetWipePhase.normal) return;
    if (phase == AssetWipePhase.suspended) beginReloadGate();
    unawaited(_reload());
  }

  @override
  Future<bool> reload({void Function(double progress)? onProgress}) {
    if (phase == AssetWipePhase.normal) {
      onProgress?.call(1.0);
      return Future<bool>.value(true);
    }
    return _reload(force: false, onProgress: onProgress);
  }

  @override
  Future<bool> retry({void Function(double progress)? onProgress}) {
    if (phase == AssetWipePhase.normal) {
      onProgress?.call(1.0);
      return Future<bool>.value(true);
    }
    return _reload(force: true, onProgress: onProgress);
  }

  Future<bool> _reload({
    bool force = false,
    void Function(double progress)? onProgress,
  }) async {
    if (_reloading) return false;
    _reloading = true;
    _ref.read(assetWipeFailedProvider.notifier).state = false;
    try {
      for (var i = 0; i < _wipedBundles.length; i++) {
        final key = _wipedBundles[i];
        bool? finished;
        void setProgress(double p) {
          final overall = (i + p.clamp(0.0, 1.0)) / _wipedBundles.length;
          _ref.read(assetWipeProgressProvider.notifier).state = overall;
          onProgress?.call(overall);
        }

        final manager = BundleManager.instance;
        final load = force
            ? manager.retryBundle(
                key,
                onProgress: setProgress,
                onBundleFinish: (_, ok) => finished = ok,
              )
            : manager.loadBundle(
                key,
                onProgress: setProgress,
                onBundleFinish: (_, ok) => finished = ok,
              );
        var timedOut = false;
        try {
          await load.timeout(_reloadTimeout);
        } on TimeoutException {
          timedOut = true;
        }

        final ok = !timedOut && (finished ?? manager.isBundleLoaded(key));
        if (!ok) {
          _trace('[AssetWipe] reload FAILED bundle=$key', isError: true);
          _ref.read(assetWipeFailedProvider.notifier).state = true;
          return false;
        }
      }

      _ref.read(assetWipeProgressProvider.notifier).state = 1.0;
      onProgress?.call(1.0);

      BundleManager.setSuspendedBundles(const <String>{});
      _phase = AssetWipePhase.normal;
      _trace(
        '[AssetWipe] resumed: $_wipedBundles reloaded, atlas '
        '${_mb(_wipedBundles.fold<int>(0, (s, k) => s + BundleManager.instance.atlasBytesOf(k)))}',
      );
      return true;
    } finally {
      _reloading = false;
    }
  }
}
