import 'package:flutter/material.dart';

import 'package:sun_sports/features/mini_game/data/dragon_ball_http_repository.dart';
import 'package:sun_sports/mini/dragon_ball/sub_views/dragon_ball_history_detail_view.dart';
import 'package:sun_sports/mini/dragon_ball_lanscape/sub_views/dragon_ball_landscape_sub_view_scaffold.dart';

class DragonBallLandscapeHistoryDetailView extends StatelessWidget {
  final DragonBallHistoryItem item;
  final VoidCallback onBack;
  final VoidCallback onClose;
  final BorderRadius borderRadius;

  const DragonBallLandscapeHistoryDetailView({
    required this.item,
    required this.onBack,
    required this.onClose,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DragonBallLandscapeSubViewScaffold(
      title: '#${item.sessionId}',
      onBack: onBack,
      onClose: onClose,
      borderRadius: borderRadius,
      child: DragonBallHistoryDetailContent(item: item),
    );
  }
}
