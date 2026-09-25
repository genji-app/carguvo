import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/game/game.dart';
import 'package:sun_sports/providers/main_content_provider.dart';

extension GameNavigationX on WidgetRef {
  void goToCasino({GameCategorySelection? selection}) {
    read(mainContentProvider.notifier).goToCasino();
    if (selection != null) {
      read(gameCategorySelectionProvider.notifier).state = selection;
    }
  }
}
