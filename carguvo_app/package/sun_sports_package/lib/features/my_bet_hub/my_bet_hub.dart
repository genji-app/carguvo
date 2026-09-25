import 'dart:math' as math;

import 'package:adaptive_overlay/adaptive_overlay.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/constants/breakpoints.dart';
import 'package:sun_sports/core/services/websocket/betslip_subscription_manager.dart';
import 'package:sun_sports/core/utils/keyboard_visibility.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/features/betting/betting.dart';
import 'package:sun_sports/shared/layouts/shell_bottom_block.dart';
import 'package:sun_sports/shared/widgets/inset_shadow/inset_shadow.dart'
    as inset;

import 'my_bet_hub_routes.dart';
import 'my_bet_hub_sheet_scope.dart';

export 'my_bet_hub_controller.dart';
export 'my_bet_hub_providers.dart';
export 'my_bet_hub_routes.dart';
export 'my_bet_hub_scaffold.dart';
export 'my_bet_hub_sheet_scope.dart';
export 'my_bet_hub_toggle_button.dart';

typedef MyBetHubNavigator = AdaptiveOverlayNavigator<MyBetHub>;

class MyBetHub extends ConsumerWidget {
  const MyBetHub({required this.child, super.key});

  final Widget child;

  static const _radius = Radius.circular(24);
  static const _backgroundColor = Color(0xFF111010);

  static final _shadows = [
    inset.BoxShadow(
      color: Colors.black.withValues(alpha: 0.75),
      offset: const Offset(-20, 4),
      blurRadius: 40,
    ),
    inset.BoxShadow(
      color: Colors.white.withValues(alpha: 0.12),
      offset: const Offset(0, 0.5),
      blurRadius: 0.5,
      inset: true,
    ),
  ];

  static const _borderSide = BorderSide(
    color: AppColorStyles.borderPrimary,
    width: 0.2,
  );

  static final decorationForBottomSheet = inset.BoxDecoration(
    color: _backgroundColor,
    boxShadow: _shadows,
    borderRadius: const BorderRadius.vertical(top: _radius),
    border: const Border(top: _borderSide),
  );

  static final decorationForOverlay = inset.BoxDecoration(
    color: _backgroundColor,
    boxShadow: _shadows,
    borderRadius: const BorderRadiusDirectional.only(topStart: _radius),
    border: const Border(left: _borderSide, top: _borderSide),
  );

  static MyBetHubNavigator of(BuildContext context) {
    return AdaptiveOverlayNavigator.of<MyBetHub>(context);
  }

  static MyBetHubNavigator? maybeOf(BuildContext context) {
    return AdaptiveOverlayNavigator.maybeOf<MyBetHub>(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(myBetHubControllerProvider);

    ref.listen(myBetNotifierProvider.select((s) => s.betSlipCount), (prev, next) {
      if (controller.isVisible && (prev ?? 0) < next) {
        controller.changeMenu(MyBetMenu.bettingSlip);
      }
    });

    ref.listen<bool>(
      myBetHubControllerProvider.select(
        (c) => c.isVisible && c.selectedMenu == MyBetMenu.bettingSlip,
      ),
      (prev, next) => BetslipSubscriptionManager.instance?.setSlipVisible(next),
    );

    final navPassThrough = ShellBottomMetrics.hasBottomNav(context)
        ? ShellBottomMetrics.navTopFromCanvasBottom
        : null;

    return AdaptiveOverlayNavigation<MyBetHub>(
      controller: controller,
      navigatorKey: controller.navigatorKey,
      initialRoute: MyBetHubRoutes.root,
      sheetBreakpoint: Breakpoints.desktop,
      sheetBottomPassThrough: navPassThrough,
      sheetBottomPassThroughSuspended: isKeyboardVisible,
      onGenerateRoute: (settings) {
        final routes = MyBetHubRoutes.getRoutes(
          bodyDecoration: decorationForOverlay,
          onClosePressed: () => controller.close(),
        );

        final builder = routes[settings.name];
        if (builder != null) {
          return CupertinoPageRoute(settings: settings, builder: builder);
        }
        return null;
      },
      overlayBuilder: (context, materialApp) {
        final isMobileOrTablet =
            MediaQuery.sizeOf(context).width < Breakpoints.desktop;

        final overriddenContent = ProviderScope(
          overrides: [
            bettingNavigatorProvider.overrideWithValue(
              const _MyBetOverlayNavigatorImpl(),
            ),
          ],
          child: materialApp,
        );

        if (isMobileOrTablet) {
          return _MobileOverlay(
            navPassThrough: navPassThrough != null,
            child: overriddenContent,
          );
        }
        return _MyBetOverlay(
          isVisible: controller.isVisible,
          decoration: decorationForOverlay,
          child: ClipRRect(
            clipBehavior: Clip.hardEdge,
            borderRadius: const BorderRadiusDirectional.only(topStart: _radius),
            child: Material(
              type: MaterialType.transparency,
              child: overriddenContent,
            ),
          ),
        );
      },
      child: child,
    );
  }
}

class _MobileOverlay extends StatelessWidget {
  const _MobileOverlay({required this.child, required this.navPassThrough});
  final Widget child;

  final bool navPassThrough;

  @override
  Widget build(BuildContext context) {
    return MyBetHubSheetScope(
      navPassThrough: navPassThrough,
      child: RepaintBoundary(
        child: Padding(
          padding: EdgeInsets.only(
            top: math.max(MediaQuery.paddingOf(context).top, 44.0) + 20.0,
          ),
          child: Container(
            decoration: MyBetHub.decorationForBottomSheet,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: MyBetHub._radius),
              clipBehavior: Clip.antiAlias,
              child: Material(type: MaterialType.transparency, child: child),
            ),
          ),
        ),
      ),
    );
  }
}

class _MyBetOverlay extends StatelessWidget {
  const _MyBetOverlay({
    required this.child,
    required this.isVisible,
    this.decoration,
  });

  final Widget child;
  final bool isVisible;
  final BoxDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    return AnimatedOverlay(
      isVisible: isVisible,
      slideBeginOffset: const Offset(1.0, 0.0),
      alignment: Alignment.centerRight,
      backdropColor: Colors.transparent,
      decoration: decoration,
      constraints: const BoxConstraints.tightFor(width: 430),
      child: child,
    );
  }
}

class _MyBetOverlayNavigatorImpl implements BettingNavigator {
  const _MyBetOverlayNavigatorImpl();

  @override
  void pushToBetDetails(BuildContext context, BetSlip bet) {
    MyBetHub.maybeOf(
      context,
    )?.pushNamed<void>(MyBetHubRoutes.details, arguments: bet);
  }
}
