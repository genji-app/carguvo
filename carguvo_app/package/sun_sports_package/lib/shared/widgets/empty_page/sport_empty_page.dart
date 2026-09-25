import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';

class SportEmptyPage extends StatelessWidget {
  const SportEmptyPage({
    super.key,
    this.message = 'Hiện tại không có trận đấu nào.',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ImageHelper.load(
              path: AppImages.iconSearchNoResultSport,
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.paragraphMedium(
                color: AppColorStyles.contentTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
