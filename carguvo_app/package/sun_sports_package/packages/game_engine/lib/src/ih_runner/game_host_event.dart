import 'dart:convert';

class GameHostEvent {
  const GameHostEvent({
    required this.type,
    this.data = const {},
    this.source,
    this.raw,
  });

  factory GameHostEvent.fromJson(dynamic input) {
    if (input == null) return const GameHostEvent(type: '');

    if (input is Map) {
      final map = input.cast<String, dynamic>();
      return GameHostEvent(
        type: map['type'] as String? ?? '',
        data: (map['data'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{},
        source: map['source'] as String?,
        raw: map['raw'] as String? ?? jsonEncode(map),
      );
    }

    final rawStr = input.toString().trim();

    if (rawStr.startsWith('{')) {
      try {
        final decoded = jsonDecode(rawStr);
        if (decoded is Map) {
          final map = decoded.cast<String, dynamic>();
          return GameHostEvent(
            type: map['type'] as String? ?? '',
            data: (map['data'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{},
            source: map['source'] as String?,
            raw: rawStr,
          );
        }
      } catch (_) {
        return const GameHostEvent(type: '');
      }
    }

    return GameHostEvent(type: rawStr, raw: rawStr);
  }

  final String type;

  final Map<String, dynamic> data;

  final String? source;

  final String? raw;

  bool get isCloseWebView {
    final t = type.toLowerCase();
    return t == 'closewebview' || t == 'exit_game' || t == 'backtoapp';
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'data': data,
        if (source != null) 'source': source,
      };

  String encode() => jsonEncode(toJson());

  @override
  String toString() => 'GameHostEvent(type: $type, data: $data, source: $source)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameHostEvent &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          data.toString() == other.data.toString() &&
          source == other.source;

  @override
  int get hashCode => type.hashCode ^ data.hashCode ^ source.hashCode;
}
