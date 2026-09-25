import 'package:flutter/foundation.dart';

import '../../platform_ui/platform_ui.dart';
import 'fullscreen_strategy.dart';

class NativeImmersiveStrategy implements FullscreenStrategy {
  NativeImmersiveStrategy(this._platformUi);

  final PlatformUiController _platformUi;
  final _notifier = ValueNotifier<bool>(false);

  @override
  String get name => 'NativeImmersive';

  @override
  ValueListenable<bool> get isFullscreen => _notifier;

  @override
  bool get needsUserGesture => false;

  @override
  Future<bool> enter() async {
    try {
      await _platformUi.apply(const PlatformUiConfig.immersiveSticky());
      _notifier.value = true;
      return true;
    } on Object catch (_) {
      return false;
    }
  }

  @override
  Future<void> exit() async {
    try {
      await _platformUi.restore();
      _notifier.value = false;
    } on Object catch (_) {
    }
  }

  @override
  void dispose() {
    _notifier.dispose();
  }

  @override
  GateSetup? setupGate({
    required VoidCallback onSatisfied,
    VoidCallback? onCancel,
  }) =>
      null;

  @override
  void teardownGate() {}
}
