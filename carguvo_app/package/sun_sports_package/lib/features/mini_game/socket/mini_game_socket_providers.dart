import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/services/auth/token_error_handler.dart';

import '../auth/mini_game_auth_providers.dart';
import '../config/mini_game_config_providers.dart';
import 'mini_game_active_scopes.dart';
import 'mini_game_kick_bus.dart';
import 'mini_game_message_codec.dart';
import 'mini_game_socket_client.dart';
import 'mini_game_socket_state.dart';

final miniGameMessageCodecProvider = Provider<MiniGameMessageCodec>((ref) {
  return const JsonMessageCodec();
});

final miniGameActiveScopesProvider = Provider<MiniGameActiveScopes>((ref) {
  return MiniGameActiveScopes();
});

const int _miniPingSeconds = int.fromEnvironment(
  'MINI_PING_SECONDS',
  defaultValue: 5,
);

final miniGameSocketClientProvider = FutureProvider<MiniGameSocketClient>((ref) async {
  final url = ref.watch(miniGameWsUrlProvider);
  final codec = ref.watch(miniGameMessageCodecProvider);
  final auth = await ref.watch(miniGameAuthProvider.future);

  final client = MiniGameSocketClient(
    url: url,
    auth: auth,
    codec: codec,
    readAuth: () => ref.read(miniGameAuthServiceProvider).read(),
    refreshCredentials: () =>
        TokenErrorHandler.instance.handleTokenError(closeGameOnFail: false),
    scopes: ref.watch(miniGameActiveScopesProvider),
    pingInterval: const Duration(seconds: _miniPingSeconds),
  );

  ref.onDispose(() {
    client.dispose();
  });

  return client;
});

final miniGameKickStreamProvider = StreamProvider<String>((ref) {
  return MiniGameKickBus.instance.stream;
});

final miniGameSocketStateProvider = StreamProvider<MiniGameSocketState>((ref) async* {
  final client = await ref.watch(miniGameSocketClientProvider.future);
  yield client.state;
  yield* client.stateStream;
});

final miniGameRawStreamProvider = StreamProvider<RawMessage>((ref) async* {
  final client = await ref.watch(miniGameSocketClientProvider.future);
  yield* client.messageStream;
});
