import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/mini_game_icons.dart';
import 'package:sun_sports/mini/up_down/widgets/up_down_common.dart';
import 'package:sun_sports/mini/up_down/widgets/up_down_list_scaffold.dart';

class UpDownLandscapeListScaffold extends StatelessWidget {
  final String title;
  final Widget columnHeader;
  final Widget body;
  final String pageLabel;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final VoidCallback? onBack;
  final VoidCallback? onClose;
  final BorderRadius borderRadius;

  static const double kColumnHeaderHeight = 32;

  static const double kRowHeight = 60;

  const UpDownLandscapeListScaffold({
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
          SizedBox(height: kColumnHeaderHeight, child: columnHeader),
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
        height: 48,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 24 / 18,
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
