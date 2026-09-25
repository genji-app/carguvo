import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:dart_kit/dart_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:sun_sports/core/services/bundle_config_service.dart';
import 'package:sun_sports/core/services/config/sb_config.dart';
import 'package:sun_sports/core/utils/bundle_defines.dart';
import 'package:sun_sports/core/utils/extensions/cached_manager.dart';
import 'package:sun_sports/core/utils/rive_file_cache.dart';
import 'package:sun_sports/core/utils/sprite/sprite_atlas.dart';
import 'package:sun_sports/core/utils/video_cache_manager.dart';

class _BundleResourceInfo {
  final String fullFilename;
  final String type;
  final String? packFile;

  _BundleResourceInfo({
    required this.fullFilename,
    required this.type,
    this.packFile,
  });
}

class _BundleConfigJson {
  final String name;
  final String? svg;
  final List<String> atlases;
  final List<String> images;
  final List<String> others;

  _BundleConfigJson({
    required this.name,
    required this.svg,
    required this.atlases,
    required this.images,
    required this.others,
  });

  factory _BundleConfigJson.fromJson(Map<String, dynamic> json) {
    return _BundleConfigJson(
      name: (json['name'] as String?) ?? '',
      svg: json['svg'] as String?,
      atlases: (json['atlases'] as List<dynamic>?)?.cast<String>() ?? [],
      images: (json['images'] as List<dynamic>?)?.cast<String>() ?? [],
      others: (json['others'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}

class ResourceResult {
  final String bundleKey;
  final String type;
  final String? packFile;
  final String? url;
  final AtlasFrame? atlasFrame;
  final String? svgContent;

  const ResourceResult({
    required this.bundleKey,
    required this.type,
    this.packFile,
    this.url,
    this.atlasFrame,
    this.svgContent,
  });
}

class _BundleSubscriber {
  _BundleSubscriber(this.onProgress, this.onItemFinish, this.onBundleFinish);
  final void Function(double progress)? onProgress;
  final void Function(String itemName, bool success)? onItemFinish;
  final void Function(String bundleKey, bool success)? onBundleFinish;
}

class _ChainProgressTracker {
  _ChainProgressTracker({
    required this.onCombinedProgress,
    required this.listeners,
    required this.notifiers,
    required this.updateProgress,
  });

  final void Function(double) onCombinedProgress;
  final List<void Function()> listeners;
  final List<ValueNotifier<double>> notifiers;
  final void Function() updateProgress;

  void dispose() {
    for (int i = 0; i < listeners.length; i++) {
      if (i < notifiers.length) {
        notifiers[i].removeListener(listeners[i]);
      }
    }
  }
}

class BundleManager {
  BundleManager._();
  static final BundleManager instance = BundleManager._();

  final Map<String, _BundleConfigJson> _configs = {};
  final Map<String, bool> _bundleLoaded = {};
  final Set<String> _failedBundles = {};

  final Map<String, Set<String>> _failedItems = {};

  final Map<String, Map<String, _BundleResourceInfo>> _resourceLookup = {};

  final Map<String, Map<String, SpriteAtlas>> _atlases = {};

  final Map<String, Map<String, String>> _svgSymbols = {};

  final Map<String, Future<void>> _loadingByBundle = {};
  final Map<String, ValueNotifier<double>> _loadProgressByBundle = {};

  final Map<String, List<_BundleSubscriber>> _subscribers = {};

  http.Client _http = http.Client();

  static const int _maxConcurrentLoads = 6;
  Semaphore _loadSlots = Semaphore(_maxConcurrentLoads);

  Future<void> _withSlot(Future<void> Function() action) async {
    final slots = _loadSlots;
    await slots.acquire();
    try {
      await action();
    } finally {
      slots.release();
    }
  }

  void _notifyProgress(String bundleKey, double progress) {
    progressFor(bundleKey).value = progress;
    loadProgress.value = progress;
    final subs = _subscribers[bundleKey];
    if (subs != null) {
      for (final s in subs) {
        s.onProgress?.call(progress);
      }
    }
  }

  void _notifyItem(String bundleKey, String itemName, bool success) {
    final subs = _subscribers[bundleKey];
    if (subs != null) {
      for (final s in subs) {
        s.onItemFinish?.call(itemName, success);
      }
    }
  }

  void _notifyFinish(String bundleKey, bool success) {
    final subs = _subscribers.remove(bundleKey);
    if (subs != null) {
      for (final s in subs) {
        s.onBundleFinish?.call(bundleKey, success);
      }
    }
  }

  int _loadSeq = 0;
  final Map<String, int> _generation = {};

  bool _isStale(String bundleKey, int gen) => _generation[bundleKey] != gen;

  void Function(String bundleKey, String item, Object error, StackTrace? stack)?
      onLoadError;

  void _reportError(String bundleKey, String item, Object error,
      [StackTrace? stack]) {
    debugPrint('BundleManager: [$bundleKey] "$item" error: $error');
    onLoadError?.call(bundleKey, item, error, stack);
  }

  void cancelBundle(String bundleKey) {
    if (_loadingByBundle[bundleKey] == null) return;
    _generation[bundleKey] = ++_loadSeq;
    _loadingByBundle.remove(bundleKey);
    _notifyFinish(bundleKey, false);
  }

  static final ValueNotifier<int> assetsGeneration = ValueNotifier<int>(0);

  static Set<String> get suspendedBundles => _suspendedBundles;
  static Set<String> _suspendedBundles = const <String>{};

  static bool get assetsSuspended => _suspendedBundles.isNotEmpty;

  static bool isBundleSuspended(String bundleKey) =>
      _suspendedBundles.contains(bundleKey);

  static void setSuspendedBundles(Set<String> bundleKeys) {
    if (_suspendedBundles.length == bundleKeys.length &&
        _suspendedBundles.containsAll(bundleKeys)) {
      return;
    }
    _suspendedBundles = Set<String>.unmodifiable(bundleKeys);
    bumpAssetsGeneration();
  }

  static void bumpAssetsGeneration() {
    assetsGeneration.value = assetsGeneration.value + 1;
  }

  int atlasBytesOf(String bundleKey) {
    final byBundle = _atlases[bundleKey];
    if (byBundle == null) return 0;
    var total = 0;
    for (final atlas in byBundle.values) {
      total += atlas.image.width * atlas.image.height * 4;
    }
    return total;
  }

  bool isBundleLoaded(String bundleKey) => _bundleLoaded[bundleKey] == true;

  ValueNotifier<double> progressFor(String bundleKey) =>
      _loadProgressByBundle.putIfAbsent(bundleKey, () => ValueNotifier<double>(0.0));

  final ValueNotifier<double> loadProgress = ValueNotifier<double>(0.0);

  Future<void> loadGlobalConfig() async {
    await BundleConfigService.instance.load();
  }

  bool get isReady =>
      _configs.isNotEmpty &&
      _configs.keys.every((key) => _bundleLoaded[key] == true);

  bool isBundleReady(String bundleKey) => _bundleLoaded[bundleKey] == true;

  bool isBundleComplete(String bundleKey) {
    final visited = <String>{};
    bool check(String key) {
      if (!visited.add(key)) return true;
      if (_bundleLoaded[key] != true) return false;
      if (_failedBundles.contains(key)) return false;
      final failed = _failedItems[key];
      if (failed != null && failed.isNotEmpty) return false;
      for (final dep in BundleDefines.bundleDependencies[key] ?? const []) {
        if (!check(dep as String)) return false;
      }
      return true;
    }

    return check(bundleKey);
  }

  Set<String> failedItemsOf(String bundleKey) =>
      Set<String>.unmodifiable(_failedItems[bundleKey] ?? const <String>{});

  List<String> get bundleNames => _configs.keys.toList();

  List<String> get loadedBundleKeys =>
      _configs.keys.where((k) => _bundleLoaded[k] == true).toList();

  Set<String> get failedBundles => Set<String>.from(_failedBundles);

  String get _cdnBase {
    final base = SbConfig.rsDomain;
    if (base.isEmpty) return '';
    return base.endsWith('/') ? base : '$base/';
  }

  String getBundleConfigUrl(String bundleKey) {
    final base = _cdnBase;
    if (base.isEmpty) return '';
    final hash = BundleConfigService.instance.getBundleHash(bundleKey);
    if (hash.isNotEmpty) {
      return '${base}assets/$bundleKey/bundle_resource_config.$hash.json';
    }
    return '${base}assets/$bundleKey/bundle_resource_config.json';
  }

  static const String _configCacheDir = 'bundle_config_cache';

  Future<String> _configCachePath(String bundleKey) async {
    final dir = await getApplicationSupportDirectory();
    final cacheDir = Directory('${dir.path}/$_configCacheDir');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return '${cacheDir.path}/$bundleKey.json';
  }

  Future<void> _saveConfigLocal(String bundleKey, String body) async {
    if (kIsWeb) return;
    try {
      final path = await _configCachePath(bundleKey);
      await File(path).writeAsString(body);
    } catch (_) {
    }
  }

  Future<String?> _loadConfigLocal(String bundleKey) async {
    if (kIsWeb) return null;
    try {
      final path = await _configCachePath(bundleKey);
      final file = File(path);
      if (await file.exists()) return await file.readAsString();
    } catch (_) {
    }
    return null;
  }

  static const Map<String, String> _typeToFolder = {
    'image': 'images',
    'atlas': 'packs',
    'svg_sprite': 'packs',
    'other': 'others',
  };

  String _fileUrl(String bundleKey, String filename, String type) {
    final base = _cdnBase;
    if (base.isEmpty) return '';
    final folder = _typeToFolder[type];
    if (folder == null) return '';
    return '${base}assets/$bundleKey/$folder/$filename';
  }

  String _atlasBaseUrl(String bundleKey, String atlasName) {
    final base = _cdnBase;
    if (base.isEmpty) return '';
    return '${base}assets/$bundleKey/packs/$atlasName';
  }

  List<String> _resolveBundleChain(String bundleKey) {
    final visited = <String>{};
    final chain = <String>[];

    void dfs(String key) {
      if (visited.contains(key)) {
        debugPrint('BundleManager: circular dependency detected for $key');
        return;
      }
      visited.add(key);

      final deps = BundleDefines.bundleDependencies[key] ?? [];
      for (final dep in deps) {
        if (!_bundleLoaded.containsKey(dep) && !_loadingByBundle.containsKey(dep)) {
          dfs(dep);
        }
      }

      if (!_isBundleDefinitelyDone(key)) {
        chain.add(key);
      }
    }

    dfs(bundleKey);
    return chain.toSet().toList();
  }

  bool _isBundleDefinitelyDone(String bundleKey) {
    return _bundleLoaded[bundleKey] == true ||
        _failedBundles.contains(bundleKey) ||
        _loadingByBundle.containsKey(bundleKey);
  }

  _ChainProgressTracker _trackChainProgress(
    List<String> chain, {
    required void Function(double) onCombinedProgress,
  }) {
    final totalItemsMap = <String, int>{};
    for (final key in chain) {
      final config = _configs[key];
      totalItemsMap[key] = config != null ? _countResources(config) : 1;
    }

    final completedItemsMap = <String, int>{};
    for (final key in chain) {
      completedItemsMap[key] = 0;
    }

    void ensureTotalItems(String bundleKey) {
      if (totalItemsMap[bundleKey] == 1) {
        final config = _configs[bundleKey];
        if (config != null) {
          totalItemsMap[bundleKey] = _countResources(config);
        }
      }
    }

    int getOverallTotal() {
      int total = 0;
      for (final key in chain) {
        ensureTotalItems(key);
        total += totalItemsMap[key] ?? 1;
      }
      return total;
    }

    int getOverallCompleted() {
      int completed = 0;
      for (final key in chain) {
        completed += completedItemsMap[key] ?? 0;
      }
      return completed;
    }

    void updateProgress() {
      final total = getOverallTotal();
      if (total == 0) {
        onCombinedProgress(1.0);
        return;
      }
      final done = getOverallCompleted();
      onCombinedProgress(done / total);
    }

    final listeners = <void Function()>[];
    final notifiers = <ValueNotifier<double>>[];
    for (final key in chain) {
      final notifier = progressFor(key);
      void listener() {
        final progress = notifier.value;
        final config = _configs[key];
        final totalItems = config != null ? _countResources(config) : 1;
        completedItemsMap[key] = (progress * totalItems).round();
        updateProgress();
      }
      notifier.addListener(listener);
      listeners.add(listener);
      notifiers.add(notifier);
    }

    return _ChainProgressTracker(
      onCombinedProgress: onCombinedProgress,
      listeners: listeners,
      notifiers: notifiers,
      updateProgress: updateProgress,
    );
  }

  Future<void> loadBundle(
    String bundleKey, {
    bool force = false,
    void Function(double progress)? onProgress,
    void Function(String itemName, bool success)? onItemFinish,
    void Function(String bundleKey, bool success)? onBundleFinish,
  }) async {
    try {
      await _loadBundleInner(
        bundleKey,
        force: force,
        onProgress: onProgress,
        onItemFinish: onItemFinish,
        onBundleFinish: onBundleFinish,
      );
    } finally {
      bumpAssetsGeneration();
    }
  }

  Future<void> _loadBundleInner(
    String bundleKey, {
    bool force = false,
    void Function(double progress)? onProgress,
    void Function(String itemName, bool success)? onItemFinish,
    void Function(String bundleKey, bool success)? onBundleFinish,
  }) async {
    if (force) {
      _failedBundles.remove(bundleKey);
      _bundleLoaded.remove(bundleKey);
      _configs.remove(bundleKey);
      _resourceLookup.remove(bundleKey);
      _failedItems.remove(bundleKey);
      _generation[bundleKey] = ++_loadSeq;
      _loadingByBundle.remove(bundleKey);
    }

    if (_bundleLoaded[bundleKey] == true || _failedBundles.contains(bundleKey)) {
      final ok = _bundleLoaded[bundleKey] == true;
      onProgress?.call(ok ? 1.0 : progressFor(bundleKey).value);
      onBundleFinish?.call(bundleKey, ok);
      return;
    }

    final chain = _resolveBundleChain(bundleKey);

    if (!chain.contains(bundleKey) && _isBundleDefinitelyDone(bundleKey)) {
      final ok = _bundleLoaded[bundleKey] == true;
      onProgress?.call(ok ? 1.0 : progressFor(bundleKey).value);
      onBundleFinish?.call(bundleKey, ok);
      return;
    }

    _subscribers.putIfAbsent(bundleKey, () => []).add(
          _BundleSubscriber(onProgress, onItemFinish, onBundleFinish),
        );

    final inFlight = _loadingByBundle[bundleKey];
    if (inFlight != null) {
      onProgress?.call(progressFor(bundleKey).value);
      return inFlight;
    }

    if (chain.length == 1) {
      final future = _doLoadBundle(bundleKey);
      _loadingByBundle[bundleKey] = future;
      try {
        await future;
      } finally {
        if (identical(_loadingByBundle[bundleKey], future)) {
          _loadingByBundle.remove(bundleKey);
        }
      }
      return;
    }

    final chainTracker = _trackChainProgress(
      chain,
      onCombinedProgress: (progress) {
        progressFor(bundleKey).value = progress;
        loadProgress.value = progress;
        final subs = _subscribers[bundleKey];
        if (subs != null) {
          for (final s in subs) {
            s.onProgress?.call(progress);
          }
        }
      },
    );

    final chainFuture = _doLoadBundleChain(bundleKey, chain);
    _loadingByBundle[bundleKey] = chainFuture;
    try {
      await chainFuture;
    } finally {
      chainTracker.dispose();
      if (identical(_loadingByBundle[bundleKey], chainFuture)) {
        _loadingByBundle.remove(bundleKey);
      }
    }
  }

  Future<void> _doLoadBundleChain(
    String rootBundleKey,
    List<String> chain,
  ) async {
    int? rootGen;

    bool allOk = true;
    for (final key in chain) {
      try {
        final future = _doLoadBundleInChain(key);
        _loadingByBundle[key] = future;
        if (key == rootBundleKey) rootGen = _generation[key];
        await future;
      } catch (e) {
        debugPrint('BundleManager: dependency $key failed in chain for $rootBundleKey: $e');
        allOk = false;
      } finally {
        _loadingByBundle.remove(key);
      }
    }

    if (rootGen != null && !_isStale(rootBundleKey, rootGen)) {
      _bundleLoaded[rootBundleKey] = allOk;
      _notifyProgress(rootBundleKey, 1.0);
      _notifyFinish(rootBundleKey, allOk);
    }
  }

  Future<void> ensureLoaded(
    String bundleKey, {
    bool force = false,
    void Function(double progress)? onProgress,
    void Function(String itemName, bool success)? onItemFinish,
    void Function(String bundleKey, bool success)? onBundleFinish,
  }) =>
      loadBundle(
        bundleKey,
        force: force,
        onProgress: onProgress,
        onItemFinish: onItemFinish,
        onBundleFinish: onBundleFinish,
      );

  Future<void> retryBundle(
    String bundleKey, {
    void Function(double progress)? onProgress,
    void Function(String itemName, bool success)? onItemFinish,
    void Function(String bundleKey, bool success)? onBundleFinish,
  }) =>
      loadBundle(
        bundleKey,
        force: true,
        onProgress: onProgress,
        onItemFinish: onItemFinish,
        onBundleFinish: onBundleFinish,
      );

  Future<void> reloadBundleDeep(String bundleKey) async {
    final visited = <String>{};
    void clearDeep(String key) {
      if (!visited.add(key)) return;
      for (final dep in BundleDefines.bundleDependencies[key] ?? const []) {
        clearDeep(dep as String);
        if (dep != bundleKey) {
          _failedBundles.remove(dep);
          _bundleLoaded.remove(dep);
          _configs.remove(dep);
          _resourceLookup.remove(dep);
          _failedItems.remove(dep);
          _loadingByBundle.remove(dep);
          _generation[dep] = ++_loadSeq;
        }
      }
    }

    clearDeep(bundleKey);
    return loadBundle(bundleKey, force: true);
  }

  Future<void> _doLoadBundle(String bundleKey) async {
    final gen = ++_loadSeq;
    _generation[bundleKey] = gen;
    try {
      await _doLoadBundleOnce(bundleKey, gen, notifyFinish: true);
    } catch (e, st) {
      if (!_isStale(bundleKey, gen)) {
        _bundleLoaded[bundleKey] = false;
        _failedBundles.add(bundleKey);
        _reportError(bundleKey, 'config', e, st);
        _notifyFinish(bundleKey, false);
      }
      rethrow;
    }
  }

  Future<void> _doLoadBundleInChain(String bundleKey) async {
    final gen = ++_loadSeq;
    _generation[bundleKey] = gen;
    try {
      await _doLoadBundleOnce(bundleKey, gen, notifyFinish: false);
    } catch (e, st) {
      if (!_isStale(bundleKey, gen)) {
        _failedBundles.add(bundleKey);
        _reportError(bundleKey, 'config', e, st);
      }
    }
  }

  Future<void> _doLoadBundleOnce(
    String bundleKey,
    int gen, {
    required bool notifyFinish,
  }) async {
    final configUrl = getBundleConfigUrl(bundleKey);
    if (configUrl.isEmpty) {
      _notifyFinish(bundleKey, false);
      return;
    }

    debugPrint('BundleManager: fetching config for bundle $bundleKey from $configUrl');

    late Map<String, dynamic> configData;

    http.Response? response;
    try {
      response = await _retry(
        () => _http
            .get(Uri.parse(configUrl))
            .timeout(const Duration(seconds: 15)),
        label: 'config $bundleKey',
      );
    } catch (e) {
      debugPrint('BundleManager: config network error for $bundleKey: $e');
      response = null;
    }

    if (response != null && response.statusCode == 200) {
      configData = jsonDecode(response.body) as Map<String, dynamic>;
      await _saveConfigLocal(bundleKey, response.body);
    } else {
      final local = await _loadConfigLocal(bundleKey);
      if (local != null) {
        debugPrint(
          'BundleManager: [$bundleKey] config trên CDN KHÔNG dùng được '
          '(${response == null ? 'lỗi mạng' : 'HTTP ${response.statusCode}'}) '
          '→ đang chạy bằng config CACHE LOCAL. Máy chưa có cache sẽ hỏng.',
        );
        configData = jsonDecode(local) as Map<String, dynamic>;
      } else if (response != null) {
        throw Exception('HTTP ${response.statusCode}');
      } else {
        throw Exception('Config fetch failed (offline, no local cache)');
      }
    }

    if (_isStale(bundleKey, gen)) return;

    final bundleConfig = _BundleConfigJson.fromJson(configData);
    _configs[bundleKey] = bundleConfig;

    _failedItems.remove(bundleKey);

    final totalItems = _countResources(bundleConfig);
    int completedCount = 0;

    final Completer<void> allDone = Completer<void>();
    int pendingAsync = 0;

    void onItemDone(String itemName, bool success) {
      completedCount++;
      if (!success) {
        debugPrint('BundleManager: item "$itemName" failed in bundle $bundleKey');
        (_failedItems[bundleKey] ??= <String>{}).add(itemName);
      } else {
        _failedItems[bundleKey]?.remove(itemName);
      }
      final progress = totalItems > 0 ? completedCount / totalItems : 1.0;
      _notifyProgress(bundleKey, progress);
      _notifyItem(bundleKey, itemName, success);

      if (completedCount >= totalItems && pendingAsync == 0 && !allDone.isCompleted) {
        if (!_isStale(bundleKey, gen)) {
          if (notifyFinish) {
            _finishBundle(bundleKey, true);
          } else {
            _markBundleLoaded(bundleKey);
          }
        }
        allDone.complete();
      }
    }

    if (bundleConfig.svg != null && bundleConfig.svg!.isNotEmpty) {
      pendingAsync++;
      _loadSvgSprite(
        bundleKey,
        bundleConfig.svg!,
        gen,
        onDone: (success) {
          pendingAsync--;
          onItemDone(bundleConfig.svg!, success);
        },
      );
    }

    for (final atlasName in bundleConfig.atlases) {
      pendingAsync++;
      _loadAtlas(
        bundleKey,
        atlasName,
        gen,
        onDone: (success) {
          pendingAsync--;
          onItemDone(atlasName, success);
        },
      );
    }

    final bool preloadImages = bundleKey != BundleDefines.dynamic;
    for (final image in bundleConfig.images) {
      if (!preloadImages) {
        _registerStandaloneFile(bundleKey, image, 'image');
        onItemDone(image, true);
        continue;
      }
      pendingAsync++;
      _loadStandaloneFile(
        bundleKey,
        image,
        'image',
        gen,
        onDone: (success) {
          pendingAsync--;
          onItemDone(image, success);
        },
      );
    }

    for (final other in bundleConfig.others) {
      pendingAsync++;
      _loadStandaloneFile(
        bundleKey,
        other,
        'other',
        gen,
        onDone: (success) {
          pendingAsync--;
          onItemDone(other, success);
        },
      );
    }

    if (pendingAsync == 0 && !allDone.isCompleted) {
      if (!_isStale(bundleKey, gen)) {
        if (notifyFinish) {
          _finishBundle(bundleKey, true);
        } else {
          _markBundleLoaded(bundleKey);
        }
      }
      allDone.complete();
    }

    await allDone.future.timeout(
      const Duration(seconds: 120),
      onTimeout: () {
        debugPrint('BundleManager: bundle $bundleKey load timed out after 120s');
        if (!_isStale(bundleKey, gen)) {
          if (notifyFinish) {
            _finishBundle(bundleKey, true);
          } else {
            _markBundleLoaded(bundleKey);
          }
        }
      },
    );

    debugPrint('BundleManager: loaded bundle $bundleKey with '
        '${_resourceLookup[bundleKey]?.length ?? 0} resources');
  }

  void _markBundleLoaded(String bundleKey) {
    _bundleLoaded[bundleKey] = true;
    _notifyProgress(bundleKey, 1.0);
  }

  void _finishBundle(String bundleKey, bool success) {
    _markBundleLoaded(bundleKey);
    _notifyFinish(bundleKey, success);
  }

  int _countResources(_BundleConfigJson config) {
    int count = 0;
    if (config.svg != null && config.svg!.isNotEmpty) count++;
    count += config.atlases.length;
    count += config.images.length;
    count += config.others.length;
    return count;
  }

  void _loadAtlas(
    String bundleKey,
    String atlasName,
    int gen, {
    required void Function(bool success) onDone,
  }) {
    _withSlot(() => _doLoadAtlas(bundleKey, atlasName, gen))
        .then((_) => onDone(true))
        .catchError((Object e, StackTrace st) {
      _reportError(bundleKey, atlasName, e, st);
      onDone(false);
    });
  }

  Future<void> _doLoadAtlas(String bundleKey, String atlasName, int gen) async {
    final baseUrl = _atlasBaseUrl(bundleKey, atlasName);
    final jsonUrl = '$baseUrl.json';
    final webpUrl = '$baseUrl.webp';

    final localAtlas = await _tryLoadAtlasFromLocal(jsonUrl, webpUrl);
    if (localAtlas != null) {
      if (_isStale(bundleKey, gen)) return;
      final atlasKey = _extractFilename(atlasName);
      (_atlases[bundleKey] ??= {})[atlasKey] = localAtlas;

      _registerAtlasFrames(bundleKey, atlasName, localAtlas.frames);
      _registerStandaloneFile(bundleKey, atlasName, 'atlas');
      return;
    }

    final Map<String, dynamic> jsonMap;
    Uint8List imageBytes;
    if (!kIsWeb) {
      final jsonFile = await _retry(
        () => AssetsCacheManager.getSingleFileForUrlWithVersioning(jsonUrl)
            .timeout(const Duration(seconds: 15)),
        label: 'atlas JSON $atlasName',
      );
      final webpFile = await _retry(
        () => AssetsCacheManager.getSingleFileForUrlWithVersioning(webpUrl)
            .timeout(const Duration(seconds: 30)),
        label: 'atlas webp $atlasName',
      );

      jsonMap = jsonDecode(await jsonFile.readAsString()) as Map<String, dynamic>;
      imageBytes = await webpFile.readAsBytes();
    } else {
      final jr = await _retry(
        () => _http
            .get(Uri.parse(jsonUrl))
            .timeout(const Duration(seconds: 15)),
        label: 'atlas JSON $atlasName',
      );
      if (jr.statusCode != 200) throw Exception('HTTP ${jr.statusCode}');

      final ir = await _retry(
        () => _http
            .get(Uri.parse(webpUrl))
            .timeout(const Duration(seconds: 30)),
        label: 'atlas webp $atlasName',
      );
      if (ir.statusCode != 200) throw Exception('HTTP ${ir.statusCode}');

      jsonMap = jsonDecode(jr.body) as Map<String, dynamic>;
      imageBytes = ir.bodyBytes;
    }

    final frames = SpriteAtlas.parseFrames(jsonMap);
    final image = await SpriteAtlas.decodeImage(imageBytes);
    final atlas = SpriteAtlas(image: image, frames: frames);

    if (_isStale(bundleKey, gen)) {
      atlas.dispose();
      return;
    }

    final atlasKey = _extractFilename(atlasName);
    (_atlases[bundleKey] ??= {})[atlasKey] = atlas;

    _registerAtlasFrames(bundleKey, atlasName, frames);

    _registerStandaloneFile(bundleKey, atlasName, 'atlas');
  }

  void _registerAtlasFrames(
    String bundleKey,
    String atlasName,
    Map<String, AtlasFrame> frames,
  ) {
    final bundleLookup = _resourceLookup.putIfAbsent(bundleKey, () => {});
    for (final entry in frames.entries) {
      final lookupKey = toLookupKey(entry.key);
      bundleLookup[lookupKey] = _BundleResourceInfo(
        fullFilename: entry.key,
        type: 'atlas_frame',
        packFile: atlasName,
      );
    }
  }

  void _loadSvgSprite(
    String bundleKey,
    String svgFilename,
    int gen, {
    required void Function(bool success) onDone,
  }) {
    _withSlot(() => _doLoadSvgSprite(bundleKey, svgFilename, gen))
        .then((_) => onDone(true))
        .catchError((Object e, StackTrace st) {
      _reportError(bundleKey, svgFilename, e, st);
      onDone(false);
    });
  }

  Future<void> _doLoadSvgSprite(
    String bundleKey,
    String svgFilename,
    int gen,
  ) async {
    final url = _fileUrl(bundleKey, svgFilename, 'svg_sprite');
    final String content;
    if (!kIsWeb) {
      final cached = await AssetsCacheManager.getCachedFileForUrlWithVersioning(url);
      if (cached != null && await cached.exists()) {
        content = await cached.readAsString();
      } else {
        final localFile = await _retry(
          () => AssetsCacheManager.getSingleFileForUrlWithVersioning(url)
              .timeout(const Duration(seconds: 15)),
          label: 'SVG sprite $svgFilename',
        );
        content = await localFile.readAsString();
      }
    } else {
      final response = await _retry(
        () => _http
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: 15)),
        label: 'SVG sprite $svgFilename',
      );
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }
      content = response.body;
    }

    if (content.length < 50) {
      throw Exception('SVG sprite content too short: ${content.length}');
    }

    final symbols = _parseSvgSymbols(content);

    if (_isStale(bundleKey, gen)) return;

    (_svgSymbols[bundleKey] ??= {}).addAll(symbols);

    _registerSvgSymbols(bundleKey, symbols);

    _registerStandaloneFile(bundleKey, svgFilename, 'svg_sprite');
  }

  Map<String, String> _parseSvgSymbols(String svgContent) {
    final map = <String, String>{};

    final rootDefs = _extractRootDefs(svgContent);

    final symbolRegex = RegExp(
      r'<symbol\b([^>]*)>(.*?)</symbol>',
      dotAll: true,
    );

    for (final match in symbolRegex.allMatches(svgContent)) {
      final attrs = match.group(1) ?? '';
      final inner = match.group(2) ?? '';

      final idMatch = RegExp(r'\bid="([^"]+)"').firstMatch(attrs);
      if (idMatch == null) continue;
      final id = idMatch.group(1)!;

      final vbMatch = RegExp(r'viewBox="([^"]*)"').firstMatch(attrs);
      final viewBox = vbMatch?.group(1) ?? '0 0 24 24';

      final inheritedAttrs = _extractInheritedAttrs(attrs);

      final defsBlock =
          rootDefs.isNotEmpty ? '\n  <defs>$rootDefs</defs>' : '';
      final wrapped = '''<svg xmlns="http://www.w3.org/2000/svg"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    viewBox="$viewBox"$inheritedAttrs>$defsBlock
  $inner
</svg>''';

      map[id] = wrapped;
    }

    return map;
  }

  static const List<String> _inheritedSvgAttrs = <String>[
    'fill',
    'stroke',
    'stroke-width',
    'stroke-linecap',
    'stroke-linejoin',
    'stroke-miterlimit',
    'stroke-dasharray',
    'stroke-dashoffset',
    'fill-rule',
    'clip-rule',
    'fill-opacity',
    'stroke-opacity',
    'color',
  ];

  String _extractInheritedAttrs(String symbolAttrs) {
    final buf = StringBuffer();
    for (final name in _inheritedSvgAttrs) {
      final m =
          RegExp('\\b${name.replaceAll('-', r'\-')}="([^"]*)"').firstMatch(symbolAttrs);
      if (m != null) buf.write(' $name="${m.group(1)}"');
    }
    return buf.toString();
  }

  String _extractRootDefs(String svgContent) {
    final defsRegex = RegExp(r'<defs\b[^>]*>(.*?)</defs>', dotAll: true);
    final buffer = StringBuffer();
    for (final m in defsRegex.allMatches(svgContent)) {
      buffer.write(m.group(1) ?? '');
    }
    return buffer.toString();
  }

  void _registerSvgSymbols(String bundleKey, Map<String, String> symbols) {
    final bundleLookup = _resourceLookup.putIfAbsent(bundleKey, () => {});
    for (final entry in symbols.entries) {
      bundleLookup[entry.key] = _BundleResourceInfo(
        fullFilename: entry.key,
        type: 'svg_symbol',
        packFile: _configs[bundleKey]?.svg,
      );
    }
  }

  void _loadStandaloneFile(
    String bundleKey,
    String filename,
    String type,
    int gen, {
    required void Function(bool success) onDone,
  }) {
    _withSlot(() => _doLoadStandaloneFile(bundleKey, filename, type, gen))
        .then((_) => onDone(true))
        .catchError((Object e, StackTrace st) {
      _reportError(bundleKey, filename, e, st);
      onDone(false);
    });
  }

  Future<void> _doLoadStandaloneFile(
    String bundleKey,
    String filename,
    String type,
    int gen,
  ) async {
    final url = _fileUrl(bundleKey, filename, type);
    if (url.isEmpty) throw Exception('Empty URL for $filename');

    if (kIsWeb &&
        !kWebPreloadDiscardableFiles &&
        !_isBytesUsedInProcess(filename)) {
      if (!_isStale(bundleKey, gen)) {
        _registerStandaloneFile(bundleKey, filename, type);
      }
      return;
    }

    final hasLocal = await _tryUseLocalStandaloneFile(url, filename, type);
    if (hasLocal) {
      if (!_isStale(bundleKey, gen)) {
        _registerStandaloneFile(bundleKey, filename, type);
      }
      return;
    }

    if (_isVideoFile(filename)) {
      final file = await _retry(
        () => VideoCacheManager.instance.getOrDownload(url)
            .timeout(const Duration(seconds: 30)),
        label: '$type $filename',
      );
      if (file == null) throw Exception('Video download failed: $filename');
    } else {
      final bytes = await _downloadBytes(url, '$type $filename');

      if (!kIsWeb) {
        await AssetsCacheManager.warmBytes(url, bytes);
      }

      if (filename.toLowerCase().endsWith('.riv')) {
        await RiveFileCache.warmFromBytes(url, bytes);
      }
    }

    if (_isStale(bundleKey, gen)) return;
    _registerStandaloneFile(bundleKey, filename, type);
  }

  void _registerStandaloneFile(String bundleKey, String filename, String type) {
    final bundleLookup = _resourceLookup.putIfAbsent(bundleKey, () => {});
    final lookupKey = toLookupKey(filename);
    bundleLookup[lookupKey] = _BundleResourceInfo(
      fullFilename: filename,
      type: type,
    );
  }

  ResourceResult? lookupResource(String filename) {
    final lookupKey = toLookupKey(filename);
    for (final entry in _resourceLookup.entries) {
      final bundleKey = entry.key;
      final info = entry.value[lookupKey];
      if (info == null) continue;

      return _buildResult(bundleKey, info);
    }
    return null;
  }

  ResourceResult? lookupResourceInBundle(String bundleKey, String filename) {
    final bundleLookup = _resourceLookup[bundleKey];
    if (bundleLookup == null) return null;

    final lookupKey = toLookupKey(filename);
    final info = bundleLookup[lookupKey];
    if (info == null) return null;

    return _buildResult(bundleKey, info);
  }

  ResourceResult _buildResult(String bundleKey, _BundleResourceInfo info) {
    switch (info.type) {
      case 'atlas_frame':
        final atlas =
            info.packFile != null ? _atlasIn(bundleKey, info.packFile!) : null;
        return ResourceResult(
          bundleKey: bundleKey,
          type: info.type,
          packFile: info.packFile,
          atlasFrame: atlas?.frame(info.fullFilename),
        );

      case 'svg_symbol':
        return ResourceResult(
          bundleKey: bundleKey,
          type: info.type,
          packFile: info.packFile,
          svgContent: _svgSymbols[bundleKey]?[info.fullFilename],
        );

      default:
        final url = _fileUrl(bundleKey, info.fullFilename, info.type);
        return ResourceResult(
          bundleKey: bundleKey,
          type: info.type,
          url: url,
        );
    }
  }

  bool hasResource(String filename) {
    final lookupKey = toLookupKey(filename);
    return _resourceLookup.values.any((map) => map.containsKey(lookupKey));
  }

  bool hasResourceInBundle(String bundleKey, String filename) {
    final bundleLookup = _resourceLookup[bundleKey];
    if (bundleLookup == null) return false;
    final lookupKey = toLookupKey(filename);
    return bundleLookup.containsKey(lookupKey);
  }

  String? findBundleByFilename(String filename) {
    final lookupKey = toLookupKey(filename);
    for (final entry in _resourceLookup.entries) {
      if (entry.value.containsKey(lookupKey)) return entry.key;
    }
    return null;
  }

  AtlasFrame? getAtlasFrame(String filename) {
    final result = lookupResource(filename);
    return result?.atlasFrame;
  }

  SpriteAtlas? getAtlasByPackFile(String packFile) {
    final atlasKey = _extractFilename(packFile);
    for (final byBundle in _atlases.values) {
      final atlas = byBundle[atlasKey];
      if (atlas != null) return atlas;
    }
    return null;
  }

  String? getSvgSymbol(String symbolId) {
    for (final byBundle in _svgSymbols.values) {
      final content = byBundle[symbolId];
      if (content != null) return content;
    }
    return null;
  }

  bool hasSvgSymbol(String symbolId) =>
      _svgSymbols.values.any((m) => m.containsKey(symbolId));

  Set<String> get svgSymbolIds =>
      {for (final m in _svgSymbols.values) ...m.keys};

  String? getResourceUrl(String bundleKey, String filename) {
    final result = lookupResourceInBundle(bundleKey, filename);
    return result?.url;
  }

  List<String> getRiveFiles(String bundleKey) {
    final config = _configs[bundleKey];
    if (config == null) return [];
    return config.others.where((f) => f.endsWith('.riv')).toList();
  }

  List<String> getRiveUrls(String bundleKey) {
    final files = getRiveFiles(bundleKey);
    return files.map((f) => _fileUrl(bundleKey, f, 'other')).toList();
  }

  List<String> getSoundFiles(String bundleKey) {
    final config = _configs[bundleKey];
    if (config == null) return [];
    return config.others.where((f) {
      final lower = f.toLowerCase();
      return lower.endsWith('.mp3')
          || lower.endsWith('.wav')
          || lower.endsWith('.ogg')
          || lower.endsWith('.aac');
    }).toList();
  }

  List<String> getSoundUrls(String bundleKey) {
    final files = getSoundFiles(bundleKey);
    return files.map((f) => _fileUrl(bundleKey, f, 'other')).toList();
  }

  List<String> getVideoFiles(String bundleKey) {
    final config = _configs[bundleKey];
    if (config == null) return [];
    return config.others.where((f) {
      final lower = f.toLowerCase();
      return lower.endsWith('.mp4')
          || lower.endsWith('.webm')
          || lower.endsWith('.mov')
          || lower.endsWith('.avi')
          || lower.endsWith('.mkv');
    }).toList();
  }

  List<String> getVideoUrls(String bundleKey) {
    final files = getVideoFiles(bundleKey);
    return files.map((f) => _fileUrl(bundleKey, f, 'other')).toList();
  }

  Future<File?> getSoundFile(String bundleKey, String filename) async {
    if (!_isSoundFile(filename)) return null;
    final url = _fileUrl(bundleKey, filename, 'other');
    if (url.isEmpty) return null;
    return AssetsCacheManager.getCachedFileForUrlWithVersioning(url);
  }

  Future<File?> getVideoFile(String bundleKey, String filename) async {
    if (!_isVideoFile(filename)) return null;
    final url = _fileUrl(bundleKey, filename, 'other');
    if (url.isEmpty) return null;
    return VideoCacheManager.instance.getCachedFile(url);
  }

  Future<File?> getOtherFile(String bundleKey, String filename) async {
    final url = _fileUrl(bundleKey, filename, 'other');
    if (url.isEmpty) return null;
    return AssetsCacheManager.getCachedFileForUrlWithVersioning(url);
  }

  ResourceResult? get(String filename) => lookupResource(filename);

  Future<File?> getLocalFile(String filename) async {
    final result = lookupResource(filename);
    if (result == null) return null;
    switch (result.type) {
      case 'image':
      case 'atlas':
      case 'svg_sprite':
      case 'other':
        if (result.url == null) return null;
        if (_isVideoFile(filename)) {
          return VideoCacheManager.instance.getCachedFile(result.url!);
        }
        return AssetsCacheManager.getCachedFileForUrlWithVersioning(result.url!);
      case 'svg_symbol':
        return null;
      case 'atlas_frame':
        return null;
    }
    return null;
  }

  Future<String?> getTextData(String filename, {String? bundleKey}) async {
    final result = bundleKey == null
        ? lookupResource(filename)
        : lookupResourceInBundle(bundleKey, filename);
    if (result == null) {
      debugPrint(
        '[Bundle Manager] getTextData: không tìm thấy $filename'
        '${bundleKey != null ? ' trong bundle $bundleKey' : ''}',
      );
      return null;
    }

    if (result.type == 'svg_symbol') return result.svgContent;
    if (result.type == 'atlas_frame') {
      debugPrint('[Bundle Manager] getTextData: $filename là atlas frame');
      return null;
    }

    final url = result.url;
    if (url == null || url.isEmpty) {
      debugPrint('[Bundle Manager] getTextData: $filename không có URL');
      return null;
    }

    if (!kIsWeb) {
      try {
        final file =
            await AssetsCacheManager.getCachedFileForUrlWithVersioning(url);
        if (file != null && await file.exists()) {
          return await file.readAsString();
        }
      } catch (e) {
        debugPrint(
          '[Bundle Manager] getTextData: đọc local $filename lỗi: $e '
          '→ tải mạng',
        );
      }
    }

    try {
      final bytes = await _downloadBytes(url, 'text $filename');
      if (!kIsWeb) {
        try {
          await AssetsCacheManager.warmBytes(url, bytes);
        } catch (_) {
        }
      }
      return utf8.decode(bytes);
    } catch (e) {
      debugPrint('[Bundle Manager] getTextData: tải $filename lỗi: $e');
      return null;
    }
  }

  String? getSvgContent(String symbolId) => getSvgSymbol(symbolId);

  ui.Image? getAtlasImage(String filename) {
    final result = lookupResource(filename);
    if (result == null || result.packFile == null) return null;
    final atlas = _atlasIn(result.bundleKey, result.packFile!);
    return atlas?.image;
  }

  SpriteAtlas? _atlasIn(String bundleKey, String packFile) =>
      _atlases[bundleKey]?[_extractFilename(packFile)];

  (ui.Image, AtlasFrame)? getAtlasImageAndFrame(String filename) {
    final result = lookupResource(filename);
    if (result == null || result.type != 'atlas_frame') return null;
    final atlas = _atlasIn(result.bundleKey, result.packFile!);
    final frame = result.atlasFrame;
    if (atlas == null || frame == null) return null;
    return (atlas.image, frame);
  }

  Future<void> releaseBundle(
    String bundleKey, {
    bool releaseRive = true,
  }) async {
    final bundleConfig = _configs[bundleKey];

    final memoryUrls = <String>[];

    if (bundleConfig != null) {
      final bundleAtlases = _atlases.remove(bundleKey);
      if (bundleAtlases != null) {
        for (final atlas in bundleAtlases.values) {
          atlas.dispose();
        }
      }
      for (final atlasName in bundleConfig.atlases) {
        final baseUrl = _atlasBaseUrl(bundleKey, atlasName);
        memoryUrls.add('$baseUrl.json');
        memoryUrls.add('$baseUrl.webp');
      }

      if (bundleConfig.svg != null) {
        _svgSymbols.remove(bundleKey);
        final svgUrl = _fileUrl(bundleKey, bundleConfig.svg!, 'svg_sprite');
        if (svgUrl.isNotEmpty) memoryUrls.add(svgUrl);
      }

      for (final image in bundleConfig.images) {
        final u = _fileUrl(bundleKey, image, 'image');
        if (u.isNotEmpty) memoryUrls.add(u);
      }

      for (final other in bundleConfig.others) {
        final url = _fileUrl(bundleKey, other, 'other');
        if (url.isEmpty) continue;
        final lower = other.toLowerCase();
        if (releaseRive && lower.endsWith('.riv')) {
          RiveFileCache.clearUrl(url);
        }
        memoryUrls.add(url);
      }
    }

    if (memoryUrls.isNotEmpty) {
      AssetsCacheManager.clearMemoryCacheForUrls(memoryUrls);
    }

    _loadProgressByBundle.remove(bundleKey)?.dispose();

    _generation.remove(bundleKey);

    _loadingByBundle.remove(bundleKey);
    _notifyFinish(bundleKey, false);

    _configs.remove(bundleKey);
    _bundleLoaded.remove(bundleKey);
    _failedBundles.remove(bundleKey);
    _resourceLookup.remove(bundleKey);

    bumpAssetsGeneration();
  }

  void dispose() {
    _http.close();
    _loadSlots.dispose();
    loadProgress.dispose();
  }

  void reset() {
    for (final byBundle in _atlases.values) {
      for (final atlas in byBundle.values) {
        atlas.dispose();
      }
    }
    _configs.clear();
    _bundleLoaded.clear();
    _failedBundles.clear();
    _resourceLookup.clear();
    _atlases.clear();
    _svgSymbols.clear();
    _subscribers.clear();
    _loadingByBundle.clear();
    _generation.clear();
    loadProgress.value = 0.0;
    for (final p in _loadProgressByBundle.values) {
      p.dispose();
    }
    _loadProgressByBundle.clear();
    _loadSlots.dispose();
    _http.close();
    _http = http.Client();
    _loadSlots = Semaphore(_maxConcurrentLoads);
    bumpAssetsGeneration();
  }

  Future<SpriteAtlas?> _tryLoadAtlasFromLocal(
    String jsonUrl,
    String webpUrl,
  ) async {
    if (kIsWeb) return null;
    try {
      final jsonFile = await AssetsCacheManager.getCachedFileForUrlWithVersioning(jsonUrl);
      final webpFile = await AssetsCacheManager.getCachedFileForUrlWithVersioning(webpUrl);
      if (jsonFile == null || webpFile == null) return null;
      if (!await jsonFile.exists() || !await webpFile.exists()) return null;

      final jsonMap = jsonDecode(await jsonFile.readAsString()) as Map<String, dynamic>;
      final frames = SpriteAtlas.parseFrames(jsonMap);
      final imageBytes = await webpFile.readAsBytes();
      final image = await SpriteAtlas.decodeImage(imageBytes);
      return SpriteAtlas(image: image, frames: frames);
    } catch (_) {
      return null;
    }
  }

  Future<bool> _tryUseLocalStandaloneFile(
    String url,
    String filename,
    String type,
  ) async {
    try {
      if (filename.toLowerCase().endsWith('.riv')) {
        if (RiveFileCache.contains(url)) return true;
        if (!kIsWeb) {
          final file = await AssetsCacheManager.getCachedFileForUrlWithVersioning(url);
          if (file != null && await file.exists()) {
            final bytes = await file.readAsBytes();
            await RiveFileCache.warmFromBytes(url, bytes);
            return true;
          }
        }
        return false;
      }

      if (_isVideoFile(filename)) {
        final file = await VideoCacheManager.instance.getCachedFile(url);
        return file != null && await file.exists();
      }

      if (kIsWeb) return false;

      if (type == 'image' || _isSoundFile(filename) || type == 'other') {
        final file = await AssetsCacheManager.getCachedFileForUrlWithVersioning(url);
        return file != null && await file.exists();
      }

      return false;
    } catch (_) {
      return false;
    }
  }

  Future<Uint8List> _downloadBytes(String url, String label) async {
    final response = await _retry(
      () => _http.get(Uri.parse(url)).timeout(const Duration(seconds: 30)),
      label: label,
    );
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
    return response.bodyBytes;
  }

  static final RegExp _hashRegex = RegExp(r'\.[0-9a-fA-F]{8,}(?=\.|$)');

  static String _extractFilename(String path) {
    final noQuery = path.split('?').first.split('#').first;
    final slash = noQuery.lastIndexOf('/');
    final basename = slash == -1 ? noQuery : noQuery.substring(slash + 1);
    final noHash = basename.replaceFirst(_hashRegex, '');
    final dot = noHash.lastIndexOf('.');
    return dot == -1 ? noHash : noHash.substring(0, dot);
  }

  static String toLookupKey(String filename) {
    return _extractFilename(filename);
  }

  static bool _isSoundFile(String filename) {
    final lower = filename.toLowerCase();
    return lower.endsWith('.mp3') ||
        lower.endsWith('.wav') ||
        lower.endsWith('.ogg') ||
        lower.endsWith('.aac');
  }

  static const bool kWebPreloadDiscardableFiles = false;

  static bool _isBytesUsedInProcess(String filename) =>
      filename.toLowerCase().endsWith('.riv');

  static bool _isVideoFile(String filename) {
    final lower = filename.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.webm') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.avi') ||
        lower.endsWith('.mkv');
  }

  static Future<T> _retry<T>(
    Future<T> Function() action, {
    int maxRetries = 3,
    String label = '',
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        return await action();
      } catch (e) {
        if (attempt >= maxRetries) {
          debugPrint('BundleManager: $label failed after $maxRetries attempts: $e');
          rethrow;
        }
        final delay = Duration(seconds: 1 << (attempt - 1));
        debugPrint('BundleManager: $label attempt $attempt/$maxRetries failed, retrying in ${delay.inSeconds}s...');
        await Future<void>.delayed(delay);
      }
    }
    throw Exception('$label: retry exhausted');
  }
}
