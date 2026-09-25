import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/utils/scroll_aware_controller.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/spacing_styles.dart';
import 'package:sun_sports/features/sport/presentation/mobile/widgets/sport_mobile_live_matches_section.dart';
import 'package:sun_sports/shared/layouts/shell_top_block.dart';

class SportMobileMainContent extends StatelessWidget {
  const SportMobileMainContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColorStyles.backgroundPrimary,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification) {
                ScrollAwareController.instance.onScrollStart();
              } else if (notification is ScrollUpdateNotification) {
                ScrollAwareController.instance.onScrollStart();
              } else if (notification is ScrollEndNotification) {
                ScrollAwareController.instance.onScrollEnd();
              }
              return false;
            },
            child: const CustomScrollView(
              slivers: [
                ShellContentTopSpacer(),
                _LiveMatchesSliver(),
              ],
            ),
          ),
      ),
    );
  }
}

class _LiveMatchesSliver extends StatelessWidget {
  const _LiveMatchesSliver();

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final chat = ShellTopMetrics.hasChat(ref)
            ? ShellTopMetrics.chatCollapsed
            : 0.0;
        final offset =
            ShellTopMetrics.header + chat + AppSpacingStyles.space300;

        return SliverToBoxAdapter(
          child: RepaintBoundary(
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height - offset,
              child: const SportMobileLiveMatchesSection(),
            ),
          ),
        );
      },
    );
  }
}
