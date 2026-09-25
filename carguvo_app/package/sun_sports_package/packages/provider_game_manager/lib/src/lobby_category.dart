part of '../provider_game_manager.dart';

enum SidebarGroup {
  priority,

  standard,
}

enum CategorySource {
  catalog,

  lobby,

  recent,

  newGames,
}

class LobbyCategory {
  const LobbyCategory({
    required this.id,
    this.source = CategorySource.catalog,
    this.iconExtension = 'svg',
    this.sidebarGroup = SidebarGroup.standard,
  });

  final String id;

  final CategorySource source;

  String get translationKey => 'txt_cat_${id.toLowerCase()}';

  final String iconExtension;

  final SidebarGroup sidebarGroup;

  String get icon => '${id.toLowerCase()}_icon.$iconExtension';
  String get iconActive => '${id.toLowerCase()}_icon_active.$iconExtension';

  GameItemType get gameType => GameItemType.forName(id);

  static const Map<String, LobbyCategory> overrides = <String, LobbyCategory>{
    'all': LobbyCategory(
      id: 'all',
      source: CategorySource.lobby,
      sidebarGroup: SidebarGroup.priority,
    ),
    'recent': LobbyCategory(id: 'recent', source: CategorySource.recent),
    'newGame': LobbyCategory(id: 'newGame', source: CategorySource.newGames),
    'sun': LobbyCategory(
      id: 'sun',
      iconExtension: 'png',
      sidebarGroup: SidebarGroup.priority,
    ),
    'jackpot': LobbyCategory(id: 'jackpot', sidebarGroup: SidebarGroup.priority),
  };

  static LobbyCategory of(String id) => overrides[id] ?? LobbyCategory(id: id);

  @override
  String toString() => 'LobbyCategory($id, ${source.name})';
}

class LobbyCategoryContent {
  const LobbyCategoryContent({
    required this.category,
    required this.sunGames,
    required this.providerGames,
    required this.lockedSunGames,
  });

  final LobbyCategory category;

  final List<SunGameDetail> sunGames;

  final List<ProductProviderInfo> providerGames;

  final List<SunGameDetail> lockedSunGames;

  bool get isEmpty =>
      sunGames.isEmpty && providerGames.isEmpty && lockedSunGames.isEmpty;

  int get length => sunGames.length + providerGames.length + lockedSunGames.length;

  List<int> get orderedGameIds => List.unmodifiable(<int>[
    for (final g in sunGames) g.gameId,
    for (final g in providerGames) g.gameId,
    for (final g in lockedSunGames) g.gameId,
  ]);
}

class LobbySection {
  const LobbySection({
    this.title,
    this.titleKey,
    this.collectionId,
    this.bannerId,
  });

  final String? title;

  final String? titleKey;

  final String? collectionId;

  final String? bannerId;

  bool get isBanner => collectionId == null && bannerId != null;

  factory LobbySection.fromJson(Map<String, dynamic> json) {
    String? collection = json['collection']?.toString();
    final filter = json['filter'];
    if (collection == null && filter is Map) {
      final params = filter['params'];
      collection = params is Map ? params['id']?.toString() : null;
    }
    return LobbySection(
      title: json['title']?.toString(),
      titleKey: (json['title_key'] ?? json['titleKey'])?.toString(),
      collectionId: (collection == null || collection.isEmpty) ? null : collection,
      bannerId: (json['banner_id'] ?? json['bannerId'])?.toString(),
    );
  }

  @override
  String toString() =>
      'LobbySection(${titleKey ?? title ?? bannerId ?? collectionId})';
}
