part of '../provider_game_manager.dart';

const int maxPriorityValue = 9007199254740991;

extension ProviderGameManagerSearch on ProviderGameManager {

  FilteredGameList searchGames(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return FilteredGameList();
    }

    final sunGames = _searchSunGames(trimmed);
    final providerGames = _searchProviderGames(trimmed);

    final result = FilteredGameList();
    result.listGame = _mergeAndSortResults(sunGames, providerGames);
    result.listSunGame = sunGames;
    result.listProviderGame = providerGames;
    return result;
  }

  List<SunGameDetail> _searchSunGames(String query) {
    final lowerQuery = query.toLowerCase();
    return _sunGameDetails.values.where((game) {
      return game.name.any(
        (name) => name.toLowerCase().contains(lowerQuery),
      );
    }).toList();
  }

  List<ProductProviderInfo> _searchProviderGames(String query) {
    final lowerQuery = query.toLowerCase();
    return _productInfos.where((info) {
      final fullCode = info.fullCode.toLowerCase();
      return fullCode.contains(lowerQuery) &&
          _lobbyGameList.containsKey(info.fullCode);
    }).toList();
  }

  List<String> _mergeAndSortResults(
    List<SunGameDetail> sunGames,
    List<ProductProviderInfo> providerGames,
  ) {
    final activeSunGames = <SunGameDetail>[];
    final maintenanceSunGames = <SunGameDetail>[];
    final comingSoonSunGames = <SunGameDetail>[];

    for (final game in sunGames) {
      final status = sunGameStatus(game.gameId);
      switch (status) {
        case SunGameStatus.active:
          activeSunGames.add(game);
        case SunGameStatus.maintenance:
          maintenanceSunGames.add(game);
        case SunGameStatus.comingSoon:
          comingSoonSunGames.add(game);
        case SunGameStatus.hidden:
        case SunGameStatus.notFound:
          break;
      }
    }

    int compareByPriority(SunGameDetail a, SunGameDetail b) =>
        a.priority.compareTo(b.priority);

    activeSunGames.sort(compareByPriority);
    maintenanceSunGames.sort(compareByPriority);
    comingSoonSunGames.sort(compareByPriority);

    final sortedProviders = List<ProductProviderInfo>.from(providerGames);
    sortedProviders.sort((a, b) {
      final priorityA = _lobbyGameList[a.fullCode] ?? maxPriorityValue;
      final priorityB = _lobbyGameList[b.fullCode] ?? maxPriorityValue;
      return priorityA.compareTo(priorityB);
    });

    final result = <String>[];

    for (final game in activeSunGames) {
      result.add(game.name.isNotEmpty ? game.name[0] : 'sun_${game.gameId}');
    }

    for (final info in sortedProviders) {
      result.add(info.fullCode);
    }

    for (final game in maintenanceSunGames) {
      result.add(game.name.isNotEmpty ? game.name[0] : 'sun_${game.gameId}');
    }

    for (final game in comingSoonSunGames) {
      result.add(game.name.isNotEmpty ? game.name[0] : 'sun_${game.gameId}');
    }

    return result;
  }
}
