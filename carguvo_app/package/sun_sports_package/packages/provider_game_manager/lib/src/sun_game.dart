part of '../provider_game_manager.dart';

enum SunGameTag {
  none,

  newGame,

  comingSoon;

  String get assetName => switch (this) {
    SunGameTag.none => '',
    SunGameTag.newGame => 'tag_new.webp',
    SunGameTag.comingSoon => 'tag_coming_soon.webp',
  };
}

enum SunGameStatus {
  active,

  comingSoon,

  maintenance,

  hidden,

  notFound;

  bool get isPlayable => this == SunGameStatus.active;

  bool get isVisible =>
      this == SunGameStatus.active ||
      this == SunGameStatus.comingSoon ||
      this == SunGameStatus.maintenance;
}

enum SunOrientation {
  portraitUp,
  portraitDown,
  landscapeLeft,
  landscapeRight;

  bool get isPortrait =>
      this == SunOrientation.portraitUp || this == SunOrientation.portraitDown;

  bool get isLandscape => !isPortrait;

  static const List<SunOrientation> portrait = [portraitUp, portraitDown];
  static const List<SunOrientation> landscape = [landscapeLeft, landscapeRight];
  static const List<SunOrientation> all = [
    portraitUp,
    landscapeLeft,
    portraitDown,
    landscapeRight,
  ];

  static List<SunOrientation> expand(String value) {
    switch (value.toLowerCase().trim()) {
      case 'portrait':
        return portrait;
      case 'landscape':
        return landscape;
      case 'all':
        return all;
      case 'portraitup':
        return const [portraitUp];
      case 'portraitdown':
        return const [portraitDown];
      case 'landscapeleft':
        return const [landscapeLeft];
      case 'landscaperight':
        return const [landscapeRight];
      default:
        return const [];
    }
  }

  static List<SunOrientation> expandAll(Iterable<String> values) {
    final out = <SunOrientation>{};
    for (final v in values) {
      out.addAll(expand(v));
    }
    return List.unmodifiable(out);
  }
}

enum SunDeviceKind {
  phone,

  tablet,

  desktop,
}

enum SunLaunchStrategy {
  standard,

  fish,

  iframe,

  sicbo,

  card,

  iframeSession,

  native,

  underDevelopment,

  unknown;

  static SunLaunchStrategy fromName(String? value) {
    if (value == null) return unknown;
    final key = value.trim();
    for (final s in SunLaunchStrategy.values) {
      if (s.name == key) return s;
    }
    final normalized = key.toLowerCase().replaceAll('_', '');
    for (final s in SunLaunchStrategy.values) {
      if (s.name.toLowerCase() == normalized) return s;
    }
    return unknown;
  }
}

sealed class SunReturnStrategy {
  const SunReturnStrategy();

  const factory SunReturnStrategy.appClose() = SunAppCloseReturn;

  const factory SunReturnStrategy.webClose() = SunWebCloseReturn;

  const factory SunReturnStrategy.windowClose() = SunWindowCloseReturn;

  const factory SunReturnStrategy.redirect(String url) = SunRedirectReturn;

  const factory SunReturnStrategy.home() = SunHomeReturn;
}

class SunAppCloseReturn extends SunReturnStrategy {
  const SunAppCloseReturn();
}

class SunWebCloseReturn extends SunReturnStrategy {
  const SunWebCloseReturn();
}

class SunWindowCloseReturn extends SunReturnStrategy {
  const SunWindowCloseReturn();
}

class SunRedirectReturn extends SunReturnStrategy {
  const SunRedirectReturn(this.url);

  final String url;
}

class SunHomeReturn extends SunReturnStrategy {
  const SunHomeReturn();
}

sealed class SunGameUrlResult {
  const SunGameUrlResult();
}

class SunUrlSuccess extends SunGameUrlResult {
  const SunUrlSuccess(this.url, this.game);

  final String url;
  final SunGameDetail game;
}

class SunUrlNative extends SunGameUrlResult {
  const SunUrlNative(this.gameId, this.gameBundle);

  final int gameId;
  final String gameBundle;
}

class SunUrlBlocked extends SunGameUrlResult {
  const SunUrlBlocked(this.gameId, this.status);

  final int gameId;
  final SunGameStatus status;
}

class SunUrlUnavailable extends SunGameUrlResult {
  const SunUrlUnavailable(this.gameId, {required this.reason});

  final int gameId;
  final String reason;
}
