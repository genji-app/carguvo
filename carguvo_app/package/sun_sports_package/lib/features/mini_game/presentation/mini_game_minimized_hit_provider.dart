import 'dart:ui' show Rect;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'widgets/mini_game_selection.dart';

class MiniGameMinimizedHit {
  final String id;
  final MiniGameSelection game;
  final Rect rect;

  final Object owner;

  const MiniGameMinimizedHit({
    required this.id,
    required this.game,
    required this.rect,
    required this.owner,
  });
}

final miniGameMinimizedHitsProvider =
    StateProvider<Map<String, MiniGameMinimizedHit>>((ref) => const {});

extension MiniGameMinimizedHitWidgetRef on WidgetRef {
  void setMiniGameMinimizedHit({
    required String id,
    required MiniGameSelection game,
    required Rect rect,
    required Object owner,
  }) {
    final n = read(miniGameMinimizedHitsProvider.notifier);
    final cur = n.state;
    final old = cur[id];
    if (old != null &&
        old.rect == rect &&
        old.game == game &&
        identical(old.owner, owner)) {
      return;
    }
    n.state = {
      ...cur,
      id: MiniGameMinimizedHit(id: id, game: game, rect: rect, owner: owner),
    };
  }

  void clearMiniGameMinimizedHit(String id, Object owner) {
    final n = read(miniGameMinimizedHitsProvider.notifier);
    clearMiniGameMinimizedHitOn(n, id, owner);
  }
}

void clearMiniGameMinimizedHitOn(
  StateController<Map<String, MiniGameMinimizedHit>> notifier,
  String id,
  Object owner,
) {
  if (!notifier.mounted) return;
  final cur = notifier.state;
  final old = cur[id];
  if (old == null || !identical(old.owner, owner)) return;
  notifier.state = {...cur}..remove(id);
}
