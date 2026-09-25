import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';

import 'package:sun_sports/core/utils/styles/mini_game_icons.dart';
import 'package:sun_sports/mini/diamond/widgets/diamond_common.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class DiamondListScaffold extends StatelessWidget {
  final String title;
  final Widget columnHeader;
  final Widget body;
  final String pageLabel;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final VoidCallback? onBack;
  final VoidCallback? onClose;
  final BorderRadius borderRadius;

  const DiamondListScaffold({
    required this.title,
    required this.columnHeader,
    required this.body,
    required this.pageLabel,
    this.onPrev,
    this.onNext,
    this.onBack,
    this.onClose,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: AppColorStyles.backgroundQuaternary, borderRadius: borderRadius),
      child: Column(
        children: [
          _header(),
          columnHeader,
          Expanded(child: body),
          _footer(),
        ],
      ),
    );
  }

  Widget _header() => Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 28 / 18,
                color: kDiamondTextPrimary,
              ),
            ),
            const Spacer(),
            DiamondIconButton(
              iconPath: MiniGameIcons.diamondClose,
              onTap: SoundTap.wrap(onBack),
            ),
          ],
        ),
      );

  Widget _footer() => Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            DiamondPageButton(icon: Icons.chevron_left_rounded, onTap: onPrev),
            Expanded(
              child: Text(
                pageLabel,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 20 / 14,
                  color: kDiamondTextTertiary,
                ),
              ),
            ),
            DiamondPageButton(
              icon: Icons.chevron_right_rounded,
              onTap: onNext,
            ),
          ],
        ),
      );
}

class DiamondPageButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const DiamondPageButton({required this.icon, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: 40,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: kDiamondChipBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kDiamondDivider, width: 0.5),
      ),
      child: Icon(icon, size: 18, color: kDiamondTextSecondary),
    );
    if (onTap == null) return box;
    return SoundTap(onTap: onTap, child: box);
  }
}
