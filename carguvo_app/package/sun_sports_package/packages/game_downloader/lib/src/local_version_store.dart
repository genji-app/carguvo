import 'package:hive_flutter/hive_flutter.dart';

import 'exceptions.dart';

class LocalVersionStore {
  static const String _boxName = 'game_versions';
  Box<String>? _box;

  Future<Box<String>> _ensureBox() async {
    if (_box != null && _box!.isOpen) return _box!;
    await Hive.initFlutter();
    _box = await Hive.openBox<String>(_boxName);
    return _box!;
  }

  Future<String?> getLocalVersion(String gameName) async {
    try {
      final box = await _ensureBox();
      return box.get(gameName);
    } catch (error) {
      throw CacheException(error.toString());
    }
  }

  Future<void> saveLocalVersion(String gameName, String version) async {
    try {
      final box = await _ensureBox();
      await box.put(gameName, version.trim());
    } catch (error) {
      throw CacheException(error.toString());
    }
  }

  Future<void> deleteVersion(String gameName) async {
    try {
      final box = await _ensureBox();
      await box.delete(gameName);
    } catch (error) {
      throw CacheException(error.toString());
    }
  }
}
