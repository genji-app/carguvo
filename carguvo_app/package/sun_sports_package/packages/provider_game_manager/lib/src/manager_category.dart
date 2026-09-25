part of '../provider_game_manager.dart';

extension ProviderGameManagerCategory on ProviderGameManager {

  List<LobbyCategory> get categories =>
      List.unmodifiable(_categoryIds.map(LobbyCategory.of));

  LobbyCategory? categoryById(String id) {
    if (_categoryIds.contains(id)) return LobbyCategory.of(id);
    if (isProviderMenuId(id)) {
      if (id == sunProviderMenuId) {
        return _categoryIds.contains(sunCategoryId)
            ? LobbyCategory.of(sunCategoryId)
            : null;
      }
      final providerId = providerIdOfMenuId(id);
      if (providerId == null || providerId.isEmpty) return null;
      final hasGame = _productInfos.any((info) => info.providerId == providerId);
      if (!hasGame) return null;
      return LobbyCategory(id: id);
    }
    return null;
  }

  static const String providerMenuIdPrefix = 'ncc:';

  static const String sunCategoryId = 'sun';

  static const String sunProviderMenuId = sunCategoryId;

  static bool isProviderMenuId(String categoryId) =>
      categoryId.startsWith(providerMenuIdPrefix);

  static String? providerIdOfMenuId(String categoryId) =>
      isProviderMenuId(categoryId)
          ? categoryId.substring(providerMenuIdPrefix.length)
          : null;

  List<LobbyCategory> providerMenuCategories() {
    final result = <LobbyCategory>[];
    if (_categoryIds.contains(sunCategoryId)) {
      result.add(LobbyCategory.of(sunCategoryId));
    }
    for (final detail in _providerDetails) {
      final id = detail.providerId;
      if (id.isEmpty || id == ProviderGameManager.sunProviderId) continue;
      final hasGame = _productInfos.any((info) => info.providerId == id);
      if (!hasGame) continue;
      result.add(LobbyCategory(id: '$providerMenuIdPrefix$id'));
    }
    return List.unmodifiable(result);
  }

  List<LobbyCategory> providerMenuCategoriesFor(String categoryId) =>
      _providerMenuCategoriesIn(categoryContent(categoryId));

  List<LobbyCategory> providerMenuCategoriesWithGames() =>
      _providerMenuCategoriesIn(categoryContent('all'));

  List<LobbyCategory> _providerMenuCategoriesIn(LobbyCategoryContent content) {
    final hasSun =
        content.sunGames.isNotEmpty || content.lockedSunGames.isNotEmpty;
    final providerIds = <String>{
      for (final info in content.providerGames) info.providerId,
    };
    return List.unmodifiable(<LobbyCategory>[
      for (final entry in providerMenuCategories())
        if (entry.id == sunProviderMenuId
            ? hasSun
            : providerIds.contains(providerIdOfMenuId(entry.id)))
          entry,
    ]);
  }

  LobbyCategoryContent categoryContent(
    String categoryId, {
    bool applyLobbyWhitelist = false,
    bool filterProviderGamesByType = false,
  }) {
    final providerMenuId = providerIdOfMenuId(categoryId);
    if (providerMenuId != null) {
      final providerGames = <ProductProviderInfo>[];
      for (final info in _productInfos) {
        if (info.providerId != providerMenuId) continue;
        if (applyLobbyWhitelist && !_lobbyGameList.containsKey(info.fullCode)) {
          continue;
        }
        providerGames.add(info);
      }
      providerGames.sort(_byLobbyPriority);
      return LobbyCategoryContent(
        category: LobbyCategory(id: categoryId),
        sunGames: const [],
        providerGames: List.unmodifiable(providerGames),
        lockedSunGames: const [],
      );
    }
    final category = LobbyCategory.of(categoryId);

    switch (category.source) {
      case CategorySource.recent:
        return _recentContent(category);
      case CategorySource.newGames:
        return _newGamesContent(category);
      case CategorySource.lobby:
        return _catalogContent(
          category,
          sunGames: visibleSunGames,
          providerIds: _providerDetails.map((d) => d.providerId).toList(),
          applyLobbyWhitelist: applyLobbyWhitelist,
          filterProviderGamesByType: false,
        );
      case CategorySource.catalog:
        return _catalogContent(
          category,
          sunGames: visibleSunGamesByCategory(category.gameType),
          providerIds: getProviderTypeByGameType(category.gameType),
          applyLobbyWhitelist: applyLobbyWhitelist,
          filterProviderGamesByType: filterProviderGamesByType,
        );
    }
  }

  LobbyCategoryContent _catalogContent(
    LobbyCategory category, {
    required List<SunGameDetail> sunGames,
    required List<String> providerIds,
    required bool applyLobbyWhitelist,
    required bool filterProviderGamesByType,
  }) {
    final (active, locked) = _splitByPlayable(sunGames);

    final providerGames = <ProductProviderInfo>[];
    final seen = <String>{};
    for (final providerId in providerIds) {
      if (providerId == 'NONE' || providerId == 'SUN') continue;
      for (final info in _productInfos) {
        if (info.providerId != providerId) continue;
        if (applyLobbyWhitelist && !_lobbyGameList.containsKey(info.fullCode)) {
          continue;
        }
        if (filterProviderGamesByType &&
            !info.gameType.contains(category.gameType.index)) {
          continue;
        }
        if (seen.add(info.fullCode)) providerGames.add(info);
      }
    }

    return LobbyCategoryContent(
      category: category,
      sunGames: active,
      providerGames: List.unmodifiable(providerGames),
      lockedSunGames: locked,
    );
  }

