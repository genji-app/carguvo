import 'dart:io';

class GameDownloaderConfig {
  final String apiBaseUrl;

  final String gameRemoteUrl;

  final String downloadPathPattern;

  final String versionPatternSource;

  const GameDownloaderConfig({
    this.apiBaseUrl = 'https://resources.gwin.info/s88',
    this.gameRemoteUrl = 'https://resources.gwin.info/s88',
    this.downloadPathPattern =
        '/games/{game_name}/{platform}/{version}/{game_name}.zip',
    this.versionPatternSource = r'^v\d+$',
  });

  RegExp get versionPattern =>
      RegExp(versionPatternSource, caseSensitive: false);

  String get platform {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'android';
  }
}
