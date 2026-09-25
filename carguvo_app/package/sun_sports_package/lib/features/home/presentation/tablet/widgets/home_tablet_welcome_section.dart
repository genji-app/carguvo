import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';

class HomeTabletWelcomeSection extends StatelessWidget {
  const HomeTabletWelcomeSection({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 160,
    child: Row(
      children: [
        Expanded(
          child: _buildWelcomeBanner(
            title: 'Chào mừng tới Sun88',
            subtitle: 'Thương hiệu cá cược thể thao của SunWin',
            buttonText: 'Chơi ngay',
          ),
        ),
        const Gap(12),
        Expanded(
          child: _buildWelcomeBanner(
            title: 'Ứng dụng trên\niOS & Android',
            subtitle: null,
            buttonText: 'Tải ngay',
          ),
        ),
      ],
    ),
  );

  Widget _buildWelcomeBanner({
    required String title,
    String? subtitle,
    required String buttonText,
  }) => Container(
    height: 160,
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
    clipBehavior: Clip.hardEdge,
    child: Stack(
      children: [
        Positioned.fill(
          child: ImageHelper.load(
            path: AppImages.backgroundIntroHome,
            fit: BoxFit.cover,
            cacheWidth: 1200,
            cacheHeight: 320,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.headingXSmall(
                      color: AppColorStyles.contentPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const Gap(4),
                    Text(
                      subtitle,
                      style: AppTextStyles.paragraphSmall(
                        color: AppColorStyles.contentPrimary,
                      ),
                    ),
                  ],
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF070606),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.12),
                      offset: const Offset(0, 0.5),
                      blurRadius: 0,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Text(
                  buttonText,
                  style: AppTextStyles.buttonSmall(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
