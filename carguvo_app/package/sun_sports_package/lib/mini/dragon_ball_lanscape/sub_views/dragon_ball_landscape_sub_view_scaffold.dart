import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/mini/tx/widgets/tai_xiu_square_button.dart';
import 'package:sun_sports/mini/up_down/widgets/up_down_list_scaffold.dart';

class DragonBallLandscapeSubViewScaffold extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback onClose;
  final Widget child;
  final BorderRadius borderRadius;

  const DragonBallLandscapeSubViewScaffold({
    required this.title,
    required this.onBack,
    required this.onClose,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    super.key,
  });

  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: AppColorStyles.backgroundQuaternary,
      borderRadius: borderRadius,
      border: Border.all(color: const Color(0xFF2A2826)),
    ),
    child: Column(
      children: [
        SizedBox(
          height: 48,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 24 / 16,
                    color: AppColorStyles.contentPrimary,
                  ),
                ),
                const Spacer(),
                TaiXiuSquareButton(icon: Icons.close_rounded, onTap: onBack),
              ],
            ),
          ),
        ),
        Expanded(child: child),
      ],
    ),
  );
}

const double kDragonBallLandscapeColumnHeaderHeight = 32;

const double kDragonBallLandscapeRowHeight = 60;

class DragonBallLandscapePaginationBar extends StatelessWidget {
  final int page;
  final int total;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const DragonBallLandscapePaginationBar({
    required this.page,
    required this.total,
    this.onPrev,
    this.onNext,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          UpDownPageButton(icon: Icons.chevron_left_rounded, onTap: onPrev),
          Expanded(
            child: Text(
              '$page/$total',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 20 / 14,
                color: AppColorStyles.contentTertiary,
              ),
            ),
          ),
          UpDownPageButton(icon: Icons.chevron_right_rounded, onTap: onNext),
        ],
      ),
    );
  }
}
