import 'dart:convert';

import 'chat_wire.dart';

bool dispatchChatFrame(
  String raw, {
  required void Function() onLogin,
  required void Function(Map<String, dynamic> data) onHistory,
  required void Function(Map<String, dynamic> data) onChat,
  required void Function(String? message) onError,
  void Function(int pongId)? onPong,
  void Function(String? command)? onUnknown,
  void Function(Object error)? onParseError,
}) {
  final dynamic decoded;
  try {
    decoded = jsonDecode(raw);
  } catch (e) {
    onParseError?.call(e);
    return false;
  }

  if (decoded is! Map) {
    if (onPong != null && decoded is List && decoded.isNotEmpty && decoded[0] == 6) {
      onPong(decoded.length > 1 ? decoded[1] as int? ?? 0 : 0);
    }
    return true;
  }

  if (onPong != null && decoded.containsKey('pong')) {
    onPong(decoded['pong'] as int? ?? 0);
    return true;
  }

  final String? command = decoded['command']?.toString();
  switch (command) {
    case ChatWsCommand.login:
      onLogin();
    case ChatWsCommand.fetchChatBox:
      onHistory(Map<String, dynamic>.from(decoded));
    case ChatWsCommand.chat:
      onChat(Map<String, dynamic>.from(decoded));
    case ChatWsCommand.error:
      onError(decoded['message']?.toString());
    default:
      onUnknown?.call(command);
  }
  return true;
}
