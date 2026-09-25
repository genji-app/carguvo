import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/features/game/game.dart';
import 'package:sun_sports/providers/casino_provider_menu_provider.dart';

const String kHomeSportTabId = 'sportProviders';

const String kHomeCustomTabId = 'custom';

class HomeCategoryItem {
  const HomeCategoryItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.iconActive,
    this.category,
    this.markerIcon = '',
  });

  final String id;
  final String label;
  final String icon;
  final String iconActive;
  final LobbyCategory? category;

  final String markerIcon;

  bool get isSportProviders => id == kHomeSportTabId;

  bool get isCustom => id == kHomeCustomTabId;

  GameCategorySelection get selection => category == null
      ? const GameCategorySelection()
      : GameCategorySelection.fromCategory(category!);
}

const List<(String, String)> _kHomeCategoryTabs = <(String, String)>[
  ('dice', 'Xanh chín'),
  ('live', 'Live'),
  ('jackpot', 'Nổ hũ'),
  ('fish', 'Bắn cá'),
  ('slot', 'Slots'),
  ('card', 'Game bài'),
  ('lottery', 'Lô đề'),
  ('miniGame', 'Game nhanh'),
];

final homeCategoryItemsProvider = Provider.autoDispose<List<HomeCategoryItem>>((
  ref,
) {
  final List<LobbyCategory> categories = ref.watch(lobbyCategoriesProvider);
  final Map<String, LobbyCategory> byId = <String, LobbyCategory>{
    for (final LobbyCategory c in categories) c.id: c,
  };
  return <HomeCategoryItem>[
    HomeCategoryItem(
      id: kHomeSportTabId,
      label: 'Thể thao',
      icon: AppIcons.catSport,
      iconActive: AppIcons.catSportActive,
    ),
    for (final (String id, String label) in _kHomeCategoryTabs)
      if (byId[id] case final LobbyCategory category?)
        HomeCategoryItem(
          id: id,
          label: label,
          icon: category.iconPath(),
          iconActive: category.iconPath(active: true),
          category: category,
          markerIcon: id == 'live' ? AppIcons.liveDot : '',
        ),
    if (categories.isNotEmpty)
      HomeCategoryItem(
        id: kHomeCustomTabId,
        label: 'Tùy chọn',
        icon: AppIcons.customIcon,
        iconActive: AppIcons.customIconActive,
      ),
  ];
});

final homeCategorySelectedIdProvider = StateProvider.autoDispose<String>(
  (ref) => kHomeSportTabId,
);

HomeCategoryItem resolveHomeCategory(
  List<HomeCategoryItem> items,
  String selectedId,
) => items.firstWhere(
  (HomeCategoryItem i) => i.id == selectedId,
  orElse: () => items.first,
);

final homeCategoryProviderIdProvider = StateProvider.autoDispose<String>(
  (ref) => '',
);

final homeCategoryRawQueryProvider = StateProvider.autoDispose<String>(
  (ref) => '',
);

final homeCategoryQueryProvider = StateProvider.autoDispose<String>((ref) => '');

final homeCategoryPendingRowIdProvider =
    StateProvider.autoDispose<String?>((ref) => null);

final homeCategoryProvidersProvider = Provider.autoDispose
    .family<List<LobbyCategory>, String>((ref, String tabId) {
      if (tabId == kHomeSportTabId) return const <LobbyCategory>[];
      ref.watch(providerGameDataProvider);
      final ProviderGameManager manager = ref.watch(providerGameManagerProvider);
      return tabId == kHomeCustomTabId
          ? manager.providerMenuCategoriesWithGames()
          : manager.providerMenuCategoriesFor(tabId);
    });

String homeEffectiveProviderId(List<LobbyCategory> chips, String providerId) {
  if (providerId.isEmpty) return '';
  return chips.any((LobbyCategory c) => c.id == providerId) ? providerId : '';
}

typedef HomeCategoryGamesKey = ({
  GameCategorySelection selection,
  String providerId,
  String query,
});

final homeCategoryGamesProvider = Provider.autoDispose
    .family<AsyncValue<List<LobbyGame>>, HomeCategoryGamesKey>((ref, key) {
      final KeepAliveLink link = ref.keepAlive();
      final Timer timer = Timer(const Duration(minutes: 5), link.close);
      ref.onDispose(timer.cancel);
      final AsyncValue<List<LobbyGame>> base = ref.watch(
        gameCategoryPreviewProvider((
          query: key.query,
          selection: key.selection,
        )),
      );
      if (key.providerId.isEmpty) return base;
      return base.whenData(
        (List<LobbyGame> games) => <LobbyGame>[
          for (final LobbyGame game in games)
            if (lobbyGameMatchesProviderMenu(game, key.providerId)) game,
        ],
      );
    });

class HomeProviderFilterRequest {
  const HomeProviderFilterRequest({
    required this.providerId,
    required this.serial,
  });

  final String providerId;
  final int serial;
}

final homeProviderFilterRequestProvider =
    StateProvider.autoDispose<HomeProviderFilterRequest?>((ref) => null);
