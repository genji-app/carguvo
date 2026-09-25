
import 'dart:async';
import 'package:app_env/app_env.dart';
import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fullscreen_guard/fullscreen_guard.dart';
import 'package:rive/rive.dart' as rive;
import 'package:sun_sports/core/constants/app_version.dart';
import 'package:sun_sports/core/perf/perf.dart';
import 'package:sun_sports/core/perf/perf_provider_observer.dart';
import 'package:sun_sports/core/providers/platform_ui_provider.dart';
import 'package:sun_sports/core/services/auth/sb_login.dart';
import 'package:sun_sports/core/services/maintenance/maintenance_service.dart';
import 'package:sun_sports/core/services/monitoring/sentry_service.dart';
import 'package:sun_sports/core/services/storage/sport_storage.dart';
import 'package:sun_sports/core/utils/landing_auth/landing_auth_params.dart';
import 'package:sun_sports/core/services/config/app_facades.dart';
import 'package:sun_sports/core/utils/web_browser_detect/web_user_agent.dart';
import 'package:sun_sports/core/utils/sound_effects.dart';
import 'package:sun_sports/features/onboarding/onboarding.dart';

class SunSports {
  SunSports._();

  static Future<List<Override>> init() async {
      if (PerfFlags.trace) {
        StressWidgetsBinding.ensureInitialized();
      } else {
      }
      StartupTrace.begin();

      AppDevice.configure(
        platform: kIsWeb
            ? HostPlatform.web
            : switch (defaultTargetPlatform) {
                TargetPlatform.android => HostPlatform.android,
                TargetPlatform.iOS => HostPlatform.ios,
                TargetPlatform.macOS => HostPlatform.macos,
                TargetPlatform.windows => HostPlatform.windows,
                TargetPlatform.linux => HostPlatform.linux,
                TargetPlatform.fuchsia => HostPlatform.unknown,
              },
        userAgent: webUserAgent,
        maxTouchPoints: webMaxTouchPoints,
        pageUrl: webPageUrl,
        pageBaseUrl: webPageBaseUrl,
      );

      await configureAppFacades();

      unawaited(SoundEffects.configureSession());

      if (kReleaseMode) {
        debugPrint = (String? message, {int? wrapWidth}) {};
      }

      final bool isMobileWeb = kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.android);
      PaintingBinding.instance.imageCache
        ..maximumSize = isMobileWeb ? 150 : 1000
        ..maximumSizeBytes = (isMobileWeb ? 40 : (kIsWeb ? 192 : 96)) << 20;

      LandingAuthSession.capture();

      MaintenanceService.instance.applyDebugOverride();

      try {
        await StartupTrace.time('main.riveInit', () => rive.RiveNative.init());
      } catch (e, st) {
        // ignore: avoid_print
        print('[init] RiveNative.init FAILED — mọi Rive sẽ trống: $e\n$st');
      }
      await StartupTrace.time('main.appVersion', AppVersion.init);

      await StartupTrace.time(
        'main.storageInit',
        () => SportStorage.instance.init().catchError((_) {}),
      );

      await StartupTrace.time(
        'main.brandConfig',
        () => SbLogin.loadBrandConfigOnly().catchError((_) {}),
      );

      final platformUiController = createPlatformUiController();

      try {
        await StartupTrace.time('main.sentryInit', SentryService.init);
      } catch (e, s) {
        SentryService.captureZoneError(e, s);
      }

      return <Override>[
          platformUiControllerProvider.overrideWith(
            (ref) => platformUiController,
          ),
          spotlightNavigatorProvider.overrideWith(
            (ref) => ShellSpotlightNavigator(ref),
          ),
        ];
  }
}
