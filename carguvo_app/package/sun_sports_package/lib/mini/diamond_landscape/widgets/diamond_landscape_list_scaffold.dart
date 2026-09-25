import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/mini_game_icons.dart';
import 'package:sun_sports/mini/diamond/widgets/diamond_common.dart';
import 'package:sun_sports/mini/diamond/widgets/diamond_list_scaffold.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class DiamondLandscapeListScaffold extends StatelessWidget {
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

  const DiamondLandscapeListScaffold({
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
        color: AppColorStyles.backgroundQuaternary,
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

  Widget _header() => SizedBox(
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
        ),
      );

  Widget _footer() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            DiamondPageButton(
              icon: Icons.chevron_left_rounded,
              onTap: onPrev,
            ),
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

class DiamondLandscapeSubHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onClose;

  final bool showBack;

  const DiamondLandscapeSubHeader({
    required this.title,
    this.onBack,
    this.onClose,
    this.showBack = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            if (showBack) ...[
              DiamondIconButton(
                iconPath: MiniGameIcons.diamondBack,
                onTap: SoundTap.wrap(onBack),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 24 / 18,
                color: kDiamondTextPrimary,
              ),
            ),
            const Spacer(),
            DiamondIconButton(
              iconPath: MiniGameIcons.diamondClose,
              onTap: SoundTap.wrap(showBack ? onClose : onBack),
            ),
          ],
        ),
      ),
    );
  }
}
