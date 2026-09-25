import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/shared/widgets/scroll_aware_scroll_reporter.dart';
import 'package:sun_sports/core/error/app_error_messages.dart';
import 'package:sun_sports/core/providers/live_chat_expanded_provider.dart';
import 'package:sun_sports/core/providers/scroll_controller_provider.dart';
import 'package:sun_sports/core/providers/scroll_hide_provider.dart';

import 'package:sun_sports/features/sport/presentation/providers/favorite_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/league_detail_provider.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/utils/auth_gate.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';

import 'package:sun_sports/shared/layouts/shell_top_overlap_sliver.dart';
import 'package:sun_sports/shared/widgets/empty_page/sport_empty_page.dart';
import 'package:sun_sports/shared/widgets/sport/league/league_events_sliver_v2.dart';
import 'package:sun_sports/shared/widgets/sport/loading/sport_shimmer_loading.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/back_to_top_overlay.dart'
    show BackToTopFloatingButton, BackToTopNavInset;

class LeagueDetailMobileScreen extends ConsumerWidget {
  const LeagueDetailMobileScreen({super.key, this.onBackPressed});

  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: _LeagueDetailMobileContent(onBackPressed: onBackPressed),
    );
  }
}

class _LeagueDetailMobileContent extends ConsumerStatefulWidget {
  const _LeagueDetailMobileContent({this.onBackPressed});

  final VoidCallback? onBackPressed;

  @override
  ConsumerState<_LeagueDetailMobileContent> createState() =>
      _LeagueDetailMobileContentState();
}

class _LeagueDetailMobileContentState
    extends ConsumerState<_LeagueDetailMobileContent> {
  @override
  Widget build(BuildContext context) {
    final scrollController = ref.watch(mainScrollControllerProvider);
    final isExpanded = ref.watch(liveChatExpandedProvider);
    final leagueInfo = ref.watch(selectedLeagueInfoProvider);
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
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: ScrollAwareScrollReporter(
          child: CustomScrollView(
            controller: scrollController,
            cacheExtent: 1200,
            slivers: [
              const ShellTopOverlapSliver(),
              const SliverToBoxAdapter(child: Gap(16)),
              PinnedHeaderSliver(
                child: ColoredBox(
                  color: const Color(0xFF141414),
                  child: _buildTitleRow(context, ref, onBackPressed, leagueInfo),
                ),
              ),
              const SliverToBoxAdapter(child: Gap(6)),
              if (leagueInfo != null) ..._buildLeagueSlivers(ref, leagueInfo),
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

  Widget _buildTitleRow(
    BuildContext context,
    WidgetRef ref,
    VoidCallback? onBackPressed,
    SelectedLeagueInfo? leagueInfo,
  ) {
    if (leagueInfo == null) {
      return const SizedBox.shrink();
    }

    final asyncLeagues = ref.watch(leagueDetailEventsProvider(leagueInfo));
    final leaguesList = asyncLeagues.valueOrNull;
    final modelFav =
        leaguesList != null &&
        leaguesList.isNotEmpty &&
        leaguesList.first.isFavorited;
    final favoriteState = ref.watch(favoriteProvider);
    final sid = leagueInfo.sportId;
    final hasBucket = favoriteState.favoritesBySport.containsKey(sid);
    final isLeagueFav = hasBucket
        ? favoriteState.isLeagueFavorite(sid, leagueInfo.leagueId)
        : modelFav;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          if (leagueInfo.leagueLogo.isNotEmpty)
            ClipRRect(
              key: ValueKey(leagueInfo.leagueId),
              borderRadius: const BorderRadius.all(Radius.circular(6)),
              child: Container(
                color: Colors.white,
                width: 24,
                height: 24,
                child: ImageHelper.load(
                  path: leagueInfo.leagueLogo,
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                  errorWidget: const SizedBox(width: 24),
                ),
              ),
            )
          else
            const SizedBox(width: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              leagueInfo.leagueName,
              style: AppTextStyles.headingXSmall(
                color: AppColorStyles.contentPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: SoundTap.wrap(() async {
              if (!requireLogin(context, ref)) return;
              final notifier = ref.read(favoriteProvider.notifier);
              final fav = ref.read(favoriteProvider);
              final snap = ref.read(leagueDetailEventsProvider(leagueInfo));
              final list = snap.valueOrNull;
              final mf = list != null && list.isNotEmpty
                  ? list.first.isFavorited
                  : false;
              final wasFavorited = fav.favoritesBySport.containsKey(sid)
                  ? fav.isLeagueFavorite(sid, leagueInfo.leagueId)
                  : mf;
              final success = wasFavorited
                  ? await notifier.removeFavoriteLeague(
                      sportId: sid,
                      leagueId: leagueInfo.leagueId,
                    )
                  : await notifier.addFavoriteLeague(
                      sportId: sid,
                      leagueId: leagueInfo.leagueId,
                    );
              if (success) {
                ref.invalidate(leagueDetailEventsProvider(leagueInfo));
                if (context.mounted) {
                  AppToast.showSuccess(
                    context,
                    message: wasFavorited
                        ? 'Đã xoá giải đấu khỏi yêu thích'
                        : 'Đã thêm giải đấu vào yêu thích',
                  );
                }
              }
            }),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: ImageHelper.load(
                path: isLeagueFav
                    ? AppIcons.iconFavoriteSelected
                    : AppIcons.iconUnFavorite,
                width: 22,
                height: 22,
                fit: BoxFit.contain,
                color: isLeagueFav ? null : const Color(0xB3FFFCDB),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  List<Widget> _buildLeagueSlivers(
    WidgetRef ref,
    SelectedLeagueInfo leagueInfo,
  ) {
    final asyncLeagues = ref.watch(leagueDetailEventsProvider(leagueInfo));

    return asyncLeagues.when(
      data: (leagues) {
        if (leagues.isEmpty) {
          return [const SliverToBoxAdapter(child: SportEmptyPage())];
        }
        return [
          LeagueEventsSliverV2(
            leagues: leagues,
            isDesktop: false,
            includeEmptyLeagues: false,
            showLeagueFavorite: false,
            headerFrameOnly: true,
            showBackToTop: false,
            enableVisibleLeagueSub: true,
            subTimeRanges: kLeagueSubAllTimeRanges,
          ),
        ];
      },
      loading: () => [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SportShimmerLoading(isDesktop: false),
          ),
        ),
      ],
      error: (err, _) => [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              localizedOrGenericError('LeagueDetail', err.toString()),
              style: AppTextStyles.textStyle(
                fontSize: 14,
                color: AppColorStyles.contentTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
