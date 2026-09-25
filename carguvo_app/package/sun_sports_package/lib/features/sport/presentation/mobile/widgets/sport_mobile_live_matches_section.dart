import 'dart:math' as math;

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/providers/auth_provider.dart';
import 'package:sun_sports/providers/main_content_provider.dart';
import 'package:sun_sports/shared/widgets/gestures/tab_pager.dart'
    show DrawerEdgeSwipe, TabPagerEdgeSwipe;
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/sport_constants.dart'
    as v2;
import 'package:sun_sports/features/sport/presentation/providers/events_v2_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/events_v2_filter_provider.dart';
import 'package:sun_sports/features/sport/data/adapters/sport_socket_adapter_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/league_detail_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/top_league_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/vibrating_odds_provider.dart';
import 'package:sun_sports/core/utils/styles/spacing_styles.dart';
import 'package:sun_sports/features/sport/presentation/widgets/sport_hot_section.dart';
import 'package:sun_sports/features/sport/presentation/widgets/sport_list_event_container.dart';
import 'package:sun_sports/shared/widgets/back_to_top_overlay.dart'
    show BackToTopWrapper;
import 'package:sun_sports/shared/widgets/empty_page/sport_empty_page.dart';
import 'package:sun_sports/shared/widgets/sport/league/league_card_v2.dart';
import 'package:sun_sports/features/sport/presentation/mobile/widgets/sport_mobile_popular_league_section.dart';
import 'package:sun_sports/features/sport/presentation/providers/league_collapse_providers.dart';
import 'package:sun_sports/shared/widgets/sport/collapse_all_toggle.dart';
import 'package:sun_sports/shared/widgets/sport/loading/sport_shimmer_loading.dart';
import 'package:sun_sports/features/sport/presentation/desktop/widgets/sport_desktop_type_filter_tabs.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

final _selectedFilterProvider = StateProvider.autoDispose<MatchFilterType>(
  (ref) => MatchFilterType.live,
);

const List<MatchFilterType> _kFilterOrder = <MatchFilterType>[
  MatchFilterType.live,
  MatchFilterType.upcoming,
  MatchFilterType.favorites,
];

const Duration _kTabSlideDuration = Duration(milliseconds: 260);

class SportMobileLiveMatchesSection extends ConsumerStatefulWidget {
  const SportMobileLiveMatchesSection({super.key});

  @override
  ConsumerState<SportMobileLiveMatchesSection> createState() =>
      _SportMobileLiveMatchesSectionState();
}

