import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/spacing_styles.dart';
import 'package:sun_sports/features/search/data/models/search_league_item.dart';
import 'package:sun_sports/features/search/data/models/search_result_item.dart';
import 'package:sun_sports/features/search/presentation/providers/search_providers.dart';
import 'package:sun_sports/features/search/presentation/widgets/search_league_row.dart';
import 'package:sun_sports/features/search/presentation/widgets/search_result_row.dart';

class SearchResultList extends ConsumerWidget {
  const SearchResultList({
    super.key,
    required this.events,
    this.leagues = const [],
    this.query = '',
    this.padding,
    this.emptyMessage = 'Không tìm thấy kết quả',
    this.onSearchResultTap,
    this.onLeagueTap,
  });

  final List<SearchResultItem> events;

  final String query;

  final List<SearchLeagueItem> leagues;

  final EdgeInsetsGeometry? padding;

  final String emptyMessage;

  final void Function(SearchResultItem item)? onSearchResultTap;

  final void Function(SearchLeagueItem item)? onLeagueTap;

  static const EdgeInsets _defaultPadding = EdgeInsets.fromLTRB(
    AppSpacingStyles.space400,
    AppSpacingStyles.space200,
    AppSpacingStyles.space400,
    AppSpacingStyles.space400,
  );

  static const String _sectionLeagues = 'Giải đấu';
  static const String _sectionEvents = 'Trận đấu';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<Map<String, int>>>(
      searchLeagueEventCountsProvider(query),
      (_, __) {},
    );

    if (leagues.isEmpty && events.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: AppTextStyles.paragraphSmall(
            color: AppColorStyles.contentTertiary,
          ),
        ),
      );
    }

    final rows = <Object>[
      if (leagues.isNotEmpty) ...[
        _sectionLeagues,
        ...leagues,
        if (events.isNotEmpty) _sectionEvents,
      ],
      ...events,
    ];

    return ListView.builder(
      padding: padding ?? _defaultPadding,
      itemCount: rows.length,
      cacheExtent: 200,
      itemBuilder: (context, index) {
        final row = rows[index];
        if (row is String) {
          return _SectionHeader(title: row);
        }
        if (row is SearchLeagueItem) {
          return _LeagueRowWithCount(
            key: ValueKey<String>('league_${row.leagueId}'),
            item: row,
            query: query,
            onTap: onLeagueTap != null ? () => onLeagueTap!(row) : null,
          );
        }
        final item = row as SearchResultItem;
        return SearchResultRow(
          key: ValueKey<String>('event_${item.eventId}'),
          item: item,
          onTap: onSearchResultTap != null
              ? () => onSearchResultTap!(item)
              : null,
        );
      },
    );
  }
}

class _LeagueRowWithCount extends StatelessWidget {
  const _LeagueRowWithCount({
    required this.item,
    required this.query,
    this.onTap,
    super.key,
  });

  final SearchLeagueItem item;
  final String query;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return SearchLeagueRow(item: item, onTap: onTap);
    }
    return Consumer(
      builder: (context, ref, _) {
        final state = ref.watch(
          searchLeagueEventCountsProvider(query).select(
            (async) => (
              counting: async.isLoading,
              count: async.valueOrNull?[searchLeagueCountKey(
                item.sportId,
                item.leagueId,
              )],
            ),
          ),
        );
        return SearchLeagueRow(
          item: item,
          eventCount: state.count,
          isCounting: state.counting,
          onTap: onTap,
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: AppTextStyles.labelLarge(color: AppColorStyles.contentPrimary),
      ),
    );
  }
}
