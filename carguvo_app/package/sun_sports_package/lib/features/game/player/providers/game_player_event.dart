part of 'game_player_notifier.dart';

sealed class GamePlayerEvent {
  const GamePlayerEvent();
}

final class GamePlayerExitEvent extends GamePlayerEvent {
  const GamePlayerExitEvent();
}
