import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider_game_manager/provider_game_manager.dart';
import 'package:sun_sports/core/services/provider_game/lobby_game_config_loader.dart';
import 'package:sun_sports/core/services/provider_game/provider_game_providers.dart';

enum GameLobbyStatus {
  loading,

  success,

  failure,
}

@immutable
class GameLobbyState {
  const GameLobbyState({
    this.status = GameLobbyStatus.loading,
    this.lobbyBlocks = const <LobbyBlock>[],
  });

  final GameLobbyStatus status;

  final List<LobbyBlock> lobbyBlocks;

  bool get isLoading => status == GameLobbyStatus.loading;
  bool get isFailure => status == GameLobbyStatus.failure;
  bool get isSuccess => status == GameLobbyStatus.success;
}

final gameLobbyProvider = Provider.autoDispose<GameLobbyState>((ref) {
  final ready = ref.watch(lobbyConfigReadyProvider);
  return ready.when(
    loading: () => const GameLobbyState(),
    error: (_, __) => const GameLobbyState(status: GameLobbyStatus.failure),
    data: (loaded) => loaded
        ? GameLobbyState(
            status: GameLobbyStatus.success,
            lobbyBlocks: ref.watch(lobbyBlocksProvider),
          )
        : const GameLobbyState(status: GameLobbyStatus.failure),
  );
});

Future<void> refreshGameLobby(WidgetRef ref) async {
  await LobbyGameConfigLoader.load(force: true);
  ref.invalidate(lobbyConfigReadyProvider);
}
