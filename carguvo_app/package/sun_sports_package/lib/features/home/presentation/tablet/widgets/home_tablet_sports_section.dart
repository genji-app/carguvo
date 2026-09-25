import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/shared/widgets/cards/inner_shadow_card.dart';

class HomeTabletSportsSection extends StatelessWidget {
  const HomeTabletSportsSection({super.key});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColorStyles.backgroundTertiary,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.white.withOpacity(0.12),
          offset: const Offset(0, 0.5),
          blurRadius: 0.5,
          spreadRadius: 0,
          blurStyle: BlurStyle.inner,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Thể thao nổi bật'),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
          child: Row(
            children: [
              Expanded(
                child: _buildSportCard(
                  'BÓNG ĐÁ',
                  const Color(0xFFB93815),
                  AppImages.personSoccer,
                ),
              ),
              const Gap(8),
              Expanded(
                child: _buildSportCard(
                  'QUẦN VỢT',
                  const Color(0xFF21847B),
                  AppImages.personTennis,
                ),
              ),
              const Gap(8),
              Expanded(
                child: _buildSportCard(
                  'BÓNG CHUYỀN',
                  const Color(0xFF0E4D6C),
                  AppImages.personVolleyball,
                ),
              ),
              const Gap(8),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildSectionHeader(String title) => Container(
    height: 44,
    padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.labelMedium(
              color: AppColorStyles.contentPrimary,
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNavigationButton(Icons.keyboard_arrow_left),
            const Gap(4),
            _buildNavigationButton(Icons.keyboard_arrow_right),
          ],
        ),
      ],
    ),
  );

  Widget _buildNavigationButton(IconData icon) => Container(
    width: 28,
    height: 28,
    decoration: BoxDecoration(
      color: AppColorStyles.backgroundQuaternary,
      borderRadius: BorderRadius.circular(100),
    ),
    child: Center(
      child: Icon(icon, size: 20, color: AppColorStyles.contentPrimary),
    ),
  );

  Widget _buildSportCard(
    String sportName,
    Color backgroundColor,
    String imagePath,
  ) => InnerShadowCard(
    borderRadius: 12,
    child: AspectRatio(
      aspectRatio: 149 / 200,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 1.0,
                  child: ImageHelper.load(
                    path: AppIcons.sunShadow,
                    fit: BoxFit.cover,
                    cacheWidth: 600,
                    cacheHeight: 800,
                  ),
                ),
              ),
              Positioned.fill(
                child: ImageHelper.load(
                  path: imagePath,
                  fit: BoxFit.cover,
                  cacheWidth: 800,
                  cacheHeight: 1000,
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.25, 1.0],
                      colors: [
                        backgroundColor.withOpacity(0),
                        backgroundColor.withOpacity(0.5),
                        backgroundColor,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.only(top: 12, bottom: 32),
                  alignment: Alignment.center,
                  child: Text(
                    sportName,
                    style: AppTextStyles.headingXSmall(
                      color: const Color(0xFFFFFEF5),
                    ).copyWith(fontWeight: FontWeight.w900, height: 20 / 20),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
