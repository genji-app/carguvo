import 'package:flutter/material.dart';

typedef ProfileHubRouteBuilder = Widget Function(BuildContext context, dynamic arguments);

abstract class ProfileHubRoutes {
  Map<String, ProfileHubRouteBuilder> get routes;
}
