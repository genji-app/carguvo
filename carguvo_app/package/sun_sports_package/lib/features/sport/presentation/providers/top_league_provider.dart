import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_events/sport_events.dart'
    show topLeagueEventsTimeRange, topLeaguesFromPopular;

import 'package:sun_sports/core/services/models/api_v2/events_request_model.dart';
import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/league_pin_item.dart';
import 'package:sun_sports/providers/infra_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/events_v2_provider.dart';

final topLeagueEventsProvider = FutureProvider.autoDispose
    .family<List<LeagueModelV2>, int>((ref, sportId) async {
      ref.keepAlive();

      final token = CancelToken();
      ref.onDispose(token.cancel);

  ref.listen(staleOfferHealBusProvider, (prev, next) {
    ref.invalidateSelf();
  });

      final http = ref.read(sbHttpManagerProvider);
      final pinList = await http.getLeaguesPin(sportId, cancelToken: token);

      if (pinList.isEmpty) {
        final popular = await http.getPopularLeagues();
        return topLeaguesFromPopular(
          popular,
          sportId: sportId,
          sportIdOf: (l) => l.sportId,
        );
      }

      final leagueIds = pinList.map((e) => e.leagueId).toList();
      final request = EventsRequestModel(
        sportId: sportId,
        timeRange: topLeagueEventsTimeRange,
        leagueIds: leagueIds,
      );
      final leaguesFromApi = await http.getEventsV2(
        request,
        cancelToken: token,
      );
      final byId = {for (final l in leaguesFromApi) l.leagueId: l};

      return pinList.map((pin) {
        final existing = byId[pin.leagueId];
        if (existing != null) {
          return existing;
        }
        return LeagueModelV2(
          sportId: sportId,
          leagueId: pin.leagueId,
          leagueName: pin.name,
          leagueNameEn: pin.name,
          leagueLogo: pin.logoUrl,
          priorityOrder: pin.sortOrder,
          events: const [],
        );
      }).toList();
    });
