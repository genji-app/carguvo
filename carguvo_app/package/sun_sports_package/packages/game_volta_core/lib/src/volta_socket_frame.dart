import 'dart:convert';

import 'package:meta/meta.dart';

import 'volta_socket_config.dart';
import 'volta_wire.dart';

@immutable
sealed class VoltaSocketFrame {
  const VoltaSocketFrame();
}

@immutable
class VoltaPongFrame extends VoltaSocketFrame {
  const VoltaPongFrame(this.value);

  final int value;
}

@immutable
class VoltaDataFrame extends VoltaSocketFrame {
  const VoltaDataFrame(this.events);

  final List<VoltaWireEvent> events;
}

@immutable
class VoltaDroppedFrame extends VoltaSocketFrame {
  const VoltaDroppedFrame(this.reason, {this.corrupt = false});

  final String reason;

  final bool corrupt;
}

class VoltaSocketFrameCodec {
  const VoltaSocketFrameCodec({this.config = const VoltaSocketConfig()});

  final VoltaSocketConfig config;

  VoltaSocketFrame decode(dynamic raw) {
    final Object? node = _parse(raw);
    if (node == null) {
      return const VoltaDroppedFrame('không parse được JSON', corrupt: true);
    }

    final VoltaSocketFrame? pong = _asPong(node);
    if (pong != null) return pong;

    if (node is! Map) {
      return const VoltaDroppedFrame('khung không phải object', corrupt: true);
    }
    final Map<Object?, Object?> body = node;

    final String type = '${body['t'] ?? ''}';
    if (!config.acceptedTypes.contains(type)) {
      return VoltaDroppedFrame('t="$type" không thuộc tập quan tâm');
    }

    final Object? payload = _parse(body['d']);
    if (payload is! List) {
      return const VoltaDroppedFrame('trường d không phải mảng', corrupt: true);
    }

    final List<VoltaWireEvent> events = VoltaWire.decodeLeagues(payload);
    if (events.isEmpty) {
      return const VoltaDroppedFrame('không có ván nào của giải Volta');
    }
    return VoltaDataFrame(events);
  }

  VoltaSocketFrame? _asPong(Object? node) {
    if (node is Map) {
      final Object? value = node['pong'];
      final int? number = _int(value);
      if (number != null && number > 0) return VoltaPongFrame(number);
      return null;
    }

    if (!config.detectArrayPong) return null;
    if (node is List && node.isNotEmpty) {
      final int? head = _int(node.first);
      if (head != null && head == config.arrayPongCommand) {
        return VoltaPongFrame(head);
      }
    }
    return null;
  }

  static Object? _parse(dynamic raw) {
    Object? node = raw;
    for (int depth = 0; depth < 2 && node is String; depth++) {
      final String text = node.trim();
      if (text.isEmpty) return null;
      if (!text.startsWith('{') && !text.startsWith('[')) return text;
      try {
        node = jsonDecode(text);
      } on FormatException {
        return null;
      }
    }
    return node;
  }

  static int? _int(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }
}
