import 'dart:io' show Platform;

import 'package:flutter/foundation.dart'
    show kIsWeb, kDebugMode, kReleaseMode, debugPrint;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sun_sports/core/env/app_env.dart';
import 'package:sun_sports/core/services/config/sb_config.dart';
import 'sentry_scrubber.dart';
import 'web_device.dart';

class SentryService {
  SentryService._();

  static const String _qcPrefix = '[S88] ';

  static String _withQcPrefix(String message) =>
      message.startsWith(_qcPrefix) ? message : '$_qcPrefix$message';

  static String get platformLabel {
    if (kIsWeb) {
      return _isWebMobile ? 'web-mobile' : 'web-desktop';
    }
    try {
      if (Platform.isAndroid) return 'android';
      if (Platform.isIOS) return 'ios';
    } catch (_) {
    }
    return 'unknown';
  }

  static bool get _isWebMobile => isWebMobileDevice() ?? false;

  static String _maskedDsn(String dsn) {
    final at = dsn.indexOf('@');
    return at > 0 ? '***@${dsn.substring(at + 1)}' : dsn;
  }

  static String get _environment => SbConfig.sentryEnvironment.isNotEmpty
      ? SbConfig.sentryEnvironment
      : (AppEnv.isProd ? 'production' : 'staging');

  static bool _initialized = false;

  static bool get _shouldEnable =>
      SbConfig.sentryEnabled &&
      SbConfig.sentryDsn.isNotEmpty &&
      (kReleaseMode || SbConfig.sentryAllowDebug);

  static Future<void> init() async {
    if (!_shouldEnable) {
      debugPrint(
        '[Sentry] DISABLED — enabled=${SbConfig.sentryEnabled}, '
        'dsn="${SbConfig.sentryDsn}" (rỗng = chưa gắn DSN vào brand config). '
        'Bỏ qua init.',
      );
      return;
    }

    final info = await PackageInfo.fromPlatform();
    const pubspecName = 'sun_sports';
    final release = '$pubspecName@${info.version}+${info.buildNumber}';
    debugPrint(
      '[Sentry] INIT — platform=$platformLabel, env=$_environment, '
      'release=$release, dsn=${_maskedDsn(SbConfig.sentryDsn)}',
    );

    await SentryFlutter.init((options) {
      options.dsn = SbConfig.sentryDsn;
      options.environment = _environment;
      options.tracesSampleRate = SbConfig.sentryTracesSampleRate;

      options.release = release;
      options.dist = info.buildNumber;

      options.enableAutoSessionTracking = true;

      options.sendDefaultPii = false;
      options.maxBreadcrumbs = 150;

      options.beforeSend = (event, hint) => scrubEvent(event);
      options.beforeBreadcrumb =
          (crumb, hint) => crumb == null ? null : scrubBreadcrumb(crumb);

      options.debug = kDebugMode;
      options.diagnosticLevel = SentryLevel.debug;
    });

    await Sentry.configureScope((scope) {
      scope.setTag('platform', platformLabel);
      if (SbConfig.brand.isNotEmpty) scope.setTag('brand', SbConfig.brand);
      if (SbConfig.appName.isNotEmpty) {
        scope.setTag('app_name', SbConfig.appName);
      }
      if (SbConfig.clientId.isNotEmpty) {
        scope.setTag('client_id', SbConfig.clientId);
      }
    });

    _initialized = true;
  }

  static Future<void> setUser({String? id, String? username}) async {
    if (!_initialized) return;
    await Sentry.configureScope((scope) {
      scope.setUser(
        (id == null && username == null)
            ? null
            : SentryUser(id: id, username: username),
      );
    });
  }

  static Future<void> captureException(
    Object error, {
    StackTrace? stackTrace,
  }) async {
    if (!_initialized) return;
    await Sentry.captureException(error, stackTrace: stackTrace);
  }

  static void captureLog(
    String message, {
    required SentryLevel level,
    Object? error,
    StackTrace? stackTrace,
    String? category,
  }) {
    if (!_initialized) return;
    final prefixed = _withQcPrefix(message);
    if (error != null) {
      Sentry.captureException(
        error,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.level = level;
          // ignore: deprecated_member_use
          scope.setExtra('log_message', prefixed);
          if (category != null) scope.setTag('log_category', category);
        },
      );
    } else {
      Sentry.captureMessage(
        prefixed,
        level: level,
        withScope: (scope) {
          if (category != null) scope.setTag('log_category', category);
        },
      );
    }
  }

  static void captureBackendError(String where, String detail) {
    if (!_initialized) return;
    Sentry.captureMessage(
      _withQcPrefix(where),
      level: SentryLevel.warning,
      withScope: (scope) {
        scope.fingerprint = ['backend-error', where];
        // ignore: deprecated_member_use
        scope.setExtra('detail', detail);
        scope.setTag('log_category', 'backend');
      },
    );
  }

  static void captureDiagnostic(
    String where,
    Map<String, Object?> data, {
    SentryLevel level = SentryLevel.warning,
  }) {
    if (!_initialized) return;
    Sentry.captureMessage(
      _withQcPrefix(where),
      level: level,
      withScope: (scope) {
        scope.fingerprint = [where];
        for (final entry in data.entries) {
          // ignore: deprecated_member_use
          scope.setExtra(entry.key, entry.value ?? 'null');
        }
        scope.setTag('log_category', 'diagnostic');
      },
    );
  }

  static void captureZoneError(Object error, StackTrace stack) {
    if (!_initialized) {
      debugPrint('[Sentry] zone error trước khi init: $error');
      return;
    }
    Sentry.captureException(error, stackTrace: stack);
  }

  static void addBreadcrumb(
    String message, {
    required SentryLevel level,
    String? category,
  }) {
    if (!_initialized) return;
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: _withQcPrefix(message),
        level: level,
        category: category,
      ),
    );
  }
}
