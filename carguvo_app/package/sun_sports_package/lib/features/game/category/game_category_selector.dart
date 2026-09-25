// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/features/game/game.dart';
import 'package:sun_sports/shared/widgets/tabs/swipe_tab_bar.dart';

final gameCategorySelectionProvider = StateProvider<GameCategorySelection>(
  (ref) => const GameCategorySelection(),
);

class GameCategorySelector extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  const GameCategorySelector({
    required this.onSelectionChanged,
    this.categoryProvider,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
    this.preferredSize = const Size.fromHeight(62),
    this.compact = false,
    this.tabBar = false,
    this.backgroundColor,
    super.key,
  });

  final ValueChanged<GameCategorySelection> onSelectionChanged;
  final Provider<List<LobbyCategory>>? categoryProvider;
  final EdgeInsetsGeometry padding;

  final bool compact;

  final bool tabBar;

  final Color? backgroundColor;

  @override
  final Size preferredSize;

  @override
  ConsumerState<GameCategorySelector> createState() =>
      _GameCategorySelectorState();
}

class _GameCategorySelectorState extends ConsumerState<GameCategorySelector> {
  bool _iconsPrecached = false;

  Provider<List<LobbyCategory>> get _source =>
      widget.categoryProvider ?? lobbyCategoriesProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_iconsPrecached) {
      _iconsPrecached = true;
      _prefetchCategoryIcons();
    }
  }

  void _prefetchCategoryIcons() {
    final List<LobbyCategory> categories = ref.read(_source);
    for (final LobbyCategory cat in categories) {
      for (final bool active in <bool>[false, true]) {
        final String path = cat.iconPath(active: active);
        if (path.isEmpty) continue;
        if (path.toLowerCase().endsWith('.svg')) {
          ImageHelper.precacheSVG(context, path).ignore();
        } else {
          ImageHelper.precacheNetworkImage(context, path).ignore();
        }
      }
    }
  }

  bool _isSelected(LobbyCategory category, GameCategorySelection selection) {
    if (category.isAll) return selection.isEmpty;
    return selection.category?.id == category.id;
  }

  Widget _buildCategoryIcon(LobbyCategory category, bool isSelected) {
    final String path = category.iconPath(active: isSelected);
    if (path.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      key: ValueKey<String>('category_icon_${category.id}'),
      child: ImageHelper.load(
        path: path,
        width: 24,
        height: 24,
        cacheWidth: 48,
        cacheHeight: 48,
        fit: BoxFit.cover,
      ),
    );
  }

  Size get _preferred => widget.compact
      ? Size.fromHeight(
          (widget.tabBar
                  ? GameCategoryButton.tabBarConstraints
                  : GameCategoryButton.compactConstraints)
              .minHeight,
        )
      : widget.preferredSize;

  @override
  Widget build(BuildContext context) {
    final List<LobbyCategory> categories = ref.watch(_source);
    final GameCategorySelection selection = ref.watch(
      gameCategorySelectionProvider,
    );

    if (categories.isEmpty) {
      return PreferredSize(
        preferredSize: widget.preferredSize,
        child: const Center(child: Text('No categories available')),
      );
    }

    final int selectedIndex = categories.indexWhere(
      (LobbyCategory c) => _isSelected(c, selection),
    );

    return PreferredSize(
      preferredSize: _preferred,
      child: SwipeTabBar(
        items: <SwipeTabItem>[
          for (final LobbyCategory c in categories)
            SwipeTabItem(
              label: c.displayName,
              key: c.id,
              iconBuilder: c.hasIcon
                  ? (bool isSelected) => _buildCategoryIcon(c, isSelected)
                  : null,
            ),
        ],
        selectedIndex: selectedIndex,
        onSelect: (int index) {
          final LobbyCategory category = categories[index];
          final GameCategorySelection next = category.isAll
              ? const GameCategorySelection()
              : GameCategorySelection.fromCategory(category);
          ref.read(gameCategorySelectionProvider.notifier).state = next;
          widget.onSelectionChanged(next);
        },
        padding: widget.padding,
        compact: widget.compact,
        tabBar: widget.tabBar,
        backgroundColor: widget.backgroundColor,
        storageKey: const PageStorageKey<String>(
          'game_category_selector_list_key',
        ),
      ),
    );
  }
}
