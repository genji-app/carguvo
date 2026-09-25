import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sport_socket/sport_socket.dart' show V2TimeRange;
import 'package:sun_sports/core/error/app_error_messages.dart';
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
import 'package:sun_sports/core/utils/styles/spacing_styles.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/shared/widgets/back_to_top_overlay.dart';
import 'package:sun_sports/shared/widgets/empty_page/sport_empty_page.dart';
import 'package:sun_sports/shared/widgets/sport/league/league_events_sliver_v2.dart';
import 'package:sun_sports/shared/widgets/sport/loading/sport_shimmer_loading.dart';
import 'package:sun_sports/shared/widgets/tab_layout/s88_tab.dart'
    show S88Tab, sportTabItems, sportIds;

class LiveEventDesktopScreen extends ConsumerWidget {
  const LiveEventDesktopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: AppColorStyles.backgroundSecondary,
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingStyles.space800,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1140, minWidth: 860),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildSportTabs(ref),
            const Gap(12),
            const Expanded(
              child: RepaintBoundary(
                child: _LiveEventsContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSportTabs(WidgetRef ref) {
    final currentSport = ref.watch(selectedSportV2Provider);
    final currentId = currentSport.id;
    final selectedIndex = sportIds.indexOf(currentId);
    final clampedIndex = selectedIndex >= 0 ? selectedIndex : 0;

    return RepaintBoundary(
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFF252423), width: 0.5),
          ),
        ),
        padding: const EdgeInsets.only(top: 8),
        child: S88Tab(
          tabs: sportTabItems,
          selectedIndex: clampedIndex,
          onTabChanged: (index) {
            final sportId = sportIds[index];
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
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28),
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
          CollapseAllToggle(provider: liveEventCollapseAllProvider),
        ],
      ),
    );
  }
}

class _LiveEventsContent extends ConsumerWidget {
  const _LiveEventsContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(liveEventsV2Provider);

    if (state.isLoading && state.leagues.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: SportShimmerLoading(isDesktop: true),
        ),
      );
    }
    if (state.error != null && state.leagues.isEmpty) {
      return Center(
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
      );
    }
    if (state.leagues.isEmpty) {
      return const SportEmptyPage();
    }

    return BackToTopWrapper(
      builder: (scrollController) => ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            LeagueEventsSliverV2(
              leagues: state.leagues,
              isDesktop: true,
              includeEmptyLeagues: false,
              showBackToTop: false,
              collapseAllProvider: liveEventCollapseAllProvider,
              enableVisibleLeagueSub: true,
              subTimeRanges: const {V2TimeRange.live},
            ),
            SliverPadding(
              padding: EdgeInsets.only(
                bottom: 80 + MediaQuery.of(context).padding.bottom,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
