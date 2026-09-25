import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:orientation_guard/orientation_guard.dart';
import 'package:provider_game_manager/provider_game_manager.dart';

abstract class GameOrientationResolver extends OrientationPolicyResolver<LobbyGame> {
  @override
  OrientationPolicy resolve(BuildContext context, LobbyGame game);
}

class DefaultGameOrientationResolver extends GameOrientationResolver {
  DefaultGameOrientationResolver({OrientationExperienceClassifier? classifier})
      : _classifier = classifier ?? OrientationExperienceClassifier.standard;

  final OrientationExperienceClassifier _classifier;

  @override
  OrientationPolicy resolve(BuildContext context, LobbyGame game) {
    final experience = _classifier.classify(context);

    final orientations = game.orientationsFor(switch (experience) {
      OrientationExperience.mobile => SunDeviceKind.phone,
      OrientationExperience.tablet => SunDeviceKind.tablet,
      OrientationExperience.largeTablet ||
      OrientationExperience.desktop => SunDeviceKind.desktop,
    });

    return OrientationPolicy(
      targets: orientations.map((o) => o.deviceOrientation).toList(),
      debugLabel:
          'LobbyGame(${game.providerId} / experience: ${experience.name})',
    );
  }
}

extension SunOrientationDeviceOrientation on SunOrientation {
  DeviceOrientation get deviceOrientation {
    switch (this) {
      case SunOrientation.portraitUp:
        return DeviceOrientation.portraitUp;
      case SunOrientation.portraitDown:
        return DeviceOrientation.portraitDown;
      case SunOrientation.landscapeLeft:
        return DeviceOrientation.landscapeLeft;
      case SunOrientation.landscapeRight:
        return DeviceOrientation.landscapeRight;
    }
  }
}
