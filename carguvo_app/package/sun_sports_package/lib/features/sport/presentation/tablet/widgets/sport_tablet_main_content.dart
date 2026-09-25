import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/utils/styles/spacing_styles.dart';
import 'package:sun_sports/features/sport/presentation/desktop/widgets/sport_desktop_banner_section.dart';
import 'package:sun_sports/features/sport/presentation/desktop/widgets/sport_desktop_live_matches_section.dart';
import 'package:sun_sports/features/sport/presentation/desktop/widgets/sport_desktop_section_tabs.dart';
import 'package:sun_sports/features/sport/presentation/widgets/sport_hot_section.dart';

class SportTabletMainContent extends StatelessWidget {
  const SportTabletMainContent({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = [
      'Cúp C1 Châu Âu',
      'Ngoại hạng anh',
      'Laliga',
      'Seria A',
      'Bundesliga',
      'Ligue 1',
    ];

    return Expanded(
      child: Container(
        alignment: Alignment.topCenter,
        margin: const EdgeInsets.only(top: AppSpacingStyles.space300),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingStyles.space800,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1140, minWidth: 860),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(
              context,
            ).copyWith(scrollbars: false),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SportDesktopBannerSection(),
                  const Gap(AppSpacingStyles.space300),
                  const Gap(AppSpacingStyles.space300),
                  const SportDesktopLiveMatchesSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
