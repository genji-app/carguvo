import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sun_sports/core/providers/live_chat_expanded_provider.dart';
import 'package:sun_sports/providers/main_content_provider.dart';
import 'package:sun_sports/core/providers/scroll_controller_provider.dart';
import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';
import 'package:sun_sports/providers/app_init_provider.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/game/game.dart';
import 'package:sun_sports/features/home/presentation/mobile/widgets/home_mobile_provider_section.dart';
import 'package:sun_sports/core/services/maintenance/sb_maintenance_provider.dart';
import 'package:sun_sports/core/services/models/api_v2/sport_constants.dart';
import 'package:sun_sports/features/home/presentation/mobile/widgets/home_category_tabs.dart';
import 'package:sun_sports/features/home/presentation/providers/home_category_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/league_provider.dart';
import 'package:sun_sports/features/sport/presentation/widgets/sport_hot_section.dart';
import 'package:sun_sports/shared/layouts/shell_pinned_align.dart';
import 'package:sun_sports/shared/layouts/shell_top_overlap_sliver.dart';
import 'package:sun_sports/features/home/presentation/mobile/widgets/home_mobile_sports_section.dart';
import 'package:sun_sports/features/home/presentation/mobile/widgets/home_mobile_welcome_section.dart';
import 'package:sun_sports/features/home/presentation/widgets/count_down_event/count_down_event_deadline.dart';
import 'package:sun_sports/features/home/presentation/widgets/count_down_event/count_down_event_screen.dart';
import 'package:sun_sports/features/home/presentation/widgets/home_footer_section.dart';
import 'package:sun_sports/features/home/presentation/widgets/home_shimmer_loading.dart';
import 'package:sun_sports/features/sport/presentation/widgets/sport_live_chat.dart';
import 'package:sun_sports/features/sport_detail/presentation/providers/sport_detail_tab_provider.dart';
import 'package:sun_sports/features/sport_detail/presentation/mobile/widgets/sport_detail_mobile_matches_section.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/cards/inner_shadow_card.dart';
import 'package:sun_sports/shared/widgets/empty_page/sport_empty_page.dart';
import 'package:sun_sports/shared/widgets/gestures/tab_pager.dart';
import 'package:sun_sports/shared/widgets/keep_alive_wrapper.dart';
import 'package:sun_sports/shared/widgets/scroll_aware_scroll_reporter.dart';
import 'package:sun_sports/shared/widgets/sport/league/league_card_v2.dart';

class HomeMobileScreen extends StatelessWidget {
  const HomeMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final isInitializing = ref.watch(isAppInitializingProvider);

        if (isInitializing) {
          return const HomeShimmerLoading(isMobile: true);
        }

        return const Scaffold(
          backgroundColor: Color(0xFF141414),
          body: HomeMobileContent(),
        );
      },
    );
  }
}

class HomeMobileContent extends ConsumerStatefulWidget {
  const HomeMobileContent({super.key});

  @override
  ConsumerState<HomeMobileContent> createState() => _HomeMobileContentState();
}

class _HomeMobileContentState extends ConsumerState<HomeMobileContent> {
  static const double _minCacheExtent = 200;
  static const double _idleCacheExtent = 400;
  static const Duration _cacheIdleDelay = Duration(milliseconds: 300);
  double _cacheExtent = 0;
  Timer? _cacheExtentDebounce;
  ScrollController? _scrollController;

  static const int _revealBatch = 2;
  late final List<Widget> _topSections = _buildTopSections();
  late final List<Widget> _bottomSections = _buildBottomSections();

  int get _sectionCount => _topSections.length + 1 + _bottomSections.length;
  int _revealed = _revealBatch;

  final GlobalKey _categoryAnchor = GlobalKey();

