import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/mini/tx/widgets/tai_xiu_square_button.dart';

enum TaiXiuSubView {
  sessionHistory('Lịch sử phiên'),
  sessionStats('Thống kê phiên'),
  betHistory('Lịch sử cược'),
  guide('Hướng dẫn'),
  ranking('Xếp hạng');

  const TaiXiuSubView(this.title);

  final String title;
}

class TaiXiuSubViewScaffold extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback onClose;
  final Widget child;

  const TaiXiuSubViewScaffold({
    required this.title,
    required this.onBack,
    required this.onClose,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 35),
    decoration: BoxDecoration(
      color: AppColorStyles.backgroundQuaternary,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Row(
            children: [
              const SizedBox(width: 32),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.textStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColorStyles.contentPrimary,
                  ),
                ),
              ),
              TaiXiuSquareButton(
                icon: Icons.close_rounded,
                onTap: onBack,
              ),
            ],
          ),
        ),
        Expanded(
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(
              context,
            ).copyWith(dragDevices: PointerDeviceKind.values.toSet()),
            child: child,
          ),
        ),
      ],
    ),
  );
}
