import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/mini_game_icons.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/texts/gradient_text.dart';

const LinearGradient kUpDownGoldGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFFFFE5B8), Color(0xFFFFB732)],
);

class UpDownGoldText extends StatelessWidget {
  final String text;

  static const double _maxFontSize = 16;

  const UpDownGoldText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: GradientText(
        text,
        maxLines: 1,
        gradient: kUpDownGoldGradient,
        style: GoogleFonts.plusJakartaSans(
          fontSize: _maxFontSize,
          fontWeight: FontWeight.w700,
          height: 20 / 16,
        ),
      ),
    );
  }
}

class UpDownSwapIcon extends StatelessWidget {
  final double size;

  const UpDownSwapIcon({required this.size, super.key});

  @override
  Widget build(BuildContext context) {
    return ImageHelper.load(
      path: MiniGameIcons.upDownIconStart,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}

class UpDownIconButton extends StatelessWidget {
  final String iconPath;
  final VoidCallback? onTap;

  const UpDownIconButton({required this.iconPath, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final icon = ImageHelper.load(
      path: iconPath,
      width: 32,
      height: 32,
    );
    if (onTap == null) return icon;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: SoundTap.wrap(onTap),
      child: MouseRegion(cursor: SystemMouseCursors.click, child: icon),
    );
  }
}
