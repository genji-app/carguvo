import 'dart:async';

import 'package:game_engine/game_engine.dart';

class GameRunnerController {
  final _streamController = StreamController<GameRunnerEvent>.broadcast(
    sync: true,
  );

  Stream<GameRunnerEvent> get events => _streamController.stream;

  void add(GameRunnerEvent event) {
    if (!_streamController.isClosed) _streamController.add(event);
  }

  void dispose() => _streamController.close();
}

sealed class GameRunnerEvent {
  const GameRunnerEvent();
}

final class RunnerLoadStarted extends GameRunnerEvent {
  const RunnerLoadStarted();
}

final class RunnerLoadStopped extends GameRunnerEvent {
  const RunnerLoadStopped();
}

final class RunnerErrorOccurred extends GameRunnerEvent {
  const RunnerErrorOccurred({required this.message});

  final String message;
}

final class RunnerLogEmitted extends GameRunnerEvent {
  const RunnerLogEmitted({
    required this.prefix,
    required this.level,
    required this.message,
    this.error,
    this.stackTrace,
  });

  final String prefix;
  final String level;
  final String message;
  final Object? error;
  final StackTrace? stackTrace;
}

final class RunnerHostMessageReceived extends GameRunnerEvent {
  const RunnerHostMessageReceived({required this.hostEvent});

  final GameHostEvent hostEvent;
}
