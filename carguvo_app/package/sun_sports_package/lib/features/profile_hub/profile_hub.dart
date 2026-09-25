import 'package:adaptive_overlay/adaptive_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:sun_sports/shared/widgets/inset_shadow/inset_shadow.dart'
    as inset;

import 'profile_hub_navigator.dart';
import 'profile_hub_providers.dart';
import 'profile_hub_routes.dart';

export 'package:sun_sports/features/profile/profile.dart';

export 'modules/betting_module.dart';
export 'modules/phone_verification_module.dart';
export 'modules/preferences_module.dart';
export 'modules/profile_module.dart';
export 'modules/security_module.dart';
export 'modules/transaction_module.dart';
export 'profile_hub_appbar.dart';
export 'profile_hub_navigator.dart';
export 'profile_hub_providers.dart';
export 'profile_hub_routes.dart';
export 'profile_hub_scaffold.dart';

class ProfileHub extends StatelessWidget {
  static const String root = '/';

  static const String security = '/security';

  static const String settings = '/settings';

  static const String betPreferences = '/bet-preferences';

  static const String bettingHistory = '/betting-history';

  static const String transactionHistory = '/transaction-history';

  static const String phoneVerification = '/phone-verification';

  static const String personal = '/personal';

  static const String avatarSelection = '/avatar-selection';

  static const String betDetails = '/bet-details';

  static const String transactionDetails = '/transaction-details';

  static const String changePassword = '/change-password';

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
    width: 1.5,
  );

  const ProfileHub({
    required this.controller,
    this.navigatorKey,
    this.child,
    this.initialRoute,
    this.onGenerateRoute,
    super.key,
  });

  final AdaptiveOverlayController controller;

  final GlobalKey<NavigatorState>? navigatorKey;

  final Widget? child;

  final String? initialRoute;

  final RouteFactory? onGenerateRoute;

  static ProfileHubNavigator of(BuildContext context) {
    return AdaptiveOverlayNavigator.of<ProfileHub>(context);
  }

  static ProfileHubNavigator? maybeOf(BuildContext context) {
    return AdaptiveOverlayNavigator.maybeOf<ProfileHub>(context);
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveOverlayNavigation<ProfileHub>(
      controller: controller,
      navigatorKey: navigatorKey,
      initialRoute: initialRoute,
      onGenerateRoute: onGenerateRoute,
      overlayBuilder: _buildAdaptiveOverlay,
      child: child,
    );
  }

  Widget _buildAdaptiveOverlay(BuildContext context, Widget materialApp) {
    if (ResponsiveBuilder.isMobile(context)) {
      return _MobileOverlay(child: materialApp);
    }
    return _DesktopOverlay(child: materialApp);
  }

  static void openRemote(WidgetRef ref) {
    ref.read(profileHubControllerProvider).open();
  }

  static void closeRemote(WidgetRef ref) {
    ref.read(profileHubControllerProvider).close();
  }

  static bool isVisibleRemote(WidgetRef ref) {
    return ref.read(profileHubControllerProvider).isVisible;
  }

  static Future<T?> pushAndRemoveUntilRemote<T>(
    WidgetRef ref,
    String routeName, {
    required RoutePredicate predicate,
    dynamic arguments,
  }) {
    final navigatorKey = ref.read(profileNavigatorKeyProvider);
    return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(
      routeName,
      predicate,
      arguments: arguments,
    );
  }

  static void openRemoteRef(Ref ref) {
    ref.read(profileHubControllerProvider).open();
  }

  static void closeRemoteRef(Ref ref) {
    ref.read(profileHubControllerProvider).close();
  }

  static bool isVisibleRemoteRef(Ref ref) {
    return ref.read(profileHubControllerProvider).isVisible;
  }

  static Future<T?> pushAndRemoveUntilRemoteRef<T>(
    Ref ref,
    String routeName, {
    required RoutePredicate predicate,
    dynamic arguments,
  }) {
    final navigatorKey = ref.read(profileNavigatorKeyProvider);
    return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(
      routeName,
      predicate,
      arguments: arguments,
    );
  }

  static Route<dynamic> _buildRoute({
    required Widget screen,
    required RouteSettings settings,
    bool animate = true,
  }) {
    return _ProfileHubPageRoute(
      builder: (_) => screen,
      settings: settings,
      duration: animate ? const Duration(milliseconds: 280) : Duration.zero,
    );
  }

  static Route<dynamic>? generateRoute(
    RouteSettings routeSettings,
    Map<String, ProfileHubRouteBuilder> registry,
  ) {
    final args = routeSettings.arguments;
    final animate = (args is Map && args['no_animation'] == true)
        ? false
        : true;

    final builder = registry[routeSettings.name];
    if (builder == null) return null;

    return _buildRoute(
      screen: Builder(builder: (context) => builder(context, args)),
      settings: routeSettings,
      animate: animate,
    );
  }
}

class _MobileOverlay extends StatelessWidget {
  final Widget child;

  const _MobileOverlay({required this.child});

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.vertical(top: Radius.circular(24));

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(top: 1.5),
        decoration: inset.BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: ProfileHub._shadows,
          border: const Border(top: ProfileHub._borderSide),
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          clipBehavior: Clip.antiAlias,
          child: Material(type: MaterialType.transparency, child: child),
        ),
      ),
    );
  }
}

class _DesktopOverlay extends StatelessWidget {
  final Widget child;

  const _DesktopOverlay({required this.child});

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadiusDirectional.only(
      topStart: Radius.circular(24),
    );

    return SafeArea(
      bottom: false,
      child: RepaintBoundary(
        child: Container(
          margin: const EdgeInsetsDirectional.only(top: 64),
          decoration: inset.BoxDecoration(
            borderRadius: borderRadius,
            boxShadow: ProfileHub._shadows,
            color: AppColorStyles.backgroundSecondary,
            border: const Border(
              left: ProfileHub._borderSide,
              top: ProfileHub._borderSide,
            ),
          ),
          child: ClipRRect(
            borderRadius: borderRadius,
            clipBehavior: Clip.antiAlias,
            child: Material(type: MaterialType.transparency, child: child),
          ),
        ),
      ),
    );
  }
}

class _ProfileHubPageRoute<T> extends PageRouteBuilder<T> {
  static final Animatable<Offset> _slide = Tween<Offset>(
    begin: const Offset(0.06, 0),
    end: Offset.zero,
  ).chain(CurveTween(curve: Curves.easeOutCubic));

  _ProfileHubPageRoute({
    required WidgetBuilder builder,
    super.settings,
    Duration duration = const Duration(milliseconds: 280),
    Duration reverseDuration = const Duration(milliseconds: 280),
  }) : super(
         transitionDuration: duration,
         reverseTransitionDuration: reverseDuration,
         pageBuilder: (context, animation, secondaryAnimation) =>
             builder(context),
         transitionsBuilder: (context, animation, secondaryAnimation, child) =>
             SlideTransition(
               position: animation.drive(_slide),
               child: RepaintBoundary(child: child),
             ),
       );
}
