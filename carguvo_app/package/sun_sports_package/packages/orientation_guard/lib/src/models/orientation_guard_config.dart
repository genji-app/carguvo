enum OrientationSystemType {
  auto,

  mobile,

  tablet,

  desktop;

  bool get isHandheld => this == mobile || this == tablet;

  bool get isDesktop => this == desktop;
}

class OrientationGuardConfig {
  const OrientationGuardConfig({
    this.forceEnforcementOnDesktopWeb = false,
    this.systemType = OrientationSystemType.auto,
  });

  final bool forceEnforcementOnDesktopWeb;

  final OrientationSystemType systemType;

  static const production = OrientationGuardConfig();

  static const devTesting = OrientationGuardConfig(
    forceEnforcementOnDesktopWeb: true,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrientationGuardConfig &&
          forceEnforcementOnDesktopWeb == other.forceEnforcementOnDesktopWeb &&
          systemType == other.systemType;

  @override
  int get hashCode => Object.hash(forceEnforcementOnDesktopWeb, systemType);

  @override
  String toString() =>
      'OrientationGuardConfig(forceEnforcementOnDesktopWeb: $forceEnforcementOnDesktopWeb, systemType: $systemType)';
}
