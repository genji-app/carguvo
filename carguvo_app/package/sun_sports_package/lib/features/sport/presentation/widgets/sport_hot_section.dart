import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/providers/main_content_provider.dart';
import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';
import 'package:sun_sports/features/sport/presentation/providers/league_provider.dart';
import 'package:sun_sports/features/bet_detail/presentation/providers/bet_detail_v2_provider.dart';
import 'package:sun_sports/features/home/domain/entities/hot_match_entity.dart';
import 'package:sun_sports/features/home/presentation/providers/hot_match_provider.dart';
import 'package:sun_sports/shared/widgets/hot_match/hot_match_container.dart';
import 'package:sun_sports/shared/widgets/hot_match/hot_match_shimmer_loading.dart';

class SportHotSection extends ConsumerStatefulWidget {
  final double height;
  final String? backgroundImage;
  final bool isRightSidebar;

  final bool compactCards;
  const SportHotSection({
    super.key,
    this.height = 152,
    this.backgroundImage,
    this.isRightSidebar = false,
    this.compactCards = false,
  });

  @override
  ConsumerState<SportHotSection> createState() => _SportHotSectionState();
}

class _SportHotSectionState extends ConsumerState<SportHotSection> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final sportId = ref.read(currentSportIdProvider);
      ref.read(hotMatchProvider.notifier).fetchHotMatches(sportId: sportId);
    });
  }

  void _onMatchTap(HotMatchEventV2 match) {
    ref.read(selectedEventV2Provider.notifier).state = match.event;
    ref.read(selectedLeagueV2Provider.notifier).state = LeagueModelV2(
      events: const [],
      sportId: match.event.sportId > 0
          ? match.event.sportId
          : ref.read(currentSportIdProvider),
      leagueId: match.leagueId,
      leagueName: match.leagueName,
      leagueNameEn: match.leagueName,
      leagueLogo: match.leagueLogo,
    );
    ref.read(mainContentProvider.notifier).goToBetDetail();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      hotMatchProvider.select((state) => state.isLoading),
    );
    final hasNoMatches = ref.watch(
      hotMatchProvider.select((state) => state.leagues.isEmpty),
    );

    if (isLoading && hasNoMatches) {
      return HotMatchShimmerLoading(
        isRightSidebar: widget.isRightSidebar,
        compactCards: widget.compactCards,
      );
    }

    return Consumer(
      builder: (context, ref, child) {
        final hotMatches = ref.watch(hotMatchesProvider);
        if (hotMatches.isEmpty) return const SizedBox.shrink();

        final displayMatch = hotMatches.first;
        final timeUntilMatch = _calculateTimeUntilMatch(displayMatch);

        return HotMatchContainer(
          match: displayMatch,
          matches: hotMatches,
          onTap: () => _onMatchTap(displayMatch),
          onMatchSelected: _onMatchTap,
          timeUntilMatch: timeUntilMatch,
          viewCount: null,
          bettingPercentage: null,
          favoredTeam: null,
          isRightSidebar: widget.isRightSidebar,
          showLeagueFilter: true,
          compactCards: widget.compactCards,
        );
      },
    );
  }

  String? _calculateTimeUntilMatch(HotMatchEventV2 match) {
    try {
      final dateTime = match.event.startDateTime;

      final now = DateTime.now();
      final difference = dateTime.difference(now);

      if (difference.isNegative) {
        return null;
      }

      if (difference.inDays > 0) {
        return '${difference.inDays} ngày';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} giờ';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} phút';
      } else {
        return 'Sắp diễn ra';
      }
    } catch (e) {
      return null;
    }
  }
}
