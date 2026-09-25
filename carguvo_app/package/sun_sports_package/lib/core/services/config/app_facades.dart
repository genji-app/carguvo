library;

import 'package:app_env/app_env.dart';
import 'package:game_launcher/game_launcher.dart';
import 'package:monitoring_domain/monitoring_domain.dart';
import 'package:provider_game_manager/provider_game_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport_events/sport_events.dart' show LeagueAliasStore;
import 'package:sport_socket/sport_socket.dart';
import 'package:sun_sports/core/network/logged_http.dart';
import 'package:sun_sports/core/network/sb_api_client.dart';
import 'package:sun_sports/core/services/monitoring/sentry_service.dart';
import 'package:sun_sports/core/utils/app_logger.dart';

Future<void> configureAppFacades() async {
  final prefs = await SharedPreferences.getInstance();
  AppStorage.configure(
    read: prefs.getString,
    write: (key, value) => prefs.setString(key, value),
    remove: prefs.remove,
  );

  AppHttp.configure(
    get: (url, {headers}) async {
      final response = await LoggedHttp.get(
        Uri.parse(url),
        action: 'AppHttp.get',
        headers: headers,
      );
      return response.statusCode >= 200 && response.statusCode < 300
          ? response.body
          : null;
    },
    post: (url, jsonBody, {headers}) async {
      final response = await LoggedHttp.post(
        Uri.parse(url),
        action: 'AppHttp.post',
        headers: {'Content-Type': 'application/json', ...?headers},
        body: jsonBody,
      );
      return response.statusCode >= 200 && response.statusCode < 300
          ? response.body
          : null;
    },
  );

  AppSession.configure(
    accessToken: () => SbApiClient.instance.userToken,
  );

  providerGameManagerLog = (message, {required isError}) =>
      isError ? AppLoggers.general.e(message) : AppLoggers.general.d(message);

  GameLauncher.logSink = AppLoggers.general.d;
  LeagueAliasStore.log = AppLoggers.general.d;

  ProtoParser.onParseError = AppLoggers.websocket.w;

  LoginTimingReport.configure(
    logInfo: AppLoggers.auth.i,
    logWarning: AppLoggers.auth.w,
    captureDiagnostic: SentryService.captureDiagnostic,
  );
}
