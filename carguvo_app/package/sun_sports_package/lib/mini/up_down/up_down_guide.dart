import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/mini_game_icons.dart';
import 'package:sun_sports/mini/up_down/widgets/up_down_common.dart';

class UpDownGuide extends StatelessWidget {
  final VoidCallback? onBack;

  final VoidCallback? onClose;

  final BorderRadius borderRadius;

  const UpDownGuide({
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
        color: AppColorStyles.backgroundQuaternary,
        borderRadius: borderRadius,
      ),
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          _header(),
          Expanded(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(
                context,
              ).copyWith(dragDevices: PointerDeviceKind.values.toSet()),
              child: const SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16, 4, 16, 20),
                child: UpDownGuideBody(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Text(
              I18n.mgGuide,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
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
  }
}

class UpDownGuideBody extends StatelessWidget {
  const UpDownGuideBody({super.key});

  static const Color _bodyColor = Color(0xFFC3C2BC);

  TextStyle get _bodyStyle => GoogleFonts.plusJakartaSans(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.45,
    color: _bodyColor,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _sectionTitle(I18n.upDownRulesTitle),
        _div(),
        _hintRow(),
        _div(),
        _para(I18n.upDownRuleDrawEachRound),
        _bigImage(MiniGameIcons.upDownGuide1, 552 / 473),
        _div(),
        _choiceRow(),
        const SizedBox(height: 12),
        _para(I18n.upDownRuleOverUnder),
        _div(),

        ImageHelper.load(
          path: MiniGameIcons.upDownGuide4,
          width: 110,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 12),
        _para(I18n.upDownRuleCashout),
        _div(),

        _para(I18n.upDownRuleAceAccumulate),
        const SizedBox(height: 12),
        _bigImage(MiniGameIcons.upDownGuide5, 635 / 384),
        const SizedBox(height: 12),
        _para(I18n.upDownRuleJackpot),
        const SizedBox(height: 12),
        _para(I18n.upDownRuleAceLostOnCashout),
        _div(),

        _para(I18n.upDownRuleTimeLimit),
        const SizedBox(height: 12),
        _bigImage(MiniGameIcons.upDownGuide6, 552 / 384),
        const SizedBox(height: 12),
        _para(I18n.upDownRuleTimeout),
        const SizedBox(height: 12),
        _para(I18n.upDownHaveFun),
      ],
    );
  }

  Widget _div() => Container(
    height: 1,
    margin: const EdgeInsets.symmetric(vertical: 12),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0x00FFFFFF), Color(0x33FFFFFF), Color(0x00FFFFFF)],
        stops: [0.0, 0.5, 1.0],
      ),
    ),
  );

  Widget _sectionTitle(String text) => Text(
    text,
    style: GoogleFonts.plusJakartaSans(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      height: 1.2,
      color: AppColors.green400,
    ),
  );

  Widget _hintRow() {
    return Row(
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ImageHelper.load(
                path: MiniGameIcons.upDownButtonStart,
                width: 40,
                height: 40,
              ),
              const UpDownSwapIcon(size: 18),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(I18n.upDownTap, style: _bodyStyle.copyWith(color: Colors.white)),
        const SizedBox(width: 6),
        const UpDownSwapIcon(size: 16),
        const SizedBox(width: 6),
        Text(I18n.upDownToStart, style: _bodyStyle.copyWith(color: Colors.white)),
      ],
    );
  }

  Widget _choiceRow() {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      runSpacing: 8,
      children: [
        Text(I18n.upDownPlayerCanChoose, style: _bodyStyle),
        _coloredInline(I18n.upDownOverQuoted, AppColors.green400),
        _barImage(MiniGameIcons.upDownGuide2),
        Text(I18n.upDownOrWord, style: _bodyStyle),
        _coloredInline(I18n.upDownUnderQuoted, AppColors.red400),
        _barImage(MiniGameIcons.upDownGuide3),
        Text(I18n.upDownEachTurn, style: _bodyStyle),
      ],
    );
  }

  Widget _coloredInline(String text, Color color) => Text(
    text,
    style: GoogleFonts.plusJakartaSans(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      height: 1.45,
      color: color,
    ),
  );

  Widget _para(String text) => Text(text, style: _bodyStyle);

  Widget _bigImage(String path, double ratio) => Center(
    child: ImageHelper.load(
      path: path,
      width: double.infinity,
      height: 150,
      fit: BoxFit.contain,
    ),
  );

  Widget _barImage(String path) => ImageHelper.load(
    path: path,
    width: 28 * (255 / 95),
    height: 28,
    fit: BoxFit.contain,
  );
}
