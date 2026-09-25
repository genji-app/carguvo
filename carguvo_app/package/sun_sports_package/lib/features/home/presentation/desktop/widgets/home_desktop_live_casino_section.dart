import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/shared/widgets/cards/inner_shadow_card.dart';

class HomeDesktopLiveCasinoSection extends StatelessWidget {
  const HomeDesktopLiveCasinoSection({super.key});

  @override
  Widget build(BuildContext context) => InnerShadowCard(
    borderRadius: 16,
    child: Container(
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundTertiary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Live Casino'),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
            child: Row(
              children: [
                Expanded(child: _buildGameCard('SICBO 88', 'sunwin')),
                const Gap(8),
                Expanded(child: _buildGameCard('SICBO 88', 'sunwin')),
                const Gap(8),
                Expanded(child: _buildGameCard('SICBO 88', 'sunwin')),
                const Gap(8),
                Expanded(child: _buildGameCard('SICBO 88', 'sunwin')),
                const Gap(8),
                Expanded(child: _buildGameCard('SICBO 88', 'sunwin')),
              ],
            ),
          ),
        ],
      ),
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
            _buildNavigationButton(Icons.chevron_left),
            const Gap(4),
            _buildNavigationButton(Icons.chevron_right),
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

  Widget _buildGameCard(String gameName, String provider) {
    const backgroundColor = Color(
      0xFF90152C,
    );

    return InnerShadowCard(
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
                    ),
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
                    padding: const EdgeInsets.only(top: 12, bottom: 20),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          gameName,
                          style:
                              AppTextStyles.headingXSmall(
                                color: const Color(0xFFFFFEF5),
                              ).copyWith(
                                fontWeight: FontWeight.w900,
                                height: 20 / 20,
                              ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Gap(2),
                        Text(
                          provider,
                          style: AppTextStyles.labelXSmall(
                            color: AppColorStyles.contentPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
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
}
