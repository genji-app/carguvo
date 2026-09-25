import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';

class NotificationCategoryLeading extends StatelessWidget {
  const NotificationCategoryLeading({required this.category, super.key});

  final String category;

  static const capNhat = 'Cập nhật kết quả trận đấu';
  static const tyLe = 'Tỷ lệ cược tốt!';

  @override
  Widget build(BuildContext context) {
    if (category == 'Khác') {
      return const SizedBox(width: 40, height: 40);
    }
    if (category == capNhat) {
      return Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColorStyles.backgroundTertiary,
          shape: BoxShape.circle,
        ),
        child: ImageHelper.load(
          path: AppIcons.iconSoccer,
          width: 22,
          height: 22,
        ),
      );
    }
    if (category == tyLe) {
      return Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Color(0xFF1A280B),
          shape: BoxShape.circle,
        ),
        child: ImageHelper.load(
          path: AppIcons.iconLikeGreen,
          width: 22,
          height: 22,
        ),
      );
    }
    return const SizedBox(width: 40, height: 40);
  }
}
