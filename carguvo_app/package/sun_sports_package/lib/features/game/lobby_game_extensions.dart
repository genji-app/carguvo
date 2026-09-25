import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider_game_manager/provider_game_manager.dart';
import 'package:sun_sports/core/constants/i18n.dart';

extension LobbyGameX on LobbyGame {
  String get imagePath => imageName;

  String? get tagPath => tag.assetName.isEmpty ? null : tag.assetName;

  String? get providerTagPath =>
      providerTagName.isEmpty ? null : providerTagName;

  ValueKey<String> buildWidgetKey(String prefix) => ValueKey('$prefix-$ref');

  SunDeviceKind deviceKindOf(BuildContext context) =>
      MediaQuery.sizeOf(context).shortestSide < 600
          ? SunDeviceKind.phone
          : SunDeviceKind.tablet;

  List<SunOrientation> orientationsIn(BuildContext context) =>
      orientationsFor(deviceKindOf(context));

  bool shouldForceLandscapeViewport(BuildContext context) {
    if (!forceLandscapeViewportOnIpad) return false;
    if (deviceKindOf(context) != SunDeviceKind.tablet) return false;
    final tablet = orientationsFor(SunDeviceKind.tablet);
    return tablet.isNotEmpty && tablet.every((o) => o.isLandscape);
  }

  bool get showScaffoldControls => scaffoldControls == true;

  bool get isPlayable => status.isPlayable;

  bool get isNativeGame => launchStrategy == SunLaunchStrategy.native;
}

extension SunOrientationX on SunOrientation {
  DeviceOrientation get deviceOrientation => switch (this) {
        SunOrientation.portraitUp => DeviceOrientation.portraitUp,
        SunOrientation.portraitDown => DeviceOrientation.portraitDown,
        SunOrientation.landscapeLeft => DeviceOrientation.landscapeLeft,
        SunOrientation.landscapeRight => DeviceOrientation.landscapeRight,
      };
}

extension LobbyCategoryX on LobbyCategory {
  String get displayName =>
      I18n.translationMap[translationKey] ?? id;

  String iconPath({bool active = false}) => active ? iconActive : icon;

  bool get hasIcon => icon.isNotEmpty;

  bool get isAll => source == CategorySource.lobby;
}

extension LobbyGroupBlockX on LobbyGroupBlock {
  String get displayTitle {
    final key = titleKey;
    if (key != null && key.isNotEmpty) {
      final translated = I18n.translationMap[key];
      if (translated != null && translated.isNotEmpty) return translated;
    }
    return title ?? collectionId ?? '';
  }
}
