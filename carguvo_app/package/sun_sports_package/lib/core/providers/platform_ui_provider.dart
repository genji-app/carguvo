import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fullscreen_guard/fullscreen_guard.dart';

final platformUiControllerProvider = Provider<PlatformUiController>((ref) {
  final controller = createPlatformUiController();
  ref.onDispose(controller.dispose);
  return controller;
});
