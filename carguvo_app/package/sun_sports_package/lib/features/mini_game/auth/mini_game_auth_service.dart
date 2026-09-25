import 'package:sun_sports/core/error/exceptions.dart';
import 'package:sun_sports/core/services/auth/sb_login.dart';
import 'package:sun_sports/core/services/auth/token_manager.dart';
import 'package:sun_sports/core/services/config/sb_config.dart';

import 'mini_game_auth_data.dart';

class MiniGameAuthService {
  final SbConfig _config;
  final Future<void> Function() _refreshTokenFn;

  MiniGameAuthService({
    SbConfig? config,
    Future<void> Function()? refreshTokenFn,
  }) : _config = config ?? SbConfig.instance,
       _refreshTokenFn = refreshTokenFn ?? SbLogin.ensureWsLoginCredentials;

  Future<MiniGameAuthData> read() async {
    var info = _config.mainWsLoginInfo;
    var sig = _config.mainWsLoginSignature;
    var ws = _config.wsToken;
    var username = _config.mainWsUsername;
    var password = _config.mainWsPassword;

    if (info == null ||
        info.isEmpty ||
        sig == null ||
        sig.isEmpty ||
        ws.isEmpty) {
      await _refreshTokenFn();
      info = _config.mainWsLoginInfo;
      sig = _config.mainWsLoginSignature;
      ws = _config.wsToken;
      username = _config.mainWsUsername;
      password = _config.mainWsPassword;
    }

    if (info == null ||
        info.isEmpty ||
        sig == null ||
        sig.isEmpty ||
        ws.isEmpty) {
      throw const AuthenticationException(
        message:
            'Sport credentials không khả dụng (chưa login hoặc refresh fail)',
      );
    }

    if (username == null ||
        username.isEmpty ||
        password == null ||
        password.isEmpty) {
      final saved = await UserManager.getSavedCredentials();
      username ??= saved.$1;
      password ??= saved.$2;
    }

    return MiniGameAuthData(
      info: info,
      signature: sig,
      wsToken: ws,
      username: username ?? '',
      password: password ?? '',
    );
  }
}
