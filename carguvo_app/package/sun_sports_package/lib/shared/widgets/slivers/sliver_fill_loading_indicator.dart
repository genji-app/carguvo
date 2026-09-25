import 'package:flutter/material.dart';

import 'package:sun_sports/shared/animations/animations.dart';
import 'package:sun_sports/shared/widgets/status_information/status_information.dart';

class SliverFillLoadingIndicator extends StatelessWidget {
  const SliverFillLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) => const SliverFillRemaining(
    hasScrollBody: false,
    child: ImmediateOpacityAnimation(
      duration: Durations.medium1,
      child: Center(child: Sun88LoadingIndicator()),
    ),
  );
}
