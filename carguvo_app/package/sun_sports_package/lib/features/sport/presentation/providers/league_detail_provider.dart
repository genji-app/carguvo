import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/core/services/models/api_v2/events_request_model.dart';
import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';
import 'package:sun_sports/providers/infra_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/events_v2_provider.dart';

class SelectedLeagueInfo {
  final int sportId;
  final int leagueId;
  final String leagueName;
  final String leagueLogo;

  const SelectedLeagueInfo({
    required this.sportId,
    required this.leagueId,
    required this.leagueName,
    required this.leagueLogo,
  });
}

final selectedLeagueInfoProvider = StateProvider<SelectedLeagueInfo?>(
  (ref) => null,
);

final leagueDetailEventsProvider = FutureProvider.autoDispose
    .family<List<LeagueModelV2>, SelectedLeagueInfo>((ref, info) async {
      final token = CancelToken();
      ref.onDispose(token.cancel);

  ref.listen(staleOfferHealBusProvider, (prev, next) {
    ref.invalidateSelf();
  });

      final http = ref.read(sbHttpManagerProvider);
      final request = EventsRequestModel(
        sportId: info.sportId,
        timeRange: 4,
        leagueIds: [info.leagueId],
      );
      final leagues = await http.getEventsV2(request, cancelToken: token);

      return leagues;
    });
