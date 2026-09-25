import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/scroll_aware_controller.dart';
import 'package:sun_sports/core/utils/styles/spacing_styles.dart';
import 'package:sun_sports/shared/widgets/back_to_top_overlay.dart';
import 'sport_desktop_banner_section.dart';
import 'sport_desktop_live_matches_section.dart';
import 'sport_desktop_section_tabs.dart';

class SportDesktopMainContent extends StatelessWidget {
  const SportDesktopMainContent({super.key});

  static const _sections = [
    'Cúp C1 Châu Âu',
    'Ngoại hạng anh',
    'Laliga',
    'Seria A',
    'Bundesliga',
    'Ligue 1',
  ];

  @override
  Widget build(BuildContext context) {
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
            child: BackToTopWrapper(
            builder: (scrollController) => NotificationListener<
                ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollStartNotification ||
                    notification is ScrollUpdateNotification) {
                  ScrollAwareController.instance.onScrollStart();
                } else if (notification is ScrollEndNotification) {
                  ScrollAwareController.instance.onScrollEnd();
                }
                return false;
              },
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SportDesktopBannerSection(),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: const SportDesktopLiveMatchesSection(),
                  ),
                ],
              ),
            ),
          ),
          ),
        ),
      ),
    );
  }
}
