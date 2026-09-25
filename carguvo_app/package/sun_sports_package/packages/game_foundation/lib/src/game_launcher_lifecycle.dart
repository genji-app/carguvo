import 'package:clock/clock.dart';
import 'package:provider_game_manager/provider_game_manager.dart';

enum GameLauncherStatus {
  idle,

  launching,

  active,

  error,
}

class GameLauncherState {
  const GameLauncherState({
    this.activeGame,
    this.status = GameLauncherStatus.idle,
    this.errorMessage,
  });

  static const Object _unset = Object();

  final LobbyGame? activeGame;
  final GameLauncherStatus status;
  final String? errorMessage;

  GameLauncherState copyWith({
    Object? activeGame = _unset,
    GameLauncherStatus? status,
    Object? errorMessage = _unset,
  }) {
    return GameLauncherState(
      activeGame: activeGame == _unset
          ? this.activeGame
          : activeGame as LobbyGame?,
      status: status ?? this.status,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameLauncherState &&
          runtimeType == other.runtimeType &&
          activeGame == other.activeGame &&
          status == other.status &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode =>
      activeGame.hashCode ^ status.hashCode ^ errorMessage.hashCode;
}

class GameLauncherConfig {
  const GameLauncherConfig({
    this.cooldownDuration = const Duration(seconds: 2),
  });

  final Duration cooldownDuration;
}

class GameLauncherLifecycle {
  GameLauncherLifecycle({GameLauncherConfig? config})
      : _config = config ?? const GameLauncherConfig();

  final GameLauncherConfig _config;
  final Map<String, DateTime> _lastSessionEndedAt = {};
  final Map<String, bool> _isSessionActive = {};

  bool canLaunchGame(String providerId) {
    if (_isSessionActive[providerId] == true) {
      return false;
    }

    final lastEndedAt = _lastSessionEndedAt[providerId];
    if (lastEndedAt != null) {
      final elapsed = clock.now().difference(lastEndedAt);
      if (elapsed < _config.cooldownDuration) {
        return false;
      }
    }

    return true;
  }

  Duration remainingCooldown(String providerId) {
    final lastEndedAt = _lastSessionEndedAt[providerId];
    if (lastEndedAt == null) return Duration.zero;

    final elapsed = clock.now().difference(lastEndedAt);
    final remaining = _config.cooldownDuration - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  void markSessionActive(String providerId) {
    _isSessionActive[providerId] = true;
  }

  void markSessionEnded(String providerId) {
    _isSessionActive[providerId] = false;
    _lastSessionEndedAt[providerId] = clock.now();
  }

  bool requiresSessionGuard(LobbyGame game) {
    return game.requiresSessionGuard;
  }

  bool isGamePlayable(SunGameStatus status) {
    return status.isPlayable;
  }

  String getMessageForStatus(SunGameStatus status) {
    return switch (status) {
      SunGameStatus.maintenance => 'Game đang bảo trì, vui lòng thử lại sau nhé',
      SunGameStatus.comingSoon => 'Game sắp ra mắt, hãy đón chờ nhé',
      _ => 'Game hiện chưa khả dụng.',
    };
  }
}
