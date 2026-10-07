import 'package:flutter/material.dart';
import 'package:app_package/shared/animations/animations.dart';
import 'package:app_package/shared/widgets/status_information/status_information.dart';

class SliverLoadingIndicator extends StatelessWidget {
  const SliverLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
    child: ImmediateOpacityAnimation(
      duration: Durations.medium1,
      child: Container(
        padding: const EdgeInsets.all(16),
        alignment: AlignmentDirectional.center,
        child: const Sun88LoadingIndicator(),
      ),
    ),
  );
}
