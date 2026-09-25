import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:sun_sports/core/utils/extensions/assets_data.dart';

class AssetsCacheManager {
  AssetsCacheManager._();
  static CacheManager? _cacheManager;
  static const Duration defaultMaxAge = Duration(days: 365);
  static const int defaultMaxNrOfCacheObjects = 20000;

  static final Map<String, String> _svgMemoryCache = {};

  static final Map<String, String> _filePathMemoryCache = {};

  static final Map<String, AssetsData> _urlToAssetRegistry = {};

  static void registerAsset(AssetsData asset) {
    try {
      final normalizedUrl = asset.urlPath.trim();
      _urlToAssetRegistry[normalizedUrl] = asset;

      if (asset.oldVersion != asset.newVersion) {
        Future.microtask(() {
          clearOldVersionsForIcon(asset).catchError((Object e) {
            if (kDebugMode) {
              debugPrint(
                'Warning: Failed to clear old version for ${asset.label}: $e',
              );
            }
          });
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error registering asset ${asset.label}: $e');
      }
    }
  }

  static void registerAssets(List<AssetsData> assets) {
    for (final asset in assets) {
      registerAsset(asset);
    }
  }

  static AssetsData? getAssetForUrl(String url) {
    return _urlToAssetRegistry[url.trim()];
  }

  static void clearRegistry() {
    _urlToAssetRegistry.clear();
  }

  static CacheManager? getInstance({Duration? maxAge}) {
    if (kIsWeb) {
      return null;
    }

    _cacheManager ??= CacheManager(
      Config(
        'sports_images_cache',
        stalePeriod: maxAge ?? defaultMaxAge,
        maxNrOfCacheObjects: defaultMaxNrOfCacheObjects,
        repo: JsonCacheInfoRepository(databaseName: 'sports_images_cache.db'),
      ),
    );
    return _cacheManager!;
  }

  static Future<void> clearCache() async {
    if (kIsWeb) {
      _svgMemoryCache.clear();
      _filePathMemoryCache.clear();
      return;
    }

    final cacheManager = getInstance();
    if (cacheManager != null) {
      await cacheManager.emptyCache();
    }
    _cacheManager = null;
    _svgMemoryCache.clear();
    _filePathMemoryCache.clear();
  }

  static Future<void> clearCacheForUrl(String url) async {
    try {
      final normalizedUrl = url.trim();

      if (kIsWeb) {
        _svgMemoryCache.remove(normalizedUrl);
        _filePathMemoryCache.remove(normalizedUrl);

        final asset = getAssetForUrl(normalizedUrl);
        if (asset != null) {
          final cacheKey = getCacheKeyForIcon(
            asset,
            autoClearOldVersions: false,
          );
          _svgMemoryCache.remove(cacheKey);
          _filePathMemoryCache.remove(cacheKey);
        }
        return;
      }

      final cacheManager = getCacheManager();
      if (cacheManager == null) return;

      final asset = getAssetForUrl(normalizedUrl);
      if (asset != null) {
        final cacheKey = getCacheKeyForIcon(asset, autoClearOldVersions: false);
        await cacheManager.removeFile(cacheKey);
        _svgMemoryCache.remove(cacheKey);
        _filePathMemoryCache.remove(cacheKey);

        if (asset.oldVersion != asset.newVersion) {
          final oldCacheKey = '${asset.label}_v${asset.oldVersion}';
          await cacheManager.removeFile(oldCacheKey);
          _svgMemoryCache.remove(oldCacheKey);
          _filePathMemoryCache.remove(oldCacheKey);
        }
      }

      await cacheManager.removeFile(normalizedUrl);
      _svgMemoryCache.remove(normalizedUrl);
      _filePathMemoryCache.remove(normalizedUrl);
    } catch (e) {
      debugPrint('Failed to clear cache for URL $url: $e');
    }
  }

  static Future<void> clearCacheForUrls(List<String> urls) async {
    try {
      final cacheManager = getCacheManager();
      final normalizedUrls = urls.map((url) => url.trim()).toList();

      for (final url in normalizedUrls) {
        _svgMemoryCache.remove(url);
        _filePathMemoryCache.remove(url);
      }

      if (cacheManager != null) {
        final futures = normalizedUrls
            .map((url) => cacheManager.removeFile(url).catchError((_) {}))
            .toList();
        await Future.wait(futures);
      }
    } catch (e) {
      debugPrint('Failed to clear cache for URLs: $e');
    }
  }

  static Future<void> clearAllIconsCache() async {
    await clearCache();
    debugPrint('Cleared all icons cache');
  }

  static String? getCachedSvgString(String url) {
    return _svgMemoryCache[url.trim()];
  }

  static void cacheSvgString(String url, String svgString) {
    _svgMemoryCache[url.trim()] = svgString;
  }

  static String? getCachedFilePath(String url) {
    return _filePathMemoryCache[url.trim()];
  }

  static void cacheFilePath(String url, String filePath) {
    _filePathMemoryCache[url.trim()] = filePath;
  }

  static CacheManager? getCacheManager({Duration? maxAge}) {
    return AssetsCacheManager.getInstance(maxAge: maxAge);
  }

  static void clearMemoryCacheForUrls(List<String> urls) {
    for (final url in urls) {
      final normalizedUrl = url.trim();
      _svgMemoryCache.remove(normalizedUrl);
      _filePathMemoryCache.remove(normalizedUrl);
      final asset = getAssetForUrl(normalizedUrl);
      if (asset != null) {
        final cacheKey = getCacheKeyForIcon(asset, autoClearOldVersions: false);
        _svgMemoryCache.remove(cacheKey);
        _filePathMemoryCache.remove(cacheKey);
      }
    }
  }

  static String getCacheKeyForIcon(
    AssetsData icon, {
    int? version,
    bool autoClearOldVersions = true,
  }) {
    final effectiveVersion = version ?? icon.newVersion;

    if (autoClearOldVersions) {
      clearOldVersionsForIcon(icon);
    }

    return '${icon.label}_v$effectiveVersion';
  }

  static Future<void> clearOldVersionsForIcon(AssetsData icon) async {
    if (icon.oldVersion != icon.newVersion) {
      final oldVersionCacheKey = '${icon.label}_v${icon.oldVersion}';
      try {
        if (kIsWeb) {
          _svgMemoryCache.remove(oldVersionCacheKey);
          _filePathMemoryCache.remove(oldVersionCacheKey);
          return;
        }

        final cacheManager = getCacheManager();
        if (cacheManager != null) {
          await cacheManager.removeFile(oldVersionCacheKey);
        }

        _svgMemoryCache.remove(oldVersionCacheKey);
        _filePathMemoryCache.remove(oldVersionCacheKey);
      } catch (_) {
      }
    }
  }

  static Future<String> getCachedSvgPath(AssetsData icon) async {
    try {
      final cacheKey = getCacheKeyForIcon(icon);

      final cachedPath = getCachedFilePath(cacheKey);
      if (cachedPath != null) {
        final file = File(cachedPath);
        if (await file.exists()) {
          return cachedPath;
        }
        _filePathMemoryCache.remove(cacheKey);
      }

      if (!kIsWeb) {
        final cacheManager = getCacheManager();
        if (cacheManager != null) {
          final fileInfo = await cacheManager.getFileFromCache(cacheKey);

          if (fileInfo != null && await fileInfo.file.exists()) {
            final filePath = fileInfo.file.path;
            cacheFilePath(cacheKey, filePath);
            return filePath;
          }

          final file = await cacheManager.getSingleFile(
            icon.urlPath,
            key: cacheKey,
          );

          if (await file.exists()) {
            final filePath = file.path;
            cacheFilePath(cacheKey, filePath);
            return filePath;
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to cache SVG icon ${icon.label}: $e');
    }
    return icon.urlPath;
  }

  static Future<File?> getCachedFileForUrlWithVersioning(String url) async {
    if (kIsWeb) {
      return null;
    }

    try {
      final normalizedUrl = url.trim();

      final asset = getAssetForUrl(normalizedUrl);
      if (asset != null) {
        final cacheKey = getCacheKeyForIcon(asset);

        final cachedPath = getCachedFilePath(cacheKey);
        if (cachedPath != null) {
          final file = File(cachedPath);
          if (await file.exists()) {
            return file;
          }
          _filePathMemoryCache.remove(cacheKey);
        }

        final cacheManager = getCacheManager();
        if (cacheManager == null) return null;

        final fileInfo = await cacheManager.getFileFromCache(cacheKey);

        if (fileInfo != null && await fileInfo.file.exists()) {
          final filePath = fileInfo.file.path;
          cacheFilePath(cacheKey, filePath);
          return fileInfo.file;
        }

        final file = await cacheManager.getSingleFile(
          normalizedUrl,
          key: cacheKey,
        );

        if (await file.exists()) {
          cacheFilePath(cacheKey, file.path);
          return file;
        }
      } else {
        return await getCachedFileForUrl(normalizedUrl);
      }
    } catch (e) {
      return await getCachedFileForUrl(url);
    }
    return null;
  }

  static Future<File?> getCachedFileForUrl(String url) async {
    if (kIsWeb) {
      return null;
    }

    try {
      final normalizedUrl = url.trim();

      final cachedPath = getCachedFilePath(normalizedUrl);
      if (cachedPath != null) {
        final file = File(cachedPath);
        if (await file.exists()) {
          return file;
        }
        _filePathMemoryCache.remove(normalizedUrl);
      }

      final cacheManager = getCacheManager();
      if (cacheManager == null) return null;

      final fileInfo = await cacheManager.getFileFromCache(normalizedUrl);

      if (fileInfo != null && await fileInfo.file.exists()) {
        final filePath = fileInfo.file.path;
        cacheFilePath(normalizedUrl, filePath);
        return fileInfo.file;
      }
    } catch (e) {
    }
    return null;
  }

  static Future<File> getSingleFileForUrlWithVersioning(String url) async {
    if (kIsWeb) {
      throw UnsupportedError(
        'getSingleFileForUrlWithVersioning is not supported on web',
      );
    }

    try {
      final normalizedUrl = url.trim();

      final asset = getAssetForUrl(normalizedUrl);
      if (asset != null) {
        final cacheKey = getCacheKeyForIcon(asset);

        final cachedPath = getCachedFilePath(cacheKey);
        if (cachedPath != null) {
          final file = File(cachedPath);
          if (await file.exists()) {
            return file;
          }
          _filePathMemoryCache.remove(cacheKey);
        }

        final cacheManager = getCacheManager();
        if (cacheManager == null) {
          throw UnsupportedError('CacheManager is not available');
        }

        final file = await cacheManager.getSingleFile(
          normalizedUrl,
          key: cacheKey,
        );

        if (await file.exists()) {
          cacheFilePath(cacheKey, file.path);
        }

        return file;
      } else {
        return await getSingleFileForUrl(normalizedUrl);
      }
    } catch (e) {
      return await getSingleFileForUrl(url);
    }
  }

  static Future<File> getSingleFileForUrl(String url) async {
    try {
      final normalizedUrl = url.trim();

      final cachedPath = getCachedFilePath(normalizedUrl);
      if (cachedPath != null) {
        final file = File(cachedPath);
        if (await file.exists()) {
          return file;
        }
        _filePathMemoryCache.remove(normalizedUrl);
      }

      final cacheManager = getCacheManager();
      if (cacheManager == null) {
        throw UnsupportedError('CacheManager is not available');
      }
      final file = await cacheManager.getSingleFile(
        normalizedUrl,
        key: normalizedUrl,
      );

      if (await file.exists()) {
        cacheFilePath(normalizedUrl, file.path);
      }

      return file;
    } catch (e) {
      rethrow;
    }
  }

  static Future<File?> warmBytes(String url, Uint8List bytes) async {
    if (kIsWeb) return null;
    try {
      final normalizedUrl = url.trim();
      final cacheManager = getCacheManager();
      if (cacheManager == null) return null;
      final asset = getAssetForUrl(normalizedUrl);
      final key = asset != null ? getCacheKeyForIcon(asset) : normalizedUrl;
      final File file = await cacheManager.putFile(
        normalizedUrl,
        bytes,
        key: key,
        fileExtension: _extractExt(normalizedUrl),
      );
      cacheFilePath(key, file.path);
      return file;
    } catch (e) {
      debugPrint('AssetsCacheManager.warmBytes failed for $url: $e');
      return null;
    }
  }

  static String _extractExt(String url) {
    final cleaned = url.split('?').first;
    final dot = cleaned.lastIndexOf('.');
    if (dot < 0 || dot < cleaned.length - 5) return '.dat';
    return cleaned.substring(dot);
  }
}
