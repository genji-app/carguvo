import 'package:game_api_client/game_api_client.dart';
import 'package:provider_game_manager/provider_game_manager.dart'
    hide CardLastJoinSession, buildCardLastJoinSession;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/services/provider_game/provider_game_providers.dart';
import 'package:sun_sports/core/services/provider_game/game_api_client_provider.dart';
import 'package:sun_sports/features/game/last_join/card_last_join_session.dart';
import 'package:sun_sports/core/utils/extensions/log_helper.dart';
import 'package:sun_sports/features/game/launcher/game_launcher.dart';
import 'package:sun_sports/providers/auth_provider.dart';

import 'game_last_join_state.dart';

final gameLastJoinProvider =
    StateNotifierProvider<GameLastJoinNotifier, GameLastJoinState>((ref) {
      return GameLastJoinNotifier(
        ref: ref,
        client: ref.watch(gameApiClientProvider),
        manager: ref.watch(providerGameManagerProvider),
      );
    });

class GameLastJoinNotifier extends StateNotifier<GameLastJoinState>
    with LoggerMixin {
  GameLastJoinNotifier({
    required Ref ref,
    required GameApiClient client,
    required ProviderGameManager manager,
  }) : _ref = ref,
       _client = client,
       _manager = manager,
       super(const GameLastJoinInitial());

  final Ref _ref;
  final GameApiClient _client;
  final ProviderGameManager _manager;

  @override
  String get logTag => 'GameLastJoin';

  static bool isEnabled = true;

  static bool debugForceFake = false;

  static int debugFakeGameId = 8;

  void debugSetFakeSession({
    int gameId = 8,
    int roomId = 9999,
    int serverId = 1,
    String password = '',
    bool enable = true,
  }) {
    debugForceFake = enable;
    debugFakeGameId = gameId;
    if (enable) {
      final session = buildCardLastJoinSession(
        manager: _manager,
        gameId: gameId,
        roomId: roomId,
        serverId: serverId,
        password: password,
      );
      if (session != null) {
        logInfo(
          'debugSetFakeSession: gameId=$gameId, roomId=$roomId, serverId=$serverId, password=$password',
        );
        state = GameLastJoinAvailable(session: session);
      }
    } else {
      logInfo('debugSetFakeSession: disabled');
      state = const GameLastJoinNone();
    }
  }

  void debugSetFakeTienLen({
    bool enable = true,
    int roomId = 9999,
    int serverId = 1,
    String password = '',
  }) => debugSetFakeSession(
    gameId: 1,
    roomId: roomId,
    serverId: serverId,
    password: password,
    enable: enable,
  );

  void debugSetFakePhom({
    bool enable = true,
    int roomId = 9999,
    int serverId = 1,
    String password = '',
  }) => debugSetFakeSession(
    gameId: 8,
    roomId: roomId,
    serverId: serverId,
    password: password,
    enable: enable,
  );

  Future<void> checkLastJoin({bool force = false}) async {
    if (!isEnabled && !debugForceFake) {
      state = const GameLastJoinNone();
      return;
    }

    if (!force &&
        (state is GameLastJoinAvailable || state is GameLastJoinChecking)) {
      logDebug('checkLastJoin skipped: already in state ${state.runtimeType}');
      return;
    }

    if (debugForceFake) {
      final fakeSession = buildCardLastJoinSession(
        manager: _manager,
        gameId: debugFakeGameId,
        roomId: 9999,
      );
      if (fakeSession != null) {
        logInfo('checkLastJoin: using debug fake session ($debugFakeGameId)');
        state = GameLastJoinAvailable(session: fakeSession);
        return;
      }
    }

    final isAuthenticated = _ref.read(isAuthenticatedProvider);
    if (!isAuthenticated) {
      logDebug('checkLastJoin: user unauthenticated, setting GameLastJoinNone');
      state = const GameLastJoinNone();
      return;
    }

    logInfo('checkLastJoin: fetching last-join session from repository...');
    state = const GameLastJoinChecking();

    try {
      final session = await fetchCardLastJoin(client: _client, manager: _manager);
      logInfo(
        'checkLastJoin result: session=${session != null ? "found" : "null"}, '
        'hasActiveRoom=${session?.hasActiveRoom}, '
        'gameId=${session?.gameId}, '
        'roomId=${session?.roomId}, '
        'serverId=${session?.serverId}, '
        'hasPassword=${session?.hasPassword}, '
        'password=${session?.password.isNotEmpty == true ? "***" : "none"}, '
        'matchedGame=${session?.game?.gameCode}',
      );

      if (session != null && session.hasActiveRoom && session.game != null) {
        state = GameLastJoinAvailable(session: session);
      } else {
        state = const GameLastJoinNone();
      }
    } catch (e, st) {
      logError('checkLastJoin failed: $e', e, st);
      state = GameLastJoinFailure(e.toString());
    }
  }

  void dismiss() {
    final current = state;
    if (current is GameLastJoinAvailable) {
      logInfo('Dismissing last-join recovery prompt');
      state = current.copyWith(isDismissed: true);
    }
  }

  void clear() {
    logInfo('Clearing last-join state');
    state = const GameLastJoinNone();
  }

  void rejoin(BuildContext context, {CardLastJoinSession? session}) {
    final activeSession =
        session ??
        (state is GameLastJoinAvailable
            ? (state as GameLastJoinAvailable).session
            : null);
    if (activeSession != null) {
      final game = activeSession.game;
      if (game != null) {
        logInfo(
          'Rejoining game session: game=${game.gameCode}, '
          'serverId=${activeSession.serverId}, '
          'roomId=${activeSession.roomId}, '
          'hasPassword=${activeSession.hasPassword}',
        );
        _ref
            .read(gameLauncherProvider.notifier)
            .launch(
              context,
              game,
              serverId: activeSession.serverId,
              roomId: activeSession.roomId,
              roomPassword: activeSession.password,
            );
      }
      state = const GameLastJoinNone();
    }
  }
}
