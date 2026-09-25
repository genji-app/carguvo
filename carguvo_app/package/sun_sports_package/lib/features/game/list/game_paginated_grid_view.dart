import 'package:flutter/material.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/features/game/game.dart';
import 'package:sun_sports/shared/widgets/buttons/buttons.dart';

class GamePaginatedGridView extends StatefulWidget {
  const GamePaginatedGridView({
    required this.games,
    this.onGameTap,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.crossAxisCount,
    this.itemsPerPage = 15,
    this.loadMoreMargin = const EdgeInsets.all(24),
    super.key,
  }) : _isSliver = false;

  const GamePaginatedGridView.sliver({
    required this.games,
    this.onGameTap,
    this.padding,
    this.crossAxisCount,
    this.itemsPerPage = 15,
    this.loadMoreMargin = const EdgeInsets.all(24),
    super.key,
  }) : _isSliver = true,
       shrinkWrap = false,
       physics = null;

  final List<LobbyGame> games;

  final void Function(LobbyGame gameBlock)? onGameTap;

  final EdgeInsetsGeometry? padding;

  final bool shrinkWrap;

  final ScrollPhysics? physics;

  final int? crossAxisCount;

  final int itemsPerPage;

  final EdgeInsetsGeometry loadMoreMargin;

  final bool _isSliver;

  @override
  State<GamePaginatedGridView> createState() => _GamePaginatedGridViewState();
}

class _GamePaginatedGridViewState extends State<GamePaginatedGridView> {
  late int _displayedItemsCount;

  @override
  void initState() {
    super.initState();
    _displayedItemsCount = widget.itemsPerPage;
  }

  @override
  void didUpdateWidget(covariant GamePaginatedGridView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.games != widget.games) {
      _displayedItemsCount = widget.itemsPerPage;
    }
  }

  void _loadMore() {
    setState(() {
      _displayedItemsCount += widget.itemsPerPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    final paginatedGames = widget.games.length <= _displayedItemsCount
        ? widget.games
        : widget.games.sublist(0, _displayedItemsCount);
    final hasMoreGames = widget.games.length > _displayedItemsCount;

    if (widget._isSliver) {
      return SliverPadding(
        padding: widget.padding ?? EdgeInsets.zero,
        sliver: SliverMainAxisGroup(
          slivers: [
            GameGridView.sliver(
              games: paginatedGames,
              onGameTap: widget.onGameTap,
              crossAxisCount: widget.crossAxisCount,
            ),

            if (hasMoreGames) SliverToBoxAdapter(child: _buildLoadMoreButton()),
          ],
        ),
      );
    }

    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GameGridView(
            games: paginatedGames,
            onGameTap: widget.onGameTap,
            shrinkWrap: widget.shrinkWrap,
            physics: widget.physics,
            crossAxisCount: widget.crossAxisCount,
          ),
          if (hasMoreGames) _buildLoadMoreButton(),
        ],
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Container(
      margin: widget.loadMoreMargin,
      child: Center(
        child: SecondaryButton.gray(
          onPressed: _loadMore,
          size: SecondaryButtonSize.sm,
          label: const Text(I18n.txtShowMore),
        ),
      ),
    );
  }
}
