import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/core/services/models/api_v2/sport_constants.dart'
    show SportType;
import 'package:sun_sports/providers/auth_provider.dart';
import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/sport_constants.dart'
    as v2;
import 'package:sun_sports/features/sport/presentation/providers/events_v2_filter_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/events_v2_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/favorite_provider.dart';
import 'package:sun_sports/features/sport/data/adapters/sport_socket_adapter_provider.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/scroll_aware_controller.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/spacing_styles.dart';

import 'package:sun_sports/shared/layouts/shell_pinned_align.dart';
import 'package:sun_sports/shared/layouts/shell_top_overlap_sliver.dart';
import 'package:sun_sports/features/sport_detail/presentation/providers/sport_detail_collapse_provider.dart';
import 'package:sun_sports/features/sport_detail/presentation/providers/sport_detail_date_provider.dart';
import 'package:sun_sports/features/sport_detail/presentation/providers/sport_detail_tab_provider.dart';
import 'package:sun_sports/features/sport_detail/presentation/widgets/sport_detail_special.dart';
import 'package:sun_sports/features/sport_detail/presentation/widgets/sport_detail_filter_tabs.dart';

import 'package:sun_sports/shared/widgets/chat/chat_login_overlay.dart';
import 'package:sun_sports/shared/widgets/sport/enums/sport_filter_enums.dart';
import 'package:sun_sports/shared/widgets/empty_page/sport_empty_page.dart';
import 'package:sun_sports/shared/widgets/back_to_top_overlay.dart'
    show BackToTopWrapper;
import 'package:sun_sports/shared/widgets/sport/league/league_events_sliver_v2.dart';
import 'package:sun_sports/shared/widgets/sport/loading/sport_shimmer_loading.dart';
import 'package:sun_sports/shared/widgets/rive_vibrating/rive_vibrating.dart';
import 'package:sun_sports/shared/widgets/gestures/tab_pager.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class SportDetailMobileScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBackPressed;

  const SportDetailMobileScreen({super.key, this.onBackPressed});

  @override
  ConsumerState<SportDetailMobileScreen> createState() =>
      _SportDetailMobileScreenState();
}

