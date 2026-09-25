import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/providers/live_chat_expanded_provider.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/spacing_styles.dart';
import 'package:sun_sports/features/sport/presentation/mobile/widgets/sport_mobile_header.dart';
import 'package:sun_sports/features/sport/presentation/mobile/widgets/sport_mobile_live_matches_section.dart';
import 'package:sun_sports/features/sport/presentation/providers/sport_navigation_provider.dart';
import 'package:sun_sports/features/sport/presentation/tablet/widgets/sport_tablet_bottom_navigation.dart';
import 'package:sun_sports/features/sport/presentation/widgets/sport_hot_section.dart';
import 'package:sun_sports/features/sport/presentation/widgets/sport_live_chat.dart';
import 'package:sun_sports/shared/layouts/shell_top_block.dart';
import 'package:sun_sports/shared/widgets/rive_vibrating/rive_vibrating.dart';

class SportMobileScreen extends ConsumerWidget {
  const SportMobileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(riveVibratingInitProvider);

    return SafeArea(
      bottom: false,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, AppColorStyles.backgroundSecondary],
            stops: [0.01, 0.05],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(
                    context,
                  ).copyWith(scrollbars: false),
                  child: CustomScrollView(
                    slivers: [
                      const ShellContentTopSpacer(),
                      const SliverToBoxAdapter(child: SportMobileHeader()),
                      const _LiveChatSliverHeader(),
                      const SliverToBoxAdapter(
                        child: Gap(AppSpacingStyles.space300),
                      ),
                      const SliverToBoxAdapter(
                        child: RepaintBoundary(
                          child: SportHotSection(height: 125),
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: Gap(AppSpacingStyles.space300),
                      ),
                      SliverToBoxAdapter(
                        child: RepaintBoundary(
                          child: SizedBox(
                            height: MediaQuery.sizeOf(context).height - 280,
                            child: SportMobileLiveMatchesSection(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _SportMobileBottomNavigation(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SportMobileBottomNavigation extends ConsumerWidget {
  const _SportMobileBottomNavigation();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(sportNavigationProvider);

    return Align(
      alignment: Alignment.bottomCenter,
      child: SportTabletBottomNavigation(
        selectedIndex: selectedIndex,
        isMobile: true,
        onItemSelected: (index) {
          ref.read(sportNavigationProvider.notifier).selectItem(index);
        },
      ),
    );
  }
}

class _LiveChatSliverHeader extends ConsumerWidget {
  const _LiveChatSliverHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpanded = ref.watch(
      liveChatExpandedProvider.select((value) => value),
    );
    final liveChatHeight = isExpanded
        ? ShellTopMetrics.chatExpanded
        : ShellTopMetrics.chatCollapsed;

    return SliverPersistentHeader(
      pinned: true,
      delegate: _StickyLiveChatDelegate(
        minHeight: liveChatHeight,
        maxHeight: liveChatHeight,
      ),
    );
  }
}

class _StickyLiveChatDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;

  _StickyLiveChatDelegate({required this.minHeight, required this.maxHeight});

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => Container(
    color: const Color(0xFF141414),
    height: maxHeight,
    child: const RepaintBoundary(child: SportLiveChat(isMobile: true)),
  );

  @override
  bool shouldRebuild(_StickyLiveChatDelegate oldDelegate) =>
      minHeight != oldDelegate.minHeight || maxHeight != oldDelegate.maxHeight;
}