  @override
  void initState() {
    super.initState();
    final sc = ref.read(mainScrollControllerProvider);
    _scrollController = sc;
    sc.addListener(_onScrollChanged);
    for (final ProviderListenable<Object?> p in <ProviderListenable<Object?>>[
      homeCategoryProviderIdProvider,
      homeCategoryRawQueryProvider,
      homeCategoryQueryProvider,
      homeCategoryPendingRowIdProvider,
    ]) {
      ref.listenManual(p, (_, __) {});
    }
    ref.listenManual<HomeProviderFilterRequest?>(
      homeProviderFilterRequestProvider,
      (HomeProviderFilterRequest? previous, HomeProviderFilterRequest? next) {
        if (next != null) _onProviderRequest(next.providerId);
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _revealNext());
  }

  @override
  void dispose() {
    _cacheExtentDebounce?.cancel();
    _scrollController?.removeListener(_onScrollChanged);
    super.dispose();
  }

  void _onScrollChanged() {
    _cacheExtentDebounce?.cancel();
    if (_cacheExtent != _minCacheExtent && mounted) {
      setState(() => _cacheExtent = _minCacheExtent);
    }
    _cacheExtentDebounce = Timer(_cacheIdleDelay, () {
      if (!mounted || _cacheExtent != _idleCacheExtent) {
        setState(() => _cacheExtent = _idleCacheExtent);
      }
    });
  }

  void _revealNext() {
    if (!mounted) return;
    if (_revealed >= _sectionCount) {
      if (_cacheExtent != _idleCacheExtent) {
        setState(() => _cacheExtent = _idleCacheExtent);
      }
      return;
    }
    setState(() {
      _revealed = (_revealed + _revealBatch).clamp(0, _sectionCount);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _revealNext());
  }

  List<Widget> _buildTopSections() => [
    const Gap(8),
    const KeepAliveWrapper(
      child: RepaintBoundary(child: HomeMobileWelcomeSection()),
    ),
    if (!isEventCupExpired()) ...[
      const Gap(8),
      const KeepAliveWrapper(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: RepaintBoundary(child: CountDownEventScreen()),
        ),
      ),
      const Gap(16),
    ] else
      const Gap(8),
    const KeepAliveWrapper(
      child: RepaintBoundary(child: _HomeHotMatchesSection()),
    ),
  ];

  List<Widget> _buildBottomSections() => [
    const Gap(24),
    const KeepAliveWrapper(
      child: RepaintBoundary(child: _HomeSportsHighlightSection()),
    ),
    const KeepAliveWrapper(
      child: RepaintBoundary(child: HomeMobileProviderSection()),
    ),
    const Gap(8),
    const KeepAliveWrapper(
      child: RepaintBoundary(child: GameGroupView.featured()),
    ),
    const Gap(8),
    const KeepAliveWrapper(
      child: RepaintBoundary(
        child: _DeferredMount(
          delay: Duration(milliseconds: 400),
          placeholder: _CarouselPlaceholder(),
          child: GameGroupView.liveCasino(),
        ),
      ),
    ),
    const Gap(8),
    const KeepAliveWrapper(
      child: RepaintBoundary(child: HomeFooterSection()),
    ),
    const Gap(10),
  ];

  int _categoryIndex(WidgetRef ref) {
    final List<HomeCategoryItem> items = ref.watch(homeCategoryItemsProvider);
    final HomeCategoryItem selected = resolveHomeCategory(
      items,
      ref.watch(homeCategorySelectedIdProvider),
    );
    final int i = items.indexOf(selected);
    return i < 0 ? 0 : i;
  }

  void _onCategoryCommitted(int index) {
    final List<HomeCategoryItem> items = ref.read(homeCategoryItemsProvider);
    if (index < 0 || index >= items.length) return;
    final String id = items[index].id;
    if (ref.read(homeCategorySelectedIdProvider) == id) return;
    ref.read(homeCategorySelectedIdProvider.notifier).state = id;
    _resetProviderIfAbsent(id);
  }

  void _resetProviderIfAbsent(String tabId) {
    final String providerId = ref.read(homeCategoryProviderIdProvider);
    if (providerId.isEmpty) return;
    final List<LobbyCategory> chips = ref.read(
      homeCategoryProvidersProvider(tabId),
    );
    if (homeEffectiveProviderId(chips, providerId).isNotEmpty) return;
    ref.read(homeCategoryProviderIdProvider.notifier).state = '';
  }

  void _onProviderRequest(String providerId) {
    if (!mounted) return;
    final List<HomeCategoryItem> items = ref.read(homeCategoryItemsProvider);
    if (!items.any((HomeCategoryItem i) => i.id == kHomeCustomTabId)) return;
    ref.read(homeCategoryProviderIdProvider.notifier).state = providerId;
    if (ref.read(homeCategorySelectedIdProvider) != kHomeCustomTabId) {
      ref.read(homeCategoryPendingRowIdProvider.notifier).state =
          kHomeCustomTabId;
      ref.read(homeCategorySelectedIdProvider.notifier).state =
          kHomeCustomTabId;
    }
    _alignCategoryBlock();
  }

  void _onCategorySelected(String id) {
    final HomeCategoryItem current = resolveHomeCategory(
      ref.read(homeCategoryItemsProvider),
      ref.read(homeCategorySelectedIdProvider),
    );
    if (id == current.id) return;
    _alignCategoryBlock();
    ref.read(homeCategorySelectedIdProvider.notifier).state = id;
  }

  void _alignCategoryBlock() {
    alignUnderShellPinnedBlockWithRef(
      ref,
      controller: ref.read(mainScrollControllerProvider),
      anchorKey: _categoryAnchor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scrollController = ref.watch(mainScrollControllerProvider);

    return GestureDetector(
      onTap: SoundTap.wrap(() {
        final isExpanded = ref.read(liveChatExpandedProvider);
        if (isExpanded) {
          FocusScope.of(context).unfocus();
          ref.read(liveChatExpandedProvider.notifier).state = false;
        }
      }),
      behavior: HitTestBehavior.translucent,
      child: Container(
        color: AppColorStyles.backgroundPrimary,
        child: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final List<HomeCategoryItem> items = ref.watch(
              homeCategoryItemsProvider,
            );
            return TabPagerHost(
              index: _categoryIndex(ref),
              count: items.length,
              onCommit: _onCategoryCommitted,
              child: child!,
            );
          },
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: ScrollAwareScrollReporter(
              child: CustomScrollView(
                controller: scrollController,
                cacheExtent: _cacheExtent,
                slivers: [
                  const ShellTopOverlapSliver(),

                  SliverList.builder(
                    itemCount: _revealed.clamp(0, _topSections.length),
                    itemBuilder: (context, index) => _topSections[index],
                  ),

                  if (_revealed > _topSections.length) ...[
                    ShellPinnedBlockAnchor(anchorKey: _categoryAnchor),
                    SliverMainAxisGroup(
                      slivers: [
                        PinnedHeaderSliver(
                          child: HomeCategoryBar(
                            onSelect: _onCategorySelected,
                            onAlign: _alignCategoryBlock,
                          ),
                        ),
                        const SliverToBoxAdapter(child: Gap(8)),
                        Consumer(
                          builder: (BuildContext context, WidgetRef ref, _) {
                            final TabPagerController? pager = TabPagerScope.maybeOf(
                              context,
                            );
                            if (pager == null) {
                              return HomeCategoryPanel(index: _categoryIndex(ref));
                            }
                            return TabPagerPanel(
                              fallbackIndex: pager.index,
                              panelBuilder:
                                  (BuildContext context, int index) =>
                                      HomeCategoryPanel(index: index),
                            );
                          },
                        ),
                      ],
                    ),
                  ],

                  SliverList.builder(
                    itemCount: (_revealed - _topSections.length - 1).clamp(
                      0,
                      _bottomSections.length,
                    ),
                    itemBuilder: (context, index) => _bottomSections[index],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeHotMatchesSection extends ConsumerWidget {
  const _HomeHotMatchesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(sbMaintenanceProvider) ||
        ref.watch(currentSportIdProvider) == SportType.badminton.id) {
      return const SizedBox.shrink();
    }
    return const Padding(
      padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: SportHotSection(compactCards: true),
    );
  }
}

class _HomeSportsHighlightSection extends ConsumerWidget {
  const _HomeSportsHighlightSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(sbMaintenanceProvider)) return const SizedBox.shrink();
    return const Padding(
      padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: HomeMobileSportsSection(),
    );
  }
}

class _HomeMobileLiveMatchesSection extends StatelessWidget {
  final List<LeagueModelV2> leagues;
  final bool isLoading;

  static const int _maxLiveEvents = 8;

  static const double _leagueCardBaseHeight = 40.0;
  static const double _matchRowHeight = 220.0;

  const _HomeMobileLiveMatchesSection({
    required this.leagues,
    required this.isLoading,
  });

  List<LeagueModelV2> _filterLeaguesToMaxEvents(List<LeagueModelV2> leagues) {
    final filteredLeagues = <LeagueModelV2>[];
    int totalEvents = 0;

    for (final league in leagues) {
      if (league.events.isEmpty) continue;

      filteredLeagues.add(league);
      totalEvents += league.events.length;

      if (totalEvents >= _maxLiveEvents) break;
    }

    return filteredLeagues;
  }

  double _calculateTotalHeight(List<LeagueModelV2> leagues) {
    double totalHeight = 0;
    for (final league in leagues) {
      totalHeight +=
          _leagueCardBaseHeight +
          (league.events.length * (_matchRowHeight + 5));
    }
    return totalHeight;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const _ShimmerLoadingListMobile();
    }

    if (leagues.isEmpty) {
      return const SportEmptyPage();
    }

    final filteredLeagues = _filterLeaguesToMaxEvents(leagues);
    if (filteredLeagues.isEmpty) {
      return const SportEmptyPage();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: InnerShadowCard(
        borderRadius: 16,
        child: Container(
          decoration: BoxDecoration(
            color: AppColorStyles.backgroundTertiary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: SizedBox(
                  height: _calculateTotalHeight(filteredLeagues),
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredLeagues.length,
                    itemBuilder: (context, index) {
                      return LeagueCardV2(league: filteredLeagues[index]);
                    },
                  ),
                ),
              ),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ).copyWith(bottom: 0),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFFFF5172),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Đang diễn ra',
              style: AppTextStyles.labelMedium(
                color: AppColorStyles.contentPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Consumer(
      builder: (context, ref, child) {
        return GestureDetector(
          onTap: SoundTap.wrap(() {
            ref.read(previousContentProvider.notifier).state =
                MainContentType.home;
            ref.read(sportDetailTabProvider.notifier).state =
                SportDetailFilterType.live;
            ref.read(mainContentProvider.notifier).goToSportDetail();
          }),
          child: Container(
            height: 48,
            margin: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0x0AFFFFFF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF393836), width: 1),
            ),
            child: Center(
              child: Text(
                'Xem thêm trận đấu',
                style: AppTextStyles.textStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFFFFEF5),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StickyLiveChatDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final ValueChanged<bool>? onStickyChanged;
  bool _lastStickyState = false;

  _StickyLiveChatDelegate({
    required this.minHeight,
    required this.maxHeight,
    this.onStickyChanged,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final isSticky = overlapsContent || shrinkOffset > 0;

    if (isSticky != _lastStickyState) {
      _lastStickyState = isSticky;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onStickyChanged?.call(isSticky);
      });
    }

    return _StickyLiveChatBody(height: maxHeight, isSticky: isSticky);
  }

  @override
  bool shouldRebuild(_StickyLiveChatDelegate oldDelegate) {
    return minHeight != oldDelegate.minHeight ||
        maxHeight != oldDelegate.maxHeight ||
        onStickyChanged != oldDelegate.onStickyChanged;
  }
}

class _StickyLiveChatBody extends StatelessWidget {
  const _StickyLiveChatBody({required this.height, required this.isSticky});

  final double height;
  final bool isSticky;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          const RepaintBoundary(child: SportLiveChat(isMobile: true)),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 40,
            child: IgnorePointer(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: isSticky ? 1.0 : 0.0,
                child: const _StickyGradientOverlay(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StickyGradientOverlay extends StatelessWidget {
  const _StickyGradientOverlay();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF000000), Color(0x00000000)],
        ),
      ),
    );
  }
}

class _ShimmerLoadingListMobile extends StatelessWidget {
  const _ShimmerLoadingListMobile();

  static const _shimmerBaseColor = Color(0xFF2A2A2A);
  static const _shimmerHighlightColor = Color(0xFF3D3D3D);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < 2; i++) _buildShimmerLeagueCard(),
      ],
    );
  }

