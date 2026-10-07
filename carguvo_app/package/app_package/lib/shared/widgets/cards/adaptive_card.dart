import 'package:flutter/material.dart';
import '../../responsive/responsive_builder.dart';

class AdaptiveCard extends StatelessWidget {
  final Widget child;

  const AdaptiveCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final elevation = ResponsiveBuilder.isDesktop(context) ? 2.0 : 1.0;
    return Card(elevation: elevation, child: child);
  }
}