class _SportMobileLiveMatchesSectionState
    extends ConsumerState<SportMobileLiveMatchesSection> {
  late final PageController _pageController;

  late int _settledIndex;

  bool _neighbourBuilt = false;

  late final ValueNotifier<int> _activeIndex;

  @override
  void initState() {
    super.initState();
    final int initial = _kFilterOrder.indexOf(ref.read(_selectedFilterProvider));
    _settledIndex = initial < 0 ? 0 : initial;
    _activeIndex = ValueNotifier<int>(_settledIndex);
    _pageController = PageController(initialPage: _settledIndex);
    _syncSwipeLock();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _activeIndex.dispose();
    _swipeLocked.dispose();
    super.dispose();
  }

  void _goToIndex(int index) {
    if (index < 0 || index >= _kFilterOrder.length) return;
    if (!_pageController.hasClients) return;
    final int current = (_pageController.page ?? _settledIndex.toDouble())
        .round();
    if (index == current) return;
    if ((index - current).abs() > 1) {
      _pageController.jumpToPage(index > current ? index - 1 : index + 1);
    }
    _pageController.animateToPage(
      index,
      duration: _kTabSlideDuration,
      curve: Curves.easeOutCubic,
    );
  }

  void _handlePageChanged(int index) {
    _activeIndex.value = index;
    ref.read(_selectedFilterProvider.notifier).state = _kFilterOrder[index];
  }

  final ValueNotifier<bool> _swipeLocked = ValueNotifier<bool>(false);

  void _syncSwipeLock() {
    final bool locked =
        !ref.read(isAuthenticatedProvider) &&
        _kFilterOrder[_activeIndex.value] == MatchFilterType.favorites;
    if (_swipeLocked.value != locked) _swipeLocked.value = locked;
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth != 0) return false;
    _handleEdgeDrag(notification);
    if (notification is ScrollEndNotification) {
      _settle();
      _syncSwipeLock();
    }
    return false;
  }

  static const TabPagerEdgeSwipe _edgeSwipe = DrawerEdgeSwipe();

  static const double _kEdgeSlop = 8;

  double _edgeDrag = 0;
  bool _edgeActive = false;

  void _handleEdgeDrag(ScrollNotification notification) {
    if (notification is ScrollStartNotification) {
      _edgeDrag = 0;
      return;
    }

    if (notification is OverscrollNotification) {
      if (notification.dragDetails == null) return;
      final ScrollMetrics m = notification.metrics;
      if (m.axis != Axis.horizontal) return;
      if (m.pixels > m.minScrollExtent) return;
      _edgeDrag = math.max(0.0, _edgeDrag - notification.overscroll);

      if (!_edgeActive) {
        if (_edgeDrag < _kEdgeSlop) return;
        if (!_edgeSwipe.begin()) {
          _edgeDrag = 0;
          return;
        }
        _edgeActive = true;
      }
      _edgeSwipe.update(_edgeDrag);
      return;
    }

    if (notification is ScrollEndNotification && _edgeActive) {
      _edgeActive = false;
      _edgeDrag = 0;
      _edgeSwipe.end();
    }
  }

  void _settle() {
    if (!_pageController.hasClients) return;
    final double? page = _pageController.page;
    if (page == null) return;
    final int index = page.round();
    if ((page - index).abs() > 0.01) return;

    final bool changed = index != _settledIndex;
    if (!changed && !_neighbourBuilt) return;

    _settledIndex = index;
    _neighbourBuilt = false;
    _activeIndex.value = index;

    final MatchFilterType filter = _kFilterOrder[index];
    ref.read(_selectedFilterProvider.notifier).state = filter;

    if (changed) {
      ref.read(vibratingOddsProvider.notifier).clearAll();
    }
    applySportTabFilter(ref, filter, refresh: changed);
  }

  Widget _buildPage(BuildContext context, int index) {
    if (index != _settledIndex) _neighbourBuilt = true;

    final Widget page = switch (_kFilterOrder[index]) {
      MatchFilterType.live => const _LiveTabPage(),
      MatchFilterType.upcoming => const SportListEventContainer(
        filter: MatchFilterType.upcoming,
      ),
      MatchFilterType.favorites => const SportListEventContainer(
        filter: MatchFilterType.favorites,
      ),
    };

    return _KeepAlivePage(
      activeIndex: _activeIndex,
      index: index,
      child: page,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(isAuthenticatedProvider, (_, __) => _syncSwipeLock());
    return Container(
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          _MatchFilterTabs(onSelect: _goToIndex),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: _handleScrollNotification,
              child: ValueListenableBuilder<bool>(
                valueListenable: _swipeLocked,
                builder: (BuildContext context, bool locked, Widget? _) {
                  return PageView.builder(
                    controller: _pageController,
                    physics: locked
                        ? const NeverScrollableScrollPhysics()
                        : const PageScrollPhysics(
                            parent: ClampingScrollPhysics(),
                          ),
                    itemCount: _kFilterOrder.length,
                    onPageChanged: _handlePageChanged,
                    itemBuilder: _buildPage,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveTabPage extends StatelessWidget {
  const _LiveTabPage();

  @override
  Widget build(BuildContext context) {
    return BackToTopWrapper(
      builder: (scrollController) => CustomScrollView(
        key: const PageStorageKey<String>('sport_mobile_tab_live'),
        controller: scrollController,
        slivers: const [
          SliverToBoxAdapter(child: Gap(AppSpacingStyles.space300)),
          SliverToBoxAdapter(
            child: RepaintBoundary(child: SportHotSection(height: 125)),
          ),
          SliverToBoxAdapter(child: SportTypeFilterTabs()),
          SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(child: _LiveContent()),
          SliverToBoxAdapter(child: SizedBox(height: 16)),
          SportMobilePopularLeagueSection(),
          SliverToBoxAdapter(child: SizedBox(height: 160)),
        ],
      ),
    );
  }
}

class _KeepAlivePage extends StatefulWidget {
  const _KeepAlivePage({
    required this.activeIndex,
    required this.index,
    required this.child,
  });

  final ValueListenable<int> activeIndex;
  final int index;
  final Widget child;

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ValueListenableBuilder<int>(
      valueListenable: widget.activeIndex,
      child: RepaintBoundary(child: widget.child),
      builder: (context, active, child) =>
          TickerMode(enabled: active == widget.index, child: child!),
    );
  }
}

class _MatchFilterTabs extends ConsumerWidget {
  const _MatchFilterTabs({required this.onSelect});

  final ValueChanged<int> onSelect;

  static const double _tabIconSize = 16;

  static const double _tabRowHeight = _tabIconSize + 2;

  static List<(MatchFilterType, String, String)> get _filters => [
    (MatchFilterType.live, 'Sảnh', AppIcons.iconHomeSport),
    (MatchFilterType.upcoming, 'Sắp diễn ra', AppIcons.iconComingSport),
    (MatchFilterType.favorites, 'Yêu thích', AppIcons.iconFavoriteSport),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(_selectedFilterProvider);
    final filters = _filters;

    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x001B1A19), Color(0xFF1B1A19)],
              ),
            ),
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFF252423), width: 0.5),
            ),
          ),
          child: Row(
            children: [
              for (int i = 0; i < filters.length; i++)
                Expanded(
                  child: _tab(
                    index: i,
                    filter: filters[i],
                    isSelected: selectedFilter == filters[i].$1,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tab({
    required int index,
    required (MatchFilterType, String, String) filter,
    required bool isSelected,
  }) {
    final Color iconColor = isSelected
        ? const Color(0xFFFDE272)
        : const Color(0xFF9C9B95);

    return GestureDetector(
      onTap: SoundTap.wrap(() => onSelect(index)),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 30,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isSelected)
              Positioned.fill(
                child: ImageHelper.load(
                  path: AppIcons.sportStatusSelected,
                  fit: BoxFit.fill,
                ),
              ),
            SizedBox(
              height: _tabRowHeight,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ImageHelper.load(
                      path: filter.$3,
                      width: _tabIconSize,
                      height: _tabIconSize,
                      color: iconColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      filter.$2,
                      style: AppTextStyles.textStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: iconColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SportTypeFilterTabs extends StatelessWidget {
  const SportTypeFilterTabs();

  @override
  Widget build(BuildContext context) {
    final sports = sportDesktopTypeFilterItems;
    debugPrint(
      'list sport ${sports.map((e) => e.name + ' - ' + e.sportId.toString()).join(', ')}',
    );
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        child: Row(
          children: [
            for (int i = 0; i < sports.length; i++)
              _MobileSportWithLeagues(
                sport: sports[i],
                isLast: i == sports.length - 1,
              ),
          ],
        ),
      ),
    );
  }
}

class _MobileSportWithLeagues extends StatelessWidget {
  final SportDesktopTypeFilterItem sport;
  final bool isLast;

  const _MobileSportWithLeagues({required this.sport, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final leagues =
            ref.watch(topLeagueEventsProvider(sport.sportId)).valueOrNull ?? [];

        debugPrint(
          'list leagues ${leagues.map((e) => e.displayName + ' - ' + e.leagueId.toString()).join(', ')}',
        );
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(
                right: leagues.isNotEmpty || !isLast ? 8 : 0,
              ),
              child: _MobileSportTabItem(sport: sport),
            ),
            for (int i = 0; i < leagues.length; i++)
              Container(
                margin: EdgeInsets.only(
                  right: (i < leagues.length - 1 || !isLast) ? 8 : 0,
                ),
                child: _MobileLeagueTabItem(
                  name: leagues[i].displayName,
                  logo: leagues[i].leagueLogo,
                  sportId: leagues[i].sportId,
                  leagueId: leagues[i].leagueId,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _MobileSportTabItem extends StatelessWidget {
  final SportDesktopTypeFilterItem sport;

  const _MobileSportTabItem({required this.sport});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) => GestureDetector(
        onTap: SoundTap.wrap(() {
          ref.read(previousContentProvider.notifier).state =
              MainContentType.sport;
          final sportType =
              v2.SportType.fromId(sport.sportId) ?? v2.SportType.soccer;
          ref.read(selectedSportV2Provider.notifier).state = sportType;
          ref
              .read(sportSocketAdapterProvider)
              .subscriptionManager
              .setActiveSport(sport.sportId);
          ref.read(mainContentProvider.notifier).goToSportDetail();
        }),
        child: child,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF252423),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: SizedBox(
              width: 28,
              height: 28,
              child: ImageHelper.load(path: sport.icon, width: 28, height: 28),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sport.name,
            style: AppTextStyles.paragraphXXSmall(
              color: AppColorStyles.contentPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _MobileLeagueTabItem extends StatelessWidget {
  final String name;
  final String logo;
  final int sportId;
  final int leagueId;

  const _MobileLeagueTabItem({
    required this.name,
    required this.logo,
    required this.sportId,
    required this.leagueId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) => GestureDetector(
        onTap: SoundTap.wrap(() {
          ref
              .read(selectedLeagueInfoProvider.notifier)
              .state = SelectedLeagueInfo(
            sportId: sportId,
            leagueId: leagueId,
            leagueName: name,
            leagueLogo: logo,
          );
          ref.read(mainContentProvider.notifier).goToLeagueDetail();
        }),
        child: child,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF252423),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: logo.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      color: Colors.white,
                      width: 28,
                      height: 28,
                      child: ImageHelper.load(
                        path: logo,
                        width: 28,
                        height: 28,
                        fit: BoxFit.fill,
                        errorWidget: const SizedBox(width: 28, height: 28),
                      ),
                    ),
                  )
                : const SizedBox(width: 28, height: 28),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 64,
            child: Text(
              name,
              style: AppTextStyles.paragraphXXSmall(
                color: AppColorStyles.contentPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveContent extends ConsumerStatefulWidget {
  const _LiveContent();

  @override
  ConsumerState<_LiveContent> createState() => _LiveContentState();
}

class _LiveContentState extends ConsumerState<_LiveContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (ref.read(selectedTimeRangeV2Provider) != v2.EventTimeRange.live) {
        ref.read(selectedTimeRangeV2Provider.notifier).state =
            v2.EventTimeRange.live;
        ref
            .read(sportSocketAdapterProvider)
            .subscriptionManager
            .setTimeRangeFromString('LIVE');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1A19),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1FFFFFFF),
            offset: Offset(0, 0.5),
            blurRadius: 0.5,
            spreadRadius: 0,
            blurStyle: BlurStyle.inner,
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_LiveHeader(), _SportFilterTabs(), _LiveMatchesList()],
      ),
    );
  }
}

class _LiveMatchesList extends StatelessWidget {
  const _LiveMatchesList();

  static const int _maxLiveEvents = 5;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final isLoading = ref.watch(
          eventsV2Provider.select((state) => state.isLoading),
        );

        if (isLoading) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: SportShimmerLoading(isDesktop: false),
          );
        }

        final leagues = ref.watch(leaguesV2Provider);
        final nonEmpty = leagues.where((l) => l.events.isNotEmpty).toList();

        if (nonEmpty.isEmpty) return const SportEmptyPage();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [..._buildLeagueWidgets(nonEmpty), const _ViewAllButton()],
        );
      },
    );
  }

  static List<Widget> _buildLeagueWidgets(List<LeagueModelV2> leagues) {
    final result = <Widget>[];
    var remaining = _maxLiveEvents;

    for (final league in leagues) {
      if (remaining <= 0) break;

      final events = league.events;
      if (events.isEmpty) continue;

      final displayLeague = events.length <= remaining
          ? league
          : league.copyWith(events: events.sublist(0, remaining));

      result.add(
        LeagueCardV2(
          league: displayLeague,
          collapseAllProvider: sportLiveMatchesCollapseAllProvider,
          enableVisibleLeagueSub: true,
          subTimeRanges: {v2.EventTimeRange.live.value},
        ),
      );
      remaining -= displayLeague.events.length;
    }

    return result;
  }
}

class _SportFilterTabs extends StatelessWidget {
  const _SportFilterTabs();

  @override
  Widget build(BuildContext context) {
    final sports = sportDesktopTypeFilterItems;
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF252423), width: 0.5),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: sports
              .map((sport) => _SportFilterTabItem(sport: sport))
              .toList(),
        ),
      ),
    );
  }
}

