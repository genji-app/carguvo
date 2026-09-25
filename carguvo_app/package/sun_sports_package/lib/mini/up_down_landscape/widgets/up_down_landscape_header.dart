import 'package:flutter/material.dart';

import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/mini_game_icons.dart';
import 'package:sun_sports/mini/up_down/widgets/up_down_common.dart';
import 'package:sun_sports/mini/up_down/widgets/up_down_header.dart';

class UpDownLandscapeHeader extends StatelessWidget {
  final VoidCallback? onClose;
  final VoidCallback? onHelp;
  final VoidCallback? onRank;
  final VoidCallback? onHistory;

  static const double kHeight = 48;

  const UpDownLandscapeHeader({
    this.onClose,
    this.onHelp,
    this.onRank,
    this.onHistory,
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
          UpDownIconButton(
            iconPath: MiniGameIcons.upDownTrophy,
            onTap: onRank,
          ),
          const SizedBox(width: 8),
          UpDownIconButton(
            iconPath: MiniGameIcons.upDownClock,
            onTap: onHistory,
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
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: UpDownJackpotAmount(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          UpDownIconButton(
            iconPath: MiniGameIcons.upDownHelp,
            onTap: onHelp,
          ),
          const SizedBox(width: 8),
          UpDownIconButton(
            iconPath: MiniGameIcons.upDownClose,
            onTap: onClose,
          ),
        ],
      ),
    );
  }
}
