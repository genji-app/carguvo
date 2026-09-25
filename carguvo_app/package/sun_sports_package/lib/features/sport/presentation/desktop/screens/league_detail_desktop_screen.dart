import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/error/app_error_messages.dart';
import 'package:sun_sports/providers/main_content_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/favorite_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/league_detail_provider.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/spacing_styles.dart';
import 'package:sun_sports/shared/utils/auth_gate.dart';
import 'package:sun_sports/shared/widgets/back_to_top_overlay.dart'
    show BackToTopWrapper;
import 'package:sun_sports/shared/widgets/empty_page/sport_empty_page.dart';
import 'package:sun_sports/shared/widgets/sport/league/league_events_sliver_v2.dart';
import 'package:sun_sports/shared/widgets/sport/loading/sport_shimmer_loading.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';

class LeagueDetailDesktopScreen extends ConsumerWidget {
  const LeagueDetailDesktopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leagueInfo = ref.watch(selectedLeagueInfoProvider);

    if (leagueInfo == null) {
      return const Expanded(child: SportEmptyPage());
    }

    return Container(
      color: AppColorStyles.backgroundSecondary,
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingStyles.space800,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1140, minWidth: 960),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LeagueDetailHeader(leagueInfo: leagueInfo),
            const Gap(12),
            Expanded(
              child: RepaintBoundary(
                child: _LeagueDetailContent(leagueInfo: leagueInfo),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeagueDetailHeader extends ConsumerWidget {
  final SelectedLeagueInfo leagueInfo;

  const _LeagueDetailHeader({required this.leagueInfo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final previousContent = ref.watch(previousContentProvider);
    final showBack = previousContent != null;

    final leaguesList = ref
        .watch(leagueDetailEventsProvider(leagueInfo))
        .valueOrNull;
    final modelFav =
        leaguesList != null &&
        leaguesList.isNotEmpty &&
        leaguesList.first.isFavorited;
    final favoriteState = ref.watch(favoriteProvider);
    final sid = leagueInfo.sportId;
    final isLeagueFav = favoriteState.favoritesBySport.containsKey(sid)
        ? favoriteState.isLeagueFavorite(sid, leagueInfo.leagueId)
        : modelFav;

    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Row(
        children: [
          if (showBack) ...[
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: SoundTap.wrap(() {
                  ref
                      .read(mainContentProvider.notifier)
                      .switchTo(previousContent);
                  ref.read(previousContentProvider.notifier).state = null;
                }),
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColorStyles.backgroundQuaternary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ImageHelper.load(
                    path: AppIcons.icBack,
                    width: 24,
                    height: 24,
                    color: const Color(0xFFFFFCDB),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          if (leagueInfo.leagueLogo.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(6)),
              child: Container(
                color: Colors.white,
                width: 28,
                height: 28,
                child: ImageHelper.load(
                  path: leagueInfo.leagueLogo,
                  width: 28,
                  height: 28,
                  fit: BoxFit.contain,
                  errorWidget: const SizedBox(width: 28),
                ),
              ),
            )
          else
            const SizedBox.shrink(),
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
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: SoundTap.wrap(() async {
                if (!requireLogin(context, ref)) return;
                final notifier = ref.read(favoriteProvider.notifier);
                final fav = ref.read(favoriteProvider);
                final list = ref
                    .read(leagueDetailEventsProvider(leagueInfo))
                    .valueOrNull;
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
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: ImageHelper.load(
                  path: isLeagueFav
                      ? AppIcons.iconFavoriteSelected
                      : AppIcons.iconUnFavorite,
                  width: 28,
                  height: 28,
                  fit: BoxFit.contain,
                  color: isLeagueFav ? null : const Color(0xB3FFFCDB),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeagueDetailContent extends ConsumerWidget {
  final SelectedLeagueInfo leagueInfo;

  const _LeagueDetailContent({required this.leagueInfo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncLeagues = ref.watch(leagueDetailEventsProvider(leagueInfo));

    return asyncLeagues.when(
      data: (leagues) {
        if (leagues.isEmpty) {
          return const SportEmptyPage();
        }
        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: BackToTopWrapper(
            builder: (scrollController) => CustomScrollView(
              controller: scrollController,
              slivers: [
                LeagueEventsSliverV2(
                  leagues: leagues,
                  isDesktop: true,
                  includeEmptyLeagues: false,
                  showBackToTop: false,
                  headerFrameOnly: true,
                  enableVisibleLeagueSub: true,
                  subTimeRanges: kLeagueSubAllTimeRanges,
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
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: SportShimmerLoading(isDesktop: true),
        ),
      ),
      error: (err, _) => Center(
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
    );
  }
}
