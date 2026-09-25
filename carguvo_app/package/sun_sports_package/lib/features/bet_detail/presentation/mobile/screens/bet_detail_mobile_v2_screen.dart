import 'dart:math' as math;

import 'package:flutter/rendering.dart' show RenderAbstractViewport, RenderBox, RenderSliver;
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/providers/live_chat_expanded_provider.dart';
import 'package:sun_sports/core/providers/scroll_hide_provider.dart';
import 'package:sun_sports/core/services/models/api_v2/event_model_v2.dart';
import 'package:sun_sports/features/sport/presentation/providers/events_v2_filter_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/league_provider.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/bet_detail/domain/enums/market_filter.dart';
import 'package:sun_sports/shared/widgets/gestures/tab_pager.dart';
import 'package:sun_sports/features/bet_detail/domain/models/market_drawer_data_v2.dart';
import 'package:sun_sports/features/bet_detail/presentation/providers/bet_detail_mobile_v2_provider.dart';
import 'package:sun_sports/features/bet_detail/presentation/providers/bet_detail_v2_provider.dart';
import 'package:sun_sports/core/services/models/api_v2/v2_to_legacy_adapter.dart';
import 'package:sun_sports/features/bet_detail/presentation/mobile/widgets/market_drawer_v2_mobile_widget.dart';
import 'package:sun_sports/features/bet_detail/presentation/mobile/widgets/match_header_mobile_widget.dart';
import 'package:sun_sports/features/bet_detail/presentation/mobile/widgets/mobile_statistics_table_widget.dart';
import 'package:sun_sports/shared/layouts/shell_top_block.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/shared/widgets/livestream/livestream_lifecycle.dart';
import 'package:sun_sports/shared/widgets/livestream/pip_manager.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/features/bet_detail/presentation/providers/detail_swap_guard_provider.dart';
import 'package:sun_sports/shared/widgets/sport/match/match_row_shared_v2.dart'
    show extractCurrentSet;

class _StickyTop extends StatelessWidget {
  const _StickyTop({
    required this.progress,
    required this.topFor,
    required this.child,
  });

