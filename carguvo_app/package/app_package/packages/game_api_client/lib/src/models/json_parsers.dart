part of 'models.dart';

int _parseInt(dynamic val) {
  if (val is int) return val;
  if (val is num) return val.toInt();
  if (val is String) return int.tryParse(val) ?? 0;
  return 0;
}

num _parseNum(dynamic val) {
  if (val is num) return val;
  if (val is String) return num.tryParse(val) ?? 0;
  return 0;
}

bool _parseBool(dynamic val) {
  if (val is bool) return val;
  if (val is num) return val == 1;
  if (val is String) {
    final lower = val.toLowerCase().trim();
    return lower == 'true' || lower == '1';
  }
  return false;
}
