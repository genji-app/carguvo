import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/services/models/api_v2/event_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/event_model_v2_extensions.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/sport/presentation/providers/event_live_provider.dart';
import 'package:sun_sports/shared/widgets/live/live_consumers.dart';

class SoccerScoreSection extends StatelessWidget {
  final EventModelV2 event;

  final bool showCards;

  const SoccerScoreSection({
    required this.event,
    super.key,
    this.showCards = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (showCards) ...[
          Consumer(
            builder: (context, ref, _) {
              final live = ref.watch(
                eventLiveProvider.select((state) {
                  final d = state.getEvent(event.eventId);
                  return d == null
                      ? null
                      : (
                          d.yellowCardsHome,
                          d.yellowCardsAway,
                          d.redCardsHome,
                          d.redCardsAway,
                        );
                }),
              );
              return Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CardsColumn(
                    homeCount: live?.$1 ?? event.yellowCardsHome,
                    awayCount: live?.$2 ?? event.yellowCardsAway,
                    color: const Color(0xFFD4A017),
                    textColor: const Color(0xFF1A1A1A),
                  ),
                  const SizedBox(width: 4),
                  _CardsColumn(
                    homeCount: live?.$3 ?? event.redCardsHome,
                    awayCount: live?.$4 ?? event.redCardsAway,
                    color: const Color(0xFFCC3333),
                    textColor: const Color(0xFFFFFEF5),
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 4),
        ],
        _ScoreColumn(
          eventId: event.eventId,
          homeScore: event.displayHomeScore,
          awayScore: event.displayAwayScore,
        ),
      ],
    );
  }
}

class _CardsColumn extends StatelessWidget {
  final int homeCount;
  final int awayCount;
  final Color color;
  final Color textColor;

  const _CardsColumn({
    required this.homeCount,
    required this.awayCount,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      child: Column(
        children: [
          _CardCell(count: homeCount, color: color, textColor: textColor),
          _CardCell(count: awayCount, color: color, textColor: textColor),
        ],
      ),
    );
  }
}

class _CardCell extends StatelessWidget {
  final int count;
  final Color color;
  final Color textColor;

  const _CardCell({
    required this.count,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      alignment: Alignment.center,
      child: count > 0
          ? Container(
              width: 16,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
              alignment: Alignment.center,
              child: Text(
                '$count',
                style: AppTextStyles.textStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: textColor,
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

class _ScoreColumn extends StatelessWidget {
  final int eventId;
  final int homeScore;
  final int awayScore;

  const _ScoreColumn({
    required this.eventId,
    required this.homeScore,
    required this.awayScore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      decoration: BoxDecoration(
        color: const Color(0x0AFFFFFF),
        border: Border.all(color: const Color(0xFF393836)),
        borderRadius: BorderRadius.circular(4),
      ),
      margin: const EdgeInsets.only(top: 5.5),
      child: Column(
        children: [
          Container(
            height: 25.5,
            alignment: Alignment.center,
            child: LiveSingleScoreDisplay(
              eventId: eventId,
              isHome: true,
              initialValue: homeScore,
            ),
          ),
          Container(
            height: 25.5,
            alignment: Alignment.center,
            child: LiveSingleScoreDisplay(
              eventId: eventId,
              isHome: false,
              initialValue: awayScore,
            ),
          ),
        ],
      ),
    );
  }
}
