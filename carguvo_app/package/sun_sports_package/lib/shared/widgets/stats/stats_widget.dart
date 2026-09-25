import 'package:flutter/material.dart';

import 'package:sun_sports/shared/widgets/stats/stats_widget_mobile.dart'
    if (dart.library.html) 'package:sun_sports/shared/widgets/stats/stats_widget_web.dart';

class StatsWidget extends StatelessWidget {
  final int eventStatsId;

  final int sportId;

  final double? height;

  final double? width;

  final bool ignoreOverlayBlock;

  const StatsWidget({
    super.key,
    required this.eventStatsId,
    required this.sportId,
    this.height,
    this.width,
    this.ignoreOverlayBlock = false,
  });

  @override
  Widget build(BuildContext context) => StatsWidgetImpl(
    eventStatsId: eventStatsId,
    sportId: sportId,
    height: height,
    width: width,
    ignoreOverlayBlock: ignoreOverlayBlock,
  );
}
