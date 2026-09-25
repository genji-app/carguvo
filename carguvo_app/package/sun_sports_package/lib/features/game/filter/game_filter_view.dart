import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/border_radius_styles.dart';
import 'package:sun_sports/core/utils/styles/spacing_styles.dart';
import 'package:sun_sports/features/game/game.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:sun_sports/shared/widgets/gestures/tab_pager.dart';
import 'package:sun_sports/shared/widgets/scroll_aware_scroll_reporter.dart';
import 'package:sun_sports/shared/widgets/slivers/slivers.dart';

class GameFilterView extends ConsumerStatefulWidget {
  const GameFilterView({
    super.key,
    this.controller,
    this.headerSlivers,
    this.footerSlivers,
    this.filterKey,
    this.shrinkWrap = false,
    this.physics,
    this.pinFilterBar = false,
    this.pinnedBackgroundColor,
  });

  final ScrollController? controller;

  final List<Widget>? headerSlivers;

  final List<Widget>? footerSlivers;

  final Key? filterKey;

  final bool shrinkWrap;

  final ScrollPhysics? physics;

  final bool pinFilterBar;

  final Color? pinnedBackgroundColor;

  @override
  ConsumerState<GameFilterView> createState() => _GameFilterViewState();
}

class _GameFilterViewState extends ConsumerState<GameFilterView> {
  void _handleGamePress(LobbyGame game) {
    ref.read(gameLauncherProvider.notifier).launch(context, game);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(gameFilterProvider);

    final isMobile = ResponsiveBuilder.isMobile(context);
    final horizontalPadding = !isMobile
        ? EdgeInsets.zero
        : const EdgeInsets.symmetric(horizontal: AppSpacingStyles.space300);

    final bool compact = !ResponsiveBuilder.isDesktop(context);
    final GameFilterNotifier filter = ref.read(gameFilterProvider.notifier);

    return Material(
      color: Colors.transparent,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppBorderRadiusStyles.borderRadius400,
          ),
          child: ScrollAwareScrollReporter(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GameLayoutScope(
                  availableWidth: constraints.maxWidth,
                  child: CustomScrollView(
                    controller: widget.controller,
                    shrinkWrap: widget.shrinkWrap,
                    physics: widget.physics,
                    slivers: [
                      if (widget.headerSlivers != null)
                        ...widget.headerSlivers!,

                      if (widget.pinFilterBar) ...[
                        SliverToBoxAdapter(
                          child: SizedBox.shrink(key: widget.filterKey),
                        ),

                        PinnedHeaderSliver(
                          child: ColoredBox(
                            color:
                                widget.pinnedBackgroundColor ??
                                AppColorStyles.backgroundPrimary,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacingStyles.space200,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: horizontalPadding,
                                    child: GameFilterInput(
                                      dense: compact,
                                      onChanged: filter.setSearchQuery,
                                    ),
                                  ),
                                  const Gap(AppSpacingStyles.space300),
                                  GameCategorySelector(
                                    padding: horizontalPadding,
                                    compact: compact,
                                    tabBar: true,
                                    onSelectionChanged:
                                        filter.setCategorySelection,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SliverToBoxAdapter(
                          child: Gap(AppSpacingStyles.space200),
                        ),
                      ] else ...[
                        SliverPadding(
                          padding: horizontalPadding,
                          sliver: SliverToBoxAdapter(
                            child: GameFilterInput(
                              key: widget.filterKey,
                              dense: compact,
                              onChanged: filter.setSearchQuery,
                            ),
                          ),
                        ),

                        const SliverToBoxAdapter(
                          child: Gap(AppSpacingStyles.space400),
                        ),

                        SliverToBoxAdapter(
                          child: GameCategorySelector(
                            padding: horizontalPadding,
                            compact: compact,
                            tabBar: true,
                            onSelectionChanged: filter.setCategorySelection,
                          ),
                        ),

                        const SliverToBoxAdapter(
                          child: Gap(AppSpacingStyles.space400),
                        ),
                      ],

                      _GameContentArea(onGamePressed: _handleGamePress),

                      if (widget.footerSlivers != null)
                        ...widget.footerSlivers!,
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _GameContentArea extends ConsumerWidget {
  const _GameContentArea({required this.onGamePressed});

  final void Function(LobbyGame game) onGamePressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TabPagerController? pager = TabPagerScope.maybeOf(context);
    if (pager != null) {
      return TabPagerPanel(
        fallbackIndex: pager.index,
        panelBuilder: (BuildContext context, int index) =>
            _GameCategoryPanel(index: index, onGamePressed: onGamePressed),
      );
    }

    final filterState = ref.watch(gameFilterProvider);

    final Widget content = switch (filterState.viewMode) {
      GameViewMode.lobby => GameLobbyView.sliver(onGamePressed: onGamePressed),
      GameViewMode.filter => _GameFilterResult(
        filterState: filterState,
        onGamePressed: onGamePressed,
      ),
    };

    return SliverFadeInSwap(
      token: filterState.categorySelection,
      sliver: content,
    );
  }
}

class _GameCategoryPanel extends ConsumerWidget {
  const _GameCategoryPanel({required this.index, required this.onGamePressed});

  final int index;
  final void Function(LobbyGame game) onGamePressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<LobbyCategory> categories = ref.watch(lobbyCategoriesProvider);
    final String query = ref.watch(
      gameFilterProvider.select((GameFilterState s) => s.searchQuery),
    );

    final GameCategorySelection selection = categories.selectionAt(index);

    if (selection.isEmpty && query.isEmpty) {
      return GameLobbyView.sliver(onGamePressed: onGamePressed);
    }

    final AsyncValue<List<LobbyGame>> games = ref.watch(
      gameCategoryPreviewProvider((query: query, selection: selection)),
    );

    return games.when(
      data: (List<LobbyGame> list) => list.isEmpty
          ? const SliverToBoxAdapter(child: GameFilterEmptyState())
          : GamePaginatedGridView.sliver(games: list, onGameTap: onGamePressed),
      loading: () => const SliverToBoxAdapter(
        child: RepaintBoundary(child: GameGridShimmer()),
      ),
      error: (Object _, StackTrace __) =>
          const SliverToBoxAdapter(child: GameFilterEmptyState()),
    );
  }
}

class _GameFilterResult extends ConsumerWidget {
  const _GameFilterResult({
    required this.filterState,
    required this.onGamePressed,
  });

  final GameFilterState filterState;
  final void Function(LobbyGame) onGamePressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (filterState.status.isLoading) {
      return const SliverToBoxAdapter(
        child: RepaintBoundary(
          child: GameGridShimmer(),
        ),
      );
    }

    if (filterState.results.isEmpty) {
      return const SliverToBoxAdapter(
        child: GameFilterEmptyState(),
      );
    }

    return GamePaginatedGridView.sliver(
      games: filterState.results,
      onGameTap: onGamePressed,
    );
  }
}
