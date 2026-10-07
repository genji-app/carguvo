part of 'models.dart';

enum GameType {
  none(-2),

  sun(-3),

  slot(1),

  sport(2),

  jackpot(3),

  card(4),

  dice(5),

  live(6),

  lottery(7),

  miniGame(8),

  fishing(9),

  others(20),

  newGame(-4),

  recent(-5),

  provider(-6),

  unknown(-1);

  const GameType(this.value);

  final int value;

  bool get isApiType => value > 0;

  static GameType fromValue(int value) {
    return GameType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => GameType.unknown,
    );
  }

  static GameType fromJson(int value) => GameType.fromValue(value);

  static int toJson(GameType type) => type.value;

  static GameType fromName(String name) {
    final normalized = name.toLowerCase().trim();
    if (normalized == 'fish') return GameType.fishing;
    if (normalized == 'cardgame') return GameType.card;
    return GameType.values.firstWhere(
      (e) => e.name.toLowerCase() == normalized,
      orElse: () => GameType.unknown,
    );
  }
}

@freezed
sealed class ProviderGames with _$ProviderGames {
  const factory ProviderGames({
    @JsonKey(name: 'providerId') required String providerId,
    @JsonKey(name: 'providerName') required String providerName,
    @JsonKey(name: 'gameList') @Default([]) List<Game> gameList,
  }) = _ProviderGames;

  factory ProviderGames.fromJson(Map<String, dynamic> json) => _$ProviderGamesFromJson(json);
}

@freezed
sealed class Game with _$Game {
  const factory Game({
    @JsonKey(name: 'productId') required String productId,
    @JsonKey(name: 'gameCode') required String gameCode,
    @JsonKey(name: 'gameName') required String gameName,
    @JsonKey(name: 'lang') required String lang,
    @JsonKey(name: 'lobbyUrl') required String lobbyUrl,
    @JsonKey(name: 'cashierUrl') required String cashierUrl,
    @JsonKey(name: 'gameType', fromJson: GameType.fromJson, toJson: GameType.toJson)
    required GameType gameType,
    @JsonKey(name: 'mobileLogin') @Default(false) bool mobileLogin,
  }) = _Game;

  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);
}
