import 'package:flutter/widgets.dart';
import 'package:game_engine/game_engine.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/features/game/game.dart';

class GameRunnerView extends StatelessWidget {
  const GameRunnerView({
    required this.game,
    required this.gameUrl,
    required this.webViewId,
    required this.controller,
    super.key,
  });

  final LobbyGame game;
  final String gameUrl;
  final String webViewId;
  final GameRunnerController controller;

  @override
  Widget build(BuildContext context) {
    return switch (game) {
      final SunLobbyGame i => _IHRunnerView(
        game: i,
        gameUrl: gameUrl,
        webViewId: webViewId,
        controller: controller,
      ),
      final ProviderLobbyGame t => _PLRunnerView(
        game: t,
        gameUrl: gameUrl,
        webViewId: webViewId,
        controller: controller,
        forceLandscapeViewport: game.shouldForceLandscapeViewport(context),
      ),
    };
  }
}

class _IHRunnerView extends StatelessWidget {
  const _IHRunnerView({
    required this.game,
    required this.gameUrl,
    required this.webViewId,
    required this.controller,
  });

  final SunLobbyGame game;
  final String gameUrl;
  final String webViewId;
  final GameRunnerController controller;

  @override
  Widget build(BuildContext context) {
    return IHRunner(
      key: ValueKey('ih-runner-$webViewId'),
      gameUrl: gameUrl,
      onLoadStart: () => controller.add(const RunnerLoadStarted()),
      onLoadStop: () => controller.add(const RunnerLoadStopped()),
      onError: (msg) => controller.add(RunnerErrorOccurred(message: msg)),
      logger: (level, message, {error, stackTrace}) => controller.add(
        RunnerLogEmitted(
          prefix: 'IH',
          level: level,
          message: message,
          error: error,
          stackTrace: stackTrace,
        ),
      ),
      onHostMessage: (hostEvent) =>
          controller.add(RunnerHostMessageReceived(hostEvent: hostEvent)),
      enableHostMessage: game.enableHostMessage,
      loadStopDebounce: game.loadStopDebounce,
      backgroundColor: AppColors.gray700,
    );
  }
}

class _PLRunnerView extends StatelessWidget {
  const _PLRunnerView({
    required this.game,
    required this.gameUrl,
    required this.webViewId,
    required this.controller,
    required this.forceLandscapeViewport,
  });

  final ProviderLobbyGame game;
  final String gameUrl;
  final String webViewId;
  final GameRunnerController controller;
  final bool forceLandscapeViewport;

  @override
  Widget build(BuildContext context) {
    return PLRunner(
      key: ValueKey('pl-runner-$webViewId'),
      gameUrl: gameUrl,
      viewId: webViewId,
      onLoadStart: () => controller.add(const RunnerLoadStarted()),
      onLoadStop: () => controller.add(const RunnerLoadStopped()),
      onError: (msg) => controller.add(RunnerErrorOccurred(message: msg)),
      logger: (level, message, {error, stackTrace}) => controller.add(
        RunnerLogEmitted(
          prefix: 'PL',
          level: level,
          message: message,
          error: error,
          stackTrace: stackTrace,
        ),
      ),
      forceLandscapeViewport: forceLandscapeViewport,
      loadStopDebounce: game.loadStopDebounce,
      backgroundColor: AppColors.gray700,
    );
  }
}
