library;

class FilterableGame {
  const FilterableGame({required this.ref, required this.name});

  final String ref;

  final String name;
}

enum GameViewMode { lobby, filter }

class GameFilterRules {
  GameFilterRules._();

  static const Duration debounceDuration = Duration(milliseconds: 400);

  static const String lobbyCategoryId = '';

  static String normalizeCategoryId(String id) =>
      id == 'all' ? lobbyCategoryId : id;

  static GameViewMode viewModeOf({
    required String searchQuery,
    required String categoryId,
  }) =>
      searchQuery.isEmpty && categoryId.isEmpty
          ? GameViewMode.lobby
          : GameViewMode.filter;

  static bool isLobbyMode({
    required String searchQuery,
    required String categoryId,
  }) =>
      searchQuery.isEmpty && categoryId.isEmpty;

  static List<FilterableGame> filter({
    required List<FilterableGame> allGames,
    List<FilterableGame>? categoryGames,
    Set<String>? matchedRefs,
  }) {
    final base = categoryGames ?? allGames;
    if (matchedRefs == null) return base;
    return base.where((g) => matchedRefs.contains(g.ref)).toList();
  }

  static String normalizeQuery(String query) => query.trim();
}
