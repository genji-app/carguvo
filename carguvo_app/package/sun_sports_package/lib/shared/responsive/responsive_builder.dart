import 'package:flutter/material.dart';
import 'package:sun_sports/core/constants/breakpoints.dart';
import 'package:sun_sports/shared/domain/enums/responsive_enums.dart';

export 'package:sun_sports/shared/domain/enums/responsive_enums.dart';

class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({required this.builder, super.key});

  final Widget Function(BuildContext context, DeviceType deviceType) builder;

  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= Breakpoints.largeDesktop) {
      return DeviceType.largeDesktop;
    } else if (width >= Breakpoints.desktop) {
      return DeviceType.desktop;
    } else if (width >= Breakpoints.mobile) {
      return DeviceType.tablet;
    } else {
      return DeviceType.mobile;
    }
  }

  static bool isMobile(BuildContext context) =>
      getDeviceType(context) == DeviceType.mobile;

  static bool isTablet(BuildContext context) =>
      getDeviceType(context) == DeviceType.tablet;

  static bool isDesktop(BuildContext context) =>
      getDeviceType(context) == DeviceType.desktop ||
      getDeviceType(context) == DeviceType.largeDesktop;

  static T responsive<T>(
    BuildContext context, {
    required T mobile,
    required T tablet,
    required T desktop,
    T? largeDesktop,
  }) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.largeDesktop:
        return largeDesktop ?? desktop;
      case DeviceType.desktop:
        return desktop;
      case DeviceType.tablet:
        return tablet;
      case DeviceType.mobile:
        return mobile;
    }
  }

  @override
  Widget build(BuildContext context) {
    return builder(context, getDeviceType(context));
  }
}
