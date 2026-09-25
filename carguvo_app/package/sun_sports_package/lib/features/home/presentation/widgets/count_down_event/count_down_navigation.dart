import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/providers/main_content_provider.dart';
import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/sport_constants.dart';
import 'package:sun_sports/features/sport/presentation/providers/league_detail_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/top_league_provider.dart';

const String _kEventCupNamePattern = 'Giải vô địch các quốc gia Đông Nam Á';

void prewarmEventCupData(WidgetRef ref) {
  // ignore: unused_result, đây là fire-and-forget để kích hoạt cache.
  ref.read(topLeagueEventsProvider(SportType.soccer.id));
}

Future<void> navigateToEventCup(WidgetRef ref) async {
  final mainContent = ref.read(mainContentProvider.notifier);

  final List<LeagueModelV2> leagues;
  try {
    leagues = await ref.read(
      topLeagueEventsProvider(SportType.soccer.id).future,
    );
  } catch (_) {
    mainContent.goToSport();
    return;
  }

  final fifaWc = leagues
      .where(
        (league) =>
            league.displayName.toLowerCase().contains(
              _kEventCupNamePattern.toLowerCase(),
            ),
      )
      .firstOrNull;

  if (fifaWc == null) {
    mainContent.goToSport();
    return;
  }

  ref.read(selectedLeagueInfoProvider.notifier).state = SelectedLeagueInfo(
    sportId: fifaWc.sportId,
    leagueId: fifaWc.leagueId,
    leagueName: fifaWc.displayName,
    leagueLogo: fifaWc.leagueLogo,
  );
  mainContent.goToLeagueDetail();
}
