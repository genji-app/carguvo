import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/services/repositories/my_bet_repository/models/bet_slip.dart';
import 'package:sun_sports/features/betting/bet_slip/detail/bet_slip_details_view.dart';
import 'package:sun_sports/features/betting/my_bet/my_bet_view.dart';

import 'my_bet_hub_providers.dart';
import 'my_bet_hub_scaffold.dart';

abstract class MyBetHubRoutes {
  static const String root = '/';

  static const String details = '/details';

  static const String filter = '/filter';

  static const String support = '/support';

  static Map<String, WidgetBuilder> getRoutes({
    required Decoration? bodyDecoration,
    required VoidCallback onClosePressed,
  }) {
    return {
      root: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final controller = ref.watch(myBetHubControllerProvider);
            return MyBetView(
              selectedMenu: controller.selectedMenu,
              onMenuChanged: (value) {
                ref.read(myBetHubControllerProvider).changeMenu(value);
                final navState = Navigator.maybeOf(context);
                if (navState != null && navState.canPop()) {
                  navState.pop();
                }
              },
              onClosePressed: onClosePressed,
              decoration: bodyDecoration,
            );
          },
        );
      },
      details: (context) {
        final arguments = ModalRoute.of(context)!.settings.arguments;
        final bet = arguments as BetSlip;
        return BetSlipDetailsView(
          slip: bet,
          scaffoldBuilder: (context, body, bottomNavigationBar) {
            return MyBetHubScaffold(
              title: const Text(I18n.txtBetDetails),
              bottomNavigationBar: bottomNavigationBar,
              onClosePressed: onClosePressed,
              body: body,
            );
          },
        );
      },
    };
  }
}
