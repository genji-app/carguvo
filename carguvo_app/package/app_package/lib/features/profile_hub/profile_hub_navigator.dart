import 'package:adaptive_overlay/adaptive_overlay.dart';
import 'package:flutter/widgets.dart';

import 'profile_hub.dart';

typedef ProfileHubNavigator = AdaptiveOverlayNavigator<ProfileHub>;

extension ProfileHubNavigatorX on ProfileHubNavigator {
  Future<T?> pushTo<T>(String routeName, {dynamic arguments}) {
    return pushNamed<T>(routeName, arguments: arguments);
  }

  bool isAt(String routeName) => isCurrent(routeName);

  Future<void> pushAndRemoveUntilRoot(
    String routeName, {
    bool checkCurrent = true,
  }) async {
    if (checkCurrent && isAt(routeName)) return;

    final wasHidden = !isVisible;

    return pushNamedAndRemoveUntil(
      routeName,
      (route) => route.settings.name == ProfileHub.root,
      arguments: wasHidden ? const {'no_animation': true} : null,
    );
  }
}

extension ProfileHubContextX on BuildContext {
  ProfileHubNavigator get profileNavigator => ProfileHub.of(this);

  void openProfile() => profileNavigator.open();

  void closeProfile() => profileNavigator.close();

  void toggleProfile() => profileNavigator.toggle();
}
