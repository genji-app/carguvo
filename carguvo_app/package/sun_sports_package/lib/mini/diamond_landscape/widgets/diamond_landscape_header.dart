import 'package:flutter/material.dart';

import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/mini_game_icons.dart';
import 'package:sun_sports/mini/diamond/widgets/diamond_common.dart';
import 'package:sun_sports/mini/diamond/widgets/diamond_header.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class DiamondLandscapeHeader extends StatelessWidget {
  final VoidCallback? onRank;
  final VoidCallback? onHistory;
  final VoidCallback? onGuide;
  final VoidCallback? onClose;

  static const double kHeight = 48;

  const DiamondLandscapeHeader({
    this.onRank,
    this.onHistory,
    this.onGuide,
    this.onClose,
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
          DiamondIconButton(
            iconPath: MiniGameIcons.diamondTrophy,
            onTap: SoundTap.wrap(onRank),
          ),
          const SizedBox(width: 8),
          DiamondIconButton(
            iconPath: MiniGameIcons.diamondClock,
            onTap: SoundTap.wrap(onHistory),
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
                          path: MiniGameIcons.diamondBackgroundJackpot,
                          fit: BoxFit.fill,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: DiamondJackpotAmount(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          DiamondIconButton(
            iconPath: MiniGameIcons.diamondHelp,
            onTap: SoundTap.wrap(onGuide),
          ),
          const SizedBox(width: 8),
          DiamondIconButton(
            iconPath: MiniGameIcons.diamondClose,
            onTap: SoundTap.wrap(onClose),
          ),
        ],
      ),
    );
  }
}
