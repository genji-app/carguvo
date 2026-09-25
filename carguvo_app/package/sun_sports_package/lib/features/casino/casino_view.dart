import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/providers/live_chat_expanded_provider.dart';
import 'package:sun_sports/core/providers/scroll_controller_provider.dart';
import 'package:sun_sports/core/providers/scroll_hide_provider.dart';
import 'package:sun_sports/features/game/game.dart';
import 'package:sun_sports/providers/auth_provider.dart';
import 'package:sun_sports/providers/main_content_provider.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:sun_sports/shared/layouts/shell_top_block.dart';
import 'package:sun_sports/shared/layouts/shell_top_overlap_sliver.dart';
import 'package:sun_sports/shared/widgets/gestures/tab_pager.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

import 'casino_banners.dart';

class CasinoView extends ConsumerStatefulWidget {
  const CasinoView({
    required this.showLiveChat,
    required this.isMobile,
    required this.hasOverlayHeader,
    super.key,
    this.backgroundColor,
    this.padding,
  });

  final bool showLiveChat;
  final bool isMobile;

  final bool hasOverlayHeader;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;

  @override
  ConsumerState<CasinoView> createState() => _CasinoViewState();
}

class _CasinoViewState extends ConsumerState<CasinoView> {
  final _filterKey = GlobalKey();

  int _categoryCount(List<LobbyCategory> categories) => categories.length;

  int _categoryIndex(
    List<LobbyCategory> categories,
    GameCategorySelection selection,
  ) => categories.indexOfSelection(selection);

  Widget _wrapWithPager(BuildContext context, Widget child) {
    final List<LobbyCategory> categories = ref.watch(lobbyCategoriesProvider);
    final GameCategorySelection selection = ref.watch(
      gameCategorySelectionProvider,
    );

    return TabPagerHost(
      index: _categoryIndex(categories, selection),
      count: _categoryCount(categories),
      onCommit: _commitCategory,
      enabled: !ResponsiveBuilder.isDesktop(context),
      child: child,
    );
  }

  void _commitCategory(int index) {
    final List<LobbyCategory> categories = ref.read(lobbyCategoriesProvider);
    if (index < 0 || index >= categories.length) return;

    final GameCategorySelection next = categories.selectionAt(index);
    if (ref.read(gameCategorySelectionProvider) == next) return;

    ref.read(gameCategorySelectionProvider.notifier).state = next;
    ref.read(gameFilterProvider.notifier).setCategorySelection(next);
  }

  ({double anchor, ScrollPosition position})? _filterAnchor() {
    final BuildContext? ctx = _filterKey.currentContext;
    final RenderObject? render = ctx?.findRenderObject();
    if (ctx == null || render is! RenderBox || !render.attached) return null;
    final RenderAbstractViewport? viewport = RenderAbstractViewport.maybeOf(
      render,
    );
    if (viewport == null) return null;
    return (
      anchor: viewport.getOffsetToReveal(render, 0.0).offset,
      position: Scrollable.of(ctx).position,
    );
  }

  double _pinBottom(double hideProgress) => ShellTopMetrics.blockBottom(
    topPadding: 0,
    hasChat: ref.read(shellHasChatProvider),
    chatHeight:
        ref.read(isAuthenticatedProvider) && ref.read(liveChatExpandedProvider)
        ? ShellTopMetrics.chatExpanded
        : ShellTopMetrics.chatCollapsed,
    hideProgress: hideProgress,
  );

  void _scrollToPinnedFilter() {
    final target = _filterAnchor();
    if (target == null) return;
    final ScrollPosition position = target.position;
    final double offset = (target.anchor - _pinBottom(1.0)).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    ref.read(scrollHideProvider).hide();
    position.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _alignContentUnderPinnedFilter() {
    final target = _filterAnchor();
    if (target == null) return;
    final ScrollPosition position = target.position;
    final double stuckAt =
        target.anchor - _pinBottom(ref.read(scrollHideProvider).progress.value);
    if (position.pixels <= stuckAt + 0.5) return;
    ref.read(scrollHideProvider).pauseDetection(
      const Duration(milliseconds: 400),
    );
    position.jumpTo(math.max(position.minScrollExtent, stuckAt));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hasOverlayHeader) {
      ref.listen<GameCategorySelection>(
        gameCategorySelectionProvider,
        (prev, next) {
          if (prev != next) _alignContentUnderPinnedFilter();
        },
      );
      ref.listen<String>(
        gameFilterProvider.select((GameFilterState s) => s.searchQuery),
        (prev, next) {
          if (prev != next) _alignContentUnderPinnedFilter();
        },
      );
    }

    final scrollController = ref.watch(mainScrollControllerProvider);
    final isExpanded = ref.watch(liveChatExpandedProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    final canShowChat = widget.showLiveChat && isAuthenticated;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: SoundTap.wrap(() {
        if (isExpanded) {
          FocusScope.of(context).unfocus();
          ref.read(liveChatExpandedProvider.notifier).state = false;
        }
      }),
      child: Container(
        color: widget.backgroundColor,
        padding: widget.padding,
        child: _wrapWithPager(
          context,
          GameFilterView(
            controller: widget.isMobile ? scrollController : null,
            filterKey: _filterKey,
            pinFilterBar: widget.hasOverlayHeader,
            pinnedBackgroundColor: widget.backgroundColor,
            headerSlivers: [
              if (widget.hasOverlayHeader) const ShellTopOverlapSliver(),

              SliverToBoxAdapter(
                child: RepaintBoundary(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Gap(canShowChat ? 12 : 6),
                      CasinoBanners(
                        onSun88Pressed: () {
                          ref.read(mainContentProvider.notifier).goToSport();
                        },
                        onCasinoGamePressed: () {
                          if (widget.hasOverlayHeader) {
                            _scrollToPinnedFilter();
                            return;
                          }
                          final filterContext = _filterKey.currentContext;
                          if (filterContext != null) {
                            Scrollable.ensureVisible(
                              filterContext,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                      ),
                      Gap(widget.hasOverlayHeader ? 12 : 20),
                    ],
                  ),
                ),
              ),
            ],
            footerSlivers: [
              SliverToBoxAdapter(child: Gap(widget.isMobile ? 80 : 96)),
            ],
          ),
        ),
      ),
    );
  }
}
