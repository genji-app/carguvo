import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/mini_game_icons.dart';
import 'package:sun_sports/mini/up_down/up_down_guide.dart';
import 'package:sun_sports/mini/up_down/widgets/up_down_common.dart';
import 'package:sun_sports/mini/up_down/widgets/up_down_list_scaffold.dart';

class UpDownLandscapeGuide extends StatelessWidget {
  final VoidCallback? onBack;

  final VoidCallback? onClose;

  final BorderRadius borderRadius;

  const UpDownLandscapeGuide({
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
          Expanded(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(
                context,
              ).copyWith(dragDevices: PointerDeviceKind.values.toSet()),
              child: const SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(12, 4, 12, 20),
                child: UpDownGuideBody(),
              ),
            ),
          ),
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
                I18n.mgGuide,
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
}