class _SportFilterTabItem extends StatelessWidget {
  final SportDesktopTypeFilterItem sport;

  const _SportFilterTabItem({required this.sport});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final isSelected = ref.watch(
          selectedSportV2Provider.select((s) => s.id == sport.sportId),
        );

        return GestureDetector(
          onTap: SoundTap.wrap(() {
            final sportType =
                v2.SportType.fromId(sport.sportId) ?? v2.SportType.soccer;
            ref.read(selectedSportV2Provider.notifier).state = sportType;
            ref
                .read(sportSocketAdapterProvider)
                .subscriptionManager
                .setActiveSport(sport.sportId);
          }),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ImageHelper.load(
                        path: isSelected
                            ? sport.iconSelected
                            : sport.iconDisabled,
                        width: 16,
                        height: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        sport.name,
                        style: AppTextStyles.paragraphXSmall(
                          color: isSelected
                              ? AppColors.yellow300
                              : const Color(0xFF9C9B95),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Positioned(
                    bottom: 0,
                    left: -20,
                    right: -20,
                    child: ImageHelper.load(
                      path: AppIcons.sportStatusSelected,
                      fit: BoxFit.fill,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LiveHeader extends StatelessWidget {
  const _LiveHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1A19),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, -0.65),
            blurRadius: 0.5,
            spreadRadius: 0.05,
            blurStyle: BlurStyle.inner,
            color: Colors.white.withValues(alpha: 0.15),
          ),
        ],
      ),
      child: Row(
        children: [
          const _LiveIcon(),
          const SizedBox(width: 6),
          Text(
            'Đang diễn ra',
            style: AppTextStyles.textStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFFFFEF5),
            ),
          ),
          const Spacer(),
          CollapseAllToggle(
            provider: sportLiveMatchesCollapseAllProvider,
            iconSize: 20,
            padding: const EdgeInsets.all(5),
          ),
        ],
      ),
    );
  }
}

class _LiveIcon extends StatelessWidget {
  const _LiveIcon();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20,
      height: 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0x1FF04438),
              shape: BoxShape.circle,
            ),
            child: SizedBox(width: 16, height: 16),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0x1FF04438),
              shape: BoxShape.circle,
            ),
            child: SizedBox(width: 11, height: 11),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFFF04438),
              shape: BoxShape.circle,
            ),
            child: SizedBox(width: 6, height: 6),
          ),
        ],
      ),
    );
  }
}

class _ViewAllButton extends StatelessWidget {
  const _ViewAllButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Consumer(
        builder: (context, ref, child) => GestureDetector(
          onTap: SoundTap.wrap(() {
            ref.read(previousContentProvider.notifier).state =
                MainContentType.sport;
            ref.read(selectedSportV2Provider.notifier).state = ref.read(
              selectedSportV2Provider,
            );
            ref.read(mainContentProvider.notifier).goToSportDetail();
          }),
          child: child,
        ),
        child: Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF393836),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Xem tất cả',
                style: AppTextStyles.textStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFFFFEF5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
