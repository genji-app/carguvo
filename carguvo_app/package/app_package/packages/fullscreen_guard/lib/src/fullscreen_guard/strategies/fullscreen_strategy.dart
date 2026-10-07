import 'package:flutter/foundation.dart';

@immutable
class GateSetup {
  const GateSetup({
    this.requiresNativeSwipe = false,
  });

  final bool requiresNativeSwipe;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GateSetup &&
          runtimeType == other.runtimeType &&
          requiresNativeSwipe == other.requiresNativeSwipe;

  @override
  int get hashCode => requiresNativeSwipe.hashCode;
}

abstract class FullscreenStrategy {
  String get name;

  ValueListenable<bool> get isFullscreen;

  bool get needsUserGesture;

  Future<bool> enter();

  Future<void> exit();

  GateSetup? setupGate({
    required VoidCallback onSatisfied,
    VoidCallback? onCancel,
  }) {
    return null;
  }

  void teardownGate() {}

  void dispose();
}