  final ValueNotifier<double> progress;
  final double Function(double progress) topFor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: progress,
      child: child,
      builder: (context, value, child) => Positioned(
        top: topFor(value),
        left: 0,
        right: 0,
        child: child!,
      ),
    );
  }
}

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
  
  static const double _statisticsTableApproxHeight = 140.0;

  static const double _statisticsStickyThreshold = 20.0;

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _statisticsTableKey = GlobalKey();
  final GlobalKey _betTabsKey = GlobalKey();
  final GlobalKey _livestreamKey = GlobalKey();

  final GlobalKey _marketDrawersKey = GlobalKey();
  final GlobalKey _stickyBetTabsKey = GlobalKey();
  final GlobalKey<State<MatchHeaderMobileWidget>> _matchHeaderKey =
      GlobalKey<State<MatchHeaderMobileWidget>>();
  bool _isStatisticsSticky = false;
  bool _isBetTabsSticky = false;
  MatchTab? _currentTab;
  double _lastScrollPosition = 0.0;

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
        final liveChatHeight = ref.read(liveChatExpandedProvider)
            ? ShellTopMetrics.chatExpanded
            : ShellTopMetrics.chatCollapsed;
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

    final pipManager = PipManager();
    if (_currentTab == MatchTab.live && !pipManager.isPiPMode) {
      pipManager.dispose().catchError((Object e) {
        debugPrint('Error disposing PipManager when back from bet_detail: $e');
      });
    } else {
    }

    _scrollHide.progress.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!mounted || !_scrollController.hasClients) return;
    _handleScrollAutoPiP();

    final topPadding = MediaQuery.of(context).padding.top;
    final hasChat = ref.read(shellHasChatProvider);
    final liveChatHeight = ref.read(liveChatExpandedProvider)
        ? ShellTopMetrics.chatExpanded
        : ShellTopMetrics.chatCollapsed;
    final liveChatTop = ShellTopMetrics.blockBottom(
      topPadding: topPadding,
      hasChat: hasChat,
      chatHeight: liveChatHeight,
      hideProgress: _scrollHide.progress.value,
    );

    livestreamClipTopNotifier.value = liveChatTop;

    _updateStatisticsSticky(liveChatTop);
    _updateBetTabsSticky(liveChatTop);
  }

  void _updateStatisticsSticky(double liveChatTop) {
    final statsContext = _statisticsTableKey.currentContext;
    if (statsContext == null) {
      if (_isStatisticsSticky) {
        setState(() => _isStatisticsSticky = false);
      }
      return;
    }

    final box = statsContext.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final offsetY = box.localToGlobal(Offset.zero).dy;
    final shouldSticky = offsetY < liveChatTop - _statisticsStickyThreshold;
    if (shouldSticky != _isStatisticsSticky) {
      setState(() => _isStatisticsSticky = shouldSticky);
    }
  }

  void _updateBetTabsSticky(double liveChatTop) {
    final tabsContext = _betTabsKey.currentContext;
    if (tabsContext == null) return;

    final tabsBox = tabsContext.findRenderObject() as RenderBox?;
    if (tabsBox == null || !tabsBox.hasSize) return;

    final tabsOffsetY = tabsBox.localToGlobal(Offset.zero).dy;
    final tabsStickyTop = _isStatisticsSticky
        ? liveChatTop + _statisticsTableApproxHeight
        : liveChatTop;
    final shouldSticky = tabsOffsetY <= tabsStickyTop;

    if (shouldSticky != _isBetTabsSticky) {
      setState(() => _isBetTabsSticky = shouldSticky);
    }
  }

  double _betTabsStickyTopFor(double progress) {
    final liveChatTop = ShellTopMetrics.blockBottom(
      topPadding: MediaQuery.of(context).padding.top,
      hasChat: ref.read(shellHasChatProvider),
      chatHeight: ref.read(liveChatExpandedProvider)
          ? ShellTopMetrics.chatExpanded
          : ShellTopMetrics.chatCollapsed,
      hideProgress: progress,
    );
    return _isStatisticsSticky
        ? liveChatTop + _statisticsTableApproxHeight
        : liveChatTop;
  }

  void _alignUnderStickyBetTabs() {
    if (!_isBetTabsSticky || _scrollController.positions.length != 1) return;
    final drawers = _marketDrawersKey.currentContext?.findRenderObject();
    final copy = _stickyBetTabsKey.currentContext?.findRenderObject();
    if (drawers is! RenderSliver || drawers.geometry == null) return;
    if (copy is! RenderBox || !copy.hasSize) return;
    final RenderAbstractViewport? viewport = RenderAbstractViewport.maybeOf(
      drawers,
    );
    if (viewport == null) return;

    final double drawersStart = viewport.getOffsetToReveal(drawers, 0.0).offset;
    final double blockEnd = drawersStart - _betTabsBottomGap;
    final double copyHeight = copy.size.height;
    final ScrollPosition position = _scrollController.position;

    final double targetShown =
        blockEnd - (_betTabsStickyTopFor(0.0) + copyHeight);
    if (targetShown < ScrollHideNotifier.headerHeight + 2) {
      _scrollHide.show();
      _scrollController.jumpTo(
        math.max(position.minScrollExtent, targetShown),
      );
      return;
    }
    _scrollHide.pauseDetection();
    _scrollController.jumpTo(
      math.max(
        position.minScrollExtent,
        blockEnd -
            (_betTabsStickyTopFor(_scrollHide.progress.value) + copyHeight),
      ),
    );
  }

  void _handleFullscreenRequest() {
    final pipEventId = PipManager().currentEventId;
    final currentEventId = ref.read(selectedEventV2Provider)?.eventId;
    if (pipEventId != null &&
        currentEventId != null &&
        pipEventId != currentEventId) {
      PipManager().closePiP(userInitiated: true);
      return;
    }

    PipManager().returnToContainer();
    if (_isStatisticsSticky || _isBetTabsSticky) {
      setState(() {
        _isStatisticsSticky = false;
        _isBetTabsSticky = false;
      });
    }
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

  void _handleScrollAutoPiP() {
    if (_currentTab != MatchTab.live) return;

    final livestreamContext = _livestreamKey.currentContext;
    if (livestreamContext == null) return;
    final livestreamBox = livestreamContext.findRenderObject() as RenderBox?;
    if (livestreamBox == null || !livestreamBox.hasSize) return;

    final livestreamOffsetY = livestreamBox.localToGlobal(Offset.zero).dy;
    final livestreamHeight = livestreamBox.size.height;
    final topPadding = MediaQuery.of(context).padding.top;
    final hasChat = ref.read(shellHasChatProvider);
    final isExpanded = ref.read(liveChatExpandedProvider);
    final liveChatHeight = isExpanded ? ShellTopMetrics.chatExpanded : ShellTopMetrics.chatCollapsed;
    final screenTop = ShellTopMetrics.blockBottom(
      topPadding: topPadding,
      hasChat: hasChat,
      chatHeight: liveChatHeight,
      hideProgress: _scrollHide.progress.value,
    );

    double scrollPercentage = 0.0;
    if (livestreamOffsetY < screenTop) {
      final scrolledAmount = screenTop - livestreamOffsetY;
      scrollPercentage = (scrolledAmount / livestreamHeight).clamp(0.0, 1.0);
    }

    final currentScrollPosition = _scrollController.offset;
    final scrollingDown = currentScrollPosition > _lastScrollPosition;
    _lastScrollPosition = currentScrollPosition;

    if (!scrollingDown ||
        scrollPercentage < 0.6 ||
        !PipManager().hasContent ||
        PipManager().userClosed) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      if (!PipManager().isPiPMode) PipManager().showPiP();
      PipManager().liftToOverlay(context);
      final matchHeaderState = _matchHeaderKey.currentState;
      if (matchHeaderState != null) {
        (matchHeaderState as MatchHeaderTabController).setTab(
          MatchTab.scoreboard,
        );
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
      final liveChatHeight = next ? ShellTopMetrics.chatExpanded : ShellTopMetrics.chatCollapsed;
      livestreamClipTopNotifier.value = ShellTopMetrics.blockBottom(
        topPadding: topPadding,
        hasChat: hasChat,
        chatHeight: liveChatHeight,
        hideProgress: _scrollHide.progress.value,
      );
    });

    return Scaffold(
      backgroundColor: AppColorStyles.backgroundPrimary,
      body: Consumer(
        builder: (context, ref, child) {
          final hasChat = ref.watch(shellHasChatProvider);
          final isExpanded = ref.watch(liveChatExpandedProvider);
          final liveChatHeight = isExpanded
              ? ShellTopMetrics.chatExpanded
              : ShellTopMetrics.chatCollapsed;

          return _buildBody(
            context,
            ref,
            topPadding,
            hasChat,
            liveChatHeight,
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    double topPadding,
    bool hasChat,
    double liveChatHeight,
  ) {
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
      return _buildLoadingState(
        context,
        topPadding,
        hasChat,
        liveChatHeight,
      );
    }

    return _buildContentState(
      context,
      ref,
      topPadding,
      hasChat,
      liveChatHeight,
      finalEventData,
      finalLeagueData,
    );
  }

  Widget _buildLoadingState(
    BuildContext context,
    double topPadding,
    bool hasChat,
    double liveChatHeight,
  ) {
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
    double topPadding,
    bool hasChat,
    double liveChatHeight,
    LeagueEventData eventData,
    LeagueData? leagueData,
  ) {
    return _BetDetailPagerHost(
      child: _BetTabsStickyScope(
      alignUnderStickyTabs: _alignUnderStickyBetTabs,
      child: Stack(
      children: [
        ScrollConfiguration(
          behavior: ScrollConfiguration.of(
            context,
          ).copyWith(scrollbars: false, overscroll: false),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              const ShellContentTopSpacer(),
              const SliverToBoxAdapter(child: Gap(12)),
              SliverList.list(
                children: [
                  const Gap(12),
                  MatchHeaderMobileWidget(
                    key: _matchHeaderKey,
                    eventData: eventData,
                    leagueData: leagueData,
                    sportId:
                        ref.read(selectedLeagueV2Provider)?.sportId ??
                        ref.read(selectedSportV2Provider).id,
                    statisticsTableKey: _statisticsTableKey,
                    hideStatisticsTableOpacity: _isStatisticsSticky,
                    livestreamKey: _livestreamKey,
                    onTabChanged: (tab) {
                      setState(() {
                        _currentTab = tab;
                        if (tab != MatchTab.scoreboard &&
                            tab != MatchTab.statistics) {
                          _isStatisticsSticky = false;
                          _isBetTabsSticky = false;
                        }
                      });
                      if (tab == MatchTab.live) {
                        PipManager().returnToContainer();
                      }
                      if (tab == MatchTab.scoreboard ||
                          tab == MatchTab.statistics) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) _handleScroll();
                        });
                      }
                    },
                  ),
                  _BetTabsConsumer(
                    betTabsKey: _betTabsKey,
                    hideBetTabsOpacity: _isBetTabsSticky,
                  ),
                ],
              ),
              _MarketDrawersPager(
                key: _marketDrawersKey,
                eventData: eventData,
                leagueData: leagueData,
              ),
              const SliverToBoxAdapter(
                child: Gap(80),
              ),
            ],
          ),
        ),
        _buildStickyStatisticsTable(
          topPadding,
          hasChat,
          liveChatHeight,
          eventData,
        ),
        _buildStickyBetTabs(ref, topPadding, hasChat, liveChatHeight),
      ],
      ),
      ),
    );
  }

  Widget _buildStickyStatisticsTable(
    double topPadding,
    bool hasChat,
    double liveChatHeight,
    LeagueEventData eventData,
  ) {
    return _StickyTop(
      progress: _scrollHide.progress,
      topFor: (progress) => ShellTopMetrics.blockBottom(
        topPadding: topPadding,
        hasChat: hasChat,
        chatHeight: liveChatHeight,
        hideProgress: progress,
      ),
      child: Offstage(
        offstage: !_isStatisticsSticky,
        child: Material(
          color: AppColorStyles.backgroundSecondary,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: MobileStatisticsTableWidget(
                eventData: eventData,
                hideBottomBorderRadius: true,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStickyBetTabs(
    WidgetRef ref,
    double topPadding,
    bool hasChat,
    double liveChatHeight,
  ) {
    return _StickyTop(
      progress: _scrollHide.progress,
      topFor: (progress) {
        final liveChatTop = ShellTopMetrics.blockBottom(
          topPadding: topPadding,
          hasChat: hasChat,
          chatHeight: liveChatHeight,
          hideProgress: progress,
        );
        return _isStatisticsSticky
            ? liveChatTop + _statisticsTableApproxHeight
            : liveChatTop;
      },
      child: Offstage(
        offstage: !_isBetTabsSticky,
        child: Material(
          key: _stickyBetTabsKey,
          color: const Color(0xFF1B1A19),
          child: Consumer(
            builder: (context, ref, child) {
              final availableTabs = ref.watch(
                betDetailMobileV2Provider.select(
                  (state) => state.availableTabs,
                ),
              );
              final currentFilter = ref.watch(
                betDetailMobileV2Provider.select(
                  (state) => state.currentFilter,
                ),
              );

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BetTabsSection(
                    availableTabs: availableTabs,
                    currentFilter: currentFilter,
                    onFilterChanged: (filter) =>
                        _selectBetTab(context, ref, availableTabs, filter),
                  ),
                  const _MarketGroupSection(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BetTabsConsumer extends ConsumerWidget {
  final GlobalKey? betTabsKey;
  final bool hideBetTabsOpacity;

  const _BetTabsConsumer({
    required this.hideBetTabsOpacity,
    this.betTabsKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasEventData = ref.watch(
      betDetailMobileV2Provider.select((state) => state.eventData != null),
    );

    if (!hasEventData) {
      return const SizedBox.shrink();
    }

    return _BetTabsWithMarketsV2Consumer(
      betTabsKey: betTabsKey,
      hideBetTabsOpacity: hideBetTabsOpacity,
    );
  }
}

class _BetTabsWithMarketsV2Consumer extends ConsumerWidget {
  final GlobalKey? betTabsKey;
  final bool hideBetTabsOpacity;

  const _BetTabsWithMarketsV2Consumer({
    required this.hideBetTabsOpacity,
    this.betTabsKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(
      betDetailMobileV2Provider.select((state) => state.currentFilter),
    );
    final availableTabs = ref.watch(
      betDetailMobileV2Provider.select((state) => state.availableTabs),
    );

    return _BetTabsWithMarketsV2(
      currentFilter: currentFilter,
      availableTabs: availableTabs,
      onFilterChanged: (filter) =>
          _selectBetTab(context, ref, availableTabs, filter),
      betTabsKey: betTabsKey,
      hideBetTabsOpacity: hideBetTabsOpacity,
    );
  }
}

class _BetTabsWithMarketsV2 extends StatelessWidget {
  final MarketFilter currentFilter;
  final void Function(MarketFilter) onFilterChanged;
  final List<BetTabData> availableTabs;
  final GlobalKey? betTabsKey;
  final bool
  hideBetTabsOpacity;

  const _BetTabsWithMarketsV2({
    required this.currentFilter,
    required this.onFilterChanged,
    required this.availableTabs,
    this.betTabsKey,
    this.hideBetTabsOpacity = false,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      IgnorePointer(
        ignoring: hideBetTabsOpacity,
        child: Opacity(
          opacity: hideBetTabsOpacity ? 0 : 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BetTabsSection(
                key: betTabsKey,
                availableTabs: availableTabs,
                currentFilter: currentFilter,
                onFilterChanged: onFilterChanged,
              ),
              const _MarketGroupSection(),
            ],
          ),
        ),
      ),
      const SizedBox(height: _betTabsBottomGap),
    ],
  );
}

const double _betTabsBottomGap = 8;

class _BetTabsStickyScope extends InheritedWidget {
  const _BetTabsStickyScope({
    required this.alignUnderStickyTabs,
    required super.child,
  });

  final VoidCallback alignUnderStickyTabs;

  static void alignOf(BuildContext context) {
    context
        .getInheritedWidgetOfExactType<_BetTabsStickyScope>()
        ?.alignUnderStickyTabs();
  }

  @override
  bool updateShouldNotify(_BetTabsStickyScope oldWidget) => false;
}

List<MarketFilter> _watchBetTabFilters(WidgetRef ref) {
  final String signature = ref.watch(
    betDetailMobileV2Provider.select(
      (state) => state.availableTabs.map((t) => t.filter.name).join(','),
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
  _BetTabsStickyScope.alignOf(context);
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

    return TabPagerHost(
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
  const _MarketDrawersPager({super.key, this.eventData, this.leagueData});

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
    final drawers = preview == null
        ? ref.watch(
            betDetailMobileV2Provider.select((state) => state.filteredDrawers),
          )
        : ref.watch(
            betDetailMobileV2Provider.select(
              (state) => state.periodDrawersFor(preview),
            ),
          );
    final oddsStyle = ref.watch(oddsStyleProvider);

    if (drawers.isEmpty && preview != null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
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

class _BetTabsSection extends StatelessWidget {
  final List<BetTabData> availableTabs;
  final MarketFilter currentFilter;
  final void Function(MarketFilter) onFilterChanged;

  const _BetTabsSection({
    super.key,
    required this.availableTabs,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
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
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(
          context,
        ).copyWith(scrollbars: false, dragDevices: _horizontalDragDevices),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: availableTabs.map((tab) {
              final isSelected = currentFilter == tab.filter;
              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: GestureDetector(
                  onTap: SoundTap.wrap(() => onFilterChanged(tab.filter)),
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
                          horizontal: 24,
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
                      _BetTabsStickyScope.alignOf(context);
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
