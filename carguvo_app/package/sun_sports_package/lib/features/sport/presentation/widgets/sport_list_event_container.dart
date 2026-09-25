import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/services/models/api_v2/sport_constants.dart'
    as v2;
import 'package:sun_sports/features/sport/presentation/providers/events_v2_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/events_v2_filter_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/favorite_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/league_collapse_providers.dart';
import 'package:sun_sports/shared/widgets/sport/collapse_all_toggle.dart';
import 'package:sun_sports/shared/widgets/sport/sport_dropdown_filter.dart';
import 'package:sun_sports/features/sport/data/adapters/sport_socket_adapter_provider.dart';
import 'package:sun_sports/shared/widgets/authenticated_widget.dart';
import 'package:sun_sports/shared/widgets/back_to_top_overlay.dart'
    show BackToTopWrapper;
import 'package:sun_sports/shared/widgets/chat/chat_login_overlay.dart';
import 'package:sun_sports/shared/widgets/empty_page/sport_empty_page.dart';
import 'package:sun_sports/shared/widgets/empty_page/sport_error_page.dart';
import 'package:sun_sports/shared/widgets/sport/league/league_events_sliver_v2.dart';
import 'package:sun_sports/shared/widgets/sport/loading/sport_shimmer_loading.dart';
import 'package:sun_sports/shared/widgets/tab_layout/s88_tab.dart'
    show S88Tab, sportTabItems, sportIds;

enum MatchFilterType { live, upcoming, favorites }

final _s88TabSportIdProvider = StateProvider.autoDispose<int>((ref) => 1);

void applySportTabFilter(
  WidgetRef ref,
  MatchFilterType filter, {
  int? sportId,
  bool refresh = false,
}) {
  final sub = ref.read(sportSocketAdapterProvider).subscriptionManager;

  switch (filter) {
    case MatchFilterType.live:
      if (ref.read(selectedSportV2Provider) != v2.SportType.soccer) {
        ref.read(selectedSportV2Provider.notifier).state = v2.SportType.soccer;
        sub.setActiveSport(v2.SportType.soccer.id);
      }
      if (ref.read(selectedTimeRangeV2Provider) != v2.EventTimeRange.live) {
        ref.read(selectedTimeRangeV2Provider.notifier).state =
            v2.EventTimeRange.live;
        sub.setTimeRangeFromString('LIVE');
      }
      if (refresh) ref.read(eventsV2Provider.notifier).refresh();
    case MatchFilterType.upcoming:
      final int id = sportId ?? ref.read(_s88TabSportIdProvider);
      ref.read(selectedSportV2Provider.notifier).state =
          v2.SportType.fromId(id) ?? v2.SportType.soccer;
      ref.read(selectedTimeRangeV2Provider.notifier).state =
          v2.EventTimeRange.todayAndEarly;
      sub.setActiveSport(id);
      sub.setTimeRangeFromString('TODAY');
      if (refresh) ref.read(eventsV2Provider.notifier).refresh();
    case MatchFilterType.favorites:
      final int id = sportId ?? ref.read(_s88TabSportIdProvider);
      ref.read(selectedSportV2Provider.notifier).state =
          v2.SportType.fromId(id) ?? v2.SportType.soccer;
      ref
          .read(favoriteProvider.notifier)
          .fetchFavoriteEvents(id, forceRefresh: refresh);
  }
}

class SportListEventContainer extends ConsumerStatefulWidget {
  final MatchFilterType filter;

  final double? maxHeight;

  final bool isDesktop;

  const SportListEventContainer({
    super.key,
    required this.filter,
    this.maxHeight,
    this.isDesktop = false,
  });

  @override
  ConsumerState<SportListEventContainer> createState() =>
      _SportListEventContainerState();
}

