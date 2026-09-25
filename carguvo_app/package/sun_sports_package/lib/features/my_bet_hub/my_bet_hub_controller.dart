import 'package:adaptive_overlay/adaptive_overlay.dart';
import 'package:flutter/material.dart';
import 'package:sun_sports/features/betting/my_bet/my_bet_menu.dart';

class MyBetHubController extends AdaptiveOverlayController {
  MyBetHubController();

  final navigatorKey = GlobalKey<NavigatorState>();

  MyBetMenu _selectedMenu = MyBetMenu.bettingSlip;

  MyBetMenu get selectedMenu => _selectedMenu;

  MyBetMenu get initialMenu => _selectedMenu;

  @override
  void open({MyBetMenu initialMenu = MyBetMenu.bettingSlip}) {
    _selectedMenu = initialMenu;
    super.open();
  }

  @override
  void toggle({MyBetMenu initialMenu = MyBetMenu.bettingSlip}) {
    _selectedMenu = initialMenu;
    super.toggle();
  }

  void changeMenu(MyBetMenu menu) {
    if (_selectedMenu != menu) {
      _selectedMenu = menu;
      notifyListeners();
    }
  }

  void push(String routeName, {Object? arguments}) {
    navigatorKey.currentState?.pushNamed(routeName, arguments: arguments);
  }

  void pushReplacement(String routeName, {Object? arguments}) {
    navigatorKey.currentState?.pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  }

  void pop() {
    navigatorKey.currentState?.pop();
  }

  void resetNavigation() {
    navigatorKey.currentState?.popUntil((route) => route.isFirst);
  }
}
