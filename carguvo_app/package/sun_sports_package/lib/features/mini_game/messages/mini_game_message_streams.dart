import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../socket/enums.dart';
import '../socket/mini_game_socket_providers.dart';
import 'slot_message.dart';
import 'tai_xiu_message.dart';
import 'tren_duoi_message.dart';

final Logger _miniGameRouteLogger = Logger();

final taiXiuMessageStreamProvider = StreamProvider<TaiXiuMessage>((ref) async* {
  final client = await ref.watch(miniGameSocketClientProvider.future);
  await for (final raw in client.messageStream) {
    if (raw.type != MessageResponse.extensionResponse.code) continue;
    final isTaiXiu =
        (raw.cmd >= 1000 && raw.cmd < 1100) ||
        (raw.cmd >= 2000 && raw.cmd < 2100);
    if (!isTaiXiu) continue;
    if (raw.cmd == 1005 || raw.cmd == 2000) {
    }
    try {
      yield parseTaiXiuMessage(raw.payload);
    } on UnimplementedError {
      _miniGameRouteLogger.w(
        '[MiniGameRoute] tai_xiu_unhandled_cmd cmd=${raw.cmd}',
      );
    } catch (e, st) {
      _miniGameRouteLogger.e(
        '[MiniGameRoute] tai_xiu_parse_failed cmd=${raw.cmd}',
        error: e,
        stackTrace: st,
      );
    }
  }
});

final trenDuoiMessageStreamProvider = StreamProvider.autoDispose<TrenDuoiMessage>((
  ref,
) async* {
  final client = await ref.watch(miniGameSocketClientProvider.future);
  await for (final raw in client.messageStream) {
    if (raw.type != MessageResponse.extensionResponse.code) continue;
    if (raw.cmd < 1500 || raw.cmd > 1599) continue;
    try {
      yield parseTrenDuoiMessage(raw.payload);
    } on UnimplementedError {
    }
  }
});

final slotMessageStreamProvider =
    StreamProvider.autoDispose.family<SlotMessage, SlotGameId>((ref, game) async* {
      final client = await ref.watch(miniGameSocketClientProvider.future);
      await for (final raw in client.messageStream) {
        if (raw.type != MessageResponse.extensionResponse.code) continue;
        if (raw.cmd < 1300 || raw.cmd > 1399) continue;
        final gid = (raw.payload['gid'] as num?)?.toInt();
        if (gid != game.code) continue;
        try {
          yield parseSlotMessage(raw.payload, game);
        } on UnimplementedError {
        }
      }
    });
