import 'package:flutter/material.dart';
import 'package:sun_sports/features/game/game.dart';

class GameGridView extends StatelessWidget {
  const GameGridView({
    required this.games,
    this.onGameTap,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.crossAxisCount,
    super.key,
  }) : _isSliver = false;

  const GameGridView.sliver({
    required this.games,
    this.onGameTap,
    this.padding,
    this.crossAxisCount,
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

  final bool _isSliver;

  @override
  Widget build(BuildContext context) {
    if (_isSliver) {
      return _GameSliverGrid(
        games: games,
        onGameTap: onGameTap,
        crossAxisCount: crossAxisCount,
        padding: padding,
      );
    }

    return _GameGrid(
      games: games,
      onGameTap: onGameTap,
      shrinkWrap: shrinkWrap,
      physics: physics,
      crossAxisCount: crossAxisCount,
      padding: padding,
    );
  }
}

class _GameGrid extends StatelessWidget {
  const _GameGrid({
    required this.games,
    this.onGameTap,
    this.shrinkWrap = false,
    this.physics,
    this.crossAxisCount,
    this.padding,
  });

  final List<LobbyGame> games;
  final void Function(LobbyGame game)? onGameTap;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final int? crossAxisCount;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final scopedWidth = GameLayoutScope.maybeOf(context);
    if (scopedWidth != null) {
      return _buildContent(context, scopedWidth);
    }

    return LayoutBuilder(
      builder: (context, constraints) =>
          _buildContent(context, constraints.maxWidth),
    );
  }

  Widget _buildContent(BuildContext context, double availableWidth) {
    final dims = GameCardLayout.calculateDimensions(
      availableWidth,
      crossAxisCount: crossAxisCount,
    );

    return Padding(
      padding:
          padding ??
          const EdgeInsets.symmetric(
            horizontal: GameCardLayout.horizontalPadding,
          ),
      child: GridView.builder(
        shrinkWrap: shrinkWrap,
        physics: physics,
        addAutomaticKeepAlives: false,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: dims.columns,
          childAspectRatio: GameCardLayout.cardAspectRatio,
          mainAxisSpacing: GameCardLayout.spacing,
          crossAxisSpacing: GameCardLayout.spacing,
        ),
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          return GameCard(
            key: game.buildWidgetKey('GameGrid'),
            gameBlock: game,
            cardWidth: dims.cardWidth,
            onPressed: onGameTap != null ? () => onGameTap!(game) : null,
          );
        },
      ),
    );
  }
}

class _GameSliverGrid extends StatelessWidget {
  const _GameSliverGrid({
    required this.games,
    this.onGameTap,
    this.crossAxisCount,
    this.padding,
  });

  final List<LobbyGame> games;
  final void Function(LobbyGame game)? onGameTap;
  final int? crossAxisCount;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final availableWidth =
        GameLayoutScope.maybeOf(context) ?? MediaQuery.sizeOf(context).width;

    final dims = GameCardLayout.calculateDimensions(
      availableWidth,
      crossAxisCount: crossAxisCount,
    );

    return SliverPadding(
      padding:
          padding ??
          const EdgeInsets.symmetric(
            horizontal: GameCardLayout.horizontalPadding,
          ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: dims.columns,
          childAspectRatio: GameCardLayout.cardAspectRatio,
          mainAxisSpacing: GameCardLayout.spacing,
          crossAxisSpacing: GameCardLayout.spacing,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final game = games[index];
            return GameCard(
              key: game.buildWidgetKey('GameSliverGrid'),
              gameBlock: game,
              cardWidth: dims.cardWidth,
              onPressed: onGameTap != null ? () => onGameTap!(game) : null,
            );
          },
          childCount: games.length,
          addAutomaticKeepAlives: false,
        ),
      ),
    );
  }
}
