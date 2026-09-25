import 'dart:convert';

import 'package:app_env/app_env.dart'
    show kRecentListMaxItems, pushRecent;
import 'package:hive_flutter/hive_flutter.dart';

class SearchRecentStorage {
  SearchRecentStorage._();

  static const String _boxName = 'search_recent';
  static const String _keySport = 'keywords_sport';
  static const String _keyCasino = 'keywords_casino';
  static const int maxItems = kRecentListMaxItems;

  static Box<String>? _box;

  static Future<void> init() async {
    if (_box != null) return;
    await Hive.initFlutter();
    _box = await Hive.openBox<String>(_boxName);
  }

  static Box<String> get _b {
    if (_box == null) {
      throw StateError(
        'SearchRecentStorage chưa init. Gọi SearchRecentStorage.init() trước.',
      );
    }
    return _box!;
  }

  static List<String> _decode(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>?;
      return list
              ?.map((e) => e.toString())
              .where((s) => s.isNotEmpty)
              .toList() ??
          [];
    } catch (_) {
      return [];
    }
  }

  static String _encode(List<String> list) => jsonEncode(list);

  static List<String> _getList(String key) => _decode(_b.get(key));
  static Future<void> _putList(String key, List<String> list) async =>
      _b.put(key, _encode(list));

  static Future<List<String>> getRecentSport() async => _getList(_keySport);

  static Future<List<String>> getRecentCasino() async => _getList(_keyCasino);

  static Future<void> addRecentSport(String keyword) async {
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) return;
    await _putList(
        _keySport, pushRecent(_getList(_keySport), trimmed, caseInsensitive: true));
  }

  static Future<void> addRecentCasino(String keyword) async {
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) return;
    await _putList(
        _keyCasino, pushRecent(_getList(_keyCasino), trimmed, caseInsensitive: true));
  }

  static Future<void> removeRecentSport(String keyword) async {
    final list = _getList(_keySport);
    list.remove(keyword.trim());
    await _putList(_keySport, list);
  }

  static Future<void> removeRecentCasino(String keyword) async {
    final list = _getList(_keyCasino);
    list.remove(keyword.trim());
    await _putList(_keyCasino, list);
  }
}
