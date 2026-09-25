import 'package:game_foundation/game_foundation.dart';
export 'package:game_foundation/game_foundation.dart' show AssetStorage;

import 'package:hive_flutter/hive_flutter.dart';
import 'package:sun_sports/core/utils/extensions/log_helper.dart';

class HiveAssetStorage with LoggerMixin implements AssetStorage {
  HiveAssetStorage({this.boxName = 'caxilo_resource_assets'});

  final String boxName;
  LazyBox<String>? _box;
  bool _isInitialized = false;
  Future<void>? _initFuture;

  @override
  String get logTag => 'HiveAssetStorage';

  @override
  Future<void> init() async {
    _initFuture ??= _doInit();
    return _initFuture;
  }

  Future<void> _doInit() async {
    if (_isInitialized) return;
    try {
      await Hive.initFlutter();
      _box = await Hive.openLazyBox<String>(boxName);
      _isInitialized = true;
      logInfo('Box $boxName opened successfully.');
    } catch (e, stack) {
      logError('Failed to initialize Hive box $boxName', e, stack);
      _isInitialized = false;
    }
  }

  @override
  Future<String?> read(String key) async {
    if (!_isInitialized) await init();
    if (_box == null) return null;
    try {
      return await _box!.get(key);
    } catch (e, stack) {
      logError('Reading key $key failed', e, stack);
      return null;
    }
  }

  @override
  Future<void> write(String key, String value) async {
    if (!_isInitialized) await init();
    if (_box == null) return;
    try {
      await _box!.put(key, value);
    } catch (e, stack) {
      logError('Writing key $key failed', e, stack);
    }
  }

  @override
  Future<void> clearAll() async {
    if (!_isInitialized) await init();
    if (_box == null) return;
    try {
      await _box!.clear();
    } catch (e, stack) {
      logError('Clearing database failed', e, stack);
    }
  }
}