class _SportListEventContainerState
    extends ConsumerState<SportListEventContainer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _syncFilterAndSport(ref),
    );
  }

  @override
  void didUpdateWidget(SportListEventContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filter != widget.filter) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _syncFilterAndSport(ref);
      });
    }
  }

  void _applySportAndFilter(WidgetRef ref, int sportId) =>
      applySportTabFilter(ref, widget.filter, sportId: sportId);

  void _syncFilterAndSport(WidgetRef ref) {
    _applySportAndFilter(ref, ref.read(_s88TabSportIdProvider));
  }

  void _onS88TabChanged(WidgetRef ref, int index) {
    final sportId = sportIds[index];
    ref.read(_s88TabSportIdProvider.notifier).state = sportId;
    _applySportAndFilter(ref, sportId);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.filter == MatchFilterType.favorites) {
      return AuthenticatedWidget(
        fallback: _buildLoginFallback(),
        child: _buildContent(context),
      );
    }
    return _buildContent(context);
  }

  Widget _buildLoginFallback() {
    final overlay = ChatLoginOverlay(isMobile: widget.maxHeight == null);
    return widget.maxHeight != null
        ? SizedBox(height: widget.maxHeight, child: overlay)
        : overlay;
  }

  Widget _buildTabRow(int clampedIndex) {
    return Row(
      children: [
        Expanded(
          child: S88Tab(
            tabs: sportTabItems,
            selectedIndex: clampedIndex,
            onTabChanged: (index) => _onS88TabChanged(ref, index),
            backgroundColor: Colors.transparent,
            defaultColor: AppColorStyles.contentPrimary,
            selectedColor: AppColors.yellow300,
            isScrollable: true,
            scrollableTabWidth: 100,
          ),
        ),
        if (widget.filter == MatchFilterType.upcoming)
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 12),
            child: CollapseAllToggle(
              provider: sportListUpcomingCollapseAllProvider,
              iconSize: 20,
              padding: const EdgeInsets.all(5),
            ),
          ),
      ],
    );
  }

  Widget _buildDropdownRow(int clampedIndex) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SportDropdownFilter(
            items: sportTabItems,
            selectedIndex: clampedIndex,
            onChanged: (index) => _onS88TabChanged(ref, index),
          ),
          if (widget.filter == MatchFilterType.upcoming)
            CollapseAllToggle(
              provider: sportListUpcomingCollapseAllProvider,
              iconSize: 20,
              padding: const EdgeInsets.all(5),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final selectedSportId = ref.watch(_s88TabSportIdProvider);
    final selectedIndex = sportIds.indexOf(selectedSportId);
    final clampedIndex = selectedIndex < 0 ? 0 : selectedIndex;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.max,
      children: [
        RepaintBoundary(
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFF252423), width: 0.5),
              ),
            ),
            padding: const EdgeInsets.only(top: 8),
            child: widget.isDesktop
                ? _buildTabRow(clampedIndex)
                : _buildDropdownRow(clampedIndex),
          ),
        ),
        const Gap(8),
        if (widget.maxHeight != null)
          BackToTopWrapper(
            builder: (scrollController) => SizedBox(
              height: widget.maxHeight!,
              child: RepaintBoundary(
                child: SportLeagueEventsContent(
                  filter: widget.filter,
                  sportId: selectedSportId,
                  scrollController: scrollController,
                  isDesktop: widget.isDesktop,
                ),
              ),
            ),
          )
        else
          Expanded(
            child: RepaintBoundary(
              child: BackToTopWrapper(
                builder: (scrollController) => SportLeagueEventsContent(
                  filter: widget.filter,
                  sportId: selectedSportId,
                  scrollController: scrollController,
                  isDesktop: widget.isDesktop,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class SportLeagueEventsContent extends ConsumerWidget {
  final MatchFilterType filter;
  final int sportId;
  final ScrollController? scrollController;

  final bool isDesktop;

  const SportLeagueEventsContent({
    super.key,
    required this.filter,
    required this.sportId,
    this.scrollController,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (filter == MatchFilterType.favorites) {
      ref.watch(favoriteEventsAutoRefreshProvider(sportId));

      final (isLoading, leagues) = ref.watch(
        favoriteProvider.select(
          (s) => (
            s.isFavoriteEventsLoading(sportId),
            s.getFavoriteEventsLeagues(sportId),
          ),
        ),
      );

      if (!isLoading && leagues == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(favoriteProvider.notifier).fetchFavoriteEvents(sportId);
        });
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(0),
            child: SportShimmerLoading(isDesktop: false),
          ),
        );
      }

      if (isLoading) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(0),
            child: SportShimmerLoading(isDesktop: false),
          ),
        );
      }
      final nonEmpty =
          leagues?.where((l) => l.events.isNotEmpty).toList() ?? [];
      if (nonEmpty.isEmpty) {
        return const SportEmptyPage();
      }
      return CustomScrollView(
        controller: scrollController,
        cacheExtent: 1200,
        slivers: [
          LeagueEventsSliverV2(
            leagues: nonEmpty,
            isDesktop: isDesktop,
            showBackToTop: false,
            enableVisibleLeagueSub: true,
            subTimeRanges: kLeagueSubAllTimeRanges,
          ),
          SliverPadding(
            padding: EdgeInsets.only(
              bottom: 80 + MediaQuery.of(context).padding.bottom,
            ),
          ),
        ],
      );
    }

    final isLoading = ref.watch(eventsV2Provider.select((s) => s.isLoading));
    final error = ref.watch(eventsV2Provider.select((s) => s.error));
    if (error != null) {
      return SportErrorPage(
        onRetry: () => ref.read(eventsV2Provider.notifier).refresh(),
      );
    }
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(0),
          child: SportShimmerLoading(isDesktop: false),
        ),
      );
    }
    return Consumer(
      builder: (context, ref, _) {
        final leagues = ref.watch(leaguesV2Provider);
        final currentTimeRange = ref.watch(selectedTimeRangeV2Provider);
        final filteredLeagues =
            (currentTimeRange == v2.EventTimeRange.today ||
                currentTimeRange == v2.EventTimeRange.early ||
                currentTimeRange == v2.EventTimeRange.todayAndEarly)
            ? leagues
                  .map(
                    (l) => l.copyWith(
                      events: l.events
                          .where((e) => e.isLive != true)
                          .toList(),
                    ),
                  )
                  .where((l) => l.events.isNotEmpty)
                  .toList()
            : leagues.where((l) => l.events.isNotEmpty).toList();

        if (filteredLeagues.isEmpty) {
          return const SportEmptyPage();
        }
        return CustomScrollView(
          controller: scrollController,
          cacheExtent: 1200,
          slivers: [
            LeagueEventsSliverV2(
              leagues: filteredLeagues,
              isDesktop: isDesktop,
              showBackToTop: false,
              collapseAllProvider: sportListUpcomingCollapseAllProvider,
              enableVisibleLeagueSub: true,
              subTimeRanges:
                  currentTimeRange == v2.EventTimeRange.todayAndEarly
                      ? kLeagueSubAllTimeRanges
                      : {currentTimeRange.value},
            ),
            SliverPadding(
              padding: EdgeInsets.only(
                bottom: 80 + MediaQuery.of(context).padding.bottom,
              ),
            ),
          ],
        );
      },
    );
  }
}
