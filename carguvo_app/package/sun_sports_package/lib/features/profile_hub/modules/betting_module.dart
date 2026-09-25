import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/features/betting/betting.dart';
import 'package:sun_sports/features/profile_hub/profile_hub.dart';

class _BettingProfileHubNavigator implements BettingNavigator {
  @override
  void pushToBetDetails(BuildContext context, BetSlip bet) {
    ProfileHub.maybeOf(context)?.pushNamed<void>(
      ProfileHub.betDetails,
      arguments: BetSlipDetailsArguments(slip: bet),
    );
  }
}

class BettingProfileHubRoutes implements ProfileHubRoutes {
  @override
  Map<String, ProfileHubRouteBuilder> get routes => {
    ProfileHub.bettingHistory: (context, args) =>
        ProfileHubScaffold.withCenterTitle(
          title: const Text(I18n.txtBetHistory),
          bodyPadding: EdgeInsets.zero,
          body: ProviderScope(
            overrides: [
              bettingNavigatorProvider.overrideWithValue(
                _BettingProfileHubNavigator(),
              ),
            ],
            child: const BettingHistoryFlowView(),
          ),
        ),
    ProfileHub.betDetails: (context, args) {
      if (args is! BetSlipDetailsArguments) {
        return const ProfileHubScaffold(
          body: Center(child: Text('Invalid Bet Details arguments')),
        );
      }
      return ProfileHubScaffold.withCenterTitle(
        title: const Text(I18n.txtBetDetails),
        body: BetSlipDetailsView(slip: args.slip),
      );
    },
  };
}

final bettingProfileHubRoutesProvider = Provider<ProfileHubRoutes>(
  (ref) => BettingProfileHubRoutes(),
);
