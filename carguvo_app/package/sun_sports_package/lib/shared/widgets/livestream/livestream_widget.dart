import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/shared/widgets/sport/match/match_notice_rive_animation.dart';

import 'package:sun_sports/shared/widgets/livestream/livestream_widget_mobile.dart'
    if (dart.library.html) 'package:sun_sports/shared/widgets/livestream/livestream_widget_web.dart';

class LivestreamWidget extends StatelessWidget {
  final String url;

  final LeagueEventData? eventData;

  final int sportId;

  final VoidCallback? onPiPActivated;

  final MatchNoticeOverlayData? notice;

  const LivestreamWidget({
    super.key,
    required this.url,
    this.eventData,
    this.sportId = 1,
    this.onPiPActivated,
    this.notice,
  });

  @override
  Widget build(BuildContext context) => LivestreamWidgetImpl(
    url: url,
    eventData: eventData,
    sportId: sportId,
    onPiPActivated: onPiPActivated,
    notice: notice,
  );
}