  LobbyCategoryContent _newGamesContent(LobbyCategory category) {
    final (active, locked) = _splitByPlayable(getListSunGameNew());
    return LobbyCategoryContent(
      category: category,
      sunGames: active,
      providerGames: getListNewGame(),
      lockedSunGames: locked,
    );
  }

  LobbyCategoryContent _recentContent(LobbyCategory category) {
    final sun = <SunGameDetail>[];
    final locked = <SunGameDetail>[];
    final provider = <ProductProviderInfo>[];
    for (final ref in recentGameRefs) {
      final gameId = int.tryParse(ref);
      if (gameId != null) {
        final sunGame = _sunGameDetails[gameId];
        if (sunGame != null) {
          if (!isSunGameVisible(gameId)) continue;
          (sunGameStatus(gameId).isPlayable ? sun : locked).add(sunGame);
          continue;
        }
        final legacy = _mapProductByGameId[gameId];
        if (legacy != null) provider.add(legacy);
        continue;
      }
      final info = _providerGameByRef(ref, applyLobbyWhitelist: false);
      if (info != null) provider.add(info);
    }
    return LobbyCategoryContent(
      category: category,
      sunGames: List.unmodifiable(sun),
      providerGames: List.unmodifiable(provider),
      lockedSunGames: List.unmodifiable(locked),
    );
  }

  (List<SunGameDetail>, List<SunGameDetail>) _splitByPlayable(
    List<SunGameDetail> games,
  ) {
    final active = <SunGameDetail>[];
    final locked = <SunGameDetail>[];
    for (final g in games) {
      (sunGameStatus(g.gameId).isPlayable ? active : locked).add(g);
    }
    return (List.unmodifiable(active), _lockedOrder(locked));
  }

  List<SunGameDetail> _lockedOrder(List<SunGameDetail> locked) {
    final maintenance = <SunGameDetail>[];
    final comingSoon = <SunGameDetail>[];
    for (final g in locked) {
      (sunGameStatus(g.gameId) == SunGameStatus.maintenance
              ? maintenance
              : comingSoon)
          .add(g);
    }
    return List.unmodifiable(<SunGameDetail>[...maintenance, ...comingSoon]);
  }

  LobbyCategoryContent collectionContent(
    String collectionId, {
    bool applyLobbyWhitelist = false,
  }) {
    final sun = <SunGameDetail>[];
    final maintenance = <SunGameDetail>[];
    final comingSoon = <SunGameDetail>[];
    final provider = <ProductProviderInfo>[];
    final seenSun = <int>{};
    final seenProvider = <String>{};
    for (final entry in _displayCollections[collectionId] ?? const <Object>[]) {
      if (entry is int) {
        final game = _sunGameDetails[entry];
        if (game == null) {
          _log('collection "$collectionId": không có game Sun #$entry', error: true);
          continue;
        }
        if (!isSunGameVisible(entry)) continue;
        if (!seenSun.add(entry)) continue;
        switch (sunGameStatus(entry)) {
          case SunGameStatus.maintenance:
            maintenance.add(game);
          case SunGameStatus.comingSoon:
            comingSoon.add(game);
          default:
            sun.add(game);
        }
        continue;
      }
      final info = _providerGameByRef(
        entry.toString(),
        applyLobbyWhitelist: applyLobbyWhitelist,
      );
      if (info == null) {
        _log(
          'collection "$collectionId": không khớp game NCC nào cho "$entry"',
          error: true,
        );
        continue;
      }
      if (seenProvider.add(info.fullCode)) provider.add(info);
    }
    return LobbyCategoryContent(
      category: LobbyCategory(id: collectionId),
      sunGames: List.unmodifiable(sun),
      providerGames: List.unmodifiable(provider),
      lockedSunGames: List.unmodifiable(<SunGameDetail>[
        ...maintenance,
        ...comingSoon,
      ]),
    );
  }

  ProductProviderInfo? _providerGameByRef(
    String ref, {
    required bool applyLobbyWhitelist,
  }) {
    bool allowed(ProductProviderInfo info) =>
        !applyLobbyWhitelist || _lobbyGameList.containsKey(info.fullCode);
    ProductProviderInfo? byMap(Map<String, ProductProviderInfo> map) {
      final info = map[ref];
      return info != null && allowed(info) ? info : null;
    }

    final byShortCode = byMap(_mapProductByCode);
    if (byShortCode != null) return byShortCode;
    final byFullCode = byMap(_mapProductByCodeFull);
    if (byFullCode != null) return byFullCode;
    final lowerRef = ref.toLowerCase();
    for (final info in _productInfos) {
      if (info.shortCode.toLowerCase() == lowerRef && allowed(info)) {
        return info;
      }
    }
    for (final info in _productInfos) {
      if (info.gameCode.toLowerCase() == lowerRef && allowed(info)) {
        return info;
      }
    }
    return null;
  }
}
