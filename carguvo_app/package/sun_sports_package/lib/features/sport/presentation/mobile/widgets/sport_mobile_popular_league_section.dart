import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/sport/presentation/desktop/widgets/sport_desktop_popular_league_section.dart';
import 'package:sun_sports/features/sport/presentation/providers/league_collapse_providers.dart';
import 'package:sun_sports/shared/widgets/empty_page/sport_empty_page.dart';
import 'package:sun_sports/shared/widgets/sport/collapse_all_toggle.dart';
import 'package:sun_sports/shared/widgets/sport/league/league_events_sliver_v2.dart';
import 'package:sun_sports/shared/widgets/sport/loading/sport_shimmer_loading.dart';

final _popularLeaguesSelector = popularLeagueProvider.select((s) => s.leagues);
final _popularLoadingSelector = popularLeagueProvider.select(
  (s) => s.isLoading,
);

class SportMobilePopularLeagueSection extends ConsumerStatefulWidget {
  const SportMobilePopularLeagueSection({super.key});

  @override
  ConsumerState<SportMobilePopularLeagueSection> createState() =>
      _SportMobilePopularLeagueSectionState();
}

class _SportMobilePopularLeagueSectionState
    extends ConsumerState<SportMobilePopularLeagueSection> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final state = ref.read(popularLeagueProvider);
      if (state.leagues.isEmpty && !state.isLoading) {
        ref.read(popularLeagueProvider.notifier).fetchPopularLeagues();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      sliver: DecoratedSliver(
        decoration: BoxDecoration(
          color: const Color(0xFF1B1A19),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, -0.65),
              blurRadius: 0.5,
              spreadRadius: 0.05,
              blurStyle: BlurStyle.inner,
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ],
        ),
        sliver: SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            Consumer(
              builder: (context, ref, _) {
                final isLoading = ref.watch(_popularLoadingSelector);
                if (isLoading) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: SportShimmerLoading(isDesktop: false),
                      ),
                    ),
                  );
                }

                final leagues = ref.watch(_popularLeaguesSelector);
                final nonEmpty = leagues
                    .where((l) => l.events.isNotEmpty)
                    .toList();

                if (nonEmpty.isEmpty) {
                  return const SliverToBoxAdapter(child: SportEmptyPage());
                }

                return LeagueEventsSliverV2(
                  leagues: nonEmpty,
                  isDesktop: false,
                  showBackToTop: false,
                  collapseAllProvider: popularLeagueCollapseAllProvider,
                  enableVisibleLeagueSub: true,
                  subTimeRanges: kLeagueSubAllTimeRanges,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Text(
            'Phổ biến',
            style: AppTextStyles.textStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFFFFEF5),
            ),
          ),
          const Spacer(),
          CollapseAllToggle(
            provider: popularLeagueCollapseAllProvider,
            iconSize: 20,
            padding: const EdgeInsets.all(5),
          ),
        ],
      ),
    );
  }
}
