import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/profile_hub/profile_hub.dart';

class _ProfileModuleNavigator implements ProfileNavigator {
  const _ProfileModuleNavigator();

  @override
  void pushToAvatarSelection(BuildContext context) {
    ProfileHub.maybeOf(context)?.pushNamed<void>(ProfileHub.avatarSelection);
  }

  @override
  void pushToPhoneVerification(BuildContext context) {
    ProfileHub.maybeOf(context)?.pushNamed<void>(ProfileHub.phoneVerification);
  }

  @override
  void pushToPersonal(BuildContext context) {
    ProfileHub.maybeOf(context)?.pushNamed<void>(ProfileHub.personal);
  }

  @override
  void pushToSecurity(BuildContext context) {
    ProfileHub.maybeOf(context)?.pushNamed<void>(ProfileHub.security);
  }

  @override
  void pushToSettings(BuildContext context) {
    ProfileHub.maybeOf(context)?.pushNamed<void>(ProfileHub.settings);
  }

  @override
  void pushToBettingHistory(BuildContext context) {
    ProfileHub.maybeOf(context)?.pushNamed<void>(ProfileHub.bettingHistory);
  }

  @override
  void close(BuildContext context) {
    ProfileHub.maybeOf(context)?.close();
  }
}

class ProfileModuleRoutes implements ProfileHubRoutes {
  @override
  Map<String, ProfileHubRouteBuilder> get routes => {
    ProfileHub.root: (context, args) => ProfileHubScaffold(
      bodyPadding: EdgeInsets.zero,
      appBar: ProfileHubAppBar.closeOnly(
        titleStyle: AppTextStyles.headingXSmall(
          color: AppColorStyles.contentPrimary,
        ),
        title: const Padding(
          padding: EdgeInsetsDirectional.only(start: 8.0),
          child: Text(I18n.txtUserInfo),
        ),
      ),
      body: ProviderScope(
        overrides: [
          profileNavigatorProvider.overrideWithValue(
            const _ProfileModuleNavigator(),
          ),
        ],
        child: const ProfileViewDeferred(),
      ),
    ),
    ProfileHub.personal: (context, args) => ProfileHubScaffold.withCenterTitle(
      title: const Text(I18n.txtPersonal),
      bodyPadding: ProfileHubScaffold.kBodyHorizontalPadding,
      body: ProviderScope(
        overrides: [
          profileNavigatorProvider.overrideWithValue(
            const _ProfileModuleNavigator(),
          ),
        ],
        child: const ProfilePersonalView(),
      ),
    ),
    ProfileHub.avatarSelection: (context, args) =>
        ProfileHubScaffold.withCenterTitle(
          title: const Text(I18n.txtChooseAvatar),
          bodyPadding: ProfileHubScaffold.kBodyHorizontalPadding,
          body: ProviderScope(
            overrides: [
              profileNavigatorProvider.overrideWithValue(
                const _ProfileModuleNavigator(),
              ),
            ],
            child: const AvatarSelectionScreen(),
          ),
        ),
  };
}

final profileModuleRoutesProvider = Provider<ProfileHubRoutes>(
  (ref) => ProfileModuleRoutes(),
);
