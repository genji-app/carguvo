import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/services/repositories/my_bet_repository/models/bet_slip.dart';

abstract class BettingNavigator {
  void pushToBetDetails(BuildContext context, BetSlip bet);
}

class BettingNavigatorStandard implements BettingNavigator {
  const BettingNavigatorStandard();

  @override
  void pushToBetDetails(BuildContext context, BetSlip bet) {
  }
}

final bettingNavigatorProvider = Provider<BettingNavigator>((ref) {
  return const BettingNavigatorStandard();
});
