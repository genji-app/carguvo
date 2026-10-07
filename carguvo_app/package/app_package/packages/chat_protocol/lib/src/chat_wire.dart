library;

import 'dart:convert';

import 'package:clock/clock.dart';

class ChatWsCommand {
  ChatWsCommand._();

  static const String login = 'login';
  static const String fetchChatBox = 'fetchChatBox';
  static const String chat = 'chat';
  static const String error = 'error';
}

Map<String, Object?> buildChatLoginPayload(String accessToken, String wsToken) =>
    {'command': ChatWsCommand.login, 'accessToken': accessToken, 'wsToken': wsToken};

Map<String, Object?> buildChatHistoryPayload(String roomName) =>
    {'command': ChatWsCommand.fetchChatBox, 'roomName': roomName};

Map<String, Object?> buildChatSendPayload(String roomName, String text) => {
  'command': ChatWsCommand.chat,
  'roomName': roomName,
  'message': jsonEncode({'chatContent': text}),
};

List<Object?> buildChatPingPayload(String zone, int pingId) => [7, zone, pingId, 0];

String unwrapChatContent(String messageJson) {
  var content = messageJson;
  try {
    if (messageJson.startsWith('{')) {
      final parsed = jsonDecode(messageJson);
      if (parsed is Map) {
        final inner = parsed['chatContent'];
        if (inner is String) content = inner;
      }
    }
  } catch (_) {
  }
  return content;
}

int chatRecoverBackoffSeconds(
  int attempts, {
  required int baseSeconds,
  required int maxSeconds,
}) {
  final exp = (attempts - 1).clamp(0, 5);
  return (baseSeconds * (1 << exp)).clamp(baseSeconds, maxSeconds);
}

Duration chatProactiveRefreshDelay({
  required DateTime? tokenExpiry,
  required Duration leadTime,
  required Duration minDelay,
  required Duration fallback,
  DateTime? now,
}) {
  final exp = tokenExpiry;
  if (exp == null) return fallback;
  final lead = exp.difference(now ?? clock.now()) - leadTime;
  return lead > minDelay ? lead : minDelay;
}
