import 'dart:io';

import 'package:clock/clock.dart';
import 'package:dart_kit/dart_kit.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sun_sports/core/utils/extensions/log_helper.dart';

import 'asset_storage.dart';

class AssetCacheController with LoggerMixin {
  @override
  String get logTag => 'AssetCache';

  static const String _keyLastClear = 'asset_last_cache_clear';

  static const String _imgCacheKey = 'app_resource_images';

  final AssetStorage assetStorage;

  final CacheManager imageCacheManager;

  final Semaphore requestSemaphore;

  final String Function()? cacheVersionProvider;

  AssetCacheController({
    required this.assetStorage,
    required this.imageCacheManager,
    required this.requestSemaphore,
    this.cacheVersionProvider,
  });

  String get cacheVersion => cacheVersionProvider?.call() ?? '1';

  List<CacheManager> get _activeManagers => [
    imageCacheManager,
  ];

  List<String> get _activeCacheKeys => [
    _imgCacheKey,
  ];

  Future<void>? _initFuture;

  Future<void> init() async {
    _initFuture ??= _doInit();
    return _initFuture;
  }

  Future<void> _doInit() async {
    logInfo('Initializing AssetCacheController instance...');
    try {
      await assetStorage.init();
      logInfo('Asset Storage initialized successfully.');
    } catch (e, stack) {
      logError('Failed to initialize Asset Storage', e, stack);
    }

    try {
      final lastClearStr = await assetStorage.read(_keyLastClear);
      final now = clock.now();

      bool shouldClear = false;
      if (lastClearStr == null) {
        logInfo(
          'First-time cache initialization detected. Scheduling clear...',
        );
        shouldClear = true;
      } else {
        final lastClear = DateTime.parse(lastClearStr);
        final difference = now.difference(lastClear).inDays;
        logInfo('Cache last cleared $difference days ago.');
        if (difference >= 3) {
          shouldClear = true;
        }
      }

      if (shouldClear) {
        logInfo('Performing periodic cache invalidation (3-day cycle)...');
        await clearAllCaches();
      }
    } catch (e, stack) {
      logError('Error checking periodic cache invalidation', e, stack);
    }
  }

  Future<double> calculateTotalCacheSizeMB() async {
    if (kIsWeb) return 0.0;
    try {
      final tempDir = await getTemporaryDirectory();
      int totalBytes = 0;

      for (final key in _activeCacheKeys) {
        final cacheDir = Directory('${tempDir.path}/$key');
        if (await cacheDir.exists()) {
          await for (final file in cacheDir.list(
            recursive: true,
            followLinks: false,
          )) {
            if (file is File) {
              totalBytes += await file.length();
            }
          }
        }
      }

      final sizeMB = totalBytes / (1024 * 1024);
      logInfo('Total cache size calculated: ${sizeMB.toStringAsFixed(2)} MB');
      return sizeMB;
    } catch (e, stack) {
      logError('Failed to calculate total cache size', e, stack);
    }
    return 0.0;
  }

  Future<void> clearAllCaches() async {
    logInfo('Clearing all Asset caches...');
    try {
      await assetStorage.clearAll();
      logInfo('Asset cache database cleared.');

      if (!kIsWeb) {
        for (final manager in _activeManagers) {
          await manager.emptyCache();
        }
        logInfo('All registered disk cache managers cleared.');
      }

      final now = clock.now();
      await assetStorage.write(_keyLastClear, now.toIso8601String());
      logInfo('Cache clear timestamp updated: ${now.toIso8601String()}');
    } catch (e, stack) {
      logError('Error occurred while clearing caches', e, stack);
    }
  }
}

class AssetCacheScope extends InheritedWidget {
  final AssetCacheController controller;

  const AssetCacheScope({
    required this.controller,
    required super.child,
    super.key,
  });

  static AssetCacheController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AssetCacheScope>();
    if (scope == null) {
      throw FlutterError(
        'AssetCacheScope.of() called with a context that does not contain an AssetCacheScope.\n'
        'No AssetCacheScope ancestor could be found starting from the context that was passed to AssetCacheScope.of().\n'
        'Please wrap your widget tree in an AssetCacheScope.',
      );
    }
    return scope.controller;
  }

  static AssetCacheController? maybeOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AssetCacheScope>();
    return scope?.controller;
  }

  @override
  bool updateShouldNotify(covariant AssetCacheScope oldWidget) {
    return controller != oldWidget.controller;
  }
}
