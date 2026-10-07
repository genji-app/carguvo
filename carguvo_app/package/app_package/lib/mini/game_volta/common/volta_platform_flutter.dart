import 'package:flutter/foundation.dart';

import 'package:game_volta_core/volta_platform.dart';
import 'package:app_package/core/services/auth/sb_login.dart';
import 'package:app_package/core/services/config/sb_config.dart';
import 'package:app_package/core/services/network/sb_http_manager.dart';

class FlutterVoltaPlatform extends VoltaPlatform {
  const FlutterVoltaPlatform();

  static void install() => VoltaPlatform.install(const FlutterVoltaPlatform());

  @override
  Object? brandConfig(String key) => SbConfig.instance.brandConfig[key];

  @override
  bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;

  @override
  bool get isDebug => kDebugMode;

  @override
  void log(String message) => debugPrint(message);

  @override
  Object? mainConfig(String key) => SbConfig.instance.mainConfig[key];

  @override
  int get agentId => SbConfig.agentId;

  @override
  String get brand => SbConfig.brand;

  @override
  String get userToken => SbHttpManager.instance.userTokenSb;

  @override
  String get apiDomain => SbHttpManager.instance.apiDomain;

  @override
  String get appCustLogin => SbHttpManager.instance.custLogin;

  @override
  String get appCustId => SbHttpManager.instance.custId;

  @override
  Stream<void>? get sessionReady => SbLogin.sessionReadyStream;

  @override
  Future<void> ensureSession() async {
    final SbHttpManager http = SbHttpManager.instance;
    if (http.userTokenSb.isNotEmpty) return;
    if (http.userToken.isEmpty) return;
    try {
      await http.getSbToken();
    } on Object catch (e) {
      debugPrint('VoltaPlatform.ensureSession: get-token hỏng — vào game ở '
          'trạng thái thiếu token, chờ lưới đỡ. $e');
    }
  }
}
