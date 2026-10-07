import 'package:flutter/material.dart';
import 'package:app_package/core/utils/device_capability/device_capability.dart';
import 'package:app_package/core/utils/styles/app_color_styles.dart';
import 'package:app_package/core/utils/styles/app_text_styles.dart';
import 'package:app_package/features/game/game.dart';
import 'package:app_package/shared/widgets/cards/inner_shadow_card.dart';
import 'package:app_package/shared/widgets/scroll/scroll.dart';

class GameHorizontalSection extends StatelessWidget {
  const GameHorizontalSection({
    required this.games,
    this.onGamePressed,
    this.title,
    double? spacing,
    double? horizontalPadding,
    this.enablePeek = false,
    this.compactHeader = false,
    super.key,
  }) : spacing = spacing ?? GameCardLayout.spacing,
       horizontalPadding =
           horizontalPadding ?? GameCardLayout.horizontalPadding;

  final List<LobbyGame> games;

  final void Function(LobbyGame gameBlock)? onGamePressed;

  final Widget? title;

  final double spacing;

  final double horizontalPadding;

  final bool enablePeek;

  final bool compactHeader;

  @override
  Widget build(BuildContext context) {
    return InnerShadowCard(
      borderRadius: 16,
      color: AppColorStyles.backgroundTertiary,
      child: HorizontalPaginatedCarousel(
        title: title,
        titleStyle: compactHeader
            ? AppTextStyles.labelSmall(
                context: context,
                color: AppColorStyles.contentPrimary,
              ).copyWith(height: 24 / 14)
            : AppTextStyles.labelMedium(
                context: context,
                color: AppColorStyles.contentPrimary,
              ),
        compactHeader: compactHeader,
        backgroundColor: Colors.transparent,
        navigationButtonColor: AppColorStyles.backgroundQuaternary,
        navigationButtonDisabledColor: AppColorStyles.backgroundQuaternary,
        navigationIconColor: AppColorStyles.contentSecondary,
        navigationIconDisabledColor: AppColorStyles.contentQuaternary,
        itemCount: games.length,
        cardBorderRadius: 16,
        columnsBuilder: GameCardLayout.getColumns,
        heightBuilder: GameCardLayout.calculateHeightFromWidth,
        horizontalPadding: horizontalPadding,
        itemSpacing: spacing,
        enablePeek: enablePeek,
        hasMouse: hasMouse,
        itemBuilderWithWidth: (context, index, cardWidth) {
          final gameData = games[index];
          return GameCard(
            key: gameData.buildWidgetKey('GameHorizontalSection'),
            gameBlock: gameData,
            cardWidth: cardWidth,
            onPressed: onGamePressed != null
                ? () => onGamePressed?.call(gameData)
                : null,
          );
        },
        itemBuilder: (_, __) => const SizedBox.shrink(),
      ),
    );
  }
}
