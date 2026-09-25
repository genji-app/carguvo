import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/shared/widgets/scroll_aware_scroll_reporter.dart';
import 'package:sun_sports/core/error/app_error_messages.dart';
import 'package:sun_sports/core/providers/live_chat_expanded_provider.dart';
import 'package:sun_sports/core/providers/scroll_controller_provider.dart';
import 'package:sun_sports/core/providers/scroll_hide_provider.dart';
import 'package:sun_sports/core/services/models/api_v2/sport_constants.dart'
    as v2;

import 'package:sun_sports/features/sport/presentation/providers/events_v2_filter_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/events_v2_provider.dart';
import 'package:sun_sports/features/sport/data/adapters/sport_socket_adapter_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/league_collapse_providers.dart';
import 'package:sun_sports/shared/widgets/sport/collapse_all_toggle.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';

import 'package:sun_sports/shared/layouts/shell_pinned_align.dart';
import 'package:sun_sports/shared/layouts/shell_top_overlap_sliver.dart';
import 'package:sun_sports/shared/widgets/back_to_top_overlay.dart';
import 'package:sun_sports/shared/widgets/empty_page/sport_empty_page.dart';
import 'package:sun_sports/shared/widgets/sport/league/league_events_sliver_v2.dart';
import 'package:sun_sports/shared/widgets/sport/loading/sport_shimmer_loading.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/tab_layout/s88_tab.dart'
    show S88Tab, sportTabItems, sportIds;

class LiveEventMobileScreen extends ConsumerWidget {
  const LiveEventMobileScreen({super.key, this.onBackPressed});

  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: _LiveEventMobileContent(onBackPressed: onBackPressed),
    );
  }
}

class _LiveEventMobileContent extends ConsumerStatefulWidget {
  const _LiveEventMobileContent({this.onBackPressed});

  final VoidCallback? onBackPressed;

  @override
  ConsumerState<_LiveEventMobileContent> createState() =>
      _LiveEventMobileContentState();
}

class _LiveEventMobileContentState
    extends ConsumerState<_LiveEventMobileContent> {
  final GlobalKey _pinnedBlockAnchor = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final scrollController = ref.watch(mainScrollControllerProvider);
    final isExpanded = ref.watch(liveChatExpandedProvider);
    final onBackPressed = widget.onBackPressed;

    return Stack(
      children: [
        GestureDetector(
          onTap: SoundTap.wrap(() {
            if (isExpanded) {
              FocusScope.of(context).unfocus();
              ref.read(liveChatExpandedProvider.notifier).state = false;
            }
          }),
          behavior: HitTestBehavior.translucent,
          child: ScrollConfiguration(
            behavior:
                ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: ScrollAwareScrollReporter(
              child: CustomScrollView(
                controller: scrollController,
                cacheExtent: 1200,
                slivers: [
                  const ShellTopOverlapSliver(),
                  const SliverToBoxAdapter(child: Gap(16)),
                  ShellPinnedBlockAnchor(anchorKey: _pinnedBlockAnchor),
                  PinnedHeaderSliver(
                    child: ColoredBox(
                      color: const Color(0xFF141414),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildTitleRow(context, onBackPressed),
                          _buildSportTabs(ref),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: Gap(12)),
                  ..._buildLeagueSlivers(ref),
                  SliverToBoxAdapter(
                    child: Gap(80 + MediaQuery.of(context).padding.bottom),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: BackToTopFloatingButton.margin,
          bottom: BackToTopFloatingButton.bottomMobileWithNav,
          child: BackToTopNavInset(
            progress: ref.read(scrollHideProvider).progress,
            child: BackToTopFloatingButton(controller: scrollController),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleRow(BuildContext context, VoidCallback? onBackPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          ImageHelper.load(
            path: AppIcons.liveDot,
            width: 24,
            height: 24,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 8),
          Text(
            'Đang diễn ra',
            style: AppTextStyles.headingXSmall(
              color: AppColorStyles.contentPrimary,
            ),
          ),
          const Spacer(),
          CollapseAllToggle(
            provider: liveEventCollapseAllProvider,
            iconSize: 20,
            padding: const EdgeInsets.all(5),
          ),
        ],
      ),
    );
  }

  Widget _buildSportTabs(WidgetRef ref) {
    final currentSport = ref.watch(selectedSportV2Provider);
    final currentId = currentSport.id;
    final selectedIndex = sportIds.indexOf(currentId);
    final clampedIndex = selectedIndex >= 0 ? selectedIndex : 0;

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF252423), width: 0.5),
        ),
      ),
      padding: const EdgeInsets.only(top: 4),
      child: S88Tab(
        tabs: sportTabItems,
        selectedIndex: clampedIndex,
        onTabChanged: (index) {
          final sportId = sportIds[index];
          if (sportId != currentId) {
            alignUnderShellPinnedBlockWithRef(
              ref,
              controller: ref.read(mainScrollControllerProvider),
              anchorKey: _pinnedBlockAnchor,
            );
          }
          ref.read(selectedSportV2Provider.notifier).state =
              v2.SportType.fromId(sportId) ?? v2.SportType.soccer;
          ref
              .read(sportSocketAdapterProvider)
              .subscriptionManager
              .setActiveSport(sportId);
        },
        backgroundColor: Colors.transparent,
        defaultColor: AppColorStyles.contentPrimary,
        selectedColor: AppColors.yellow300,
        isScrollable: true,
        scrollableTabWidth: 100,
      ),
    );
  }

  List<Widget> _buildLeagueSlivers(WidgetRef ref) {
    final state = ref.watch(liveEventsV2Provider);

    if (state.isLoading && state.leagues.isEmpty) {
      return [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: SportShimmerLoading(isDesktop: false),
          ),
        ),
      ];
    }
    if (state.error != null && state.leagues.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              localizedOrGenericError('LiveEvents', state.error ?? ''),
              style: AppTextStyles.textStyle(
                fontSize: 14,
                color: AppColorStyles.contentTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ];
    }
    if (state.leagues.isEmpty) {
      return [const SliverToBoxAdapter(child: SportEmptyPage())];
    }

    return [
      LeagueEventsSliverV2(
        leagues: state.leagues,
        isDesktop: false,
        includeEmptyLeagues: false,
        collapseAllProvider: liveEventCollapseAllProvider,
        showBackToTop: false,
        enableVisibleLeagueSub: true,
        subTimeRanges: {v2.EventTimeRange.live.value},
      ),
    ];
  }
}
