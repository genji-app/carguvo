import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/providers/main_content_provider.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/sport/presentation/providers/league_provider.dart';
import 'package:sun_sports/features/bet_detail/presentation/providers/bet_detail_v2_provider.dart';
import 'package:sun_sports/features/home/domain/entities/hot_match_entity.dart';
import 'package:sun_sports/features/home/presentation/providers/hot_match_provider.dart';
import 'package:sun_sports/features/sport/presentation/desktop/widgets/match_filter_tabs.dart';
import 'package:sun_sports/features/sport/presentation/providers/match_filter_tab_provider.dart';
import 'package:sun_sports/features/sport/presentation/widgets/sport_list_event_container.dart';
import 'package:sun_sports/features/sport/presentation/providers/events_v2_provider.dart';
import 'package:sun_sports/shared/widgets/hot_match/hot_match_container.dart';
import 'package:sun_sports/shared/widgets/hot_match/hot_match_shimmer_loading.dart';
import 'package:sun_sports/shared/widgets/sport/sport_widgets.dart';
import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/sport_constants.dart'
    as v2;
import 'package:sun_sports/features/sport/presentation/providers/events_v2_filter_provider.dart';
import 'package:sun_sports/shared/widgets/empty_page/sport_empty_page.dart';
import 'package:sun_sports/shared/widgets/sport/league/league_card_v2.dart';
import 'package:sun_sports/shared/widgets/sport/loading/sport_shimmer_loading.dart';
import 'package:sun_sports/features/sport/presentation/desktop/widgets/sport_desktop_type_filter_tabs.dart';
import 'package:sun_sports/features/sport/presentation/providers/league_collapse_providers.dart';
import 'package:sun_sports/shared/widgets/sport/collapse_all_toggle.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/features/sport/data/adapters/sport_socket_adapter_provider.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

final _hotMatchesSelector = hotMatchesProvider;
final _hotMatchLoadingSelector = hotMatchProvider.select((s) => s.isLoading);
final _currentSportIdSelector = currentSportIdProvider;

class SportDesktopLiveMatchesSection extends ConsumerStatefulWidget {
  const SportDesktopLiveMatchesSection({super.key});

  @override
  ConsumerState<SportDesktopLiveMatchesSection> createState() =>
      _SportDesktopLiveMatchesSectionState();
}

