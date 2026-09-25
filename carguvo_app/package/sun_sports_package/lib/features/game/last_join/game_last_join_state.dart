import 'package:sun_sports/features/game/last_join/card_last_join_session.dart';
import 'package:flutter/foundation.dart';

@immutable
sealed class GameLastJoinState {
  const GameLastJoinState();
}

class GameLastJoinInitial extends GameLastJoinState {
  const GameLastJoinInitial();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameLastJoinInitial && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

class GameLastJoinChecking extends GameLastJoinState {
  const GameLastJoinChecking();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameLastJoinChecking && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

class GameLastJoinAvailable extends GameLastJoinState {
  const GameLastJoinAvailable({
    required this.session,
    this.isDismissed = false,
  });

  final CardLastJoinSession session;

  final bool isDismissed;

  GameLastJoinAvailable copyWith({
    CardLastJoinSession? session,
    bool? isDismissed,
  }) {
    return GameLastJoinAvailable(
      session: session ?? this.session,
      isDismissed: isDismissed ?? this.isDismissed,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameLastJoinAvailable &&
          runtimeType == other.runtimeType &&
          session == other.session &&
          isDismissed == other.isDismissed;

  @override
  int get hashCode => session.hashCode ^ isDismissed.hashCode;
}

class GameLastJoinNone extends GameLastJoinState {
  const GameLastJoinNone();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameLastJoinNone && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

class GameLastJoinFailure extends GameLastJoinState {
  const GameLastJoinFailure(this.message);

  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameLastJoinFailure &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}
