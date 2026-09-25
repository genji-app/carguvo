import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sun_sports/features/sport/presentation/providers/events_v2_provider.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/empty_page/sport_empty_page.dart';
import 'package:sun_sports/shared/widgets/sport/league/league_card_v2.dart';
import 'package:sun_sports/shared/widgets/cards/inner_shadow_card.dart';

class HomeDesktopLiveMatchesSection extends StatelessWidget {
  const HomeDesktopLiveMatchesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return InnerShadowCard(
      borderRadius: 16,
      child: Container(
        decoration: BoxDecoration(
          color: AppColorStyles.backgroundTertiary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Consumer(
                builder: (context, ref, _) {
                  final isLoading = ref.watch(
                    eventsV2Provider.select((s) => s.isLoading),
                  );

                  if (isLoading) {
                    return const _ShimmerLoadingList();
                  }

                  return const _LeaguesListContent();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.only(left: 16, right: 12, top: 8, bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFFFF5172),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Đang diễn ra',
              style: AppTextStyles.labelMedium(
                color: AppColorStyles.contentPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaguesListContent extends ConsumerWidget {
  const _LeaguesListContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leagues = ref.watch(eventsV2Provider.select((s) => s.leagues));

    if (leagues.isEmpty) {
      return const SportEmptyPage();
    }

    final leaguesWithEvents = leagues
        .where((league) => league.events.isNotEmpty)
        .toList();

    if (leaguesWithEvents.isEmpty) {
      return const SportEmptyPage();
    }

    return Column(
      children: [
        for (final league in leaguesWithEvents)
          LeagueCardV2(league: league, isDesktop: true),
      ],
    );
  }
}

class _ShimmerLoadingList extends StatelessWidget {
  const _ShimmerLoadingList();

  static const _shimmerBaseColor = Color(0xFF2A2A2A);
  static const _shimmerHighlightColor = Color(0xFF3D3D3D);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < 2; i++) _buildShimmerLeagueCard(),
      ],
    );
  }

  Widget _buildShimmerLeagueCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0x0AFFF6E4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                _buildShimmerBox(width: 26, height: 26, borderRadius: 6),
                const SizedBox(width: 8),
                _buildShimmerBox(width: 120, height: 14, borderRadius: 4),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [for (int i = 0; i < 3; i++) _buildShimmerMatchRow()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerMatchRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerBox(width: 40, height: 12, borderRadius: 4),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildShimmerBox(width: 20, height: 20, borderRadius: 10),
                    const SizedBox(width: 8),
                    _buildShimmerBox(width: 80, height: 12, borderRadius: 4),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildShimmerBox(width: 20, height: 20, borderRadius: 10),
                    const SizedBox(width: 8),
                    _buildShimmerBox(width: 90, height: 12, borderRadius: 4),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                for (int i = 0; i < 6; i++) ...[
                  _buildShimmerBox(width: 50, height: 36, borderRadius: 6),
                  if (i < 5) const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBox({
    required double width,
    required double height,
    required double borderRadius,
  }) {
    return Shimmer(
      duration: const Duration(milliseconds: 1500),
      color: _shimmerHighlightColor,
      colorOpacity: 0.3,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: _shimmerBaseColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