class _SportDetailMobileScreenState
    extends ConsumerState<SportDetailMobileScreen> {
  final GlobalKey _pinnedBlockAnchor = GlobalKey();

  ScrollController? _scrollController;

  bool _suppressAlign = false;

  void _alignUnderPinnedBlock() {
    final ScrollController? controller = _scrollController;
    if (controller == null || _suppressAlign) return;
    alignUnderShellPinnedBlockWithRef(
      ref,
      controller: controller,
      anchorKey: _pinnedBlockAnchor,
    );
  }

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

      ref.listenManual(selectedSportV2Provider, (previous, next) {
        if (previous?.id == next.id) return;

        final favoriteState = ref.read(favoriteProvider);
        if (favoriteState.getFavoriteData(next.id) == null) {
          ref.read(favoriteProvider.notifier).fetchFavorites(next.id);
        }

        final currentTab = ref.read(sportDetailTabProvider);
        if (currentTab == SportDetailFilterType.favorites) {
          ref
              .read(favoriteProvider.notifier)
              .fetchFavoriteEvents(next.id, forceRefresh: true);
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

  void _commitTabIndex(int index) {
    final int sportId = ref.read(selectedSportV2Provider).id;
    final List<SportDetailFilterType> filters = _tabFilters(sportId);
    final List<String> dates =
        ref.read(eventDatesProvider(sportId)).valueOrNull ?? const <String>[];
    final String? selectedDate = ref.read(sportDetailSelectedDateProvider);

    final int current = _tabIndexOf(
      filters: filters,
      dates: dates,
      selectedDate: selectedDate,
      filter: ref.read(sportDetailTabProvider),
    );
    if (index == current || index < 0) return;

    _suppressAlign = true;
    try {
      if (index < filters.length) {
        ref.read(sportDetailSelectedDateProvider.notifier).state = null;
        _onFilterChanged(filters[index]);
        return;
      }
      final int d = index - filters.length;
      if (d < dates.length) {
        ref.read(sportDetailSelectedDateProvider.notifier).state = dates[d];
      }
    } finally {
      _suppressAlign = false;
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

    ref.listen<SportDetailFilterType>(sportDetailTabProvider, (prev, next) {
      if (prev != next) _alignUnderPinnedBlock();
    });
    ref.listen<String?>(sportDetailSelectedDateProvider, (prev, next) {
      if (prev != next) _alignUnderPinnedBlock();
    });

    return Container(
      color: AppColorStyles.backgroundPrimary,
      child: BackToTopWrapper(
        builder: (scrollController) {
          _scrollController = scrollController;
          return _SportDetailPagerHost(
          onCommit: _commitTabIndex,
          child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollStartNotification) {
              ScrollAwareController.instance.onScrollStart();
            } else if (notification is ScrollUpdateNotification) {
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
              const ShellTopOverlapSliver(),
              const SliverToBoxAdapter(child: Gap(12)),

              ShellPinnedBlockAnchor(anchorKey: _pinnedBlockAnchor),
              PinnedHeaderSliver(
                child: ColoredBox(
                  color: AppColorStyles.backgroundPrimary,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Consumer(
                        builder: (context, ref, _) {
                          final currentSportId = ref.watch(
                            selectedSportV2Provider.select((s) => s.id),
                          );
                          return _buildSportNameSelected(currentSportId);
                        },
                      ),
                      SportDetailFilterTabs(
                        isDesktop: false,
                        onFilterChanged: _onFilterChanged,
                      ),
                    ],
                  ),
                ),
              ),

              Consumer(
                builder: (context, ref, _) {
                  final int sportId = ref.watch(
                    selectedSportV2Provider.select((s) => s.id),
                  );
                  final int activeIndex = _tabIndexOf(
                    filters: _tabFilters(sportId),
                    dates:
                        ref.watch(eventDatesProvider(sportId)).valueOrNull ??
                        const <String>[],
                    selectedDate: ref.watch(sportDetailSelectedDateProvider),
                    filter: ref.watch(sportDetailTabProvider),
                  );
                  return TabPagerPanel(
                    fallbackIndex: activeIndex,
                    panelBuilder: (BuildContext context, int index) =>
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          sliver: index != activeIndex
                              ? const SliverToBoxAdapter(
                                  child: SportShimmerLoading(isDesktop: false),
                                )
                              : Consumer(
                                  builder: (context, ref, _) {
                    final selectedFilter = ref.watch(sportDetailTabProvider);
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
                      );
                    }

                    if (selectedFilter == SportDetailFilterType.special &&
                        currentSportId != 1) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          ref.read(sportDetailTabProvider.notifier).state =
                              SportDetailFilterType.live;
                        }
                      });
                    }

                    if (selectedFilter == SportDetailFilterType.special) {
                      return const SportDetailMobileSpecial();
                    }

                    if (selectedFilter == SportDetailFilterType.favorites) {
                      if (!ref.watch(isAuthenticatedProvider)) {
                        return const SliverFillRemaining(
                          hasScrollBody: false,
                          child: ChatLoginOverlay(isMobile: true),
                        );
                      }
                      ref.watch(
                        favoriteEventsAutoRefreshProvider(currentSportId),
                      );
                      final isLoading = ref.watch(
                        favoriteProvider.select(
                          (s) => s.isFavoriteEventsLoading(currentSportId),
                        ),
                      );
                      final favoriteLeagues =
                          ref.watch(
                            favoriteProvider.select(
                              (s) => s.getFavoriteEventsLeagues(currentSportId),
                            ),
                          ) ??
                          [];

                      if (!isLoading && favoriteLeagues.isEmpty) {
                        Future.microtask(() {
                          ref
                              .read(favoriteProvider.notifier)
                              .fetchFavoriteEvents(currentSportId);
                        });
                      }

                      if (isLoading) {
                        return const SliverToBoxAdapter(
                          child: SportShimmerLoading(isDesktop: false),
                        );
                      }

                      final nonEmptyLeagues = favoriteLeagues
                          .where((l) => l.events.isNotEmpty)
                          .toList();

                      if (nonEmptyLeagues.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: SportEmptyPage(),
                        );
                      }

                      return LeagueEventsSliverV2(
                        leagues: nonEmptyLeagues,
                        isDesktop: false,
                        showBackToTop: false,
                        collapseAllProvider: sportDetailCollapseAllProvider,
                        enableVisibleLeagueSub: true,
                        subTimeRanges: kLeagueSubAllTimeRanges,
                      );
                    }

                    final isLoading = ref.watch(
                      eventsV2Provider.select((s) => s.isLoading),
                    );

                    if (isLoading) {
                      return const SliverToBoxAdapter(
                        child: SportShimmerLoading(isDesktop: false),
                      );
                    }

                    final leagues = ref.watch(leaguesV2Provider);
                    final currentTimeRange = ref.watch(
                      selectedTimeRangeV2Provider,
                    );

                    final List<LeagueModelV2> filteredLeagues;
                    if (currentTimeRange == v2.EventTimeRange.today ||
                        currentTimeRange == v2.EventTimeRange.early ||
                        currentTimeRange == v2.EventTimeRange.todayAndEarly) {
                      filteredLeagues = leagues
                          .map(
                            (l) => l.copyWith(
                              events: l.events
                                  .where((e) => e.isLive != true)
                                  .toList(),
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
                      return const SliverToBoxAdapter(child: SportEmptyPage());
                    }

                    return LeagueEventsSliverV2(
                      leagues: nonEmptyLeagues,
                      isDesktop: false,
                      showBackToTop: false,
                      collapseAllProvider: sportDetailCollapseAllProvider,
                      enableVisibleLeagueSub: true,
                      subTimeRanges:
                          currentTimeRange == v2.EventTimeRange.todayAndEarly
                              ? kLeagueSubAllTimeRanges
                              : {currentTimeRange.value},
                    );
                  },
                                ),
                        ),
                  );
                },
              ),

              const SliverToBoxAdapter(child: Gap(AppSpacingStyles.space2400)),
            ],
          ),
        ),
        ),
        );
        },
      ),
    );
  }

  Widget _buildSportNameSelected(int currentSportId) {
    final sport = SportType.fromId(currentSportId);
    final name = _getSportName(sport ?? SportType.soccer);
    final icon = _getSportIcon(sport ?? SportType.soccer);

    return Container(
      color: const Color(0xFF1B1A19),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 6),
      child: Row(
        children: [
          ImageHelper.load(path: icon, width: 24, height: 24),
          const SizedBox(width: 6),
          Text(
            name,
            style: AppTextStyles.textStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: AppColorStyles.contentPrimary,
            ),
          ),
          const Spacer(),
          _buildCollapseAllButton(),
        ],
      ),
    );
  }

  Widget _buildCollapseAllButton() {
    return Consumer(
      builder: (context, ref, _) {
        final collapseAll = ref.watch(sportDetailCollapseAllProvider);
        return GestureDetector(
          onTap: SoundTap.wrap(() {
            final notifier = ref.read(sportDetailCollapseAllProvider.notifier);
            notifier.state = !notifier.state;
          }),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7.5),
            decoration: BoxDecoration(
              color: const Color(0x1486CB3C),
              borderRadius: BorderRadius.circular(12),
            ),
            child: AnimatedRotation(
              duration: const Duration(milliseconds: 200),
              turns: collapseAll ? 0.5 : 0,
              child: ImageHelper.load(
                path: AppIcons.iconCollapse,
                width: 24,
                height: 24,
              ),
            ),
          ),
        );
      },
    );
  }

  String _getSportName(SportType sport) {
    switch (sport) {
      case SportType.soccer:
        return 'Bóng đá';
      case SportType.tennis:
        return 'Tennis';
      case SportType.basketball:
        return 'Bóng rổ';
      case SportType.volleyball:
        return 'Bóng chuyền';
      case SportType.tableTennis:
        return 'Bóng bàn';
      case SportType.badminton:
        return 'Cầu lông';
      default:
        return 'Bóng đá';
    }
  }

  String _getSportIcon(SportType sport) {
    switch (sport) {
      case SportType.soccer:
        return AppIcons.iconFootballSelected;
      case SportType.tennis:
        return AppIcons.iconTennisSelected;
      case SportType.basketball:
        return AppIcons.iconBasketballSelected;
      case SportType.volleyball:
        return AppIcons.iconVolleyballSelected;
      case SportType.tableTennis:
        return AppIcons.iconTableTennisSelected;
      case SportType.badminton:
        return AppIcons.iconBadmintonSelected;
      default:
        return AppIcons.iconFootballSelected;
    }
  }
}

