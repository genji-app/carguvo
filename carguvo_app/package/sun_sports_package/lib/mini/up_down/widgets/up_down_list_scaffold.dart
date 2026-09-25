import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';

import 'package:sun_sports/core/utils/styles/mini_game_icons.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/texts/gradient_text.dart';
import 'package:sun_sports/mini/up_down/widgets/up_down_common.dart';

const Color kUpDownPanelBg = AppColorStyles.backgroundQuaternary;
const Color kUpDownStripBg = Color(0xFF111010);
const Color kUpDownDivider = Color(0xFF4A4946);
const Color kUpDownTextPrimary = Color(0xFFFFFEF5);
const Color kUpDownTextSecondary = Color(0xFFC3C2BC);
const Color kUpDownTextTertiary = Color(0xFF9C9B95);
const Color kUpDownGray = Color(0xFF74736F);
const Color kUpDownGreen = Color(0xFF86CB3C);
const Color kUpDownRed = Color(0xFFF97066);

TextStyle upDownColumnLabelStyle() => GoogleFonts.plusJakartaSans(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      height: 18 / 12,
      color: kUpDownTextSecondary,
    );

class UpDownListScaffold extends StatelessWidget {
  final String title;
  final Widget columnHeader;
  final Widget body;
  final String pageLabel;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final VoidCallback? onBack;
  final VoidCallback? onClose;
  final BorderRadius borderRadius;

  const UpDownListScaffold({
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
      decoration: BoxDecoration(
        color: kUpDownPanelBg,
        borderRadius: borderRadius,
      ),
      child: Column(
        children: [
          _header(),
          columnHeader,
          Expanded(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context)
                  .copyWith(dragDevices: PointerDeviceKind.values.toSet()),
              child: body,
            ),
          ),
          _footer(),
        ],
      ),
    );
  }

  Widget _header() => Container(
        color: AppColorStyles.backgroundQuaternary,
        height: 56,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 28 / 18,
                  color: kUpDownTextPrimary,
                ),
              ),
              const Spacer(),
              UpDownIconButton(
                iconPath: MiniGameIcons.upDownClose,
                onTap: onBack,
              ),
            ],
          ),
        ),
      );

  Widget _footer() => Container(
        color: AppColorStyles.backgroundTertiary,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            UpDownPageButton(icon: Icons.chevron_left_rounded, onTap: onPrev),
            Expanded(
              child: Text(
                pageLabel,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 20 / 14,
                  color: kUpDownTextTertiary,
                ),
              ),
            ),
            UpDownPageButton(icon: Icons.chevron_right_rounded, onTap: onNext),
          ],
        ),
      );
}

class UpDownPageButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const UpDownPageButton({required this.icon, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: 40,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundQuaternary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kUpDownDivider, width: 0.5),
      ),
      child: Icon(icon, size: 18, color: kUpDownTextSecondary),
    );
    if (onTap == null) return box;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: SoundTap.wrap(onTap),
      child: MouseRegion(cursor: SystemMouseCursors.click, child: box),
    );
  }
}

class UpDownGoldAmount extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;

  const UpDownGoldAmount(this.text, {this.textAlign, super.key});

  @override
  Widget build(BuildContext context) {
    return GradientText(
      text,
      gradient: kUpDownGoldGradient,
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
