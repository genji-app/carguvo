import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/error/app_error_messages.dart';
import 'package:sun_sports/core/services/maintenance/sb_maintenance_provider.dart';
import 'package:sun_sports/providers/main_content_provider.dart';
import 'package:sun_sports/core/services/models/api_v2/sport_constants.dart';
import 'package:sun_sports/core/services/network/sb_http_manager.dart';
import 'package:provider_game_manager/provider_game_manager.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/spacing_styles.dart';
import 'package:sun_sports/features/game/game.dart';
import 'package:sun_sports/features/bet_detail/presentation/providers/bet_detail_v2_provider.dart';
import 'package:sun_sports/features/search/data/models/search_league_item.dart';
import 'package:sun_sports/features/search/data/models/search_result_item.dart';
import 'package:sun_sports/features/search/data/storage/casino_recent_games_storage.dart';
import 'package:sun_sports/features/search/data/storage/search_recent_storage.dart';
import 'package:sun_sports/features/search/presentation/providers/search_providers.dart';
import 'package:sun_sports/features/search/presentation/widgets/search_casino_empty_content.dart';
import 'package:sun_sports/features/sport/presentation/providers/events_v2_filter_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/league_detail_provider.dart';
import 'package:sun_sports/features/search/presentation/widgets/search_casino_results.dart';
import 'package:sun_sports/features/search/presentation/widgets/search_sport_empty_content.dart';
import 'package:sun_sports/features/search/presentation/widgets/search_sport_results.dart';
import 'package:sun_sports/shared/widgets/maintenance/sb_maintenance_view.dart';

class SearchBody extends ConsumerWidget {
  const SearchBody({
    super.key,
    required this.query,
    required this.isSport,
    this.onRecentKeywordTap,
    this.onCasinoGameTap,
    this.emptyMessageSport = 'Nhập từ khóa để tìm kiếm trận đấu, đội bóng.',
    this.emptyMessageCasino = 'Nhập từ khóa để tìm kiếm game casino.',
    this.emptyResultMessage = 'Không tìm thấy kết quả',
  });

  final String query;

  final bool isSport;
  final ValueChanged<String>? onRecentKeywordTap;

  final void Function(LobbyGame game)? onCasinoGameTap;

  final String emptyMessageSport;
  final String emptyMessageCasino;

  final String emptyResultMessage;

  void _saveRecentKeyword(WidgetRef ref) {
    if (!isSport) return;
    final keyword = ref.read(searchDebouncedQueryProvider).trim();
    if (keyword.isEmpty) return;
    SearchRecentStorage.addRecentSport(keyword);
    ref.invalidate(searchRecentSportProvider);
  }

  void _onSearchResultTap(
    BuildContext context,
    WidgetRef ref,
    SearchResultItem item,
  ) {
    _saveRecentKeyword(ref);
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sport = SportType.fromId(item.sportId) ?? SportType.soccer;
      SbHttpManager.instance.sportTypeId = sport.id;
      ref.read(selectedSportV2Provider.notifier).state = sport;
      ref.read(selectedEventV2Provider.notifier).state = item.toEventModelV2();
      ref.read(selectedLeagueV2Provider.notifier).state = item.toLeagueModelV2();
      ref.read(mainContentProvider.notifier).goToBetDetail();
    });
  }

  void _onLeagueTap(BuildContext context, WidgetRef ref, SearchLeagueItem item) {
    _saveRecentKeyword(ref);
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedLeagueInfoProvider.notifier).state = SelectedLeagueInfo(
        sportId: item.sportId > 0 ? item.sportId : SportType.soccer.id,
        leagueId: item.leagueId,
        leagueName: item.leagueName,
        leagueLogo: item.leagueLogoUrl,
      );
      ref.read(mainContentProvider.notifier).goToLeagueDetail();
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queryTrimmed = query.trim();

    if (isSport && ref.watch(sbMaintenanceProvider)) {
      return const Expanded(child: SbMaintenanceInline());
    }

    if (queryTrimmed.isEmpty) {
      if (!isSport) {
        final recentBlocks = ref.watch(casinoRecentGameBlocksProvider);
        final popularBlocks = ref.watch(casinoPopularGamesProvider);
        final catalogReady = ref.watch(lobbyConfigReadyProvider);

        return Expanded(
          child: ScrollConfiguration(
            behavior:
                ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: catalogReady.when(
              data: (_) => SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacingStyles.space400),
                child: SearchCasinoEmptyContent(
                  recentBlocks: recentBlocks,
                  popularBlocks: popularBlocks,
                  onGameTap: (game) {
                    CasinoRecentGamesStorage.addGame(
                      game.providerId,
                      game.productId,
                      game.gameCode,
                    ).then((_) => ref.invalidate(casinoRecentKeysProvider));
                    onCasinoGameTap?.call(game);
                  },
                ),
              ),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacingStyles.space600),
                child: CircularProgressIndicator(
                  color: AppColorStyles.contentPrimary,
                ),
              ),
            ),
            error: (err, _) => Center(
              child: Text(
                localizedOrGenericError('SearchCasinoGames', err.toString()),
                style: AppTextStyles.paragraphSmall(
                  color: AppColorStyles.contentTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          ),
        );
      }

      return Expanded(
        child: ScrollConfiguration(
          behavior:
              ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SearchSportEmptyContent(
            onRecentKeywordTap: onRecentKeywordTap ?? (_) {},
            onSearchResultTap: (item) => _onSearchResultTap(context, ref, item),
          ),
        ),
      );
    }

    final debouncedQuery = ref.watch(searchDebouncedQueryProvider);

    if (debouncedQuery.isEmpty) {
      return Expanded(
        child: ScrollConfiguration(
          behavior:
              ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacingStyles.space600),
              child: CircularProgressIndicator(
                color: AppColorStyles.contentPrimary,
              ),
            ),
          ),
        ),
      );
    }

    if (!isSport) {
      final catalogReady = ref.watch(lobbyConfigReadyProvider);
      final casinoResults = ref.watch(casinoSearchResultsProvider);

      return Expanded(
        child: ScrollConfiguration(
          behavior:
              ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: catalogReady.when(
            data: (_) => SearchCasinoResults(
              games: casinoResults,
              onGameTap: onCasinoGameTap,
              emptyMessage: emptyResultMessage,
            ),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacingStyles.space600),
                child: CircularProgressIndicator(
                  color: AppColorStyles.contentPrimary,
                ),
              ),
            ),
            error: (err, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacingStyles.space400),
                child: Text(
                  localizedOrGenericError('SearchCasinoResults', err.toString()),
                  style: AppTextStyles.paragraphSmall(
                    color: AppColorStyles.contentTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      );
    }

    final asyncResult = ref.watch(searchResultProvider(debouncedQuery));
    return Expanded(
      child: ScrollConfiguration(
        behavior:
            ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: asyncResult.when(
          data: (model) => SearchSportResults(
            leagues: model.leagues,
            events: model.events,
            query: debouncedQuery,
            emptyMessage: emptyResultMessage,
            onSearchResultTap: (item) =>
                _onSearchResultTap(context, ref, item),
            onLeagueTap: (item) => _onLeagueTap(context, ref, item),
          ),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacingStyles.space600),
              child: CircularProgressIndicator(
                color: AppColorStyles.contentPrimary,
              ),
            ),
          ),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacingStyles.space400),
              child: Text(
                localizedOrGenericError('SearchSportResults', err.toString()),
                style: AppTextStyles.paragraphSmall(
                  color: AppColorStyles.contentTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
