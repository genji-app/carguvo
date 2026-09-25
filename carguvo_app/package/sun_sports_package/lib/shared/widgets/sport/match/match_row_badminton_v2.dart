import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/services/models/api_v2/event_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/event_model_v2_extensions.dart';
import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/odds_style_model_v2.dart';
import 'package:sun_sports/features/sport/presentation/providers/events_v2_filter_provider.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/shared/widgets/teams/team_display.dart';
import 'package:sun_sports/shared/widgets/scroll_blocked_tap.dart';
import 'package:sun_sports/shared/widgets/sport/match/match_row_shared_v2.dart';
import 'package:sun_sports/shared/widgets/sport/match/score/badminton_score_section.dart';
import 'package:sun_sports/shared/widgets/sport/match/score_header_config.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class MatchRowBadmintonV2 extends ConsumerWidget {
  final EventModelV2 event;
  final LeagueModelV2? league;
  final bool isDesktop;

  const MatchRowBadmintonV2({
    required this.event,
    this.league,
    this.isDesktop = false,
    super.key,
  });

  static final _config = ScoreHeaderConfig.forSport(7);

  bool get _canShowStats => event.eventStatsId > 0;
  bool get _canShowTracker => event.eventStatsId > 0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const oddsFormat = OddsFormatV2.decimal;
    final oddsSportId = sportIdForFavoriteEvent(
      event,
      league,
      ref.read(selectedSportV2Provider).id,
    );
    final betColumns = getBetColumnsV2(event, oddsFormat);
    final isLive = event.isLive;
    final matchTime = isLive ? event.liveStatusDisplay : event.formattedTime;
    final (minute, period) = parseMatchTime(matchTime);

    return Container(
      color: AppColorStyles.backgroundQuaternary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NonSoccerHeader(
            config: _config,
            isLive: isLive,
            isDesktop: isDesktop,
            minute: minute,
            period: period,
            eventId: event.eventId,
            sportId: event.sportId,
            initialCurrentSet: extractCurrentSet(event),
            initialSetScore: extractSetScore(event),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildTeams(ref)),
                BadmintonScoreSection(event: event, isDesktop: isDesktop),
              ],
            ),
          ),

          NonSoccerOddsSection(
            sportId: oddsSportId,
            event: event,
            league: league,
            columns: betColumns,
            isDesktop: isDesktop,
          ),

          MatchFooterV2(
            event: event,
            league: league,
            canShowStats: _canShowStats,
            canShowTracker: _canShowTracker,
            showLiveBadge: true,
            onNavigate: () => navigateToBetDetail(ref, event, league),
            onFavoriteTap: () =>
                toggleFavoriteEvent(context, ref, event, league: league),
          ),
        ],
      ),
    );
  }

  Widget _buildTeams(WidgetRef ref) {
    return ScrollBlockedTap(
      showClickCursor: true,
      behavior: HitTestBehavior.opaque,
      onTap: SoundTap.wrap(() => navigateToBetDetail(ref, event, league)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: TeamDisplay(
              teamName: event.homeName,
              teamLogo: event.homeLogo,
              otherTeamLogo: event.awayLogo,
              sportId: event.sportId,
              isHome: true,
              isUpperTeam: event.hasUpperTeam ? event.isHomeUpper : null,
            ),
          ),
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: TeamDisplay(
              teamName: event.awayName,
              teamLogo: event.awayLogo,
              otherTeamLogo: event.homeLogo,
              sportId: event.sportId,
              isHome: false,
              isUpperTeam: event.hasUpperTeam ? event.isAwayUpper : null,
            ),
          ),
        ],
      ),
    );
  }
}
