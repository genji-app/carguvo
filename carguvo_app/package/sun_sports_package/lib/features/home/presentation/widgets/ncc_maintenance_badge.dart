import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';

class NccMaintenanceBadge extends StatelessWidget {
  const NccMaintenanceBadge({super.key});

  @override
  Widget build(BuildContext context) => Container(
    width: 88,
    height: 32,
    alignment: Alignment.center,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFB10000), Color(0xFF3E0000)],
      ),
      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16)),
    ),
    child: Text(
      'Bảo trì',
      style: AppTextStyles.textStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: const Color(0xFFFFFEF5),
      ),
    ),
  );
}
