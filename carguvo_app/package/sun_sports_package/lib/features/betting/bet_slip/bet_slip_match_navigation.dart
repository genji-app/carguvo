import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/services/models/api_v2/event_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/sport_constants.dart';
import 'package:sun_sports/core/services/network/sb_http_manager.dart';
import 'package:sun_sports/core/services/repositories/my_bet_repository/models/bet_slip.dart';
import 'package:sun_sports/features/bet_detail/presentation/providers/bet_detail_v2_provider.dart';
import 'package:sun_sports/features/my_bet_hub/my_bet_hub_providers.dart';
import 'package:sun_sports/features/profile_hub/profile_hub_providers.dart';
import 'package:sun_sports/features/sport/data/adapters/sport_socket_adapter_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/events_v2_filter_provider.dart';
import 'package:sun_sports/providers/main_content_provider.dart';

import 'bet_slip_ui_extensions.dart';

extension BetSlipMatchNavigationX on BetSlip {
  int get matchEventId => int.tryParse(matchId) ?? 0;

  bool get canViewMatch =>
      !isSettled && !isOutright && !isComboBet && matchEventId > 0;
}

void openMatchDetailFromBetSlip(WidgetRef ref, BetSlip bet) {
  final eventId = bet.matchEventId;
  if (eventId <= 0) return;

  final sport = SportType.fromId(bet.sportId) ?? SportType.soccer;

  SbHttpManager.instance.sportTypeId = sport.id;
  ref.read(selectedSportV2Provider.notifier).state = sport;
  ref
      .read(sportSocketAdapterProvider)
      .subscriptionManager
      .setActiveSport(sport.id);

  ref.read(selectedEventV2Provider.notifier).state = EventModelV2(
    sportId: bet.sportId,
    eventId: eventId,
    startDate: bet.startDate.toIso8601String(),
    startTime: bet.startDate.millisecondsSinceEpoch,
    eventStatsId: bet.eventStatsId,
    homeId: bet.homeId,
    awayId: bet.awayId,
    homeName: bet.homeName ?? '',
    awayName: bet.awayName ?? '',
    isLive: bet.isMatchLive,
    markets: const [],
  );
  ref.read(selectedLeagueV2Provider.notifier).state = LeagueModelV2(
    events: const [],
    sportId: bet.sportId,
    leagueId: 0,
    leagueName: bet.leagueName,
    leagueNameEn: bet.leagueName,
    leagueLogo: '',
  );

  ref.read(myBetHubControllerProvider).close();
  ref.read(profileHubControllerProvider).close();

  ref.read(mainContentProvider.notifier).goToBetDetail();
}
