import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../overlay/adaptive_overlay.dart';
import '../overlay/adaptive_overlay_controller.dart';
import 'adaptive_overlay_navigator.dart';

class AdaptiveOverlayNavigation<T> extends StatefulWidget {
  const AdaptiveOverlayNavigation({
    this.child,
    this.controller,
    this.navigatorKey,
    this.navigator,
    this.overlayBuilder,
    this.overlayConstraints = const BoxConstraints.tightFor(width: 430),
    this.overlayAlignment = Alignment.centerRight,
    this.sheetBreakpoint = 733.0,
    this.sheetBottomPassThrough,
    this.sheetBottomPassThroughSuspended,
    this.pages = const <Page<dynamic>>[],
    this.initialRoute,
    this.onGenerateInitialRoutes = Navigator.defaultGenerateInitialRoutes,
    this.onGenerateRoute,
    this.onUnknownRoute,
    this.transitionDelegate = const DefaultTransitionDelegate<dynamic>(),
    this.reportsRouteUpdateToEngine = false,
    this.clipBehavior = Clip.hardEdge,
    this.observers = const <NavigatorObserver>[],
    this.requestFocus = true,
    this.restorationScopeId,
    this.routeTraversalEdgeBehavior = kDefaultRouteTraversalEdgeBehavior,
    this.routeDirectionalTraversalEdgeBehavior =
        kDefaultRouteDirectionalTraversalEdgeBehavior,
    this.onDidRemovePage,
    super.key,
  });

  final Widget? child;

  final AdaptiveOverlayController? controller;

  final GlobalKey<NavigatorState>? navigatorKey;

  final AdaptiveOverlayNavigator<T>? navigator;

  final BoxConstraints overlayConstraints;

  final Alignment overlayAlignment;

  final Widget Function(BuildContext context, Widget materialApp)?
  overlayBuilder;

  final double sheetBreakpoint;

  final ValueListenable<double>? sheetBottomPassThrough;

  final bool Function(BuildContext context)? sheetBottomPassThroughSuspended;

  final List<Page<dynamic>> pages;

  final String? initialRoute;

  final List<Route<dynamic>> Function(NavigatorState, String)
  onGenerateInitialRoutes;

  final RouteFactory? onGenerateRoute;

  final RouteFactory? onUnknownRoute;

  final TransitionDelegate<dynamic> transitionDelegate;

  final bool reportsRouteUpdateToEngine;

  final Clip clipBehavior;

  final List<NavigatorObserver> observers;

  final bool requestFocus;

  final String? restorationScopeId;

  final TraversalEdgeBehavior routeTraversalEdgeBehavior;

  final TraversalEdgeBehavior routeDirectionalTraversalEdgeBehavior;

  final void Function(Page<Object?>)? onDidRemovePage;

  @override
  State<AdaptiveOverlayNavigation<T>> createState() =>
      _AdaptiveOverlayNavigationState<T>();
}

class _AdaptiveOverlayNavigationState<T>
    extends State<AdaptiveOverlayNavigation<T>> {
  AdaptiveOverlayController? _controller;
  GlobalKey<NavigatorState>? _navigatorKey;
  ThemeData? _cachedTheme;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.navigator != null) {
      _controller = widget.navigator!.controller;
      _navigatorKey = widget.navigator!.navigatorKey;
    } else {
      _controller = widget.controller ?? AdaptiveOverlay.of(context);
      _navigatorKey = widget.navigatorKey;
    }
  }

  Widget _buildNavigatorContent() {
    final parentTheme = Theme.of(context);
    _cachedTheme ??= parentTheme;

    final customTheme = _cachedTheme!.copyWith(
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          for (final platform in TargetPlatform.values)
            platform: const CupertinoPageTransitionsBuilder(),
        },
      ),
    );

    return RepaintBoundary(
      child: Theme(
        data: customTheme,
        child: Navigator(
          key: _navigatorKey,
          pages: widget.pages,
          initialRoute: widget.initialRoute,
          onGenerateInitialRoutes: widget.onGenerateInitialRoutes,
          onGenerateRoute: widget.onGenerateRoute,
          onUnknownRoute: widget.onUnknownRoute,
          transitionDelegate: widget.transitionDelegate,
          reportsRouteUpdateToEngine: widget.reportsRouteUpdateToEngine,
          clipBehavior: widget.clipBehavior,
          observers: widget.observers,
          requestFocus: widget.requestFocus,
          restorationScopeId: widget.restorationScopeId,
          routeTraversalEdgeBehavior: widget.routeTraversalEdgeBehavior,
          routeDirectionalTraversalEdgeBehavior:
              widget.routeDirectionalTraversalEdgeBehavior,
          onDidRemovePage: widget.onDidRemovePage,
        ),
      ),
    );
  }

  void _onOverlayDismissed() {
    _cachedTheme = null;
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const SizedBox.shrink();
    }

    return AdaptiveOverlayNavigator<T>(
      controller: _controller!,
      navigatorKey: _navigatorKey,
      child: AdaptiveOverlay(
        controller: _controller!,
        overlayConstraints: widget.overlayConstraints,
        overlayAlignment: widget.overlayAlignment,
        sheetBreakpoint: widget.sheetBreakpoint,
        sheetBottomPassThrough: widget.sheetBottomPassThrough,
        sheetBottomPassThroughSuspended: widget.sheetBottomPassThroughSuspended,
        onOverlayDismissed: _onOverlayDismissed,
        overlayBuilder: (context, controller) {
          final navigatorContent = _buildNavigatorContent();

          final content = widget.overlayBuilder != null
              ? widget.overlayBuilder!(context, navigatorContent)
              : navigatorContent;

          return AdaptiveOverlayNavigator<T>(
            controller: _controller!,
            navigatorKey: _navigatorKey,
            child: content,
          );
        },
        child: widget.child,
      ),
    );
  }
}
