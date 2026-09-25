import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientation_guard/orientation_guard.dart';

import 'package:sun_sports/shared/widgets/orientation/app_orientation_provider.dart';

int miniGameQuarterTurns(BuildContext context, OrientationPolicy? policy) {
  final targets = policy?.targets;
  if (targets == null || targets.isEmpty) return 0;

  final wantsLandscape = targets.every((t) => t.isLandscape);
  final wantsPortrait = targets.every((t) => t.isPortrait);
  if (!wantsLandscape && !wantsPortrait) return 0;

  final deviceLandscape =
      MediaQuery.orientationOf(context) == Orientation.landscape;
  if (wantsLandscape && !deviceLandscape) return 1;
  if (wantsPortrait && deviceLandscape) return 3;
  return 0;
}

class MiniGameOrientationBuilder extends ConsumerWidget {
  const MiniGameOrientationBuilder({required this.builder, super.key});

  final Widget Function(BuildContext context, int quarterTurns) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(orientationControllerProvider);
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) =>
          builder(context, miniGameQuarterTurns(context, controller.activePolicy)),
    );
  }
}

class MiniGameRotated extends StatelessWidget {
  const MiniGameRotated({
    required this.quarterTurns,
    required this.child,
    this.swapMediaQuery = true,
    super.key,
  });

  final int quarterTurns;
  final bool swapMediaQuery;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    var content = child;
    if (swapMediaQuery) {
      final mq = MediaQuery.of(context);
      final swapped = quarterTurns % 2 == 1;
      content = MediaQuery(
        data: mq.copyWith(
          size: swapped ? Size(mq.size.height, mq.size.width) : mq.size,
          padding: _rotate(mq.padding, quarterTurns),
          viewPadding: _rotate(mq.viewPadding, quarterTurns),
          viewInsets: _rotate(mq.viewInsets, quarterTurns),
        ),
        child: content,
      );
    }
    return RotatedBox(quarterTurns: quarterTurns, child: content);
  }

  static EdgeInsets _rotate(EdgeInsets i, int turns) =>
      switch (turns % 4) {
        1 => EdgeInsets.fromLTRB(i.top, i.right, i.bottom, i.left),
        2 => EdgeInsets.fromLTRB(i.right, i.bottom, i.left, i.top),
        3 => EdgeInsets.fromLTRB(i.bottom, i.left, i.top, i.right),
        _ => i,
      };
}
