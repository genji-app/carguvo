import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/features/phone_verification/phone_verification.dart';
import 'package:sun_sports/features/profile_hub/profile_hub.dart';

class PhoneVerificationProfileHubRoutes implements ProfileHubRoutes {
  @override
  Map<String, ProfileHubRouteBuilder> get routes => {
    ProfileHub.phoneVerification: (context, args) =>
        ProfileHubScaffold.withCenterTitle(
          title: const Text(I18n.txtActivateAccount),
          bodyPadding: ProfileHubScaffold.kBodyHorizontalPadding,
          body: const PhoneVerificationView(),
        ),
  };
}

final phoneVerificationProfileHubRoutesProvider = Provider<ProfileHubRoutes>(
  (ref) => PhoneVerificationProfileHubRoutes(),
);
