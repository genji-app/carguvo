export 'package:game_foundation/game_foundation.dart'
    show GameUrlState, GameUrlStatus, GameUrlFailureKind;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/env/app_env.dart';
import 'package:sun_sports/core/services/auth/token_manager.dart';
import 'package:sun_sports/core/utils/extensions/log_helper.dart';
import 'package:sun_sports/features/game/game.dart';

class GameUrlNotifier extends StateNotifier<GameUrlState> with LoggerMixin {
  GameUrlNotifier({required ProviderGameManager manager})
    : _manager = manager,
      super(const GameUrlState());

  final ProviderGameManager _manager;

  LobbyGame? _lastGame;

  Future<String?> getGameUrl(LobbyGame game) async {
    logInfo('Lấy URL vào game: ${game.ref} (${game.gameName})');
    _lastGame = game;
    state = state.copyWith(
      status: GameUrlStatus.loading,
      error: null,
      failureKind: null,
    );

    try {
      final result = await _manager.gameUrlOf(
        game,
        accessToken: await TokenManager.getAccessToken() ?? '',
        refreshToken: await TokenManager.getRefreshToken() ?? '',
        baseUrlTransformer:
            AppEnv.isPreRelease ? AppEnv.injectPreReleasePath : null,
      );

      switch (result) {
        case LobbyGameUrlReady(:final url):
          logDebug('URL: $url');
          state = state.copyWith(url: url, status: GameUrlStatus.success);
          return url;

        case LobbyGameUrlNative(:final gameBundle):
          logInfo('Game native, mở bundle $gameBundle');
          state = state.copyWith(
            status: GameUrlStatus.success,
            nativeBundle: gameBundle,
          );
          return null;

        case LobbyGameUrlBlocked(:final status):
          logWarning('Game ${game.ref} bị chặn: ${status.name}');
          state = state.copyWith(
            status: GameUrlStatus.error,
            failureKind: GameUrlFailureKind.blocked,
            error: status.name,
          );
          return null;

        case LobbyGameUrlUnavailable(:final reason):
          logError('Không lấy được URL game ${game.ref}: $reason');
          state = state.copyWith(
            status: GameUrlStatus.error,
            failureKind: GameUrlFailureKind.unavailable,
            error: reason,
          );
          return null;
      }
    } catch (e, stackTrace) {
      logError('Lỗi ngoài dự kiến khi lấy URL game', e, stackTrace);
      state = state.copyWith(
        status: GameUrlStatus.error,
        failureKind: GameUrlFailureKind.unknown,
        error: '$e',
      );
      return null;
    }
  }

  Future<String?> retry() async {
    final game = _lastGame;
    if (game == null) {
      logWarning('Retry: chưa có lượt nào để gọi lại');
      state = state.copyWith(
        status: GameUrlStatus.error,
        failureKind: GameUrlFailureKind.unknown,
        error: 'Chưa có lượt nào để gọi lại',
      );
      return null;
    }
    return getGameUrl(game);
  }

  void clear() {
    state = const GameUrlState();
    _lastGame = null;
  }
}

final gameUrlProvider = StateNotifierProvider<GameUrlNotifier, GameUrlState>(
  (ref) => GameUrlNotifier(manager: ref.watch(providerGameManagerProvider)),
);
