import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/sport/data/adapters/sport_socket_adapter_provider.dart';
import 'package:sun_sports/core/services/models/api_v2/sport_constants.dart';
import 'package:sun_sports/features/sport/presentation/providers/events_v2_filter_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/events_v2_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/favorite_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/vibrating_odds_provider.dart';
import 'package:sun_sports/features/sport/presentation/widgets/sport_list_event_container.dart';

class MatchFilterState {
  const MatchFilterState({
    this.selected = MatchFilterType.live,
    this.contentLoading = false,
  });

  final MatchFilterType selected;
  final bool contentLoading;

  MatchFilterState copyWith({
    MatchFilterType? selected,
    bool? contentLoading,
  }) => MatchFilterState(
    selected: selected ?? this.selected,
    contentLoading: contentLoading ?? this.contentLoading,
  );
}

class MatchFilterNotifier extends AutoDisposeNotifier<MatchFilterState> {
  @override
  MatchFilterState build() => const MatchFilterState();

  void selectTab(int index) {
    final currentIndex = MatchFilterType.values.indexOf(state.selected);
    if (index == currentIndex) return;
    final filter = MatchFilterType.values[index];
    state = state.copyWith(selected: filter, contentLoading: true);

    ref.read(vibratingOddsProvider.notifier).clearAll();

    switch (filter) {
      case MatchFilterType.live:
        if (ref.read(selectedSportV2Provider) != SportType.soccer) {
          ref.read(selectedSportV2Provider.notifier).state = SportType.soccer;
          ref
              .read(sportSocketAdapterProvider)
              .subscriptionManager
              .setActiveSport(SportType.soccer.id);
        }
        if (ref.read(selectedTimeRangeV2Provider) != EventTimeRange.live) {
          ref.read(selectedTimeRangeV2Provider.notifier).state =
              EventTimeRange.live;
          ref
              .read(sportSocketAdapterProvider)
              .subscriptionManager
              .setTimeRangeFromString('LIVE');
        }
        ref.read(eventsV2Provider.notifier).refresh();
        break;
      case MatchFilterType.upcoming:
      case MatchFilterType.favorites:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (filter == MatchFilterType.upcoming) {
            ref.read(selectedTimeRangeV2Provider.notifier).state =
                EventTimeRange.todayAndEarly;
            ref.read(eventsV2Provider.notifier).refresh();
          } else {
            final sportId = ref.read(selectedSportV2Provider).id;
            ref
                .read(favoriteProvider.notifier)
                .fetchFavoriteEvents(sportId, forceRefresh: true);
          }
        });
        break;
    }
  }

  void clearContentLoading() {
    state = state.copyWith(contentLoading: false);
  }
}

final matchFilterProvider =
    NotifierProvider.autoDispose<MatchFilterNotifier, MatchFilterState>(
      MatchFilterNotifier.new,
    );

final matchFilterSelectedProvider = Provider.autoDispose<MatchFilterType>(
  (ref) => ref.watch(matchFilterProvider.select((s) => s.selected)),
);

final matchFilterContentLoadingProvider = Provider.autoDispose<bool>(
  (ref) => ref.watch(matchFilterProvider.select((s) => s.contentLoading)),
);

final isCurrentMatchFilterDataLoadingProvider = Provider.autoDispose<bool>((
  ref,
) {
  final filter = ref.watch(matchFilterProvider.select((s) => s.selected));
  if (filter == MatchFilterType.live || filter == MatchFilterType.upcoming) {
    return ref.watch(eventsV2Provider.select((s) => s.isLoading));
  }
  if (filter == MatchFilterType.favorites) {
    final sportId = ref.watch(selectedSportV2Provider).id;
    return ref.watch(
      favoriteProvider.select((s) => s.isFavoriteEventsLoading(sportId)),
    );
  }
  return false;
});
