import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/core/services/models/api_v2/events_request_model.dart';
import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';
import 'package:sun_sports/providers/infra_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/events_v2_provider.dart';

final upcomingLeagueEventsProvider = FutureProvider.autoDispose
    .family<List<LeagueModelV2>, int>((ref, sportId) async {
      final token = CancelToken();
      ref.onDispose(token.cancel);

  ref.listen(staleOfferHealBusProvider, (prev, next) {
    ref.invalidateSelf();
  });

      final http = ref.read(sbHttpManagerProvider);
      final request = EventsRequestModel(
        sportId: sportId,
        timeRange: 3,
        sortByTime: true,
      );
      final leagues = await http.getEventsV2(request, cancelToken: token);

      return leagues.mergeDuplicateLeagues();
    });
