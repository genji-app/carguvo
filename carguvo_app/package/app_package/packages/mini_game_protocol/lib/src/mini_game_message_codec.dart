import 'dart:convert';

import 'enums.dart';

class RawMessage {
  final int type;

  final int cmd;
  final Map<String, dynamic> payload;

  const RawMessage({
    required this.type,
    required this.cmd,
    required this.payload,
  });
}

abstract class MiniGameMessageCodec {
  Object encode(List<Object?> message);

  RawMessage decode(Object data);
}

class JsonMessageCodec implements MiniGameMessageCodec {
  const JsonMessageCodec();

  @override
  Object encode(List<Object?> message) => jsonEncode(message);

  @override
  RawMessage decode(Object data) {
    final list = jsonDecode(data as String) as List;
    if (list.isEmpty) {
      throw const FormatException('Empty WS message');
    }
    final type = (list[0] as num).toInt();
    Map<String, dynamic> payload = const {};
    int cmd = 0;

    for (var i = 1; i < list.length; i++) {
      final item = list[i];
      if (item is Map && item['cmd'] != null) {
        payload = Map<String, dynamic>.from(item);
        cmd = _cmdOf(payload['cmd']);
        break;
      }
    }

    if (payload.isEmpty && list.length > 1 && list[1] is Map) {
      payload = Map<String, dynamic>.from(list[1] as Map);
      cmd = _cmdOf(payload['cmd']);
    } else if (type == MessageResponse.pingResponse.code && list.length > 1) {
      payload = {'pingId': list[1]};
    }

    return RawMessage(type: type, cmd: cmd, payload: payload);
  }

  static int _cmdOf(dynamic raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw) ?? 0;
    return 0;
  }
}

class BinaryMessageCodec implements MiniGameMessageCodec {
  const BinaryMessageCodec();

  @override
  Object encode(List<Object?> message) {
    throw UnimplementedError(
      'Binary (MessagePack) codec deferred to Phase 2. '
      'Use JsonMessageCodec or set useWSJSON=true in remote config.',
    );
  }

  @override
  RawMessage decode(Object data) {
    throw UnimplementedError('Binary (MessagePack) codec deferred to Phase 2.');
  }
}
