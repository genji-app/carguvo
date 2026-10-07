import 'dart:async';

import 'package:clock/clock.dart';
import 'package:dart_kit/dart_kit.dart';

extension AssetUrlFormatter on String {
  String toBustedUrl(String version) {
    final cleanUrl = trim();
    if (cleanUrl.isEmpty) return cleanUrl;

    final isNetwork =
        cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://');
    if (!isNetwork || version.isEmpty) return cleanUrl;

    try {
      final uri = Uri.parse(cleanUrl);
      final queryParams = Map<String, String>.from(uri.queryParameters);

      if (!queryParams.containsKey('v')) {
        queryParams['v'] = version;
        return uri.replace(queryParameters: queryParams).toString();
      }
    } catch (_) {
    }
    return cleanUrl;
  }
}

abstract class AssetStorage {
  Future<void> init();
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> clearAll();
}

class AssetCacheConfig {
  const AssetCacheConfig({
    this.imageCacheKey = 'app_resource_images',
    this.maxConcurrentRequests = 6,
    this.cacheVersion = '1',
    this.periodicClearDays = 3,
  });

  final String imageCacheKey;
  final int maxConcurrentRequests;
  final String cacheVersion;
  final int periodicClearDays;
}

class AssetCacheController {
  AssetCacheController({
    required this.storage,
    required this.config,
    Semaphore? semaphore,
  }) : _semaphore = semaphore ?? Semaphore(config.maxConcurrentRequests);

  final AssetStorage storage;
  final AssetCacheConfig config;
  final Semaphore _semaphore;

  static const String _keyLastClear = 'asset_last_cache_clear';

  Future<void>? _initFuture;

  String get cacheVersion => config.cacheVersion;

  Future<void> init() async {
    _initFuture ??= _doInit();
    return _initFuture;
  }

  Future<void> _doInit() async {
    await storage.init();

    await _checkPeriodicClear();
  }

  Future<void> _checkPeriodicClear() async {
    try {
      final lastClearStr = await storage.read(_keyLastClear);
      if (lastClearStr != null) {
        final lastClear = DateTime.tryParse(lastClearStr);
        if (lastClear != null) {
          final daysSinceClear = clock.now().difference(lastClear).inDays;
          if (daysSinceClear >= config.periodicClearDays) {
            await clearAllCaches();
          }
        }
      }
    } catch (_) {
    }
  }

  Future<void> clearAllCaches() async {
    await storage.clearAll();
    final now = clock.now();
    await storage.write(_keyLastClear, now.toIso8601String());
  }

  Future<void> acquireSemaphore() => _semaphore.acquire();

  void releaseSemaphore() => _semaphore.release();
}
