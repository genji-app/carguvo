part of '../provider_game_manager.dart';

sealed class LobbyGameUrl {
  const LobbyGameUrl();

  LobbyGame get game;
}

class LobbyGameUrlReady extends LobbyGameUrl {
  const LobbyGameUrlReady(this.url, this.game);

  final String url;

  @override
  final LobbyGame game;
}

class LobbyGameUrlNative extends LobbyGameUrl {
  const LobbyGameUrlNative(this.gameBundle, this.game);

  final String gameBundle;

  @override
  final LobbyGame game;
}

class LobbyGameUrlBlocked extends LobbyGameUrl {
  const LobbyGameUrlBlocked(this.status, this.game);

  final SunGameStatus status;

  @override
  final LobbyGame game;
}

class LobbyGameUrlUnavailable extends LobbyGameUrl {
  const LobbyGameUrlUnavailable(this.game, {required this.reason});

  @override
  final LobbyGame game;

  final String reason;
}
