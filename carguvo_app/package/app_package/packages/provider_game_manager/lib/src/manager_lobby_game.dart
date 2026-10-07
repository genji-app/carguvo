part of '../provider_game_manager.dart';

sealed class LobbyBlock {
  const LobbyBlock();
}

class LobbyGroupBlock extends LobbyBlock {
  const LobbyGroupBlock({
    required this.games,
    this.title,
    this.titleKey,
    this.collectionId,
  });

  final String? title;

  final String? titleKey;

  final String? collectionId;

  final List<LobbyGame> games;
}

class LobbyBannerBlock extends LobbyBlock {
  const LobbyBannerBlock(this.bannerId);

  final String bannerId;
}

extension ProviderGameManagerLobbyGame on ProviderGameManager {

  SunLobbyGame lobbyGameOfSun(SunGameDetail detail) => SunLobbyGame(
        detail: detail,
        status: sunGameStatus(detail.gameId),
        tag: sunGameTag(detail.gameId),
        loadStopDebounceMs: _sunLoadStopDebounceMs[detail.gameId],
      );

  ProviderLobbyGame lobbyGameOfProvider(ProductProviderInfo info) =>
      ProviderLobbyGame(
        info: info,
        providerOverride: _providerOverrides[info.providerId],
        apiGameCode: _apiGameCodes[info.shortCode],
        isNew: _newGameList.contains(info.fullCode) ||
            _newGameList.contains(info.shortCode),
        sortOrder: _lobbyPriority(info),
      );

  LobbyGame? lobbyGameByRef(String ref) {
    final gameId = int.tryParse(ref);
    if (gameId != null) {
      final detail = _sunGameDetails[gameId];
      if (detail != null) return lobbyGameOfSun(detail);
      final info = _mapProductByGameId[gameId];
      if (info != null) return lobbyGameOfProvider(info);
      return null;
    }
    final info = _providerGameByRef(ref, applyLobbyWhitelist: false);
    return info == null ? null : lobbyGameOfProvider(info);
  }

  SunLobbyGame? lobbyGameOfGameId(int gameId) {
    final detail = _sunGameDetails[gameId];
    return detail == null ? null : lobbyGameOfSun(detail);
  }

  List<LobbyGame> gamesOf(LobbyCategoryContent content) =>
      List<LobbyGame>.unmodifiable(<LobbyGame>[
        for (final g in content.sunGames) lobbyGameOfSun(g),
        for (final g in content.providerGames) lobbyGameOfProvider(g),
        for (final g in content.lockedSunGames) lobbyGameOfSun(g),
      ]);

  List<LobbyGame> categoryGames(
    String categoryId, {
    bool applyLobbyWhitelist = false,
    bool filterProviderGamesByType = false,
  }) =>
      gamesOf(categoryContent(
        categoryId,
        applyLobbyWhitelist: applyLobbyWhitelist,
        filterProviderGamesByType: filterProviderGamesByType,
      ));

  List<LobbyGame> collectionGames(
    String collectionId, {
    bool applyLobbyWhitelist = false,
  }) =>
      gamesOf(collectionContent(
        collectionId,
        applyLobbyWhitelist: applyLobbyWhitelist,
      ));

  List<LobbyGame> allLobbyGames({bool applyLobbyWhitelist = false}) =>
      categoryGames('all', applyLobbyWhitelist: applyLobbyWhitelist);

  List<LobbyGame> popularGames() => collectionGames(popularCollectionId);

  static const String popularCollectionId = 'popular';

  List<LobbyGame> searchLobbyGames(String query) {
    final raw = query.trim().toLowerCase();
    if (raw.isEmpty) return const <LobbyGame>[];
    final normalized = removeSunDiacritics(raw);

    bool matchesText(String value) {
      final lower = value.toLowerCase();
      return lower.contains(raw) ||
          removeSunDiacritics(lower).contains(normalized);
    }

    final sun = <SunGameDetail>[];
    for (final detail in visibleSunGames) {
      if (detail.name.any(matchesText)) sun.add(detail);
    }
    final (active, locked) = _splitByPlayable(sun);

    final provider = <ProductProviderInfo>[];
    for (final info in _productInfos) {
      if (matchesText(info.gameName) ||
          matchesText(info.providerName) ||
          matchesText(info.gameCode) ||
          matchesText(info.productId) ||
          matchesText(info.providerId)) {
        provider.add(info);
      }
    }
    provider.sort(_byLobbyPriority);

    return List<LobbyGame>.unmodifiable(<LobbyGame>[
      for (final g in active) lobbyGameOfSun(g),
      for (final g in provider) lobbyGameOfProvider(g),
      for (final g in locked) lobbyGameOfSun(g),
    ]);
  }

  List<LobbyBlock> lobbyBlocks({bool applyLobbyWhitelist = false}) {
    final blocks = <LobbyBlock>[];
    for (final section in _lobbySections) {
      if (section.isBanner) {
        blocks.add(LobbyBannerBlock(section.bannerId!));
        continue;
      }
      final collectionId = section.collectionId;
      if (collectionId == null) continue;
      final games = collectionGames(
        collectionId,
        applyLobbyWhitelist: applyLobbyWhitelist,
      );
      if (games.isEmpty) continue;
      blocks.add(LobbyGroupBlock(
        games: games,
        title: section.title,
        titleKey: section.titleKey,
        collectionId: collectionId,
      ));
    }
    return List.unmodifiable(blocks);
  }
}

String removeSunDiacritics(String input) {
  const plain = 'aAeEoOuUiIdDyY';
  const accented = <String>[
    'aàảãáạăằẳẵắặâầẩẫấậ',
    'AÀẢÃÁẠĂẰẲẴẮẶÂẦẨẪẤẬ',
    'eèẻẽéẹêềểễếệ',
    'EÈẺẼÉẸÊỀỂỄẾỆ',
    'oòỏõóọôồổỗốộơờởỡớợ',
    'OÒỎÕÓỌÔỒỔỖỐỘƠỜỞỠỚỢ',
    'uùủũúụưừửữứự',
    'UÙỦŨÚỤƯỪỬỮỨỰ',
    'iìỉĩíị',
    'IÌỈĨÍỊ',
    'dđ',
    'DĐ',
    'yỳỷỹýỵ',
    'YỲỶỸÝỴ',
  ];
  var result = input;
  for (var i = 0; i < accented.length; i++) {
    result = result.replaceAll(RegExp('[${accented[i]}]'), plain[i]);
  }
  return result;
}
