part of '../provider_game_manager.dart';

sealed class LobbyGame {
  const LobbyGame();

  String get providerId;

  String get providerName;

  String get productId;

  String get gameCode;

  String get gameName;

  String get imageName;

  String get providerTagName;

  SunGameTag get tag;

  SunGameStatus get status;

  String get ref;

  int get sortOrder;

  String get lang => 'vi';

  bool get isSunGame => this is SunLobbyGame;

  bool get isProviderGame => this is ProviderLobbyGame;

  int get gameId;

  String? get gameBundle;

  SunLaunchStrategy get launchStrategy;

  List<SunOrientation> orientationsFor(SunDeviceKind kind);

  bool get enableHostMessage;

  bool get redirectOnIOSSafariWeb;

  bool get redirectOnMobileWeb;

  bool get forceLandscapeViewportOnIpad;

  bool get openInNewTabOnIOSSafariWeb;

  bool get requiresSessionGuard;

  bool? get scaffoldControls;

  bool get useSafeArea;

  Duration get loadStopDebounce;

  String get effectiveApiGameCode => gameCode;

  bool get isLandscape =>
      orientationsFor(SunDeviceKind.phone).any((o) => o.isLandscape);

  static const Duration defaultLoadStopDebounce = Duration(milliseconds: 555);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LobbyGame &&
          other.runtimeType == runtimeType &&
          other.ref == ref &&
          other.status == status &&
          other.tag == tag;

  @override
  int get hashCode => Object.hash(runtimeType, ref, status, tag);

  @override
  String toString() => '$runtimeType($ref, $gameName)';
}

class SunLobbyGame extends LobbyGame {
  const SunLobbyGame({
    required this.detail,
    required this.status,
    required this.tag,
    this.loadStopDebounceMs,
  });

  final SunGameDetail detail;

  @override
  final SunGameStatus status;

  @override
  final SunGameTag tag;

  final int? loadStopDebounceMs;

  @override
  String get providerId => ProviderGameManager.sunProviderId;

  @override
  String get providerName => ProviderGameManager.sunProviderName;

  @override
  String get productId => '${ProviderGameManager.sunProviderId}_${detail.gameId}';

  @override
  String get gameCode => detail.gameBundle;

  @override
  String get gameName =>
      detail.name.isNotEmpty ? detail.name.first : 'Game ${detail.gameId}';

  @override
  String get imageName => detail.imageName;

  @override
  String get providerTagName => detail.providerTagName;

  @override
  String get ref => detail.gameId.toString();

  @override
  int get sortOrder => detail.priority;

  @override
  int get gameId => detail.gameId;

  @override
  String? get gameBundle => detail.gameBundle;

  @override
  SunLaunchStrategy get launchStrategy => detail.launchStrategy;

  @override
  List<SunOrientation> orientationsFor(SunDeviceKind kind) {
    final raw = switch (kind) {
      SunDeviceKind.phone => detail.mobileOrientation,
      SunDeviceKind.tablet => detail.tabletOrientation,
      SunDeviceKind.desktop => detail.desktopOrientation,
    };
    final resolved = SunOrientation.expandAll(raw);
    if (resolved.isNotEmpty) return resolved;
    return switch (kind) {
      SunDeviceKind.phone || SunDeviceKind.tablet => SunOrientation.landscape,
      SunDeviceKind.desktop => SunOrientation.all,
    };
  }

  @override
  bool get enableHostMessage => true;

  @override
  bool get redirectOnIOSSafariWeb => true;

  @override
  bool get redirectOnMobileWeb => true;

  @override
  bool get forceLandscapeViewportOnIpad => false;

  @override
  bool get openInNewTabOnIOSSafariWeb => false;

  @override
  bool get requiresSessionGuard => false;

  @override
  bool? get scaffoldControls => null;

  @override
  bool get useSafeArea => false;

  @override
  Duration get loadStopDebounce => loadStopDebounceMs == null
      ? LobbyGame.defaultLoadStopDebounce
      : Duration(milliseconds: loadStopDebounceMs!);
}

class ProviderLobbyGame extends LobbyGame {
  const ProviderLobbyGame({
    required this.info,
    this.providerOverride,
    this.apiGameCode,
    this.isNew = false,
    this.sortOrder = 0,
  });

  final ProductProviderInfo info;

  final ProviderOverride? providerOverride;

  final String? apiGameCode;

  final bool isNew;

  @override
  final int sortOrder;

  @override
  String get providerId => info.providerId;

  @override
  String get providerName => info.providerName;

  @override
  String get productId => info.productId;

  @override
  String get gameCode => info.gameCode;

  @override
  String get gameName => info.gameName;

  @override
  String get imageName => info.imageName;

  @override
  String get providerTagName => info.providerTagName;

  @override
  String get ref => info.shortCode;

  @override
  int get gameId => info.gameId;

  @override
  String? get gameBundle => null;

  @override
  SunLaunchStrategy get launchStrategy => SunLaunchStrategy.standard;

  @override
  SunGameStatus get status => SunGameStatus.active;

  @override
  SunGameTag get tag => isNew ? SunGameTag.newGame : SunGameTag.none;

  @override
  List<SunOrientation> orientationsFor(SunDeviceKind kind) {
    final declared = SunOrientation.expandAll(
      providerOverride?.orientationsFor(kind) ?? const <String>[],
    );
    if (declared.isNotEmpty) return declared;
    return info.orientation == DefineOrientation.landscape
        ? SunOrientation.landscape
        : SunOrientation.portrait;
  }

  @override
  bool get enableHostMessage => false;

  @override
  bool get redirectOnIOSSafariWeb => false;

  @override
  bool get redirectOnMobileWeb => false;

  @override
  bool get forceLandscapeViewportOnIpad =>
      providerOverride?.forceLandscapeViewportOnIpad ?? false;

  @override
  bool get openInNewTabOnIOSSafariWeb =>
      providerOverride?.openInNewTabOnIOSSafariWeb ?? false;

  @override
  bool get requiresSessionGuard => providerOverride?.requiresSessionGuard ?? false;

  @override
  bool? get scaffoldControls => providerOverride?.scaffoldControls;

  @override
  bool get useSafeArea => providerOverride?.useSafeArea ?? true;

  @override
  Duration get loadStopDebounce {
    final ms = providerOverride?.loadStopDebounceMs;
    return ms == null
        ? LobbyGame.defaultLoadStopDebounce
        : Duration(milliseconds: ms);
  }

  @override
  String get effectiveApiGameCode =>
      (apiGameCode != null && apiGameCode!.isNotEmpty)
          ? apiGameCode!
          : info.gameCode;
}
