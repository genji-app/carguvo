import 'package:flutter/material.dart';
import 'responsive_builder.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;
  final Widget? largeDesktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
    this.largeDesktop,
  });

  @override
  Widget build(BuildContext context) => ResponsiveBuilder(
    builder: (context, deviceType) {
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
    },
  );
}
