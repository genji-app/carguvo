import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/mini_game_icons.dart';
import 'package:sun_sports/shared/widgets/texts/gradient_text.dart';

const Color kDiamondPanelBg = Color(0xFF1C1B1A);
const Color kDiamondPanelBg2 = Color(0xFF141312);
const Color kDiamondStripBg = Color(0xFF111010);
const Color kDiamondDivider = Color(0xFF3A3937);
const Color kDiamondTextPrimary = Color(0xFFFFFEF5);
const Color kDiamondTextSecondary = Color(0xFFC3C2BC);
const Color kDiamondTextTertiary = Color(0xFF9C9B95);
const Color kDiamondChipBg = Color(0xFF26241F);
const Color kDiamondChipBorder = Color(0xFF4A4946);

const LinearGradient kDiamondGoldGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFFFFE5B8), Color(0xFFFFB732)],
);

const LinearGradient kDiamondSpinGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFFFFC24B), Color(0xFFF2612F)],
);

const int kDiamondSymbolCount = 6;

final List<String> kDiamondSymbolAssets = <String>[
  MiniGameIcons.diamondWild,
  MiniGameIcons.diamondBlue,
  MiniGameIcons.diamondRed,
  MiniGameIcons.diamondOrange,
  MiniGameIcons.diamondGreen,
  MiniGameIcons.diamondPurple,
];

String diamondSymbolAsset(int code) {
  final n = kDiamondSymbolAssets.length;
  return kDiamondSymbolAssets[((code % n) + n) % n];
}

class DiamondGoldText extends StatelessWidget {
  final String text;
  final double fontSize;

  const DiamondGoldText(this.text, {this.fontSize = 20, super.key});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: GradientText(
        text,
        maxLines: 1,
        gradient: kDiamondGoldGradient,
        style: GoogleFonts.plusJakartaSans(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          height: 1.1,
        ),
      ),
    );
  }
}

class DiamondGoldAmount extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;

  const DiamondGoldAmount(this.text, {this.textAlign, super.key});

  @override
  Widget build(BuildContext context) {
    return GradientText(
      text,
      gradient: kDiamondGoldGradient,
      textAlign: textAlign,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 20 / 14,
      ),
    );
  }
}

class DiamondIconButton extends StatelessWidget {
  final String iconPath;
  final VoidCallback? onTap;
  final double size;

  const DiamondIconButton({
    required this.iconPath,
    this.onTap,
    this.size = 32,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final icon = ImageHelper.load(path: iconPath, width: size, height: size);
    if (onTap == null) return icon;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: MouseRegion(cursor: SystemMouseCursors.click, child: icon),
    );
  }
}

TextStyle diamondColumnLabelStyle() => GoogleFonts.plusJakartaSans(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      height: 18 / 12,
      color: kDiamondTextSecondary,
    );
