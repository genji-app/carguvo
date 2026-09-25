import 'package:flutter/material.dart';

import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/money_formatter.dart';
import 'package:sun_sports/core/utils/styles/mini_game_icons.dart';
import 'package:sun_sports/mini/minipoker/widgets/minipoker_common.dart';
import 'package:sun_sports/mini/tx/widgets/tai_xiu_square_button.dart';
import 'package:sun_sports/mini/widgets/jackpot_count_animation.dart';

class DragonBallHeader extends StatelessWidget {
  final VoidCallback? onRanking;

  final VoidCallback? onHistory;

  final VoidCallback? onGuide;

  final VoidCallback? onClose;

  final int jackpot;

  const DragonBallHeader({
    this.onRanking,
    this.onHistory,
    this.onGuide,
    this.onClose,
    this.jackpot = 0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Padding(
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
                    width: 200,
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
                            horizontal: 24,
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
      ),
    );
  }
}

class DragonBallJackpotAmount extends StatefulWidget {
  const DragonBallJackpotAmount(this.jackpot, {super.key});

  final int jackpot;

  @override
  State<DragonBallJackpotAmount> createState() =>
      _DragonBallJackpotAmountState();
}

class _DragonBallJackpotAmountState extends State<DragonBallJackpotAmount> {
  @override
  Widget build(BuildContext context) {
    return JackpotCountAnimation(
      jackpot: widget.jackpot,
      money: (int a) => MoneyFormatter.formatWithCommas(a),
      gold: (String t) => MinipokerGoldText(t),
    );
  }
}
