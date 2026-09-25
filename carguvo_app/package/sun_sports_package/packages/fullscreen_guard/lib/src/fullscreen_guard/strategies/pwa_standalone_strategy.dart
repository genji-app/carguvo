import 'package:flutter/foundation.dart';

import 'fullscreen_strategy.dart';

class PwaStandaloneStrategy implements FullscreenStrategy {
  PwaStandaloneStrategy();

  final _notifier = ValueNotifier<bool>(true);

  @override
  String get name => 'PwaStandalone';

  @override
  ValueListenable<bool> get isFullscreen => _notifier;

  @override
  bool get needsUserGesture => false;

  @override
  Future<bool> enter() async => true;

  @override
  Future<void> exit() async {
    _notifier.value = false;
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