class _DateEventsContent extends ConsumerWidget {
  final int sportId;
  final String date;

  const _DateEventsContent({required this.sportId, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(
      eventsByDateProvider((sportId: sportId, date: date)),
    );

    return eventsAsync.when(
      loading: () => const SliverToBoxAdapter(
        child: SportShimmerLoading(isDesktop: false),
      ),
      error: (_, _) => const SliverToBoxAdapter(child: SportEmptyPage()),
      data: (leagues) {
        final nonEmptyLeagues = leagues
            .where((l) => l.events.isNotEmpty)
            .toList();

        if (nonEmptyLeagues.isEmpty) {
          return const SliverToBoxAdapter(child: SportEmptyPage());
        }

        return LeagueEventsSliverV2(
          leagues: nonEmptyLeagues,
          isDesktop: false,
          showBackToTop: false,
          collapseAllProvider: sportDetailCollapseAllProvider,
          enableVisibleLeagueSub: true,
          subTimeRanges: kLeagueSubAllTimeRanges,
        );
      },
    );
  }
}

List<SportDetailFilterType> _tabFilters(int sportId) =>
    SportDetailFilterType.values
        .where(
          (filter) => filter != SportDetailFilterType.special || sportId == 1,
        )
        .toList();

int _tabIndexOf({
  required List<SportDetailFilterType> filters,
  required List<String> dates,
  required String? selectedDate,
  required SportDetailFilterType filter,
}) {
  if (selectedDate != null) {
    final int i = dates.indexOf(selectedDate);
    return i < 0 ? 0 : filters.length + i;
  }
  final int i = filters.indexOf(filter);
  return i < 0 ? 0 : i;
}

class _SportDetailPagerHost extends ConsumerWidget {
  const _SportDetailPagerHost({required this.onCommit, required this.child});

  final ValueChanged<int> onCommit;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int sportId = ref.watch(selectedSportV2Provider.select((s) => s.id));
    final List<SportDetailFilterType> filters = _tabFilters(sportId);
    final List<String> dates =
        ref.watch(eventDatesProvider(sportId)).valueOrNull ?? const <String>[];

    return TabPagerHost(
      index: _tabIndexOf(
        filters: filters,
        dates: dates,
        selectedDate: ref.watch(sportDetailSelectedDateProvider),
        filter: ref.watch(sportDetailTabProvider),
      ),
      count: filters.length + dates.length,
      onCommit: onCommit,
      slideOnExternalChange: false,
      child: child,
    );
  }
}
