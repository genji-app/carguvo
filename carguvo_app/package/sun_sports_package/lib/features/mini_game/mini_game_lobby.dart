import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import 'messages/mini_game_senders.dart';
import 'socket/mini_game_kick_bus.dart';
import 'socket/mini_game_socket_client.dart';
import 'socket/mini_game_socket_providers.dart';
import 'socket/mini_game_socket_state.dart';

final Logger _miniGameLobbyLogger = Logger();

final miniGameLobbyProvider = FutureProvider<MiniGameSocketClient>((ref) async {
  final client = await ref.watch(miniGameSocketClientProvider.future);
  var subscribed = false;

  final StreamSubscription<MiniGameSocketState> sub = client.stateStream.listen(
    (state) {
      if (state is SocketAuthenticated && !subscribed) {
        subscribed = true;
        _subscribeBadgeFeeds(client);
      } else if (state is SocketConnecting ||
          state is SocketReconnecting ||
          state is SocketDisconnected) {
        subscribed = false;
      }
    },
  );
  ref.onDispose(sub.cancel);

  final StreamSubscription<String> kickSub = client.kickStream.listen(
    MiniGameKickBus.instance.emit,
  );
  ref.onDispose(kickSub.cancel);

  await client.connect();
  return client;
});

void _subscribeBadgeFeeds(MiniGameSocketClient client) {
  _miniGameLobbyLogger.i('[MiniGameLobby] subscribe_taixiu cmd=1005');
  TaiXiuSender(client).subscribe();
}
