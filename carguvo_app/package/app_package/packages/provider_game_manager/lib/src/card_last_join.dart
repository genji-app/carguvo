part of '../provider_game_manager.dart';

class CardLastJoinData {
  const CardLastJoinData({
    required this.gameId,
    required this.roomId,
    required this.serverId,
    required this.password,
    required this.hasPassword,
  });

  final int gameId;
  final int roomId;
  final int serverId;
  final String password;
  final bool hasPassword;

  bool get hasActiveRoom => roomId > 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardLastJoinData &&
          runtimeType == other.runtimeType &&
          gameId == other.gameId &&
          roomId == other.roomId &&
          serverId == other.serverId &&
          password == other.password &&
          hasPassword == other.hasPassword;

  @override
  int get hashCode =>
      gameId.hashCode ^
      roomId.hashCode ^
      serverId.hashCode ^
      password.hashCode ^
      hasPassword.hashCode;

  @override
  String toString() =>
      'CardLastJoinData(gameId: $gameId, roomId: $roomId, serverId: $serverId, hasPassword: $hasPassword)';
}

class CardLastJoinSession {
  const CardLastJoinSession({required this.data, this.game});

  final CardLastJoinData data;

  final LobbyGame? game;

  bool get hasActiveRoom => data.hasActiveRoom;

  int get roomId => data.roomId;

  int get gameId => data.gameId;

  int get serverId => data.serverId;

  String get password => data.password;

  bool get hasPassword => data.hasPassword;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardLastJoinSession &&
          runtimeType == other.runtimeType &&
          data == other.data &&
          game == other.game;

  @override
  int get hashCode => data.hashCode ^ game.hashCode;

  @override
  String toString() =>
      'CardLastJoinSession(data: $data, game: ${game?.gameName})';
}

CardLastJoinData? parseCardLastJoin(Map<dynamic, dynamic> data) {
  final roomId = _asInt(data['roomId'], fallback: -1);
  if (roomId <= 0) return null;

  final gameId = _asInt(data['gameId']);
  final serverId = _asInt(data['serverId'] ?? data['sid'] ?? data['serverID']);
  final password = (data['password'] ?? data['pwd'] ?? data['roomPassword'])?.toString() ?? '';
  final hasPassword = password.isNotEmpty;

  return CardLastJoinData(
    gameId: gameId,
    roomId: roomId,
    serverId: serverId,
    password: password,
    hasPassword: hasPassword,
  );
}

CardLastJoinSession? parseCardLastJoinWithCatalog(
  Map<dynamic, dynamic> data,
  List<LobbyGame> catalog,
) {
  final parsed = parseCardLastJoin(data);
  if (parsed == null) return null;

  LobbyGame? matchedGame;
  for (final game in catalog) {
    if (game.gameId == parsed.gameId) {
      matchedGame = game;
      break;
    }
  }

  return CardLastJoinSession(data: parsed, game: matchedGame);
}

CardLastJoinSession buildCardLastJoinSession({
  required List<LobbyGame> catalog,
  required int gameId,
  int roomId = 9999,
  int serverId = 1,
  String password = '',
}) {
  LobbyGame? matchedGame;
  for (final game in catalog) {
    if (game.gameId == gameId) {
      matchedGame = game;
      break;
    }
  }

  return CardLastJoinSession(
    data: CardLastJoinData(
      gameId: gameId,
      roomId: roomId,
      serverId: serverId,
      password: password,
      hasPassword: password.isNotEmpty,
    ),
    game: matchedGame,
  );
}

int _asInt(Object? value, {int fallback = 0}) => switch (value) {
  final int v => v,
  final num v => v.toInt(),
  final String v => int.tryParse(v) ?? num.tryParse(v)?.toInt() ?? fallback,
  _ => fallback,
};