  Widget _buildShimmerLeagueCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0x0AFFF6E4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                _buildShimmerBox(width: 24, height: 24, borderRadius: 6),
                const SizedBox(width: 8),
                _buildShimmerBox(width: 100, height: 12, borderRadius: 4),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Column(
              children: [for (int i = 0; i < 3; i++) _buildShimmerMatchRow()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerMatchRow() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0x08FFFFFF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShimmerBox(width: 50, height: 10, borderRadius: 4),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildShimmerBox(width: 20, height: 20, borderRadius: 10),
              const SizedBox(width: 8),
              Expanded(
                child: _buildShimmerBox(
                  width: double.infinity,
                  height: 12,
                  borderRadius: 4,
                ),
              ),
              const SizedBox(width: 12),
              _buildShimmerBox(width: 40, height: 24, borderRadius: 4),
              const SizedBox(width: 6),
              _buildShimmerBox(width: 40, height: 24, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildShimmerBox(width: 20, height: 20, borderRadius: 10),
              const SizedBox(width: 8),
              Expanded(
                child: _buildShimmerBox(
                  width: double.infinity,
                  height: 12,
                  borderRadius: 4,
                ),
              ),
              const SizedBox(width: 12),
              _buildShimmerBox(width: 40, height: 24, borderRadius: 4),
              const SizedBox(width: 6),
              _buildShimmerBox(width: 40, height: 24, borderRadius: 4),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBox({
    required double width,
    required double height,
    required double borderRadius,
  }) {
    return Shimmer(
      duration: const Duration(milliseconds: 1500),
      color: _shimmerHighlightColor,
      colorOpacity: 0.3,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: _shimmerBaseColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class _DeferredMount extends StatefulWidget {
  const _DeferredMount({
    required this.child,
    required this.placeholder,
    this.delay = const Duration(milliseconds: 400),
  });

  final Widget child;
  final Widget placeholder;
  final Duration delay;

  @override
  State<_DeferredMount> createState() => _DeferredMountState();
}

class _DeferredMountState extends State<_DeferredMount> {
  bool _show = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.delay, () {
      if (mounted) setState(() => _show = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _show ? widget.child : widget.placeholder;
}

class _CarouselPlaceholder extends StatelessWidget {
  const _CarouselPlaceholder();

  static const double _paddingH = 4;
  static const double _spacing = 8;
  static const double _chromeHeight = 48 + 16;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final cols = GameCardLayout.getColumns(w);
        final cardW = (w - 2 * _paddingH - (cols - 1) * _spacing) / cols;
        final cardH = GameCardLayout.calculateHeightFromWidth(cardW);
        return SizedBox(height: cardH + _chromeHeight);
      },
    );
  }
}
