import 'dart:async';

import 'package:flutter/material.dart';

import '../overlay/adaptive_overlay_controller.dart';

class AdaptiveOverlayNavigator<T> extends InheritedWidget {
  AdaptiveOverlayNavigator({
    required this.controller,
    required super.child,
    GlobalKey<NavigatorState>? navigatorKey,
    super.key,
  }) : navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>();

  final AdaptiveOverlayController controller;

  final GlobalKey<NavigatorState> navigatorKey;

  bool get isVisible => controller.isVisible;

  String? get currentRouteName {
    String? name;
    navigatorKey.currentState?.popUntil((route) {
      name = route.settings.name;
      return true;
    });
    return name;
  }

  bool isCurrent(String routeName) => currentRouteName == routeName;

  void open() => controller.open();

  void close() => controller.close();

  void toggle() => controller.toggle();

  void pop<R>([R? result]) {
    navigatorKey.currentState?.pop<R>(result);
  }

  void _ensureOpen() {
    if (!controller.isVisible) {
      controller.open();
    }
  }

  Future<NavigatorState?> _prepareNavigator() async {
    if (!isVisible) {
      _ensureOpen();
    }

    final existingState = navigatorKey.currentState;
    if (existingState != null) return existingState;

    final completer = Completer<NavigatorState?>();

    void checkMount(Duration _) {
      final state = navigatorKey.currentState;
      if (state != null) {
        completer.complete(state);
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          completer.complete(navigatorKey.currentState);
        });
      }
    }

    WidgetsBinding.instance.addPostFrameCallback(checkMount);

    return completer.future;
  }

  Future<R?> push<R>(Widget page) async {
    final state = await _prepareNavigator();
    return state?.push<R>(MaterialPageRoute(builder: (_) => page));
  }

  Future<R?> pushNamed<R>(String routeName, {Object? arguments}) async {
    final state = await _prepareNavigator();
    return state?.pushNamed<R>(routeName, arguments: arguments);
  }

  Future<R?> pushReplacement<R, TO>(Widget page, {TO? result}) async {
    final state = await _prepareNavigator();
    return state?.pushReplacement<R, TO>(
      MaterialPageRoute(builder: (_) => page),
      result: result,
    );
  }

  Future<R?> pushReplacementNamed<R, TO>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) async {
    final state = await _prepareNavigator();
    return state?.pushReplacementNamed<R, TO>(
      routeName,
      result: result,
      arguments: arguments,
    );
  }

  Future<R?> pushAndRemoveUntil<R>(
    Widget page,
    RoutePredicate predicate,
  ) async {
    final state = await _prepareNavigator();
    return state?.pushAndRemoveUntil<R>(
      MaterialPageRoute(builder: (_) => page),
      predicate,
    );
  }

  Future<R?> pushNamedAndRemoveUntil<R>(
    String routeName,
    RoutePredicate predicate, {
    Object? arguments,
  }) async {
    final state = await _prepareNavigator();
    return state?.pushNamedAndRemoveUntil<R>(
      routeName,
      predicate,
      arguments: arguments,
    );
  }

  void popUntil(RoutePredicate predicate) {
    navigatorKey.currentState?.popUntil(predicate);
  }

  Future<bool> maybePop<R>([R? result]) async {
    return navigatorKey.currentState?.maybePop<R>(result) ??
        Future.value(false);
  }

  bool canPop() {
    return navigatorKey.currentState?.canPop() ?? false;
  }

  static AdaptiveOverlayNavigator<T> of<T>(BuildContext context) {
    final result = maybeOf<T>(context);
    assert(result != null, 'No AdaptiveOverlayNavigator<$T> found in context');
    return result!;
  }

  static AdaptiveOverlayNavigator<T>? maybeOf<T>(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AdaptiveOverlayNavigator<T>>();
  }

  @override
  bool updateShouldNotify(AdaptiveOverlayNavigator<T> oldWidget) {
    return controller != oldWidget.controller ||
        navigatorKey != oldWidget.navigatorKey;
  }
}

extension AdaptiveOverlayNavigatorContextX on BuildContext {
  AdaptiveOverlayController? get adaptiveOverlayController =>
      adaptiveOverlayNavigator?.controller;

  AdaptiveOverlayNavigator<dynamic>? get adaptiveOverlayNavigator =>
      AdaptiveOverlayNavigator.maybeOf<dynamic>(this);

  void open() => adaptiveOverlayController?.open();

  void close() => adaptiveOverlayController?.close();

  void toggle() => adaptiveOverlayController?.toggle();

  void pop<R>([R? result]) => adaptiveOverlayNavigator?.pop<R>(result);

  Future<R?> push<R>(Widget page) =>
      adaptiveOverlayNavigator?.push<R>(page) ?? Future.value(null);

  Future<R?> pushNamed<R>(String routeName, {Object? arguments}) =>
      adaptiveOverlayNavigator?.pushNamed<R>(routeName, arguments: arguments) ??
      Future.value(null);

  Future<R?> pushReplacement<R, TO>(Widget page, {TO? result}) =>
      adaptiveOverlayNavigator?.pushReplacement<R, TO>(page, result: result) ??
      Future.value(null);

  Future<R?> pushReplacementNamed<R, TO>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) =>
      adaptiveOverlayNavigator?.pushReplacementNamed<R, TO>(
        routeName,
        result: result,
        arguments: arguments,
      ) ??
      Future.value(null);

  Future<R?> pushAndRemoveUntil<R>(Widget page, RoutePredicate predicate) =>
      adaptiveOverlayNavigator?.pushAndRemoveUntil<R>(page, predicate) ??
      Future.value(null);

  Future<R?> pushNamedAndRemoveUntil<R>(
    String routeName,
    RoutePredicate predicate, {
    Object? arguments,
  }) =>
      adaptiveOverlayNavigator?.pushNamedAndRemoveUntil<R>(
        routeName,
        predicate,
        arguments: arguments,
      ) ??
      Future.value(null);

  void popUntil(RoutePredicate predicate) =>
      adaptiveOverlayNavigator?.popUntil(predicate);

  Future<bool> maybePop<R>([R? result]) =>
      adaptiveOverlayNavigator?.maybePop<R>(result) ?? Future.value(false);

  bool canPop() => adaptiveOverlayNavigator?.canPop() ?? false;

  String? get currentRouteName => adaptiveOverlayNavigator?.currentRouteName;

  bool isCurrent(String routeName) =>
      adaptiveOverlayNavigator?.isCurrent(routeName) ?? false;
}
