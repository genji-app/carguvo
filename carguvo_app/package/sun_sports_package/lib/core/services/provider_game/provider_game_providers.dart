library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider_game_manager/provider_game_manager.dart';
import 'package:sun_sports/core/services/provider_game/lobby_game_config_loader.dart';

final providerGameManagerProvider = Provider<ProviderGameManager>(
  (ref) => ProviderGameManager.instance,
);

final providerGameDataProvider = StreamProvider<void>((ref) {
  final manager = ref.watch(providerGameManagerProvider);
  final controller = StreamController<void>.broadcast();
  final subs = <StreamSubscription<void>>[
    manager.onLobbyGameConfigLoaded.listen(controller.add),
    manager.onUpdateGameList.listen(controller.add),
  ];
  ref.onDispose(() {
    for (final s in subs) {
      s.cancel();
    }
    controller.close();
  });
  return controller.stream;
});

final lobbyConfigReadyProvider = FutureProvider<bool>(
  (ref) => LobbyGameConfigLoader.load(),
);

T _withCatalog<T>(Ref ref, T Function(ProviderGameManager manager) read) {
  ref.watch(providerGameDataProvider);
  return read(ref.watch(providerGameManagerProvider));
}

final lobbyCategoriesProvider = Provider<List<LobbyCategory>>(
  (ref) => _withCatalog(ref, (m) => m.categories),
);

final categoryGamesProvider = Provider.family<List<LobbyGame>, String>(
  (ref, categoryId) => _withCatalog(ref, (m) => m.categoryGames(categoryId)),
);

final collectionGamesProvider = Provider.family<List<LobbyGame>, String>(
  (ref, collectionId) =>
      _withCatalog(ref, (m) => m.collectionGames(collectionId)),
);

final allLobbyGamesProvider = Provider<List<LobbyGame>>(
  (ref) => _withCatalog(ref, (m) => m.allLobbyGames()),
);

final popularGamesProvider = Provider<List<LobbyGame>>(
  (ref) => _withCatalog(ref, (m) => m.popularGames()),
);

final lobbyBlocksProvider = Provider<List<LobbyBlock>>(
  (ref) => _withCatalog(ref, (m) => m.lobbyBlocks()),
);

final searchLobbyGamesProvider = Provider.family<List<LobbyGame>, String>(
  (ref, query) => _withCatalog(ref, (m) => m.searchLobbyGames(query)),
);

final recentGamesProvider = Provider<List<LobbyGame>>(
  (ref) => _withCatalog(ref, (m) => m.categoryGames('recent')),
);
