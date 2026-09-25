import 'package:flutter/foundation.dart';
import 'package:game_api_client/game_api_client.dart' as gac;
import 'package:provider_game_manager/provider_game_manager.dart';

@immutable
class CardLastJoinSession {
  const CardLastJoinSession({required this.data, this.game});

  final gac.CardLastJoinData data;

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

Future<CardLastJoinSession?> fetchCardLastJoin({
  required gac.GameApiClient client,
  required ProviderGameManager manager,
}) async {
  final data = await client.getCardLastJoin();
  if (data == null || !data.hasActiveRoom) return null;
  return CardLastJoinSession(
    data: data,
    game: manager.lobbyGameOfGameId(data.gameId),
  );
}

CardLastJoinSession? buildCardLastJoinSession({
  required ProviderGameManager manager,
  required int gameId,
  int roomId = 9999,
  int serverId = 1,
  String password = '',
}) {
  final game = manager.lobbyGameOfGameId(gameId);
  if (game == null) return null;
  return CardLastJoinSession(
    data: gac.CardLastJoinData(
      gameId: gameId,
      roomId: roomId,
      serverId: serverId,
      password: password,
      hasPassword: password.isNotEmpty,
    ),
    game: game,
  );
}
