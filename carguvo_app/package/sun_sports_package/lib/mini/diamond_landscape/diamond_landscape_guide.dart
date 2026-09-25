import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/mini_game_icons.dart';
import 'package:sun_sports/mini/diamond_landscape/widgets/diamond_landscape_list_scaffold.dart';

class DiamondLandscapeGuide extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onClose;
  final BorderRadius borderRadius;

  const DiamondLandscapeGuide({
    this.onBack,
    this.onClose,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundQuaternary,
        borderRadius: borderRadius,
      ),
      child: Column(
        children: [
          DiamondLandscapeSubHeader(
            title: I18n.mgGuide,
            onBack: onBack,
            onClose: onClose,
          ),
          Expanded(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(
                context,
              ).copyWith(dragDevices: PointerDeviceKind.values.toSet()),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth - 24;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                    child: ImageHelper.load(
                      path: MiniGameIcons.diamondGuide,
                      width: w,
                      fit: BoxFit.fitWidth,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
