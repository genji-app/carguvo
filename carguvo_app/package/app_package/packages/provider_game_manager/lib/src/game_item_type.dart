part of '../provider_game_manager.dart';

enum DefineOrientation {
  portrait,
  landscape;

  static DefineOrientation fromServerValue(int serverValue) {
    final i = serverValue - 1;
    if (i >= 0 && i < DefineOrientation.values.length) {
      return DefineOrientation.values[i];
    }
    return DefineOrientation.portrait;
  }
}

class GameItemType {
  const GameItemType._(this.name, this.index);

  static const GameItemType none = GameItemType._('NONE', 0);
  static const GameItemType newGame = GameItemType._('NEW_GAME', 1);
  static const GameItemType recent = GameItemType._('RECENT', 2);

  static final Map<String, GameItemType> _byName = <String, GameItemType>{
    none.name: none,
    newGame.name: newGame,
    recent.name: recent,
  };

  static GameItemType register(String name, int index) {
    final existing = _byName[name];
    if (existing != null && existing.index == index) return existing;
    final created = GameItemType._(name, index);
    _byName[name] = created;
    return created;
  }

  static void registerAll(Map<String, int> members) {
    members.forEach(register);
  }

  static GameItemType forName(String name) =>
      _byName.putIfAbsent(name, () => GameItemType._(name, -1));

  final String name;

  final int index;

  @override
  bool operator ==(Object other) =>
      other is GameItemType && other.name == name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'GameItemType($name#$index)';
}
