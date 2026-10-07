import 'package:flutter/material.dart';

import 'package:app_package/shared/widgets/tracker/tracker_widget_mobile.dart'
    if (dart.library.html) 'package:app_package/shared/widgets/tracker/tracker_widget_web.dart';

class TrackerWidget extends StatelessWidget {
  final int eventStatsId;

  final int sportId;

  final double height;

  final double borderRadius;

  final bool hidden;

  final bool ignoreOverlayBlock;

  final double croppedTop;

  const TrackerWidget({
    super.key,
    required this.eventStatsId,
    required this.sportId,
    this.height = 400,
    this.borderRadius = 0,
    this.hidden = false,
    this.ignoreOverlayBlock = false,
    this.croppedTop = 0,
  });

  @override
  Widget build(BuildContext context) => TrackerWidgetImpl(
    eventStatsId: eventStatsId,
    sportId: sportId,
    height: height,
    borderRadius: borderRadius,
    hidden: hidden,
    ignoreOverlayBlock: ignoreOverlayBlock,
    croppedTop: croppedTop,
  );
}
