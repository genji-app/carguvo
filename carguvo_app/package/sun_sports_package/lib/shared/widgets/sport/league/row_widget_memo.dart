import 'package:flutter/widgets.dart';
import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';

class WidgetMemo<K> {
  final Map<K, (Object inputs, Widget widget)> _entries = {};

  Widget reuse(K key, Object inputs, Widget Function() build) {
    final entry = _entries[key];
    if (entry != null && entry.$1 == inputs) return entry.$2;
    final widget = build();
    _entries[key] = (inputs, widget);
    return widget;
  }

  void retainOnly(Iterable<K> keys) {
    final keep = keys is Set<K> ? keys : keys.toSet();
    _entries.removeWhere((k, _) => !keep.contains(k));
  }

  void clear() => _entries.clear();

  @visibleForTesting
  int get length => _entries.length;
}

typedef LeagueRowMeta = (int, int, String, String, String, int, int?, bool);

LeagueRowMeta leagueRowMetaOf(LeagueModelV2 league) => (
      league.leagueId,
      league.sportId,
      league.leagueName,
      league.leagueNameEn,
      league.leagueLogo,
      league.priorityOrder,
      league.leagueOrder,
      league.isFavorited,
    );

typedef LeagueHeaderMeta = (LeagueRowMeta, int);

LeagueHeaderMeta leagueHeaderMetaOf(LeagueModelV2 league) =>
    (leagueRowMetaOf(league), league.events.length);