class _SportDesktopLiveMatchesSectionState
    extends ConsumerState<SportDesktopLiveMatchesSection> {

  bool _hotMatchRefreshing = true;

  bool _contentReady = false;

  @override
  void initState() {
    super.initState();
    final hasData = ref.read(_hotMatchesSelector).isNotEmpty;
    _hotMatchRefreshing = !hasData;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      setState(() => _contentReady = true);

      if (ref.read(matchFilterSelectedProvider) == MatchFilterType.live &&
          ref.read(selectedTimeRangeV2Provider) != v2.EventTimeRange.live) {
        ref.read(selectedTimeRangeV2Provider.notifier).state =
            v2.EventTimeRange.live;
        ref
            .read(sportSocketAdapterProvider)
            .subscriptionManager
            .setTimeRangeFromString('LIVE');
      }

      if (hasData) return;

      final sportId = ref.read(_currentSportIdSelector);
      try {
        await ref
            .read(hotMatchProvider.notifier)
            .fetchHotMatches(sportId: sportId);
      } finally {
        if (mounted && _hotMatchRefreshing) {
          setState(() => _hotMatchRefreshing = false);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedFilter = ref.watch(matchFilterSelectedProvider);
    final showUpcomingFavorites =
        selectedFilter == MatchFilterType.upcoming ||
        selectedFilter == MatchFilterType.favorites;

    ref.listen(isCurrentMatchFilterDataLoadingProvider, (prev, next) {
      if (prev == true && next == false) {
        ref.read(matchFilterProvider.notifier).clearContentLoading();
      }
    });

    ref.listen(_hotMatchLoadingSelector, (prev, next) {
      if (prev == true && next == false && _hotMatchRefreshing && mounted) {
        setState(() => _hotMatchRefreshing = false);
      }
    });

    final hotMatches = ref.watch(_hotMatchesSelector);
    final showHotMatchShimmer = _hotMatchRefreshing;

    final currentMatch = hotMatches.isNotEmpty ? hotMatches.first : null;

    void onMatchTap(HotMatchEventV2 match) {
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

    return Container(
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const MatchFilterTabs(),
          if (!showUpcomingFavorites) ...[
            if (!showHotMatchShimmer && hotMatches.isNotEmpty)
              RepaintBoundary(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 12,
                  ),
                  child: HotMatchContainer(
                    match: currentMatch!,
                    matches: hotMatches,
                    onTap: () => onMatchTap(currentMatch),
                    onMatchSelected: onMatchTap,
                    favoredTeam: currentMatch.awayName,
                    isRightSidebar: false,
                    showLeagueFilter: true,
                  ),
                ),
              )
            else if (showHotMatchShimmer)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                child: HotMatchShimmerLoading(isRightSidebar: false),
              ),
            const SportDesktopTypeFilterTabs(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: _buildLiveContent(ref),
            ),
          ],
          if (showUpcomingFavorites)
            SportListEventContainer(
              filter: selectedFilter,
              maxHeight: MediaQuery.sizeOf(context).height,
              isDesktop: true,
            ),
        ],
      ),
    );
  }

  static const int _maxLiveEvents = 5;

  Widget _buildLiveContent(WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1A19),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1FFFFFFF),
            offset: Offset(0, 0.5),
            blurRadius: 0.5,
            spreadRadius: 0,
            blurStyle: BlurStyle.inner,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLiveHeader(),
          _buildSportFilterTabs(),
          Consumer(
            builder: (context, ref, _) {
              if (!_contentReady) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: SportShimmerLoading(isDesktop: true),
                  ),
                );
              }

              final isLoading = ref.watch(
                eventsV2Provider.select((s) => s.isLoading),
              );

              if (isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: SportShimmerLoading(isDesktop: true),
                  ),
                );
              }

              final leagues = ref.watch(leaguesV2Provider);
              final nonEmpty = leagues
                  .where((l) => l.events.isNotEmpty)
                  .toList();

              if (nonEmpty.isEmpty) return const SportEmptyPage();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._buildLeagueWidgets(nonEmpty),
                  _buildViewAllButton(ref),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildViewAllButton(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: InkWell(
        onTap: SoundTap.wrap(() {
          ref.read(previousContentProvider.notifier).state =
              MainContentType.sport;
          ref.read(selectedSportV2Provider.notifier).state = ref.read(
            selectedSportV2Provider,
          );
          ref.read(mainContentProvider.notifier).goToSportDetail();
        }),
        child: Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF393836),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Xem tất cả',
                style: AppTextStyles.textStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFFFFEF5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildLeagueWidgets(List<LeagueModelV2> leagues) {
    final result = <Widget>[];
    var remaining = _maxLiveEvents;

    for (final league in leagues) {
      if (remaining <= 0) break;

      final events = league.events;
      if (events.isEmpty) continue;

      final displayLeague = events.length <= remaining
          ? league
          : league.copyWith(events: events.sublist(0, remaining));

      result.add(
        LeagueCardV2(
          league: displayLeague,
          isDesktop: true,
          collapseAllProvider: sportLiveMatchesCollapseAllProvider,
          enableVisibleLeagueSub: true,
          subTimeRanges: {v2.EventTimeRange.live.value},
        ),
      );
      remaining -= displayLeague.events.length;
    }

    return result;
  }

  Widget _buildSportFilterTabs() {
    final sports = sportDesktopTypeFilterItems;
    final selectedSportId = ref.watch(
      selectedSportV2Provider.select((s) => s.id),
    );

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF252423), width: 0.5),
        ),
      ),
      child: Row(
        children: sports.map((sport) {
          final isSelected = sport.sportId == selectedSportId;
          return Expanded(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: SoundTap.wrap(() => _onSportFilterTap(sport)),
                behavior: HitTestBehavior.opaque,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ImageHelper.load(
                            path: isSelected
                                ? sport.iconSelected
                                : sport.iconDisabled,
                            width: 20,
                            height: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            sport.name,
                            style: AppTextStyles.paragraphXSmall(
                              color: isSelected
                                  ? AppColors.yellow300
                                  : const Color(0xFF9C9B95),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Positioned(
                        bottom: 0,
                        left: -20,
                        right: -20,
                        child: ImageHelper.load(
                          path: AppIcons.sportStatusSelected,
                          fit: BoxFit.fill,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _onSportFilterTap(SportDesktopTypeFilterItem sport) {
    final sportType = v2.SportType.fromId(sport.sportId) ?? v2.SportType.soccer;
    ref.read(selectedSportV2Provider.notifier).state = sportType;
    ref
        .read(sportSocketAdapterProvider)
        .subscriptionManager
        .setActiveSport(sport.sportId);
  }

  Widget _buildLiveHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 0,
      ).copyWith(top: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1A19),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
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
      child: Row(
        children: [
          _buildLiveIcon(),
          const SizedBox(width: 6),
          Text(
            'Đang diễn ra',
            style: AppTextStyles.textStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFFFFEF5),
            ),
          ),
          const Spacer(),
          CollapseAllToggle(provider: sportLiveMatchesCollapseAllProvider),
        ],
      ),
    );
  }

  Widget _buildLiveIcon() {
    return const SizedBox(
      width: 20,
      height: 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0x1FF04438),
              shape: BoxShape.circle,
            ),
            child: SizedBox(width: 16, height: 16),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0x1FF04438),
              shape: BoxShape.circle,
            ),
            child: SizedBox(width: 11, height: 11),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFFF04438),
              shape: BoxShape.circle,
            ),
            child: SizedBox(width: 6, height: 6),
          ),
        ],
      ),
    );
  }
}
