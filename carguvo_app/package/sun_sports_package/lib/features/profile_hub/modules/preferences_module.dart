import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/providers/auth_provider.dart';
import 'package:sun_sports/features/preferences/preferences.dart';
import 'package:sun_sports/features/profile_hub/profile_hub.dart';

class _PreferencesProfileHubNavigator implements PreferencesNavigator {
  const _PreferencesProfileHubNavigator();

  @override
  void pushToBetPreferences(BuildContext context) {
    ProfileHub.maybeOf(context)?.pushNamed<void>(ProfileHub.betPreferences);
  }
}

class PreferencesProfileHubRoutes implements ProfileHubRoutes {
  @override
  Map<String, ProfileHubRouteBuilder> get routes => {
    ProfileHub.settings: (context, args) => ProfileHubScaffold.withCenterTitle(
      title: const Text(I18n.txtSettings),
      body: ProviderScope(
        overrides: [
          preferencesNavigatorProvider.overrideWithValue(
            const _PreferencesProfileHubNavigator(),
          ),
        ],
        child: const SettingsView(),
      ),
    ),
    ProfileHub.betPreferences: (context, args) => Consumer(
      builder: (context, ref, _) {
        final isGuest = !ref.watch(isAuthenticatedProvider);
        return ProfileHubScaffold.withCenterTitle(
          title: const Text(I18n.txtOdds),
          hideBack: isGuest,
          body: const SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: BetPreferencesView(),
          ),
        );
      },
    ),
  };
}

final preferencesProfileHubRoutesProvider = Provider<ProfileHubRoutes>(
  (ref) => PreferencesProfileHubRoutes(),
);
