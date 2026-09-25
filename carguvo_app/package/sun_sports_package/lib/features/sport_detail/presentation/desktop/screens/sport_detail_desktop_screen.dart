import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/sport_constants.dart'
    as v2;
import 'package:sun_sports/features/sport/presentation/providers/events_v2_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/events_v2_filter_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/favorite_provider.dart';
import 'package:sun_sports/providers/auth_provider.dart';
import 'package:sun_sports/features/sport/data/adapters/sport_socket_adapter_provider.dart';
import 'package:sun_sports/core/utils/scroll_aware_controller.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/spacing_styles.dart';
import 'package:sun_sports/features/sport_detail/presentation/providers/sport_detail_collapse_provider.dart';
import 'package:sun_sports/features/sport_detail/presentation/providers/sport_detail_date_provider.dart';
import 'package:sun_sports/features/sport_detail/presentation/providers/sport_detail_tab_provider.dart';
import 'package:sun_sports/features/sport_detail/presentation/desktop/widgets/sport_detail_desktop_header.dart';
import 'package:sun_sports/features/sport_detail/presentation/widgets/sport_detail_filter_tabs.dart';
import 'package:sun_sports/features/sport_detail/presentation/widgets/sport_detail_special.dart';
import 'package:sun_sports/shared/widgets/back_to_top_overlay.dart'
    show BackToTopWrapper;
import 'package:sun_sports/shared/widgets/chat/chat_login_overlay.dart';
import 'package:sun_sports/shared/widgets/empty_page/sport_empty_page.dart';
import 'package:sun_sports/shared/widgets/sport/enums/sport_filter_enums.dart';
import 'package:sun_sports/shared/widgets/sport/league/league_events_sliver_v2.dart';
import 'package:sun_sports/shared/widgets/sport/loading/sport_shimmer_loading.dart';
import 'package:sun_sports/shared/widgets/rive_vibrating/rive_vibrating.dart';

class SportDetailDesktopScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBackPressed;

  const SportDetailDesktopScreen({super.key, this.onBackPressed});

  @override
  ConsumerState<SportDetailDesktopScreen> createState() =>
      _SportDetailDesktopScreenState();
}

