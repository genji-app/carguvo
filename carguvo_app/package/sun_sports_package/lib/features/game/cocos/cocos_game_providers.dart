import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_downloader/game_downloader.dart';
import 'package:game_launcher/game_launcher.dart';

import 'package:sun_sports/core/env/app_env.dart';

const String kCocosEntryFileName = 'data/main.js';

final gameDownloaderConfigProvider = Provider<GameDownloaderConfig>((ref) {
  final base = AppEnv.gameResourceUrl;
  return GameDownloaderConfig(apiBaseUrl: base, gameRemoteUrl: base);
});

final gameDownloaderProvider = Provider<GameDownloader>((ref) {
  final config = ref.watch(gameDownloaderConfigProvider);
  return GameDownloader(config: config, entryFileName: kCocosEntryFileName);
});

final nativeGameLauncherProvider = Provider<GameLauncher>((ref) {
  return GameLauncher();
});
