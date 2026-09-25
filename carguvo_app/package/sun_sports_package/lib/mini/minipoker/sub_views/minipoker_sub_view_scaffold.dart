import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/mini/tx/widgets/tai_xiu_square_button.dart';

enum MinipokerSubView {
  betHistory('Lịch sử cược'),
  ranking('Xếp hạng'),
  guide('Hướng dẫn');

  const MinipokerSubView(this.title);

  final String title;
}

class MinipokerSubViewScaffold extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback onClose;
  final Widget child;
  final BorderRadius borderRadius;

  const MinipokerSubViewScaffold({
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
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: Row(
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColorStyles.contentPrimary,
                    ),
                  ),
                  const Spacer(),
                  TaiXiuSquareButton(
                    icon: Icons.close_rounded,
                    onTap: onBack,
                  ),
                ],
              ),
            ),
            Expanded(child: child),
          ],
        ),
      );
}
