import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_package/features/game/game.dart';
import 'package:app_package/providers/main_content_provider.dart';

extension GameNavigationX on WidgetRef {
  void goToCasino({GameCategorySelection? selection}) {
    read(mainContentProvider.notifier).goToCasino();
    if (selection != null) {
      read(gameCategorySelectionProvider.notifier).state = selection;
    }
  }
}
