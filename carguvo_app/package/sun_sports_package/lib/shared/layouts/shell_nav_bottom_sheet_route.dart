import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/providers/scroll_hide_provider.dart';
import 'package:sun_sports/core/services/config/sb_config.dart';
import 'package:sun_sports/core/utils/extensions/enums/bottom_navigation_item.dart';
import 'package:sun_sports/core/utils/keyboard_visibility.dart';
import 'package:sun_sports/core/utils/platform_utils.dart';
import 'package:sun_sports/features/betting/my_bet/my_bet_menu.dart';
import 'package:sun_sports/features/my_bet_hub/my_bet_hub.dart';
import 'package:sun_sports/features/mini_game/presentation/mini_game_floating_overlay.dart'
    show miniGameMenuOpenProvider, toggleMiniGameLobbyFromNav;
import 'package:sun_sports/features/sport/presentation/tablet/widgets/sport_tablet_bottom_navigation.dart';
import 'package:sun_sports/providers/main_content_provider.dart';
import 'package:sun_sports/shared/layouts/shell_bottom_block.dart';
import 'package:sun_sports/shared/layouts/shell_bottom_navigation.dart';
import 'package:sun_sports/shared/utils/auth_gate.dart';
import 'package:sun_sports/shared/widgets/maintenance/sb_maintenance_view.dart';
import 'package:url_launcher/url_launcher.dart';

class ShellNavBottomSheetRoute<T> extends ModalBottomSheetRoute<T> {
  ShellNavBottomSheetRoute({
    required super.builder,
    required super.isScrollControlled,
    super.capturedThemes,
    super.barrierLabel,
    super.barrierOnTapHint,
    super.backgroundColor,
    super.modalBarrierColor,
    super.isDismissible,
    super.enableDrag,
    super.settings,
  });

  static double navBottomInset(BuildContext context) =>
      PlatformUtils.isAndroid ? MediaQuery.paddingOf(context).bottom : 0.0;

  static double navClearance(BuildContext context) {
    if (!ShellBottomMetrics.hasBottomNav(context)) return 0.0;
    if (MediaQuery.viewInsetsOf(context).bottom > 0 ||
        isKeyboardVisible(context)) {
      return 0.0;
    }
    return ShellBottomMetrics.navTopFromCanvasBottom.value;
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final sheet = super.buildPage(context, animation, secondaryAnimation);
    if (!ShellBottomMetrics.hasBottomNav(context)) return sheet;
    return Stack(
      fit: StackFit.expand,
      children: [
        sheet,
        Positioned(
          left: 0,
          right: 0,
          bottom: navBottomInset(context),
          child: const _ShellNavOverSheet(),
        ),
      ],
    );
  }
}

class _ShellNavOverSheet extends ConsumerWidget {
  const _ShellNavOverSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hubVisible = ref.watch(
      myBetHubControllerProvider.select((c) => c.isVisible),
    );
    final selectedIndex = hubVisible
        ? BottomNavigationItem.all.indexOf(BottomNavigationItem.bettingTickets)
        : ShellBottomNavigation.selectedIndexFor(ref.watch(mainContentProvider));
    return HideOnKeyboard(
      child: SportTabletBottomNavigation(
        selectedIndex: selectedIndex,
        isMobile: true,
        isOverlayCopy: true,
        onItemSelected: (index) =>
            _handleItemSelected(context, ref, index, selectedIndex),
      ),
    );
  }

  void _handleItemSelected(
    BuildContext context,
    WidgetRef ref,
    int index,
    int selectedIndex,
  ) {
    final route = ModalRoute.of(context);
    if (route == null || !route.isCurrent) return;

    final item = BottomNavigationItem.all[index];

    if (item == BottomNavigationItem.sun247) {
      launchUrl(
        Uri.parse(SbConfig.livechatUrl),
        mode: LaunchMode.externalApplication,
      );
      return;
    }
    if (item == BottomNavigationItem.menu) return;

    if (item == BottomNavigationItem.miniGames) {
      if (!ref.read(miniGameMenuOpenProvider) && !requireLogin(context, ref)) {
        return;
      }
      toggleMiniGameLobbyFromNav(ref);
      return;
    }

    if (item == BottomNavigationItem.bettingTickets &&
        blockedBySbMaintenance(context, ref)) {
      return;
    }

    final container = ProviderScope.containerOf(context, listen: false);
    final scrollHide = container.read(scrollHideProvider);
    final navigator = Navigator.of(context);

    scrollHide.show();
    scrollHide.pauseDetection();
    navigator.pop();

    switch (item) {
      case BottomNavigationItem.home:
      case BottomNavigationItem.casino:
      case BottomNavigationItem.sports:
        final hub = container.read(myBetHubControllerProvider);
        if (hub.isVisible) hub.close();
        if (index == selectedIndex) return;
        final notifier = container.read(mainContentProvider.notifier);
        switch (item) {
          case BottomNavigationItem.home:
            notifier.goToHome();
          case BottomNavigationItem.casino:
            notifier.goToCasino();
          default:
            notifier.goToSport();
        }
      case BottomNavigationItem.bettingTickets:
        final hub = container.read(myBetHubControllerProvider);
        if (hub.isVisible) return;
        route.completed.then((_) {
          container
              .read(myBetHubControllerProvider)
              .open(initialMenu: MyBetMenu.bettingSlip);
        });
      case BottomNavigationItem.sun247:
      case BottomNavigationItem.menu:
      case BottomNavigationItem.miniGames:
        break;
    }
  }
}
