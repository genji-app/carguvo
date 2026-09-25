library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider_game_manager/provider_game_manager.dart';
import 'package:sun_sports/core/services/provider_game/provider_game_providers.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';

const String kCasinoProviderCategoryPrefix = 'ncc:';

const Map<String, String> _kProviderLabels = {
  'amb-vn': 'Sexy Gaming',
  'via-casino-vn': 'VIA casino',
  'vivo': 'VIVO casino',
  'lcevo': 'Evolution',
};

final Map<String, ({String icon, String active})> _kProviderIcons = {
  'amb-vn': (icon: AppIcons.iconNccSexy, active: AppIcons.iconNccSexySelected),
  'via-casino-vn': (
    icon: AppIcons.iconNccVia,
    active: AppIcons.iconNccViaSelected,
  ),
  'vivo': (icon: AppIcons.iconNccVivo, active: AppIcons.iconNccVivoSelected),
  'lcevo': (icon: AppIcons.iconNccEvo, active: AppIcons.iconNccEvoSelected),
};

const String _kProviderFallbackIcon = 'ic_arcade.svg';

String casinoProviderMenuLabel(LobbyCategory category, ProviderGameManager manager) {
  if (category.id == 'sun') return 'Sunwin';
  final providerId = category.id.startsWith(kCasinoProviderCategoryPrefix)
      ? category.id.substring(kCasinoProviderCategoryPrefix.length)
      : category.id;
  final labeled = _kProviderLabels[providerId];
  if (labeled != null) return labeled;
  for (final info in manager.productInfos) {
    if (info.providerId == providerId && info.providerName.isNotEmpty) {
      return info.providerName;
    }
  }
  return providerId;
}

({String icon, String active}) casinoProviderMenuIcons(LobbyCategory category) {
  if (category.id == 'sun') {
    return (icon: category.icon, active: category.iconActive);
  }
  final providerId = category.id.startsWith(kCasinoProviderCategoryPrefix)
      ? category.id.substring(kCasinoProviderCategoryPrefix.length)
      : category.id;
  return _kProviderIcons[providerId] ??
      (icon: _kProviderFallbackIcon, active: _kProviderFallbackIcon);
}

bool lobbyGameMatchesProviderMenu(LobbyGame game, String providerMenuId) {
  if (providerMenuId.isEmpty) return true;
  if (providerMenuId == ProviderGameManagerCategory.sunProviderMenuId) {
    return game.isSunGame;
  }
  final providerId = ProviderGameManagerCategory.providerIdOfMenuId(
    providerMenuId,
  );
  return game.isProviderGame && game.providerId == providerId;
}

final casinoProviderCategoriesProvider = Provider<List<LobbyCategory>>((ref) {
  ref.watch(providerGameDataProvider);
  final manager = ref.watch(providerGameManagerProvider);
  return manager.providerMenuCategories();
});
