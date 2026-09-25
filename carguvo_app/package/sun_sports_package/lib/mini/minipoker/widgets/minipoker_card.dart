import 'package:flutter/material.dart';

import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/mini_game_icons.dart';

enum PorkerSuit { club, diamond, heart, spade }

class PorkerCard {
  final PorkerSuit suit;
  final String rank;

  const PorkerCard(this.suit, this.rank);
}

String porkerCardAsset(PorkerSuit suit, String rank) =>
    'porker_${suit.name}_${rank.toLowerCase()}.svg';

class MinipokerCardView extends StatelessWidget {
  final PorkerCard card;
  final double? width;
  final double? height;

  const MinipokerCardView({
    required this.card,
    this.width,
    this.height,
    super.key,
  });

  @override
  Widget build(BuildContext context) => ImageHelper.load(
        path: porkerCardAsset(card.suit, card.rank),
        width: width,
        height: height,
        fit: BoxFit.contain,
      );
}

class MinipokerResultCardBox extends StatelessWidget {
  final List<PorkerCard> cards;
  final double boxWidth;
  final double cardWidth;
  final double cardHeight;

  const MinipokerResultCardBox({
    required this.cards,
    this.boxWidth = 158.96,
    this.cardWidth = 26.65,
    this.cardHeight = 35.27,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Container(
        width: boxWidth,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColorStyles.backgroundTertiary,
          borderRadius: BorderRadius.circular(14.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final c in cards)
              ClipRRect(
                borderRadius: BorderRadius.circular(5.4),
                child: ColoredBox(
                  color: const Color(0xFFF0F0F0),
                  child: MinipokerCardView(
                    card: c,
                    width: cardWidth,
                    height: cardHeight,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
