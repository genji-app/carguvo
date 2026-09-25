import 'package:flutter/material.dart';

import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';

class SubViewPlaceholder extends StatelessWidget {
  final IconData icon;
  final String label;

  const SubViewPlaceholder({required this.icon, required this.label, super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 48, color: AppColorStyles.contentTertiary),
        const SizedBox(height: 12),
        Text(
          label,
          style: AppTextStyles.textStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColorStyles.contentSecondary,
          ),
        ),
      ],
    ),
  );
}
