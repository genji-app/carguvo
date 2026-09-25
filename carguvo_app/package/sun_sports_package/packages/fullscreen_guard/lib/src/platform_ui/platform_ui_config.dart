import 'package:flutter/material.dart';

enum PlatformSystemUiMode {
  edgeToEdge,

  immersive,

  immersiveSticky,

  manual,
}

@immutable
class PlatformUiConfig {
  const PlatformUiConfig({
    this.systemUiMode,
    this.statusBarColor,
    this.statusBarIconBrightness,
    this.statusBarBrightness,
    this.navigationBarColor,
    this.navigationBarIconBrightness,
    this.debugLabel = 'Default',
  });

  const PlatformUiConfig.systemDefault({
    Brightness brightness = Brightness.dark,
    String debugLabel = 'SystemDefault',
  })  : systemUiMode = PlatformSystemUiMode.edgeToEdge,
        statusBarColor = null,
        statusBarIconBrightness =
            brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        statusBarBrightness = brightness,
        navigationBarColor = const Color(0xFF000000),
        navigationBarIconBrightness =
            brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        debugLabel = debugLabel;

  const PlatformUiConfig.immersive({String debugLabel = 'Immersive'})
      : systemUiMode = PlatformSystemUiMode.immersive,
        statusBarColor = null,
        statusBarIconBrightness = null,
        statusBarBrightness = null,
        navigationBarColor = null,
        navigationBarIconBrightness = null,
        debugLabel = debugLabel;

  const PlatformUiConfig.immersiveSticky({String debugLabel = 'ImmersiveSticky'})
      : systemUiMode = PlatformSystemUiMode.immersiveSticky,
        statusBarColor = null,
        statusBarIconBrightness = null,
        statusBarBrightness = null,
        navigationBarColor = null,
        navigationBarIconBrightness = null,
        debugLabel = debugLabel;

  const PlatformUiConfig.edgeToEdge({String debugLabel = 'EdgeToEdge'})
      : systemUiMode = PlatformSystemUiMode.edgeToEdge,
        statusBarColor = null,
        statusBarIconBrightness = null,
        statusBarBrightness = null,
        navigationBarColor = null,
        navigationBarIconBrightness = null,
        debugLabel = debugLabel;

  const PlatformUiConfig.branded({String debugLabel = 'Branded'})
      : systemUiMode = PlatformSystemUiMode.edgeToEdge,
        statusBarColor = const Color(0x00000000),
        statusBarIconBrightness = Brightness.light,
        statusBarBrightness = Brightness.dark,
        navigationBarColor = const Color(0x00000000),
        navigationBarIconBrightness = Brightness.light,
        debugLabel = debugLabel;

  const PlatformUiConfig.splash({String debugLabel = 'Splash'})
      : systemUiMode = PlatformSystemUiMode.manual,
        statusBarColor = null,
        statusBarIconBrightness = null,
        statusBarBrightness = null,
        navigationBarColor = null,
        navigationBarIconBrightness = null,
        debugLabel = debugLabel;

  const PlatformUiConfig.styleOnly({
    this.statusBarColor,
    this.statusBarIconBrightness,
    this.statusBarBrightness,
    this.navigationBarColor,
    this.navigationBarIconBrightness,
    String debugLabel = 'StyleOnly',
  })  : systemUiMode = null,
        debugLabel = debugLabel;

  final PlatformSystemUiMode? systemUiMode;

  final Color? statusBarColor;

  final Brightness? statusBarIconBrightness;

  final Brightness? statusBarBrightness;

  final Color? navigationBarColor;

  final Brightness? navigationBarIconBrightness;

  final String debugLabel;

  bool get hasOverlayStyle =>
      statusBarColor != null ||
      statusBarIconBrightness != null ||
      statusBarBrightness != null ||
      navigationBarColor != null ||
      navigationBarIconBrightness != null;

  PlatformUiConfig merge(PlatformUiConfig other) {
    return PlatformUiConfig(
      systemUiMode: other.systemUiMode ?? systemUiMode,
      statusBarColor: other.statusBarColor ?? statusBarColor,
      statusBarIconBrightness: other.statusBarIconBrightness ?? statusBarIconBrightness,
      statusBarBrightness: other.statusBarBrightness ?? statusBarBrightness,
      navigationBarColor: other.navigationBarColor ?? navigationBarColor,
      navigationBarIconBrightness: other.navigationBarIconBrightness ?? navigationBarIconBrightness,
      debugLabel: '${debugLabel}+${other.debugLabel}',
    );
  }

  PlatformUiConfig copyWith({
    PlatformSystemUiMode? systemUiMode,
    Color? statusBarColor,
    Brightness? statusBarIconBrightness,
    Brightness? statusBarBrightness,
    Color? navigationBarColor,
    Brightness? navigationBarIconBrightness,
    String? debugLabel,
  }) {
    return PlatformUiConfig(
      systemUiMode: systemUiMode ?? this.systemUiMode,
      statusBarColor: statusBarColor ?? this.statusBarColor,
      statusBarIconBrightness: statusBarIconBrightness ?? this.statusBarIconBrightness,
      statusBarBrightness: statusBarBrightness ?? this.statusBarBrightness,
      navigationBarColor: navigationBarColor ?? this.navigationBarColor,
      navigationBarIconBrightness: navigationBarIconBrightness ?? this.navigationBarIconBrightness,
      debugLabel: debugLabel ?? this.debugLabel,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlatformUiConfig &&
          runtimeType == other.runtimeType &&
          systemUiMode == other.systemUiMode &&
          statusBarColor == other.statusBarColor &&
          statusBarIconBrightness == other.statusBarIconBrightness &&
          statusBarBrightness == other.statusBarBrightness &&
          navigationBarColor == other.navigationBarColor &&
          navigationBarIconBrightness == other.navigationBarIconBrightness &&
          debugLabel == other.debugLabel;

  @override
  int get hashCode =>
      systemUiMode.hashCode ^
      statusBarColor.hashCode ^
      statusBarIconBrightness.hashCode ^
      statusBarBrightness.hashCode ^
      navigationBarColor.hashCode ^
      navigationBarIconBrightness.hashCode ^
      debugLabel.hashCode;

  @override
  String toString() => 'PlatformUiConfig('
      'systemUiMode: $systemUiMode, '
      'statusBarColor: $statusBarColor, '
      'statusBarIconBrightness: $statusBarIconBrightness, '
      'statusBarBrightness: $statusBarBrightness, '
      'navigationBarColor: $navigationBarColor, '
      'navigationBarIconBrightness: $navigationBarIconBrightness, '
      'debugLabel: $debugLabel)';
}
