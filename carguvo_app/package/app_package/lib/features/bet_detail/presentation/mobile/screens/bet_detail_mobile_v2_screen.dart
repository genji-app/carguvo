import 'package:flutter/rendering.dart' show RenderBox;
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_package/core/providers/live_chat_expanded_provider.dart';
import 'package:app_package/core/providers/scroll_hide_provider.dart';
import 'package:app_package/core/services/models/api_v2/event_model_v2.dart';
import 'package:app_package/features/sport/presentation/providers/events_v2_filter_provider.dart';
import 'package:app_package/features/sport/presentation/providers/league_provider.dart';
import 'package:app_package/core/utils/extensions/image_helper.dart';
import 'package:app_package/core/utils/styles/app_color.dart';
import 'package:app_package/core/utils/styles/app_color_styles.dart';
import 'package:app_package/core/utils/styles/app_icons.dart';
import 'package:app_package/core/utils/styles/app_text_styles.dart';
import 'package:app_package/features/bet_detail/domain/enums/market_filter.dart';
import 'package:app_package/shared/widgets/gestures/tab_pager.dart';
import 'package:app_package/features/bet_detail/domain/models/market_drawer_data_v2.dart';
import 'package:app_package/features/bet_detail/presentation/providers/bet_detail_mobile_v2_provider.dart';
import 'package:app_package/features/bet_detail/presentation/providers/bet_detail_v2_provider.dart';
import 'package:app_package/core/services/models/api_v2/v2_to_legacy_adapter.dart';
import 'package:app_package/features/bet_detail/presentation/mobile/widgets/market_drawer_v2_mobile_widget.dart';
import 'package:app_package/features/bet_detail/presentation/mobile/widgets/match_header_mobile_widget.dart';
import 'package:app_package/shared/layouts/shell_pinned_align.dart';
import 'package:app_package/shared/layouts/shell_top_block.dart';
import 'package:app_package/shared/layouts/shell_top_overlap_sliver.dart';
import 'package:app_package/core/services/models/league_model.dart';
import 'package:app_package/shared/widgets/livestream/livestream_lifecycle.dart';
import 'package:app_package/shared/widgets/livestream/pip_manager.dart';
import 'package:app_package/shared/widgets/buttons/sound_tap.dart';
import 'package:app_package/features/bet_detail/presentation/providers/detail_swap_guard_provider.dart';
import 'package:app_package/shared/widgets/sport/match/match_row_shared_v2.dart'
    show extractCurrentSet;

const Set<PointerDeviceKind> _horizontalDragDevices = {
  PointerDeviceKind.touch,
  PointerDeviceKind.mouse,
  PointerDeviceKind.trackpad,
  PointerDeviceKind.stylus,
  PointerDeviceKind.invertedStylus,
};

class BetDetailMobileV2Screen extends ConsumerStatefulWidget {
  const BetDetailMobileV2Screen({super.key});

  @override
  ConsumerState<BetDetailMobileV2Screen> createState() =>
      _BetDetailMobileV2ScreenState();
}

