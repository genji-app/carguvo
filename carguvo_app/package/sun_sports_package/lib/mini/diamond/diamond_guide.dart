import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/mini_game_icons.dart';
import 'package:sun_sports/mini/diamond/widgets/diamond_common.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class DiamondGuide extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onClose;
  final BorderRadius borderRadius;

  const DiamondGuide({
    this.onBack,
    this.onClose,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 620,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration:
            BoxDecoration(color: AppColorStyles.backgroundQuaternary, borderRadius: borderRadius),
        child: Column(
          children: [
            _header(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth - 32;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                    child: ImageHelper.load(
                      path: MiniGameIcons.diamondGuide,
                      width: w,
                      fit: BoxFit.fitWidth,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() => Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Text(
              I18n.mgGuide,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
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
}
