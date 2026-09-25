import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/mini_game_icons.dart';
import 'package:sun_sports/mini/diamond/state/diamond_state.dart';
import 'package:sun_sports/mini/diamond/state/diamond_state_provider.dart';
import 'package:sun_sports/mini/diamond/widgets/diamond_common.dart';
import 'package:sun_sports/mini/widgets/jackpot_count_animation.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/texts/gradient_text.dart';

class DiamondHeader extends StatelessWidget {
  final VoidCallback? onRank;
  final VoidCallback? onHistory;
  final VoidCallback? onGuide;
  final VoidCallback? onClose;

  const DiamondHeader({
    this.onRank,
    this.onHistory,
    this.onGuide,
    this.onClose,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
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
                            horizontal: 24,
                            vertical: 8,
                          ),
                          child: DiamondJackpotAmount(),
                        ),
                      ],
                    ),
                  ),
                ],
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

class DiamondJackpotAmount extends ConsumerStatefulWidget {
  const DiamondJackpotAmount({super.key});

  @override
  ConsumerState<DiamondJackpotAmount> createState() =>
      _DiamondJackpotAmountState();
}

class _DiamondJackpotAmountState extends ConsumerState<DiamondJackpotAmount> {
  static const double _maxFontSize = 16;
  static final TextStyle _numberStyle = GoogleFonts.plusJakartaSans(
    fontSize: _maxFontSize,
    fontWeight: FontWeight.w700,
    height: 20 / _maxFontSize,
  );

  @override
  Widget build(BuildContext context) {
    final jackpot = ref.watch(diamondStateProvider.select((s) => s.jackpot));
    final amount = JackpotCountAnimation(
      jackpot: jackpot,
      money: diamondMoney,
      gold: _gold,
    );
    if (!kDebugMode) return amount;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () =>
          ref.read(diamondStateProvider.notifier).debugShowJackpot(),
      child: amount,
    );
  }

  Widget _gold(String text) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            text,
            maxLines: 1,
            style: _numberStyle.copyWith(
              color: Colors.transparent,
              shadows: const [
                Shadow(
                  offset: Offset(0, 1),
                  blurRadius: 2,
                  color: Color(0x99000000),
                ),
              ],
            ),
          ),
          GradientText(
            text,
            gradient: kDiamondGoldGradient,
            maxLines: 1,
            style: _numberStyle,
          ),
        ],
      ),
    );
  }
}
