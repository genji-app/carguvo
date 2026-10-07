import 'package:flutter/foundation.dart';

class OrientationRuntimeContext {
  const OrientationRuntimeContext({
    required this.platform,
    required this.isWeb,
  });

  final TargetPlatform platform;

  final bool isWeb;

  factory OrientationRuntimeContext.current() => OrientationRuntimeContext(
        platform: defaultTargetPlatform,
        isWeb: kIsWeb,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrientationRuntimeContext &&
          runtimeType == other.runtimeType &&
          platform == other.platform &&
          isWeb == other.isWeb;

  @override
  int get hashCode => platform.hashCode ^ isWeb.hashCode;

  @override
  String toString() => 'OrientationRuntimeContext(platform: $platform, isWeb: $isWeb)';
}