class _SportDetailDesktopScreenState
    extends ConsumerState<SportDetailDesktopScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(riveVibratingInitProvider);

      final timeRange = ref.read(selectedTimeRangeV2Provider);
      final currentTab = _v2TimeRangeToFilterType(timeRange);

      final sportId = ref.read(selectedSportV2Provider).id;
      final finalTab =
          (currentTab == SportDetailFilterType.special && sportId != 1)
          ? SportDetailFilterType.live
          : currentTab;

      ref.read(sportDetailTabProvider.notifier).state = finalTab;

      ref.listenManual(selectedSportV2Provider.select((s) => s.id), (
        previous,
        next,
      ) {
        final tab = ref.read(sportDetailTabProvider);
        if (tab == SportDetailFilterType.special && next != 1) {
          ref.read(sportDetailTabProvider.notifier).state =
              SportDetailFilterType.live;
        }
      });
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
        return v2
            .EventTimeRange
            .live;
    }
  }

  void _onFilterChanged(SportDetailFilterType filter) {
    final currentTimeRange = ref.read(selectedTimeRangeV2Provider);
    final newTimeRange = _filterTypeToV2TimeRange(filter);

    ref.read(sportDetailTabProvider.notifier).state = filter;

    if (filter == SportDetailFilterType.favorites) {
      final sportId = ref.read(selectedSportV2Provider).id;
      ref
          .read(favoriteProvider.notifier)
          .fetchFavoriteEvents(sportId, forceRefresh: true);
    }

    if (currentTimeRange != newTimeRange &&
        filter != SportDetailFilterType.special &&
        filter != SportDetailFilterType.favorites) {
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

    ref.listen(selectedSportV2Provider.select((s) => s.id), (previous, next) {
      if (previous == next) return;

      final favNotifier = ref.read(favoriteProvider.notifier);
      final favState = ref.read(favoriteProvider);

      if (favState.getFavoriteData(next) == null) {
        favNotifier.fetchFavorites(next);
      }

      final currentTab = ref.read(sportDetailTabProvider);
      if (currentTab == SportDetailFilterType.favorites) {
        favNotifier.fetchFavoriteEvents(next, forceRefresh: true);
      }
    });

    ref.listen(sportDetailTabProvider, (previous, next) {
      if (next == SportDetailFilterType.favorites) {
        final sportId = ref.read(selectedSportV2Provider).id;
        ref
            .read(favoriteProvider.notifier)
            .fetchFavoriteEvents(sportId, forceRefresh: true);
      }
    });

    ref.listen(isAuthenticatedProvider, (previous, next) {
      if (previous != true &&
          next == true &&
          ref.read(sportDetailTabProvider) == SportDetailFilterType.favorites) {
        final sportId = ref.read(selectedSportV2Provider).id;
        ref
            .read(favoriteProvider.notifier)
            .fetchFavoriteEvents(sportId, forceRefresh: true);
      }
    });

    return Container(
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingStyles.space800,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1140, minWidth: 860),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(
              context,
            ).copyWith(scrollbars: false),
            child: BackToTopWrapper(
              builder: (scrollController) =>
                  NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollStartNotification ||
                      notification is ScrollUpdateNotification) {
                    ScrollAwareController.instance.onScrollStart();
                  } else if (notification is ScrollEndNotification) {
                    ScrollAwareController.instance.onScrollEnd();
                  }
                  return false;
                },
                child: CustomScrollView(
                  controller: scrollController,
                  cacheExtent: 1200,
                  slivers: [
                  SliverToBoxAdapter(
                    child: RepaintBoundary(
                      child: SportDetailDesktopHeader(
                        onBackPressed: widget.onBackPressed,
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B1A19),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SportDetailFilterTabs(
                            isDesktop: true,
                            onFilterChanged: _onFilterChanged,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 0,
                    ),
                    sliver: Consumer(
                      builder: (context, ref, _) {
                        final selectedFilter = ref.watch(
                          sportDetailTabProvider,
                        );
                        final currentSportId = ref.watch(
                          selectedSportV2Provider.select((s) => s.id),
                        );

                        final selectedDate = ref.watch(
                          sportDetailSelectedDateProvider,
                        );
                        if (selectedDate != null) {
                          return _DateEventsContent(
                            sportId: currentSportId,
                            date: selectedDate,
                            buildEmptyState: _buildEmptyState,
                          );
                        }

                        if (selectedFilter == SportDetailFilterType.special &&
                            currentSportId != 1) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            ref.read(sportDetailTabProvider.notifier).state =
                                SportDetailFilterType.live;
                          });
                          return const SliverToBoxAdapter(
                            child: SportShimmerLoading(isDesktop: true),
                          );
                        }

                        if (selectedFilter == SportDetailFilterType.special) {
                          return const SportDetailMobileSpecial(
                            isDesktop: true,
                          );
                        }

                        if (selectedFilter == SportDetailFilterType.favorites) {
                          return _FavoritesContent(
                            sportId: currentSportId,
                            buildEmptyState: _buildEmptyState,
                          );
                        }

                        return _EventsContent(
                          buildEmptyState: _buildEmptyState,
                        );
                      },
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() => const SportEmptyPage();
}

class _DateEventsContent extends ConsumerWidget {
  final int sportId;
  final String date;
  final Widget Function() buildEmptyState;

  const _DateEventsContent({
    required this.sportId,
    required this.date,
    required this.buildEmptyState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(
      eventsByDateProvider((sportId: sportId, date: date)),
    );

    return eventsAsync.when(
      loading: () => const SliverToBoxAdapter(
        child: SportShimmerLoading(isDesktop: true),
      ),
      error: (_, _) => SliverToBoxAdapter(child: buildEmptyState()),
      data: (leagues) {
        final nonEmptyLeagues = leagues
            .where((l) => l.events.isNotEmpty)
            .toList();

        if (nonEmptyLeagues.isEmpty) {
          return SliverToBoxAdapter(child: buildEmptyState());
        }

        return LeagueEventsSliverV2(
          leagues: nonEmptyLeagues,
          isDesktop: true,
          showBackToTop: false,
          collapseAllProvider: sportDetailCollapseAllProvider,
          enableVisibleLeagueSub: true,
          subTimeRanges: kLeagueSubAllTimeRanges,
        );
      },
    );
  }
}

class _FavoritesContent extends ConsumerWidget {
  final int sportId;
  final Widget Function() buildEmptyState;

  const _FavoritesContent({
    required this.sportId,
    required this.buildEmptyState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(isAuthenticatedProvider)) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: ChatLoginOverlay(),
      );
    }

    ref.watch(favoriteEventsAutoRefreshProvider(sportId));

    final isLoading = ref.watch(
      favoriteProvider.select((s) => s.isFavoriteEventsLoading(sportId)),
    );

    if (isLoading) {
      return const SliverToBoxAdapter(
        child: SportShimmerLoading(isDesktop: true),
      );
    }

    final favoriteLeagues = ref.watch(
      favoriteProvider.select((s) => s.getFavoriteEventsLeagues(sportId)),
    );

    if (favoriteLeagues == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(favoriteProvider.notifier).fetchFavoriteEvents(sportId);
      });
      return const SliverToBoxAdapter(
        child: SportShimmerLoading(isDesktop: true),
      );
    }

    final nonEmptyLeagues = favoriteLeagues
        .where((l) => l.events.isNotEmpty)
        .toList();

    if (nonEmptyLeagues.isEmpty) {
      return SliverToBoxAdapter(child: buildEmptyState());
    }

    return LeagueEventsSliverV2(
      leagues: nonEmptyLeagues,
      isDesktop: true,
      showBackToTop: false,
      collapseAllProvider: sportDetailCollapseAllProvider,
      enableVisibleLeagueSub: true,
      subTimeRanges: kLeagueSubAllTimeRanges,
    );
  }
}

class _EventsContent extends ConsumerWidget {
  final Widget Function() buildEmptyState;

  const _EventsContent({required this.buildEmptyState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(
      eventsV2Provider.select((state) => state.isLoading),
    );

    if (isLoading) {
      return const SliverToBoxAdapter(
        child: SportShimmerLoading(isDesktop: true),
      );
    }

    final leagues = ref.watch(leaguesV2Provider);
    final currentTimeRange = ref.watch(selectedTimeRangeV2Provider);

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

    final nonEmptyLeagues = filteredLeagues
        .where((l) => l.events.isNotEmpty)
        .toList();

    if (nonEmptyLeagues.isEmpty) {
      return SliverToBoxAdapter(child: buildEmptyState());
    }

    return LeagueEventsSliverV2(
      leagues: nonEmptyLeagues,
      isDesktop: true,
      showBackToTop: false,
      collapseAllProvider: sportDetailCollapseAllProvider,
      enableVisibleLeagueSub: true,
      subTimeRanges: currentTimeRange == v2.EventTimeRange.todayAndEarly
          ? kLeagueSubAllTimeRanges
          : {currentTimeRange.value},
    );
  }
}
