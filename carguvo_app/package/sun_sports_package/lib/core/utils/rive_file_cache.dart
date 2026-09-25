import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:rive/rive.dart' as rive;

import 'package:sun_sports/core/utils/extensions/cached_manager.dart';
import 'package:sun_sports/core/utils/styles/app_rive.dart';

class RiveFileCache {
  RiveFileCache._();

  static final Map<String, Future<rive.File?>> _cache = {};

  static final Map<String, ValueNotifier<double>> _progress = {};

  static Future<rive.File?> load(String url) {
    final cached = _cache[url];
    if (cached != null) return cached;

    final future = rive.File.url(
      url,
      riveFactory: AppRive.factoryForUrl(url),
    ).catchError((Object e) {
      _cache.remove(url);
      throw e;
    });

    _cache[url] = future;
    return future;
  }

  static (Future<rive.File?>, ValueListenable<double>) loadWithProgress(
    String url,
  ) {
    final existingFuture = _cache[url];
    final existingProgress = _progress[url];
    if (existingFuture != null && existingProgress != null) {
      return (existingFuture, existingProgress);
    }

    final progress = _progress.putIfAbsent(url, () => ValueNotifier<double>(0));
    final future = _downloadWithProgress(url, progress);
    _cache[url] = future;
    return (future, progress);
  }

  static (Future<void>, ValueListenable<double>) loadAllWithProgress(
    List<String> urls,
  ) {
    if (urls.isEmpty) {
      return (Future<void>.value(), ValueNotifier<double>(1.0));
    }

    final entries = urls.map(loadWithProgress).toList(growable: false);
    final progresses = entries.map((e) => e.$2).toList(growable: false);

    final aggregate = ValueNotifier<double>(_averageProgress(progresses));
    void recompute() => aggregate.value = _averageProgress(progresses);
    for (final p in progresses) {
      p.addListener(recompute);
    }

    final done = Future.wait(
      entries.map((e) => e.$1.catchError((_) => null)),
    ).whenComplete(() {
      for (final p in progresses) {
        p.removeListener(recompute);
      }
      aggregate.value = 1.0;
    });

    return (done, aggregate);
  }

  static double _averageProgress(List<ValueListenable<double>> ps) {
    if (ps.isEmpty) return 1.0;
    var sum = 0.0;
    for (final p in ps) {
      sum += p.value;
    }
    return (sum / ps.length).clamp(0.0, 1.0);
  }

  static Future<rive.File?> _downloadWithProgress(
    String url,
    ValueNotifier<double> progress,
  ) async {
    final client = http.Client();
    try {
      final res = await client.send(http.Request('GET', Uri.parse(url)));
      final total = res.contentLength ?? 0;
      final builder = BytesBuilder(copy: false);
      var received = 0;
      await for (final chunk in res.stream) {
        builder.add(chunk);
        received += chunk.length;
        if (total > 0) {
          progress.value = (received / total).clamp(0.0, 0.99);
        }
      }
      final bytes = builder.toBytes();
      final file = await rive.File.decode(
        bytes,
        riveFactory: AppRive.factoryForUrl(url),
      );
      progress.value = 1.0;

      if (!kIsWeb) {
        await AssetsCacheManager.warmBytes(url, bytes);
      }
      return file;
    } catch (e) {
      _cache.remove(url);
      _progress.remove(url);
      rethrow;
    } finally {
      client.close();
    }
  }

  static Future<void> warm(String url) async {
    try {
      await load(url);
    } catch (_) {
    }
  }

  static Future<void> warmFromBytes(String url, Uint8List bytes) async {
    if (_cache.containsKey(url)) return;

    final future = _decodeWithErrorHandling(url, bytes);
    _cache[url] = future;
    await future;
  }

  static Future<rive.File?> _decodeWithErrorHandling(
    String url,
    Uint8List bytes,
  ) async {
    try {
      final file = await rive.File.decode(
        bytes,
        riveFactory: AppRive.factoryForUrl(url),
      );
      return file;
    } catch (_) {
      _cache.remove(url);
      return null;
    }
  }

  static bool contains(String url) => _cache.containsKey(url);

  static void clearUrl(String url) {
    final evicted = _cache.remove(url);
    _progress.remove(url);
    evicted?.then((file) => file?.dispose()).catchError((_) {
    });
  }

  static void clearAll() {
    _cache.clear();
    _progress.clear();
  }
}
