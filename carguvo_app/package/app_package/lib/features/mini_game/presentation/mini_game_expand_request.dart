import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_package/features/mini_game/presentation/widgets/mini_game_selection.dart';

final miniGameExpandRequestProvider =
    StateProvider.family<int, MiniGameSelection>((ref, game) => 0);

final miniGameMinimizeRequestProvider =
    StateProvider.family<int, MiniGameSelection>((ref, game) => 0);
