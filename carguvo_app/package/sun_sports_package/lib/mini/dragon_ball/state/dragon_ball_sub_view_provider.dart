import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/features/mini_game/data/dragon_ball_http_repository.dart';

enum DragonBallSubView { none, history, historyDetail, ranking, guide }

final dragonBallSubViewProvider = StateProvider.autoDispose<DragonBallSubView>(
  (ref) => DragonBallSubView.none,
);

final dragonBallHistoryDetailItemProvider =
    StateProvider.autoDispose<DragonBallHistoryItem?>((ref) => null);
