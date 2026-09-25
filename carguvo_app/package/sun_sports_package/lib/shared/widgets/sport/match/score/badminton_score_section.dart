import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/models/api_v2/event_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/score_model_v2.dart';
import 'package:sun_sports/shared/widgets/sport/match/score/set_based_score_section.dart';

class BadmintonScoreSection extends StatelessWidget {
  final EventModelV2 event;
  final bool isDesktop;

  const BadmintonScoreSection({super.key, required this.event, this.isDesktop = false});

  @override
  Widget build(BuildContext context) {
    final score = event.score;
    if (score is! BadmintonScoreModelV2) {
      return SetBasedScoreSection(
        eventId: event.eventId,
        liveScores: const [],
        homeSetScore: 0,
        awaySetScore: 0,
        homeTotalPoint: 0,
        awayTotalPoint: 0,
        fixedColumnCount: 3,
        isDesktop: isDesktop,
      );
    }

    return SetBasedScoreSection(
      eventId: event.eventId,
      liveScores: score.liveScores,
      homeSetScore: score.homeGameScore,
      awaySetScore: score.awayGameScore,
      homeTotalPoint: score.homeTotalPoint,
      awayTotalPoint: score.awayTotalPoint,
      fixedColumnCount: 3,
      isDesktop: isDesktop,
    );
  }
}
