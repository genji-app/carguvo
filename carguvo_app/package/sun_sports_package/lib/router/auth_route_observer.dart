import 'package:flutter/widgets.dart';
import 'package:sun_sports/core/utils/app_logger.dart';
import 'package:sun_sports/router/auth_navigation.dart';

class AuthRouteExitObserver extends NavigatorObserver {
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _report('pop', route);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _report('remove', route);
  }

  void _report(String kind, Route<dynamic> route) {
    if (!identical(route, authScreenRoute)) return;
    AppLoggers.auth.w(
      '[auth-route-exit] $kind — màn login rời stack\n${StackTrace.current}',
    );
  }
}

final AuthRouteExitObserver authRouteExitObserver = AuthRouteExitObserver();
