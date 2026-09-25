import 'package:flutter/material.dart';

import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/mini_game_icons.dart';
import 'package:sun_sports/mini/dragon_ball/widgets/dragon_ball_header.dart';
import 'package:sun_sports/mini/tx/widgets/tai_xiu_square_button.dart';

class DragonBallLandscapeHeader extends StatelessWidget {
  final VoidCallback? onRanking;

  final VoidCallback? onHistory;

  final VoidCallback? onGuide;

  final VoidCallback? onClose;

  final int jackpot;

  static const double kHeight = 48;

  const DragonBallLandscapeHeader({
    this.onRanking,
    this.onHistory,
    this.onGuide,
    this.onClose,
    this.jackpot = 0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kHeight,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF393836), width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          TaiXiuSquareButton(
            iconPath: MiniGameIcons.txRanking,
            onTap: onRanking ?? () {},
          ),
          const SizedBox(width: 8),
          TaiXiuSquareButton(
            iconPath: MiniGameIcons.txHistory,
            onTap: onHistory ?? () {},
          ),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: 170,
                  height: 40,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: ImageHelper.load(
                          path: MiniGameIcons.upDownBackgroundTotalMoney,
                          fit: BoxFit.fill,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: DragonBallJackpotAmount(jackpot),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          TaiXiuSquareButton(
            iconPath: MiniGameIcons.txQa,
            onTap: onGuide ?? () {},
          ),
          const SizedBox(width: 8),
          TaiXiuSquareButton(
            icon: Icons.close_rounded,
            onTap: onClose ?? () {},
          ),
        ],
      ),
    );
  }
}
