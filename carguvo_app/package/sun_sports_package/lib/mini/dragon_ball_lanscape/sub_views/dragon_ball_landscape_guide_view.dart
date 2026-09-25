import 'package:flutter/material.dart';

import 'package:sun_sports/mini/dragon_ball/sub_views/dragon_ball_guide_view.dart';
import 'package:sun_sports/mini/dragon_ball_lanscape/sub_views/dragon_ball_landscape_sub_view_scaffold.dart';

class DragonBallLandscapeGuideView extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onClose;
  final BorderRadius borderRadius;

  const DragonBallLandscapeGuideView({
    required this.onBack,
    required this.onClose,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DragonBallLandscapeSubViewScaffold(
      title: 'Hướng dẫn',
      onBack: onBack,
      onClose: onClose,
      borderRadius: borderRadius,
      child: const DragonBallGuideContent(),
    );
  }
}
