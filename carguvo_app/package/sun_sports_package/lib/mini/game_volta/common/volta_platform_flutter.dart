import 'package:flutter/foundation.dart';

import 'package:game_volta_core/volta_platform.dart';
import 'package:sun_sports/core/services/config/sb_config.dart';
import 'package:sun_sports/core/services/network/sb_http_manager.dart';

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
}
