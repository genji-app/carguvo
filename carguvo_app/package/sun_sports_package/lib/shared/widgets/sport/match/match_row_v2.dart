import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/services/models/api_v2/event_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';
import 'package:sun_sports/shared/widgets/sport/match/match_row_soccer_v2.dart';
import 'package:sun_sports/shared/widgets/sport/match/match_row_basketball_v2.dart';
import 'package:sun_sports/shared/widgets/sport/match/match_row_tennis_v2.dart';
import 'package:sun_sports/shared/widgets/sport/match/match_row_volleyball_v2.dart';
import 'package:sun_sports/shared/widgets/sport/match/match_row_badminton_v2.dart';

class MatchRowV2 extends ConsumerWidget {
  final EventModelV2 event;
  final LeagueModelV2? league;
  final bool isDesktop;
  final VoidCallback? onTap;

  const MatchRowV2({
    required this.event,
    this.league,
    this.isDesktop = false,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (event.sportId) {
      2 => MatchRowBasketballV2(
          event: event,
          league: league,
          isDesktop: isDesktop,
        ),
      4 => MatchRowTennisV2(
          event: event,
          league: league,
          isDesktop: isDesktop,
        ),
      5 => MatchRowVolleyballV2(
          event: event,
          league: league,
          isDesktop: isDesktop,
        ),
      7 => MatchRowBadmintonV2(
          event: event,
          league: league,
          isDesktop: isDesktop,
        ),
      _ => MatchRowSoccerV2(
          event: event,
          league: league,
          isDesktop: isDesktop,
        ),
    };
  }
}
