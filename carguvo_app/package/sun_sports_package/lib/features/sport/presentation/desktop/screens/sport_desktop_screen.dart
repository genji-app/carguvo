import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/providers/main_content_provider.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/features/sport/presentation/desktop/widgets/sport_desktop_live_matches_section.dart';
import 'package:sun_sports/features/sport/presentation/desktop/widgets/sport_desktop_popular_league_section.dart';
import 'package:sun_sports/features/sport/presentation/providers/match_filter_tab_provider.dart';
import 'package:sun_sports/features/sport/presentation/widgets/sport_list_event_container.dart'
    show MatchFilterType;
import 'package:sun_sports/core/utils/styles/spacing_styles.dart';
import 'package:sun_sports/shared/widgets/back_to_top_overlay.dart';
import 'package:sun_sports/shared/widgets/rive_vibrating/rive_vibrating.dart';

class SportDesktopScreen extends ConsumerStatefulWidget {
  const SportDesktopScreen({super.key});

  @override
  ConsumerState<SportDesktopScreen> createState() => _SportDesktopScreenState();
}

class _SportDesktopScreenState extends ConsumerState<SportDesktopScreen> {
  double _cacheExtent = 0;

  bool _popularReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _cacheExtent = 3000;
          _popularReady = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.read(riveVibratingInitProvider);

    final selectedFilter = ref.watch(matchFilterSelectedProvider);
    final showUpcomingFavorites =
        selectedFilter == MatchFilterType.upcoming ||
        selectedFilter == MatchFilterType.favorites;

    return Container(
      color: AppColorStyles.backgroundSecondary,
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingStyles.space800,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1140, minWidth: 860),
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: BackToTopWrapper(
            builder: (scrollController) => CustomScrollView(
              controller: scrollController,
              cacheExtent: _cacheExtent,
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                const SliverToBoxAdapter(
                  child: SportDesktopLiveMatchesSection(),
                ),
                if (!showUpcomingFavorites && _popularReady) ...[
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  const SportDesktopPopularLeagueSection(),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