class _BetDetailMobileV2ScreenState
    extends ConsumerState<BetDetailMobileV2Screen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _livestreamKey = GlobalKey();

  final GlobalKey _pinnedHeadKey = GlobalKey();
  final GlobalKey _pinnedBetTabsKey = GlobalKey();

  final GlobalKey _drawersAnchorKey = GlobalKey();

  final GlobalKey<State<MatchHeaderMobileWidget>> _matchHeaderKey =
      GlobalKey<State<MatchHeaderMobileWidget>>();
  MatchTab? _currentTab;

  late final DetailSwapGuardNotifier _swapGuard;

  late final ScrollHideNotifier _scrollHide;

  @override
  void initState() {
    super.initState();
    _swapGuard = ref.read(detailSwapGuardProvider.notifier);
    _scrollController.addListener(_handleScroll);
    _scrollHide = ref.read(scrollHideProvider);
    _scrollHide.progress.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PipManager().setOnVideoPage(true);
      _initializeData();
      if (mounted) {
        final topPadding = MediaQuery.of(context).padding.top;
        final hasChat = ref.read(shellHasChatProvider);
        final liveChatHeight = ShellTopMetrics.readChat(ref);
        livestreamClipTopNotifier.value = ShellTopMetrics.blockBottom(
          topPadding: topPadding,
          hasChat: hasChat,
          chatHeight: liveChatHeight,
          hideProgress: ref.read(scrollHideProvider).progress.value,
        );
      }

      if (!PipManager().hasContent) {
        PipManager().initialize(
          context,
          onFullscreenRequested: () {
            _handleFullscreenRequest();
          },
        );
      } else {
        PipManager().setFullscreenCallback(() {
          _handleFullscreenRequest();
        });
      }
    });
  }

  void _initializeData() {
    if (!mounted) return;
    final selectedEventV2 = ref.read(selectedEventV2Provider);
    final selectedLeagueV2 = ref.read(selectedLeagueV2Provider);
    final sportId =
        selectedLeagueV2?.sportId ?? ref.read(selectedSportV2Provider).id;

    if (selectedEventV2 != null && selectedLeagueV2 != null) {
      final eventData = selectedEventV2.toLegacy();
      final leagueData = selectedLeagueV2.toLegacy();
      final currentSet = extractCurrentSet(selectedEventV2) ?? 1;
      ref
          .read(betDetailMobileV2Provider.notifier)
          .init(
            eventData: eventData,
            leagueData: leagueData,
            sportId: sportId,
            currentSet: currentSet,
          );

      _swapGuard.enterDetail(eventData.eventId);
    }
  }

  @override
  void dispose() {
    _swapGuard.exitDetail();

    PipManager().setOnVideoPage(false);

    livestreamClipTopNotifier.value = 0;

    if (_currentTab == MatchTab.live) {
      PipManager().dispose().catchError((Object e) {
        debugPrint('Error releasing the livestream WebView: $e');
      });
    }

    _scrollHide.progress.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!mounted || !_scrollController.hasClients) return;

    livestreamClipTopNotifier.value = ShellTopMetrics.blockBottom(
      topPadding: MediaQuery.of(context).padding.top,
      hasChat: ref.read(shellHasChatProvider),
      chatHeight: ShellTopMetrics.readChat(ref),
      hideProgress: _scrollHide.progress.value,
    );
  }

  double _pinnedHeight(GlobalKey key) {
    final RenderObject? box = key.currentContext?.findRenderObject();
    return box is RenderBox && box.hasSize ? box.size.height : 0;
  }

  void _alignUnderPinnedBetTabs() {
    alignUnderShellPinnedBlockWithRef(
      ref,
      controller: _scrollController,
      anchorKey: _drawersAnchorKey,
      pinnedAbove:
          _pinnedHeight(_pinnedHeadKey) + _pinnedHeight(_pinnedBetTabsKey),
    );
  }

  void _handleFullscreenRequest() {
    _switchToLiveTab();
  }

  void _switchToLiveTab() {
    final st = _matchHeaderKey.currentState;
    if (st != null) {
      (st as MatchHeaderTabController).setTab(MatchTab.live);
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 50),
          curve: Curves.easeOut,
        );
      }
      return;
    }

    if (_scrollController.hasClients) _scrollController.jumpTo(0);
    _retrySwitchToLiveTab(5);
  }

  void _retrySwitchToLiveTab(int attemptsLeft) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final st = _matchHeaderKey.currentState;
      if (st != null) {
        (st as MatchHeaderTabController).setTab(MatchTab.live);
      } else if (attemptsLeft > 0) {
        _retrySwitchToLiveTab(attemptsLeft - 1);
      }
    });
  }

  void _checkHeaderRevealableAfterLayout() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_scrollController.hasClients) return;
      ref
          .read(scrollHideProvider)
          .ensureRevealableOrShow(_scrollController.position);
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    ref.listen<EventModelV2?>(selectedEventV2Provider, (previous, next) {
      if (next == null) return;
      if (previous?.eventId == next.eventId) return;
      Future.microtask(_initializeData);
    });

    ref.listen<List<MarketDrawerDataV2>>(
      betDetailMobileV2Provider.select((state) => state.filteredDrawers),
      (_, __) => _checkHeaderRevealableAfterLayout(),
    );

    ref.listen<bool>(liveChatExpandedProvider, (previous, next) {
      final hasChat = ref.read(shellHasChatProvider);
      final liveChatHeight = ShellTopMetrics.readChat(ref);
      livestreamClipTopNotifier.value = ShellTopMetrics.blockBottom(
        topPadding: topPadding,
        hasChat: hasChat,
        chatHeight: liveChatHeight,
        hideProgress: _scrollHide.progress.value,
      );
    });

    return Scaffold(
      backgroundColor: AppColorStyles.backgroundPrimary,
      body: Consumer(builder: (context, ref, child) => _buildBody(context, ref)),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref) {
    final eventData = ref.watch(
      betDetailMobileV2Provider.select((state) => state.eventData),
    );
    final leagueData = ref.watch(
      betDetailMobileV2Provider.select((state) => state.leagueData),
    );

    final selectedEventV2 = ref.read(selectedEventV2Provider);
    final selectedLeagueV2 = ref.read(selectedLeagueV2Provider);
    final finalEventData = eventData ?? selectedEventV2?.toLegacy();
    final finalLeagueData = leagueData ?? selectedLeagueV2?.toLegacy();

    if (finalEventData == null) {
      return _buildLoadingState(context);
    }

    return _buildContentState(context, ref, finalEventData, finalLeagueData);
  }

  Widget _buildLoadingState(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: CustomScrollView(
        slivers: [
          const ShellContentTopSpacer(),
          const SliverToBoxAdapter(child: Gap(12)),
          const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFFFFD700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentState(
    BuildContext context,
    WidgetRef ref,
    LeagueEventData eventData,
    LeagueData? leagueData,
  ) {
    return _BetDetailPagerHost(
      child: _BetTabsAlignScope(
        alignUnderPinnedTabs: _alignUnderPinnedBetTabs,
        child: MatchHeaderMobileWidget(
          key: _matchHeaderKey,
          eventData: eventData,
          leagueData: leagueData,
          eventEnded: ref.watch(
            betDetailMobileV2Provider.select((state) => state.eventMissing),
          ),
          sportId:
              ref.read(selectedLeagueV2Provider)?.sportId ??
              ref.read(selectedSportV2Provider).id,
          livestreamKey: _livestreamKey,
          onTabChanged: (tab) => _currentTab = tab,
          layoutBuilder: (context, pinnedHead, body) => ScrollConfiguration(
            behavior: ScrollConfiguration.of(
              context,
            ).copyWith(scrollbars: false, overscroll: false),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                const ShellTopOverlapSliver(),
                if (pinnedHead == null) const SliverToBoxAdapter(child: Gap(16)),
                if (pinnedHead != null)
                  PinnedHeaderSliver(
                    child: ColoredBox(
                      key: _pinnedHeadKey,
                      color: AppColorStyles.backgroundPrimary,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: pinnedHead,
                      ),
                    ),
                  ),
                if (body != null) SliverToBoxAdapter(child: body),
                PinnedHeaderSliver(
                  child: ColoredBox(
                    key: _pinnedBetTabsKey,
                    color: AppColorStyles.backgroundPrimary,
                    child: const _BetTabsConsumer(),
                  ),
                ),
                ShellPinnedBlockAnchor(anchorKey: _drawersAnchorKey),
                _MarketDrawersPager(
                  eventData: eventData,
                  leagueData: leagueData,
                ),
                const SliverToBoxAdapter(
                  child: Gap(80),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BetTabsConsumer extends ConsumerWidget {
  const _BetTabsConsumer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasEventData = ref.watch(
      betDetailMobileV2Provider.select((state) => state.eventData != null),
    );

    if (!hasEventData) {
      return const SizedBox.shrink();
    }

    return const _BetTabsWithMarketsV2Consumer();
  }
}

class _BetTabsWithMarketsV2Consumer extends ConsumerWidget {
  const _BetTabsWithMarketsV2Consumer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(
      betDetailMobileV2Provider.select((state) => state.currentFilter),
    );
    final availableTabs = ref.watch(
      betDetailMobileV2Provider.select(
        (state) => state.availableTabsOf(mergeHalves: true),
      ),
    );

    return _BetTabsWithMarketsV2(
      currentFilter: currentFilter,
      availableTabs: availableTabs,
      onFilterChanged: (filter) =>
          _selectBetTab(context, ref, availableTabs, filter),
    );
  }
}

class _BetTabsWithMarketsV2 extends StatelessWidget {
  final MarketFilter currentFilter;
  final void Function(MarketFilter) onFilterChanged;
  final List<BetTabData> availableTabs;

  const _BetTabsWithMarketsV2({
    required this.currentFilter,
    required this.onFilterChanged,
    required this.availableTabs,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      _BetTabsSection(
        availableTabs: availableTabs,
        currentFilter: currentFilter,
        onFilterChanged: onFilterChanged,
      ),
      if (_kShowMarketGroupChipsOnMobile) const _MarketGroupSection(),
      const SizedBox(height: _betTabsBottomGap),
    ],
  );
}

const bool _kShowMarketGroupChipsOnMobile = false;

const double _betTabsBottomGap = 8;

class _BetTabsAlignScope extends InheritedWidget {
  const _BetTabsAlignScope({
    required this.alignUnderPinnedTabs,
    required super.child,
  });

  final VoidCallback alignUnderPinnedTabs;

  static void alignOf(BuildContext context) {
    context
        .getInheritedWidgetOfExactType<_BetTabsAlignScope>()
        ?.alignUnderPinnedTabs();
  }

  @override
  bool updateShouldNotify(_BetTabsAlignScope oldWidget) => false;
}

List<MarketFilter> _watchBetTabFilters(WidgetRef ref) {
  final String signature = ref.watch(
    betDetailMobileV2Provider.select(
      (state) => state
          .availableTabsOf(mergeHalves: true)
          .map((t) => t.filter.name)
          .join(','),
    ),
  );
  if (signature.isEmpty) return const <MarketFilter>[];
  return signature
      .split(',')
      .map((String name) => MarketFilter.values.byName(name))
      .toList();
}

void _selectBetTab(
  BuildContext context,
  WidgetRef ref,
  List<BetTabData> availableTabs,
  MarketFilter filter,
) {
  if (ref.read(betDetailMobileV2Provider).currentFilter == filter) return;
  _BetTabsAlignScope.alignOf(context);
  final TabPagerController? pager = TabPagerScope.readOf(context);
  final int target = availableTabs.indexWhere((t) => t.filter == filter);
  if (pager == null || target < 0 || !pager.slideTo(target)) {
    ref.read(betDetailMobileV2Provider.notifier).changeFilter(filter);
  }
}

class _BetDetailPagerHost extends ConsumerWidget {
  const _BetDetailPagerHost({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<MarketFilter> tabs = _watchBetTabFilters(ref);
    final MarketFilter currentFilter = ref.watch(
      betDetailMobileV2Provider.select((state) => state.currentFilter),
    );
    final int index = tabs.indexOf(currentFilter);

    final bool searching = ref.watch(
      betDetailMobileV2Provider.select((s) => s.marketQuery.trim().isNotEmpty),
    );

    return TabPagerHost(
      enabled: !searching,
      index: index < 0 ? 0 : index,
      count: tabs.length,
      onCommit: (int i) {
        if (i < 0 || i >= tabs.length) return;
        ref.read(betDetailMobileV2Provider.notifier).changeFilter(tabs[i]);
      },
      slideOnExternalChange: false,
      child: child,
    );
  }
}

class _MarketDrawersPager extends ConsumerWidget {
  const _MarketDrawersPager({this.eventData, this.leagueData});

  final LeagueEventData? eventData;
  final LeagueData? leagueData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<MarketFilter> tabs = _watchBetTabFilters(ref);
    final MarketFilter currentFilter = ref.watch(
      betDetailMobileV2Provider.select((state) => state.currentFilter),
    );
    final int active = tabs.indexOf(currentFilter);

    return TabPagerPanel(
      fallbackIndex: active < 0 ? 0 : active,
      panelBuilder: (BuildContext context, int index) {
        final MarketFilter? filter = (index >= 0 && index < tabs.length)
            ? tabs[index]
            : null;
        return _MarketDrawersSliverV2(
          eventData: eventData,
          leagueData: leagueData,
          previewFilter: (filter == null || filter == currentFilter)
              ? null
              : filter,
        );
      },
    );
  }
}

class _MarketDrawersSliverV2 extends ConsumerWidget {
  final LeagueEventData? eventData;
  final LeagueData? leagueData;

  final MarketFilter? previewFilter;

  const _MarketDrawersSliverV2({
    this.eventData,
    this.leagueData,
    this.previewFilter,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasEventData = ref.watch(
      betDetailMobileV2Provider.select((state) => state.eventData != null),
    );
    if (!hasEventData) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final MarketFilter? preview = previewFilter;
    final String query = ref.watch(
      betDetailMobileV2Provider.select((state) => state.marketQuery.trim()),
    );
    final bool searching = query.isNotEmpty;
    final String homeName = eventData?.homeName ?? '';
    final String awayName = eventData?.awayName ?? '';

    final drawers = preview == null
        ? (searching
              ? ref.watch(
                  betDetailMobileV2Provider.select(
                    (state) => state.searchDrawers(homeName, awayName),
                  ),
                )
              : ref.watch(
                  betDetailMobileV2Provider.select(
                    (state) => state.periodDrawersNoGroup,
                  ),
                ))
        : (searching
              ? const <MarketDrawerDataV2>[]
              : ref.watch(
                  betDetailMobileV2Provider.select(
                    (state) => state.periodDrawersFor(preview),
                  ),
                ));
    final oddsStyle = ref.watch(oddsStyleProvider);

    final MarketFilter activeFilter =
        preview ??
        ref.watch(
          betDetailMobileV2Provider.select((state) => state.currentFilter),
        );
    final String? periodPrefix = searching ? null : activeFilter.displayName;

    if (drawers.isEmpty && preview != null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    if (drawers.isEmpty && searching) {
      return SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.all(24),
          alignment: Alignment.center,
          child: Text(
            'Không tìm thấy kèo nào khớp \u201C$query\u201D',
            textAlign: TextAlign.center,
            style: AppTextStyles.textStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0x80FFFCDB),
            ),
          ),
        ),
      );
    }

    if (drawers.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Consumer(
            builder: (context, ref, _) {
              final isBusy = ref.watch(
                betDetailMobileV2Provider.select((s) => s.isEmptyMarketsBusy),
              );
              if (isBusy) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(
                    color: AppColorStyles.contentPrimary,
                  ),
                );
              }
              final emptyText = ref.watch(
                betDetailMobileV2Provider.select((s) => s.emptyMarketsText),
              );
              return Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.center,
                child: Text(
                  emptyText,
                  style: AppTextStyles.textStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0x80FFFCDB),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      sliver: SliverList.builder(
        itemCount: drawers.length,
        addAutomaticKeepAlives: false,
        itemBuilder: (context, index) {
          final drawer = drawers[index];
          return MarketDrawerV2MobileWidget(
            drawer: drawer,
            oddsStyle: oddsStyle,
            periodPrefix: periodPrefix,
            onToggle: preview != null
                ? () {}
                : () => ref
                      .read(betDetailMobileV2Provider.notifier)
                      .toggleDrawer(index),
            eventData: eventData,
            leagueData: leagueData,
          );
        },
      ),
    );
  }
}

final _betMarketSearchOpenProvider = StateProvider.autoDispose<bool>(
  (ref) => false,
);

class _BetTabsSection extends ConsumerStatefulWidget {
  final List<BetTabData> availableTabs;
  final MarketFilter currentFilter;
  final void Function(MarketFilter) onFilterChanged;

  const _BetTabsSection({
    required this.availableTabs,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  ConsumerState<_BetTabsSection> createState() => _BetTabsSectionState();
}

class _BetTabsSectionState extends ConsumerState<_BetTabsSection> {
  static const Duration _kAnim = Duration(milliseconds: 250);

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final Map<MarketFilter, GlobalKey> _tabKeys = <MarketFilter, GlobalKey>{};

  GlobalKey _keyFor(MarketFilter filter) =>
      _tabKeys.putIfAbsent(filter, GlobalKey.new);

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _openSearch() {
    ref.read(_betMarketSearchOpenProvider.notifier).state = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void _closeSearch() {
    _controller.clear();
    _focusNode.unfocus();
    ref.read(_betMarketSearchOpenProvider.notifier).state = false;
    ref.read(betDetailMobileV2Provider.notifier).setMarketQuery('');
  }

  void _onTabTap(MarketFilter filter) {
    widget.onFilterChanged(filter);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final BuildContext? ctx = _keyFor(filter).currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        alignment: 0.5,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool expanded = ref.watch(_betMarketSearchOpenProvider);
    final String query = ref.watch(
      betDetailMobileV2Provider.select((state) => state.marketQuery),
    );
    if (!_focusNode.hasFocus && _controller.text != query) {
      _controller.text = query;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
      width: double.infinity,
      height: 44,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF000000),
            Color(0x00000000),
          ],
          stops: [0.0, 1.0],
        ),
        border: Border(
          bottom: BorderSide(color: Color(0xFF252423), width: 0.5),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double full = constraints.maxWidth;
          final double clusterWidth = (full - 8 - 30).clamp(0.0, full);
          return Row(
            children: [
              const Gap(8),
              _searchBox(expanded, full),
              Expanded(
                child: ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.centerLeft,
                    minWidth: 0,
                    maxWidth: full,
                    child: SizedBox(
                      width: clusterWidth,
                      child: IgnorePointer(
                        ignoring: expanded,
                        child: AnimatedOpacity(
                          duration: _kAnim,
                          opacity: expanded ? 0 : 1,
                          child: Row(
                            children: [
                              const Gap(8),
                              _collapseAllButton(),
                              const Gap(4),
                              Expanded(child: _tabRow()),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _searchBox(bool expanded, double rowWidth) {
    final double width = expanded ? (rowWidth - 8).clamp(30.0, rowWidth) : 30;
    return AnimatedContainer(
      duration: _kAnim,
      curve: Curves.easeOut,
      width: width,
      height: 30,
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundTertiary,
        border: Border.all(color: AppColorStyles.borderSecondary, width: 0.7),
        borderRadius: BorderRadius.circular(expanded ? 8 : 12),
      ),
      clipBehavior: Clip.hardEdge,
      child: expanded
          ? Row(
              children: [
                const Gap(8),
                ImageHelper.load(
                  path: AppIcons.icSearch,
                  width: 18,
                  height: 18,
                ),
                const Gap(8),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    textInputAction: TextInputAction.search,
                    onChanged: (value) => ref
                        .read(betDetailMobileV2Provider.notifier)
                        .setMarketQuery(value),
                    style: AppTextStyles.textStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColorStyles.contentPrimary,
                    ),
                    cursorColor: AppColors.yellow300,
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      hintText: 'Tìm kèo',
                      hintStyle: AppTextStyles.textStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColorStyles.contentTertiary,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: SoundTap.wrap(_closeSearch),
                  behavior: HitTestBehavior.opaque,
                  child: const SizedBox(
                    width: 30,
                    height: 30,
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: Color(0xFFC3C2BC),
                    ),
                  ),
                ),
              ],
            )
          : GestureDetector(
              onTap: SoundTap.wrap(_openSearch),
              behavior: HitTestBehavior.opaque,
              child: Center(
                child: ImageHelper.load(
                  path: AppIcons.icSearch,
                  width: 18,
                  height: 18,
                ),
              ),
            ),
    );
  }

  Widget _collapseAllButton() {
    final bool allExpanded = ref.watch(
      betDetailMobileV2Provider.select((state) => state.allExpanded),
    );
    return GestureDetector(
      onTap: SoundTap.wrap(
        () => ref.read(betDetailMobileV2Provider.notifier).toggleAllExpanded(),
      ),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedRotation(
          duration: const Duration(milliseconds: 200),
          turns: allExpanded ? 0 : 0.5,
          child: ImageHelper.load(
            path: AppIcons.iconCollapse,
            width: 18,
            height: 18,
            color: const Color(0x80FFFCDB),
          ),
        ),
      ),
    );
  }

  Widget _tabRow() {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(
        context,
      ).copyWith(scrollbars: false, dragDevices: _horizontalDragDevices),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: widget.availableTabs.map((tab) {
            final isSelected = widget.currentFilter == tab.filter;
            return Padding(
              key: _keyFor(tab.filter),
              padding: EdgeInsets.zero,
              child: GestureDetector(
                onTap: SoundTap.wrap(() => _onTabTap(tab.filter)),
                child: Stack(
                  children: [
                    if (isSelected)
                      Positioned(
                        bottom: 0,
                        left: -20,
                        right: -20,
                        top: -10,
                        child: ImageHelper.load(
                          path: AppIcons.sportStatusSelected,
                          fit: BoxFit.fill,
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Center(
                        child: Text(
                          tab.label,
                          style: AppTextStyles.textStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? AppColors.yellow300
                                : AppColorStyles.contentTertiary,
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
      ),
    );
  }
}

class _MarketGroupSection extends ConsumerWidget {
  const _MarketGroupSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(betDetailMobileV2Provider.select((s) => s.groupFilterSignature));
    final selectedKey = ref.watch(
      betDetailMobileV2Provider.select((s) => s.marketGroupKey),
    );
    final groups = ref.read(betDetailMobileV2Provider).availableGroups;

    if (groups.length <= 2) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(
          context,
        ).copyWith(scrollbars: false, dragDevices: _horizontalDragDevices),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final g in groups)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _MarketGroupChip(
                    label: g.label,
                    isSelected: selectedKey == g.key,
                    onTap: () {
                      if (selectedKey == g.key) return;
                      _BetTabsAlignScope.alignOf(context);
                      ref
                          .read(betDetailMobileV2Provider.notifier)
                          .changeMarketGroup(g.key);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MarketGroupChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MarketGroupChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: SoundTap.wrap(onTap),
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF252423),
          borderRadius: BorderRadius.circular(1000),
          border: Border.all(
            color: isSelected ? AppColors.yellow300 : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.textStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 20 / 13,
            color: isSelected ? AppColors.yellow300 : AppColorStyles.contentTertiary,
          ),
        ),
      ),
    );
  }
}
