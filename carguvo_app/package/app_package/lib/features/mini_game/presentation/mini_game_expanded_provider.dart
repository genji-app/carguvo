import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'widgets/mini_game_selection.dart';

final miniGameExpandedProvider =
    StateProvider<Set<MiniGameSelection>>((ref) => const {});

extension MiniGameExpandedRef on Ref {
  void setMiniGameExpanded(MiniGameSelection game, {required bool expanded}) {
    final n = read(miniGameExpandedProvider.notifier);
    final cur = n.state;
    if (expanded) {
      if (!cur.contains(game)) n.state = {...cur, game};
    } else {
      if (cur.contains(game)) n.state = {...cur}..remove(game);
    }
  }
}

extension MiniGameExpandedWidgetRef on WidgetRef {
  void setMiniGameExpanded(MiniGameSelection game, {required bool expanded}) {
    final n = read(miniGameExpandedProvider.notifier);
    final cur = n.state;
    if (expanded) {
      if (!cur.contains(game)) n.state = {...cur, game};
    } else {
      if (cur.contains(game)) n.state = {...cur}..remove(game);
    }
  }
}
