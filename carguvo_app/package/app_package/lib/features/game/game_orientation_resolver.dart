export 'package:game_orientation/game_orientation.dart'
    show GameOrientationResolver;

import 'package:game_orientation/game_orientation.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final gameOrientationResolverProvider = Provider(
  (ref) => DefaultGameOrientationResolver(),
);
