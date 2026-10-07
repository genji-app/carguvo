import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

class SbConfigCache {
  SbConfigCache._();

  static const String _boxName = 'sb_config_cache';

  static const String _keyEvents = '__events';

  static Box<String>? _box;
  static bool _opening = false;

  static const String eventOk = 'ok';
  static const String eventFallback = 'fallback_used';
  static const String eventInvalid = 'invalid';

  static Future<void> init() async {
    if (_box != null || _opening) return;
    _opening = true;
    try {
      await Hive.initFlutter();
      _box = await Hive.openBox<String>(_boxName);
    } finally {
      _opening = false;
    }
  }

  static Box<String>? get _b {
    if (_box != null) return _box;
    if (!_opening) {
      _opening = true;
      Hive.initFlutter()
          .then((_) => Hive.openBox<String>(_boxName))
          .then((box) => _box = box)
          .whenComplete(() => _opening = false);
    }
    return null;
  }

  static Future<void> remember(String url, Map<String, dynamic> data) async {
    final box = _b;
    if (box == null) return;
    try {
      await box.put(
        url,
        jsonEncode({'data': data, 'savedAt': DateTime.now().toIso8601String()}),
      );
      await _addEvent(url, eventOk);
    } catch (_) {
    }
  }

  static Future<void> rememberInvalid(String url, String rawSample) async {
    final box = _b;
    if (box == null) return;
    try {
      await box.put(
        '$url::invalid',
        jsonEncode({
          'raw': rawSample.length > 500 ? rawSample.substring(0, 500) : rawSample,
          'savedAt': DateTime.now().toIso8601String(),
        }),
      );
      await _addEvent(url, eventInvalid);
    } catch (_) {}
  }

  static Future<Map<String, dynamic>?> recall(String url) async {
    final box = _b;
    if (box == null) return null;
    try {
      final raw = box.get(url);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      final data = decoded['data'];
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> markFallback(String url) =>
      _addEvent(url, eventFallback);

  static Future<void> _addEvent(String url, String status) async {
    final box = _b;
    if (box == null) return;
    try {
      final events = _decodeEvents(box.get(_keyEvents));
      events.add({
        'url': url,
        'status': status,
        'at': DateTime.now().toIso8601String(),
      });
      if (events.length > 50) {
        events.removeRange(0, events.length - 50);
      }
      await box.put(_keyEvents, jsonEncode(events));
    } catch (_) {}
  }

  static List<Map<String, dynamic>> takeDiagnostics() {
    final box = _b;
    if (box == null) return [];
    try {
      final events = _decodeEvents(box.get(_keyEvents));
      if (events.isNotEmpty) {
        box.delete(_keyEvents);
        for (final e in events) {
          if (e['status'] == eventInvalid) {
            box.delete('${e['url']}::invalid');
          }
        }
      }
      return events;
    } catch (_) {
      return [];
    }
  }

  static List<Map<String, dynamic>> _decodeEvents(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw);
      if (list is List) {
        return list.whereType<Map<dynamic, dynamic>>().map(Map<String, dynamic>.from).toList();
      }
    } catch (_) {}
    return [];
  }
}
