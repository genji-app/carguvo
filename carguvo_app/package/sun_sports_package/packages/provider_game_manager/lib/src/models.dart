part of '../provider_game_manager.dart';

class ProviderInfo {
  String providerId = '';
  String providerName = '';
}

class ProductProviderInfo {
  String providerId = '';
  String providerName = '';
  String productId = '';
  String gameName = '';
  int gameId = 0;
  String gameCode = '';
  List<int> gameType = const <int>[];
  DefineOrientation orientation = DefineOrientation.portrait;

  String get fullCode =>
      '${providerId}_${productId}_${gameCode}_$gameName';

  String get shortCode => '${providerId}_${productId}_$gameCode';

  String get imageName =>
      '${providerId}_${productId}_${gameCode.toLowerCase()}.webp';

  String get providerTagName => 'tag_$providerId.webp';
}

class ProviderDetail {
  String providerId = '';
  int priority = 0;
}

class ProviderOverride {
  const ProviderOverride({
    this.gameType,
    this.mobileOrientation = const [],
    this.tabletOrientation = const [],
    this.desktopOrientation = const [],
    this.forceLandscapeViewportOnIpad,
    this.openInNewTabOnIOSSafariWeb,
    this.requiresSessionGuard,
    this.scaffoldControls,
    this.useSafeArea,
    this.loadStopDebounceMs,
  });

  final String? gameType;

  final List<String> mobileOrientation;
  final List<String> tabletOrientation;
  final List<String> desktopOrientation;

  final bool? forceLandscapeViewportOnIpad;

  final bool? openInNewTabOnIOSSafariWeb;

  final bool? requiresSessionGuard;

  final bool? scaffoldControls;

  final bool? useSafeArea;

  final int? loadStopDebounceMs;

  factory ProviderOverride.fromJson(Map<String, dynamic> json) {
    List<String> list(Object? raw) => [
          for (final v in (raw as List? ?? const [])) v.toString(),
        ];
    return ProviderOverride(
      gameType: json['game_type']?.toString(),
      mobileOrientation: list(json['mobile_orientation']),
      tabletOrientation: list(json['tablet_orientation']),
      desktopOrientation: list(json['desktop_orientation']),
      forceLandscapeViewportOnIpad: json['force_landscape_viewport_on_ipad'] as bool?,
      openInNewTabOnIOSSafariWeb: json['open_in_new_tab_on_ios_safari_web'] as bool?,
      requiresSessionGuard: json['requires_session_guard'] as bool?,
      scaffoldControls: json['scaffold_controls'] as bool?,
      useSafeArea: json['use_safe_area'] as bool?,
      loadStopDebounceMs: (json['load_stop_debounce_ms'] as num?)?.toInt(),
    );
  }

  List<String> orientationsFor(SunDeviceKind kind) => switch (kind) {
      SunDeviceKind.phone => mobileOrientation,
      SunDeviceKind.tablet => tabletOrientation,
      SunDeviceKind.desktop => desktopOrientation,
    };
}

class SunGameDetail {
  int gameId = 0;
  List<String> name = const <String>[];
  int priority = 0;
  List<GameItemType> category = const <GameItemType>[];

  List<String> mobileOrientation = const <String>[];

  List<String> tabletOrientation = const <String>[];

  List<String> desktopOrientation = const <String>[];

  String gameBundle = '';

  SunLaunchStrategy launchStrategy = SunLaunchStrategy.unknown;

  String get imageName => '${gameBundle}_$gameId.webp';

  String get providerTagName => ProviderGameManager.sunProviderTag;
}

const String kGameImageDir = 'images/games';

const String kProviderTagDir = 'packs/icons';

class FilteredGameList {
  List<String> listGame = <String>[];
  List<SunGameDetail> listSunGame = <SunGameDetail>[];
  List<ProductProviderInfo> listProviderGame = <ProductProviderInfo>[];
}

class ProviderGameEvent {
  static const String updateGameList = 'UPDATE_GAME_LIST';
  static const String playGameProvider = 'PLAY_GAME_PROVIDER';
  static const String closeGameProvider = 'CLOSE_GAME_PROVIDER';
  static const String lobbyGameConfigLoaded = 'lobbyGameConfigLoaded';
}
