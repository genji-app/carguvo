import 'package:meta/meta.dart';

@immutable
class ExtractedKey {
  final String key;

  final String type;

  final String raw;

  final int? sportId;

  final int? eventId;

  final int? leagueId;

  final int? marketId;

  final bool isBatch;

  const ExtractedKey({
    required this.key,
    required this.type,
    required this.raw,
    this.sportId,
    this.eventId,
    this.leagueId,
    this.marketId,
    this.isBatch = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtractedKey &&
          runtimeType == other.runtimeType &&
          key == other.key;

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() {
    return 'ExtractedKey(key: $key, type: $type, sportId: $sportId)';
  }
}

@immutable
class ParsedMessage {
  final String type;

  final int sportId;

  final Map<String, dynamic> data;

  final String raw;

  final DateTime timestamp;

  const ParsedMessage({
    required this.type,
    required this.sportId,
    required this.data,
    required this.raw,
    required this.timestamp,
  });

  int? getInt(String key) {
    final value = data[key];
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }

  String? getString(String key) {
    final value = data[key];
    if (value == null) return null;
    return value.toString();
  }

  bool getBool(String key, {bool defaultValue = false}) {
    final value = data[key];
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return defaultValue;
  }

  double? getDouble(String key) {
    final value = data[key];
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    if (value is num) return value.toDouble();
    return null;
  }

  Map<String, dynamic>? getMap(String key) {
    final value = data[key];
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  List<dynamic>? getList(String key) {
    final value = data[key];
    if (value == null) return null;
    if (value is List) return value;
    return null;
  }

  @override
  String toString() {
    return 'ParsedMessage(type: $type, sportId: $sportId)';
  }
}
