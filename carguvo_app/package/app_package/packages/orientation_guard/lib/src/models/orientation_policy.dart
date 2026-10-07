import 'package:flutter/services.dart';

extension DeviceOrientationX on DeviceOrientation {
  bool get isPortrait =>
      this == DeviceOrientation.portraitUp || this == DeviceOrientation.portraitDown;

  bool get isLandscape =>
      this == DeviceOrientation.landscapeLeft || this == DeviceOrientation.landscapeRight;
}

class DeviceOrientations {
  static const portrait = [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ];

  static const landscape = [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ];

  static const both = [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ];
}

class OrientationPolicy {
  static const portrait = OrientationPolicy(
    targets: DeviceOrientations.portrait,
    debugLabel: 'portrait',
  );

  static const landscape = OrientationPolicy(
    targets: DeviceOrientations.landscape,
    debugLabel: 'landscape',
  );

  static const adaptive = OrientationPolicy(
    targets: DeviceOrientations.both,
    blockOnMismatch: false,
    debugLabel: 'adaptive',
  );

  const OrientationPolicy({
    required this.targets,
    this.blockOnMismatch = true,
    this.ignoreMismatchOnDesktop = true,
    this.debugLabel,
  });

  final List<DeviceOrientation> targets;

  final bool blockOnMismatch;

  final bool ignoreMismatchOnDesktop;

  final String? debugLabel;

  bool get allowsLandscape => targets.any((t) => t.isLandscape);

  bool get allowsPortrait => targets.any((t) => t.isPortrait);

  bool get isAdaptive => allowsLandscape && allowsPortrait;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrientationPolicy &&
          runtimeType == other.runtimeType &&
          _listEquals(targets, other.targets) &&
          blockOnMismatch == other.blockOnMismatch &&
          ignoreMismatchOnDesktop == other.ignoreMismatchOnDesktop &&
          debugLabel == other.debugLabel;

  @override
  int get hashCode =>
      Object.hashAll(targets) ^
      blockOnMismatch.hashCode ^
      ignoreMismatchOnDesktop.hashCode ^
      debugLabel.hashCode;

  bool _listEquals(List<Object?>? a, List<Object?>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    if (identical(a, b)) return true;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }

  @override
  String toString() =>
      'OrientationPolicy(targets: $targets, blockOnMismatch: $blockOnMismatch, ignoreMismatchOnDesktop: $ignoreMismatchOnDesktop, label: $debugLabel)';
}
