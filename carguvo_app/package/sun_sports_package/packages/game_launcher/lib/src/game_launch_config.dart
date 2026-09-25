import 'game_credentials.dart';

class GameLaunchConfig {
  final String gamePath;

  final String gameId;

  final String xxteaKey;

  final bool isLandscape;

  final GameCredentials credentials;
  final bool enableBackgroundMusic;
  final bool enableSound;

  const GameLaunchConfig({
    required this.gamePath,
    required this.gameId,
    required this.credentials,
    this.xxteaKey = '',
    this.isLandscape = true,
    this.enableBackgroundMusic = true,
    this.enableSound = true,
  });

  Map<String, dynamic> toArguments() => {
    'gamePath': gamePath,
    'gameId': gameId,
    'xxteaKey': xxteaKey,
    'isLandscape': isLandscape,
    'enableBackgroundMusic': enableBackgroundMusic,
    'enableSound': enableSound,
    ...credentials.toArguments(),
  };
}
