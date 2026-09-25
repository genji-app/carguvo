import 'dart:convert';

import 'package:app_env/app_env.dart'
    show casinoRecentGameKey, kRecentListMaxItems, pushRecent;
import 'package:hive_flutter/hive_flutter.dart';

class CasinoRecentGamesStorage {
  CasinoRecentGamesStorage._();

  static const String _boxName = 'casino_recent_games';
  static const String _keyList = 'keys';
  static const int maxItems = kRecentListMaxItems;

  static Box<String>? _box;

  static Future<void> init() async {
    if (_box != null) return;
    await Hive.initFlutter();
    _box = await Hive.openBox<String>(_boxName);
  }

  static Box<String> get _b {
    if (_box == null) {
      throw StateError('CasinoRecentGamesStorage chưa init. Gọi init() trước.');
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

  static Future<List<String>> getKeys() async {
    final raw = _b.get(_keyList);
    final list = _decode(raw);
    return list.take(maxItems).toList();
  }

  static Future<void> addGame(
    String providerId,
    String productId,
    String gameCode,
  ) async {
    final key = casinoRecentGameKey(providerId, productId, gameCode);
    await _b.put(
      _keyList,
      _encode(pushRecent(_decode(_b.get(_keyList)), key)),
    );
  }
}
