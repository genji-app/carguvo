import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';
import 'package:sun_sports/core/services/network/sb_http_manager.dart';
import 'package:sun_sports/providers/infra_provider.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/sport/presentation/providers/league_collapse_providers.dart';
import 'package:sun_sports/shared/widgets/empty_page/sport_empty_page.dart';
import 'package:sun_sports/shared/widgets/sport/collapse_all_toggle.dart';
import 'package:sun_sports/shared/widgets/sport/league/league_events_sliver_v2.dart';
import 'package:sun_sports/shared/widgets/sport/loading/sport_shimmer_loading.dart';

class PopularLeagueState {
  final List<LeagueModelV2> leagues;
  final bool isLoading;
  final String? error;

  final bool hasFetched;

  const PopularLeagueState({
    this.leagues = const [],
    this.isLoading = false,
    this.error,
    this.hasFetched = false,
  });

  PopularLeagueState copyWith({
    List<LeagueModelV2>? leagues,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool? hasFetched,
  }) {
    return PopularLeagueState(
      leagues: leagues ?? this.leagues,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      hasFetched: hasFetched ?? this.hasFetched,
    );
  }
}

class PopularLeagueNotifier extends StateNotifier<PopularLeagueState> {
  final SbHttpManager _httpManager;

  PopularLeagueNotifier(this._httpManager) : super(const PopularLeagueState());

  Future<void> fetchPopularLeagues() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final leagues = await _httpManager.getPopularLeagues();
      state = state.copyWith(
        leagues: leagues,
        isLoading: false,
        hasFetched: true,
      );
    } catch (e) {
      debugPrint('[PopularLeague] Error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        hasFetched: true,
      );
    }
  }
}

final popularLeagueProvider =
    StateNotifierProvider<PopularLeagueNotifier, PopularLeagueState>((ref) {
      final httpManager = ref.read(sbHttpManagerProvider);
      return PopularLeagueNotifier(httpManager);
    });

final _popularLeaguesSelector = popularLeagueProvider.select((s) => s.leagues);
final _popularLoadingSelector = popularLeagueProvider.select(
  (s) => s.isLoading,
);
final _popularHasFetchedSelector = popularLeagueProvider.select(
  (s) => s.hasFetched,
);

class SportDesktopPopularLeagueSection extends ConsumerStatefulWidget {
  const SportDesktopPopularLeagueSection({super.key});

  @override
  ConsumerState<SportDesktopPopularLeagueSection> createState() =>
      _SportDesktopPopularLeagueSectionState();
}

class _SportDesktopPopularLeagueSectionState
    extends ConsumerState<SportDesktopPopularLeagueSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(popularLeagueProvider.notifier).fetchPopularLeagues();
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
                final hasFetched = ref.watch(_popularHasFetchedSelector);
                if (isLoading || !hasFetched) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: SportShimmerLoading(isDesktop: true),
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
                  isDesktop: true,
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
          CollapseAllToggle(provider: popularLeagueCollapseAllProvider),
        ],
      ),
    );
  }
}
