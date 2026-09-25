import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/services/storage/quick_guide_settings.dart';
import 'package:sun_sports/features/betting/my_bet/my_bet_menu.dart';
import 'package:sun_sports/features/mini_game/presentation/mini_game_visibility_provider.dart';
import 'package:sun_sports/features/my_bet_hub/my_bet_hub.dart';
import 'package:sun_sports/providers/main_content_provider.dart';

import 'spotlight_core.dart';

class ShellSpotlightNavigator implements SpotlightNavigator {
  ShellSpotlightNavigator(this._ref);

  final Ref _ref;

  Future<void> _settle([int ms = 350]) =>
      Future<void>.delayed(Duration(milliseconds: ms));

  @override
  Future<void> prepareTour() async {
    _ref.read(miniGameVisibilityProvider.notifier).hide();
  }

  @override
  Future<void> goHome() async {
    _ref.read(myBetHubControllerProvider).close();
    _ref.read(mainContentProvider.notifier).goToHome();
    await _settle();
  }

  @override
  Future<void> openSampleMatchWithBetSlip() async {
    final controller = _ref.read(myBetHubControllerProvider);
    if (!controller.isVisible) {
      controller.open(initialMenu: MyBetMenu.bettingSlip);
    } else {
      controller.changeMenu(MyBetMenu.bettingSlip);
    }
    await _settle();
  }

  @override
  Future<void> showMyBets() async {
    final controller = _ref.read(myBetHubControllerProvider);
    if (!controller.isVisible) {
      controller.open(initialMenu: MyBetMenu.myBets);
    } else {
      controller.changeMenu(MyBetMenu.myBets);
    }
    await _settle();
  }

  @override
  Future<void> closeBetSlip() async {
    final controller = _ref.read(myBetHubControllerProvider);
    if (controller.isVisible) {
      controller.close();
      await _settle();
    }
  }

  @override
  Future<void> restoreAfterTour() async {
    _ref.read(myBetHubControllerProvider).close();
    _ref.read(miniGameVisibilityProvider.notifier).show();
    QuickGuideSettings.instance.setEnabled(false);
  }
}
