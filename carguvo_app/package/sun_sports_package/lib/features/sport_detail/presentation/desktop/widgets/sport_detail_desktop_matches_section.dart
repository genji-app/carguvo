import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/sport_constants.dart'
    as v2;
import 'package:sun_sports/features/sport/presentation/providers/events_v2_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/events_v2_filter_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/favorite_provider.dart';
import 'package:sun_sports/features/sport/data/adapters/sport_socket_adapter_provider.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/sport_detail/presentation/providers/sport_detail_tab_provider.dart';
import 'package:sun_sports/shared/widgets/empty_page/sport_empty_page.dart';
import 'package:sun_sports/shared/widgets/sport/enums/sport_filter_enums.dart';
import 'package:sun_sports/shared/widgets/sport/league/league_card_v2.dart';
import 'package:sun_sports/shared/widgets/sport/loading/sport_shimmer_loading.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class SportDetailDesktopMatchesSection extends ConsumerStatefulWidget {
  final ScrollController scrollController;

  const SportDetailDesktopMatchesSection({
    super.key,
    required this.scrollController,
  });

  @override
  ConsumerState<SportDetailDesktopMatchesSection> createState() =>
      _SportDetailDesktopMatchesSectionState();
}

class _SportDetailDesktopMatchesSectionState
    extends ConsumerState<SportDetailDesktopMatchesSection> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final timeRange = ref.read(selectedTimeRangeV2Provider);
      ref.read(sportDetailTabProvider.notifier).state =
          _v2TimeRangeToFilterType(timeRange);
    });
  }

  SportDetailFilterType _v2TimeRangeToFilterType(v2.EventTimeRange timeRange) {
    switch (timeRange) {
      case v2.EventTimeRange.live:
        return SportDetailFilterType.live;
      case v2.EventTimeRange.today:
        return SportDetailFilterType.today;
      case v2.EventTimeRange.early:
        return SportDetailFilterType.upcoming;
      case v2.EventTimeRange.todayAndEarly:
        return SportDetailFilterType.upcoming;
    }
  }

  v2.EventTimeRange _filterTypeToV2TimeRange(SportDetailFilterType filter) {
    switch (filter) {
      case SportDetailFilterType.live:
        return v2.EventTimeRange.live;
      case SportDetailFilterType.today:
        return v2.EventTimeRange.today;
      case SportDetailFilterType.upcoming:
        return v2.EventTimeRange.todayAndEarly;
      case SportDetailFilterType.special:
      case SportDetailFilterType.favorites:
        return v2.EventTimeRange.live;
    }
  }

  void _onFilterChanged(SportDetailFilterType filter) {
    final currentTimeRange = ref.read(selectedTimeRangeV2Provider);
    final newTimeRange = _filterTypeToV2TimeRange(filter);

    ref.read(sportDetailTabProvider.notifier).state = filter;

    if (filter == SportDetailFilterType.favorites) {
      final sportId = ref.read(selectedSportV2Provider).id;
      ref.read(favoriteProvider.notifier).fetchFavoriteEvents(sportId);
      return;
    }

    if (currentTimeRange != newTimeRange &&
        filter != SportDetailFilterType.special) {
      ref.read(selectedTimeRangeV2Provider.notifier).state = newTimeRange;

      final timeRangeStr = _timeRangeToString(newTimeRange);
      ref
          .read(sportSocketAdapterProvider)
          .subscriptionManager
          .setTimeRangeFromString(timeRangeStr);
    }
  }

  String _timeRangeToString(v2.EventTimeRange timeRange) {
    switch (timeRange) {
      case v2.EventTimeRange.live:
        return 'LIVE';
      case v2.EventTimeRange.today:
        return 'TODAY';
      case v2.EventTimeRange.early:
        return 'EARLY';
      case v2.EventTimeRange.todayAndEarly:
        return 'TODAY';
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(selectedSportV2Provider.select((s) => s.id), (
      previous,
      currentSportId,
    ) {
      final currentTab = ref.read(sportDetailTabProvider);
      if (currentTab == SportDetailFilterType.favorites) {
        ref
            .read(favoriteProvider.notifier)
            .fetchFavoriteEvents(currentSportId);
      }
    });

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1B1A19),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Consumer(
            builder: (context, ref, _) {
              final selectedFilter = ref.watch(sportDetailTabProvider);
              final currentSportId = ref.watch(
                selectedSportV2Provider.select((sport) => sport.id),
              );
              return _buildFilterTabs(selectedFilter, currentSportId);
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Consumer(
              builder: (context, ref, _) {
                final currentTab = ref.watch(sportDetailTabProvider);

                if (currentTab == SportDetailFilterType.favorites) {
                  return _buildFavoritesContent(ref);
                }

                final isLoading = ref.watch(
                  eventsV2Provider.select((state) => state.isLoading),
                );

                if (isLoading) {
                  return const SportShimmerLoading(isDesktop: true);
                }

                return _buildLeaguesContent(ref);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesContent(WidgetRef ref) {
    final sportId = ref.watch(selectedSportV2Provider.select((s) => s.id));
    final isLoading = ref.watch(
      favoriteProvider.select((s) => s.isFavoriteEventsLoading(sportId)),
    );
    final leagues = ref.watch(
      favoriteProvider.select((s) => s.getFavoriteEventsLeagues(sportId)),
    );

    if (isLoading && (leagues == null || leagues.isEmpty)) {
      return const SportShimmerLoading(isDesktop: true);
    }
    if (leagues == null || leagues.isEmpty) {
      return const SportEmptyPage();
    }
    return _buildLeaguesList(leagues);
  }

  Widget _buildLeaguesContent(WidgetRef ref) {
    final currentTimeRange = ref.watch(selectedTimeRangeV2Provider);
    final List<LeagueModelV2> leagues = ref.watch(leaguesV2Provider);

    final List<LeagueModelV2> filteredLeagues;
    if (currentTimeRange == v2.EventTimeRange.today ||
        currentTimeRange == v2.EventTimeRange.early ||
        currentTimeRange == v2.EventTimeRange.todayAndEarly) {
      filteredLeagues = leagues
          .map(
            (l) => l.copyWith(
              events: l.events.where((e) => e.isLive != true).toList(),
            ),
          )
          .where((l) => l.events.isNotEmpty)
          .toList();
    } else {
      filteredLeagues = leagues;
    }

    if (filteredLeagues.isEmpty) {
      return const SportEmptyPage();
    }

    return _buildLeaguesList(filteredLeagues);
  }

  Widget _buildLeaguesList(List<LeagueModelV2> leagues) {
    final nonEmptyLeagues = leagues.where((l) => l.events.isNotEmpty).toList();
    if (nonEmptyLeagues.isEmpty) return const SportEmptyPage();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: nonEmptyLeagues.map((league) {
        return RepaintBoundary(
          key: ValueKey('repaint_league_${league.leagueId}'),
          child: LeagueCardV2(
            key: ValueKey('league_${league.leagueId}'),
            league: league,
            isDesktop: true,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFilterTabs(
    SportDetailFilterType selectedFilter,
    int currentSportId,
  ) {
    final filters = SportDetailFilterType.values
        .where(
          (filter) =>
              filter != SportDetailFilterType.special || currentSportId == 1,
        )
        .toList();

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF252423), width: 0.5),
        ),
      ),
      child: Row(
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter;

          return Expanded(
            child: GestureDetector(
              onTap: SoundTap.wrap(() => _onFilterChanged(filter)),
              behavior: HitTestBehavior.opaque,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (isSelected)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: ImageHelper.load(
                        path: AppIcons.sportStatusSelected,
                        fit: BoxFit.fill,
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                    child: Center(
                      child: Text(
                        filter.label,
                        style: AppTextStyles.textStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? AppColors.yellow300
                              : const Color(0xFF9C9B95),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
