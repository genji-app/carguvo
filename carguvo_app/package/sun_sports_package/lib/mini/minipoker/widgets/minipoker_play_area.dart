import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';

import 'package:sun_sports/mini/minipoker/widgets/minipoker_reels_rive.dart';
import 'package:sun_sports/mini/minipoker/widgets/minipoker_win_banner.dart';

class MinipokerPlayArea extends StatelessWidget {
  final List<MinipokerReelCard> entryCards;
  final List<MinipokerReelCard>? resultCards;
  final bool turbo;
  final int spinStartToken;

  final int resultToken;
  final int winToken;
  final String? winHand;
  final int winAmount;
  final bool roundInProgress;
  final VoidCallback? onRoundDone;

  final int jackpotToken;

  final double height;

  final bool showBrand;

  const MinipokerPlayArea({
    this.entryCards = kMinipokerDefaultEntry,
    this.resultCards,
    this.turbo = false,
    this.spinStartToken = 0,
    this.resultToken = 0,
    this.winToken = 0,
    this.winHand,
    this.winAmount = 0,
    this.roundInProgress = false,
    this.onRoundDone,
    this.jackpotToken = 0,
    this.height = kMinipokerPlayAreaHeight,
    this.showBrand = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            MinipokerReelsRive(
              entryCards: entryCards,
              resultCards: resultCards,
              turbo: turbo,
              spinStartToken: spinStartToken,
              resultToken: resultToken,
              roundInProgress: roundInProgress,
              onRoundDone: onRoundDone,
              jackpotToken: jackpotToken,
            ),
            if (showBrand)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Center(
                  child: Text(
                    'MINIPOKER · SUN88',
                    style: AppTextStyles.textStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColorStyles.contentQuaternary,
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: -22,
              child: Center(
                child: MinipokerWinBanner(
                  winToken: winToken,
                  hand: winHand,
                  amount: winAmount,
                  turbo: turbo,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const List<MinipokerReelCard> kMinipokerDefaultEntry = [
  MinipokerReelCard(rank: 10),
  MinipokerReelCard(rank: 11),
  MinipokerReelCard(rank: 12),
  MinipokerReelCard(rank: 13),
  MinipokerReelCard(rank: 1),
];

const double kMinipokerPlayAreaHeight = 180;
