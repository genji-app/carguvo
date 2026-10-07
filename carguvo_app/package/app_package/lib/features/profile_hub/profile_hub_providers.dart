import 'package:adaptive_overlay/adaptive_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'profile_hub.dart';

final profileNavigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>();
});

final profileHubControllerProvider =
    ChangeNotifierProvider<AdaptiveOverlayController>((ref) {
      final controller = AdaptiveOverlayController();

      return controller;
    });

final profileHubVisibleProvider = Provider<bool>((ref) {
  return ref.watch(profileHubControllerProvider.select((c) => c.isVisible));
});

final profileModulesProvider = Provider<List<ProfileHubRoutes>>(
  (ref) => [
    ref.watch(profileModuleRoutesProvider),
    ref.watch(securityProfileHubRoutesProvider),
    ref.watch(preferencesProfileHubRoutesProvider),
    ref.watch(bettingProfileHubRoutesProvider),
    ref.watch(transactionProfileHubRoutesProvider),
    ref.watch(phoneVerificationProfileHubRoutesProvider),
  ],
);

final profileRouteRegistryProvider =
    Provider<Map<String, ProfileHubRouteBuilder>>((ref) {
      final registry = <String, ProfileHubRouteBuilder>{};

      final modules = ref.watch(profileModulesProvider);
      for (final module in modules) {
        registry.addAll(module.routes);
      }

      return registry;
    });
