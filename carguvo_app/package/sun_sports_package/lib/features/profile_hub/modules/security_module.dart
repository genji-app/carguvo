import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/features/profile_hub/profile_hub.dart';
import 'package:sun_sports/features/security/security.dart';

class _SecurityProfileHubNavigator implements SecurityNavigator {
  @override
  void pushToChangePassword(BuildContext context) {
    ProfileHub.maybeOf(context)?.pushNamed<void>(ProfileHub.changePassword);
  }

  @override
  void onPasswordChangedSuccess(BuildContext context, WidgetRef ref) {
    ProfileHub.closeRemote(ref);
  }
}

class SecurityProfileHubRoutes implements ProfileHubRoutes {
  @override
  Map<String, ProfileHubRouteBuilder> get routes => {
    ProfileHub.security: (context, args) => ProfileHubScaffold.withCenterTitle(
      title: const Text(I18n.txtSecurity),
      body: ProviderScope(
        overrides: [
          securityNavigatorProvider.overrideWithValue(
            _SecurityProfileHubNavigator(),
          ),
        ],
        child: const SecurityView(),
      ),
    ),
    ProfileHub.changePassword: (context, args) => ProviderScope(
      overrides: [
        securityNavigatorProvider.overrideWithValue(
          _SecurityProfileHubNavigator(),
        ),
      ],
      child: const ChangePasswordScreen(),
    ),
  };
}

final securityProfileHubRoutesProvider = Provider<ProfileHubRoutes>(
  (ref) => SecurityProfileHubRoutes(),
);
