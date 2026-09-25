import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_api_client/game_api_client.dart' as gac;
import 'package:sun_sports/core/services/auth/token_error_handler.dart';
import 'package:sun_sports/core/services/network/dio_logger_interceptor.dart';
import 'package:sun_sports/core/services/sportbook_api.dart'
    show SbHttpManager, SbConfig;

final gameApiClientProvider = Provider<gac.GameApiClient>((ref) {
  final gameApiUrl = SbConfig.gameApiUrl;

  final dioClient = gac.GameApiClient.createDioClient(gameApiUrl, () async {
    final refreshed = await TokenErrorHandler.instance.handleTokenError();
    return refreshed ? SbHttpManager.instance.userToken : null;
  });

  dioClient.interceptors.insert(
    0,
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final url = SbConfig.gameApiUrl;
        if (url.isNotEmpty) options.baseUrl = url;
        handler.next(options);
      },
    ),
  );

  if (kDebugMode) {
    debugPrint('🎮 GameApiClient initialized:');
    debugPrint('  gameApiUrl: $gameApiUrl');
    dioClient.interceptors.add(DioLoggerInterceptor());
  }

  return gac.GameApiClient(
    dio: dioClient,
    tokenProvider: () async => SbHttpManager.instance.userToken,
  );
});
