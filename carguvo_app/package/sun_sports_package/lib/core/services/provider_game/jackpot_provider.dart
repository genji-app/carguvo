import 'dart:async';

import 'package:casino_jackpot/casino_jackpot.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/utils/app_logger.dart';

import 'package:sun_sports/core/services/provider_game/game_api_client_provider.dart';

final _logger = AppLogger(tag: 'Jackpot');

void _onLog(
  JackpotLogLevel level,
  String message, {
  Object? error,
  StackTrace? stackTrace,
}) {
  switch (level) {
    case JackpotLogLevel.debug:
      _logger.d(message, error, stackTrace);
    case JackpotLogLevel.warning:
      _logger.w(message, error, stackTrace);
    case JackpotLogLevel.error:
      _logger.e(message, error: error, stackTrace: stackTrace);
  }
}

final jackpotTickerConfigProvider = Provider<JackpotTickerConfig>((ref) {
  return const JackpotTickerConfig.vivid();
});

final jackpotRepositoryProvider = Provider<JackpotRepository>((ref) {
  final client = ref.watch(gameApiClientProvider);
  final config = ref.watch(jackpotTickerConfigProvider);
  final repository = JackpotRepository(
    client: client,
    config: config,
    onLog: _onLog,
  );

  final lifecycleListener = AppLifecycleListener(
    onPause: repository.pausePolling,
    onHide: repository.pausePolling,
    onResume: () => unawaited(repository.resumePolling()),
    onShow: () => unawaited(repository.resumePolling()),
  );

  ref.onDispose(() {
    lifecycleListener.dispose();
    repository.dispose();
  });

  unawaited(repository.start());

  return repository;
});

final jackpotStreamProvider =
    StreamProvider.autoDispose<Map<int, JackpotDisplayState>>((ref) {
      final link = ref.keepAlive();
      Timer? grace;
      ref.onCancel(() {
        grace?.cancel();
        grace = Timer(_jackpotStreamGrace, link.close);
      });
      ref.onResume(() => grace?.cancel());
      ref.onDispose(() => grace?.cancel());

      final repository = ref.watch(jackpotRepositoryProvider);
      return repository.jackpotStream;
    });

const Duration _jackpotStreamGrace = Duration(seconds: 10);

final jackpotForGameProvider = Provider.autoDispose
    .family<JackpotDisplayState?, int>((ref, gameId) {
      final streamMap = ref.watch(jackpotStreamProvider).valueOrNull;
      if (streamMap != null) {
        return streamMap[gameId];
      }
      return ref.watch(jackpotRepositoryProvider).currentJackpots[gameId];
    });
