import 'package:go_router/go_router.dart';

String? currentRouterLocation(GoRouter? router) {
  final RouteMatchList? config = router?.routerDelegate.currentConfiguration;
  if (config == null || config.isEmpty) return null;

  RouteMatchBase last = config.matches.last;
  while (last is ShellRouteMatch && last.matches.isNotEmpty) {
    last = last.matches.last;
  }
  if (last is ImperativeRouteMatch) return last.matches.uri.toString();
  return config.uri.toString();
}
