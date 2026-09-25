import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/features/game/game.dart';
import 'package:sun_sports/features/home/presentation/mobile/widgets/home_mobile_ncc_section.dart';
import 'package:sun_sports/features/home/presentation/mobile/widgets/home_provider_filter_bar.dart';
import 'package:sun_sports/features/home/presentation/providers/home_category_provider.dart';
import 'package:sun_sports/shared/widgets/gestures/tab_pager.dart';
import 'package:sun_sports/shared/widgets/tabs/swipe_tab_bar.dart';

const double _kFilterRowGap = 12;

const Duration _kQueryDebounce = Duration(milliseconds: 400);

class HomeCategoryBar extends ConsumerStatefulWidget {
  const HomeCategoryBar({
    required this.onSelect,
    required this.onAlign,
    super.key,
  });

  final ValueChanged<String> onSelect;

  final VoidCallback onAlign;

  @override
  ConsumerState<HomeCategoryBar> createState() => _HomeCategoryBarState();
}

class _HomeCategoryBarState extends ConsumerState<HomeCategoryBar> {
  TabPagerController? _pager;
  Timer? _queryDebounce;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final TabPagerController? pager = TabPagerScope.maybeOf(context);
    if (identical(pager, _pager)) return;
    _detach();
    _pager = pager;
    pager?.offset.addListener(_onPagerOffset);
    pager?.addListener(_onPagerSettle);
  }

  void _detach() {
    _pager?.offset.removeListener(_onPagerOffset);
    _pager?.removeListener(_onPagerSettle);
  }

  @override
  void dispose() {
    _detach();
    _queryDebounce?.cancel();
    super.dispose();
  }

  void _onPagerOffset() {
    final TabPagerController? pager = _pager;
    if (pager == null || !pager.isDragging) return;
    final List<HomeCategoryItem> items = ref.read(homeCategoryItemsProvider);
    if (items.isEmpty) return;
    final int target = pager.position.round().clamp(0, items.length - 1);
    _setPendingRow(items[target].id);
  }

  void _onPagerSettle() {
    final TabPagerController? pager = _pager;
    if (pager == null || pager.isActive) return;
    _writePendingRow(null);
  }

  void _setPendingRow(String id) {
    final String? current = ref.read(homeCategoryPendingRowIdProvider);
    final String shown = current ?? ref.read(homeCategorySelectedIdProvider);
    if (shown == id) return;
    _writePendingRow(id);
  }

  void _writePendingRow(String? id) {
    void apply() {
      if (!mounted) return;
      if (ref.read(homeCategoryPendingRowIdProvider) == id) return;
      ref.read(homeCategoryPendingRowIdProvider.notifier).state = id;
    }

    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) => apply());
      return;
    }
    apply();
  }

  void _onSelect(String id) {
    _setPendingRow(id);
    widget.onSelect(id);
  }

  void _onProvider(String id) {
    if (id == ref.read(homeCategoryProviderIdProvider)) return;
    widget.onAlign();
    ref.read(homeCategoryProviderIdProvider.notifier).state = id;
  }

  void _onQuery(String raw) {
    widget.onAlign();
    if (raw != ref.read(homeCategoryRawQueryProvider)) {
      ref.read(homeCategoryRawQueryProvider.notifier).state = raw;
    }
    _queryDebounce?.cancel();
    if (raw.isEmpty) {
      if (ref.read(homeCategoryQueryProvider).isNotEmpty) {
        ref.read(homeCategoryQueryProvider.notifier).state = '';
      }
      return;
    }
    _queryDebounce = Timer(_kQueryDebounce, () {
      if (!mounted || ref.read(homeCategoryQueryProvider) == raw) return;
      ref.read(homeCategoryQueryProvider.notifier).state = raw;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<HomeCategoryItem> items = ref.watch(homeCategoryItemsProvider);
    final HomeCategoryItem selected = resolveHomeCategory(
      items,
      ref.watch(homeCategorySelectedIdProvider),
    );
    final int selectedIndex = items.indexOf(selected);

    final String rowTabId =
        ref.watch(homeCategoryPendingRowIdProvider) ?? selected.id;
    final List<LobbyCategory> chips = ref.watch(
      homeCategoryProvidersProvider(rowTabId),
    );
    final String providerId = homeEffectiveProviderId(
      chips,
      ref.watch(homeCategoryProviderIdProvider),
    );

    return ColoredBox(
      color: AppColorStyles.backgroundPrimary,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SwipeTabBar(
              items: <SwipeTabItem>[
                for (final HomeCategoryItem item in items)
                  SwipeTabItem(
                    label: item.label,
                    key: item.id,
                    iconBuilder: (bool isSelected) => ImageHelper.load(
                      path: isSelected ? item.iconActive : item.icon,
                      width: GameCategoryButton.compactIconSize,
                      height: GameCategoryButton.compactIconSize,
                    ),
                    markerIconBuilder: item.markerIcon.isEmpty
                        ? null
                        : (bool _) => ImageHelper.load(
                            path: item.markerIcon,
                            width: GameCategoryButton.compactIconSize,
                            height: GameCategoryButton.compactIconSize,
                            fit: BoxFit.contain,
                          ),
                  ),
              ],
              selectedIndex: selectedIndex,
              onSelect: (int i) => _onSelect(items[i].id),
              compact: true,
              tabBar: true,
            ),
            _FilterRowSlot(
              open: rowTabId != kHomeSportTabId,
              child: HomeProviderFilterBar(
                providers: chips,
                providerId: providerId,
                onProvider: _onProvider,
                rawQuery: ref.watch(homeCategoryRawQueryProvider),
                onQuery: _onQuery,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterRowSlot extends StatefulWidget {
  const _FilterRowSlot({required this.open, required this.child});

  final bool open;
  final Widget child;

  @override
  State<_FilterRowSlot> createState() => _FilterRowSlotState();
}

class _FilterRowSlotState extends State<_FilterRowSlot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: kHomeProviderFilterDuration,
    value: widget.open ? 1 : 0,
  );

  @override
  void didUpdateWidget(_FilterRowSlot old) {
    super.didUpdateWidget(old);
    if (widget.open == old.open) return;
    if (widget.open) {
      _anim.forward();
    } else {
      _anim.reverse();
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      child: Padding(
        padding: const EdgeInsets.only(top: _kFilterRowGap),
        child: widget.child,
      ),
      builder: (BuildContext context, Widget? child) {
        final double t = Curves.easeOut.transform(_anim.value);
        if (t == 0) return const SizedBox(width: double.infinity, height: 0);
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: math.max(t, 0.0),
            child: IgnorePointer(
              ignoring: !widget.open,
              child: Opacity(opacity: t, child: child),
            ),
          ),
        );
      },
    );
  }
}

const int kHomeCategoryRows = 2;

class HomeCategoryPanel extends ConsumerWidget {
  const HomeCategoryPanel({required this.index, super.key});

  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<HomeCategoryItem> items = ref.watch(homeCategoryItemsProvider);
    if (index < 0 || index >= items.length) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverToBoxAdapter(
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: _content(context, ref, items[index]),
      ),
    );
  }

  Widget _content(BuildContext context, WidgetRef ref, HomeCategoryItem item) {
    if (item.isSportProviders) {
      return const HomeMobileNccSection();
    }

    final String providerId = homeEffectiveProviderId(
      ref.watch(homeCategoryProvidersProvider(item.id)),
      ref.watch(homeCategoryProviderIdProvider),
    );
    final AsyncValue<List<LobbyGame>> games = ref.watch(
      homeCategoryGamesProvider((
        selection: item.selection,
        providerId: providerId,
        query: ref.watch(homeCategoryQueryProvider).trim(),
      )),
    );

    return games.when(
      data: (List<LobbyGame> list) => list.isEmpty
          ? const GameFilterEmptyState()
          : KeyedSubtree(
              key: ValueKey<String>('home-category-${item.id}'),
              child: GamePaginatedGridView(
                games: list,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemsPerPage:
                    kHomeCategoryRows *
                    GameCardLayout.getColumns(MediaQuery.sizeOf(context).width),
                loadMoreMargin: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                onGameTap: (LobbyGame game) =>
                    ref.read(gameLauncherProvider.notifier).launch(context, game),
              ),
            ),
      loading: () => const GameGridShimmer(rows: kHomeCategoryRows),
      error: (Object _, StackTrace __) => const GameFilterEmptyState(),
    );
  }
}
