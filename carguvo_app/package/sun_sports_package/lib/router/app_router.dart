import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sun_sports/router/auth_navigation.dart';
import 'package:sun_sports/router/auth_route_observer.dart';
import 'package:sun_sports/features/auth/presentation/desktop/screens/auth_desktop_screen.dart';
import 'package:sun_sports/shared/layouts/main_shell_layout.dart';
import 'package:sun_sports/shared/widgets/back_to_top_overlay.dart'
    show backToTopRouteObserver;
import 'package:sun_sports/shared/widgets/livestream/livestream_overlay_blocker.dart'
    show livestreamDialogRouteObserver;

class AppRouter {
  AppRouter._();

  static final List<RouteBase> _routes = [
    GoRoute(
      path: '/',
      name: 'main',
      builder: (BuildContext context, GoRouterState state) =>
          const MainShellLayout(),
    ),
    GoRoute(
      path: '/auth/:showLogin',
      name: 'auth',
      builder: (BuildContext context, GoRouterState state) => AuthDesktopScreen(
        showLogin: state.pathParameters['showLogin'] == 'true',
      ),
    ),
  ];

  static String? _redirect(
    GoRouterState state, {
    bool Function()? isLoggedIn,
  }) {
    if (state.matchedLocation.startsWith('/auth')) {
      if (isLoggedIn?.call() ?? false) return '/';
      if (authFlowActive) return null;
      if (!authOpenIntentional) return '/';
    }
    return null;
  }

  static final GoRouter instance = GoRouter(
    routes: _routes,
    redirect: (context, state) => _redirect(state),
  );

  static GoRouter createInstance(
    GlobalKey<NavigatorState> navigatorKey, {
    bool Function()? isLoggedIn,
  }) => GoRouter(
    navigatorKey: navigatorKey,
    routes: _routes,
    redirect: (context, state) => _redirect(state, isLoggedIn: isLoggedIn),
    observers: [
      backToTopRouteObserver,
      livestreamDialogRouteObserver,
      authRouteExitObserver,
    ],
  );
}

final goRouterProvider = Provider<GoRouter>((ref) => AppRouter.instance);
