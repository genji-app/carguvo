import 'package:dio/dio.dart' show DioException, DioExceptionType, Response;
import 'package:flutter/foundation.dart';
import 'package:game_volta_core/volta_http.dart';

import 'package:sun_sports/core/network/sb_api_client.dart';
import 'package:sun_sports/core/services/network/sb_http_manager.dart';

class FlutterVoltaHttpTransport extends VoltaHttpTransport {
  const FlutterVoltaHttpTransport();

  static void install() => VoltaHttp.install(const FlutterVoltaHttpTransport());

  @override
  Future<dynamic> get(String url) {
    if (!VoltaDebugOverrides.active) {
      return _appCall(
        () => SbHttpManager.instance.send(url, headerToken: true, json: true),
      );
    }
    _warnOnce();
    return _debugCall(
      () => SbApiClient.instance.get<dynamic>(
        url,
        headers: <String, String>{'token': VoltaDebugOverrides.token},
      ),
    );
  }

  @override
  Future<dynamic> getText(String url) {
    if (!VoltaDebugOverrides.active) {
      return _appCall(() => SbHttpManager.instance.send(url, headerToken: true));
    }
    _warnOnce();
    return _debugCall(
      () => SbApiClient.instance.get<dynamic>(
        url,
        headers: <String, String>{'token': VoltaDebugOverrides.token},
      ),
    );
  }

  @override
  Future<dynamic> getPublic(String url) =>
      _appCall(() => SbHttpManager.instance.send(url, json: true));

  @override
  Future<dynamic> post(String url, String body, {required String language}) {
    if (!VoltaDebugOverrides.active) {
      return _appCall(
        () => SbHttpManager.instance.send(
          url,
          post: true,
          body: body,
          contentJson: true,
          headerToken: true,
          json: true,
          lng: language,
        ),
      );
    }
    _warnOnce();
    return _debugCall(
      () => SbApiClient.instance.post<dynamic>(
        url,
        data: body,
        headers: <String, String>{
          'token': VoltaDebugOverrides.token,
          'Content-Type': 'application/json',
          'lng': language,
        },
      ),
    );
  }

  static Future<dynamic> _appCall(Future<dynamic> Function() call) async {
    try {
      return await call();
    } on HttpException catch (e) {
      throw VoltaHttpException(e.statusCode, e.message, body: e.body);
    }
  }

  static Future<dynamic> _debugCall(
    Future<Response<dynamic>> Function() call,
  ) async {
    try {
      final Response<dynamic> response = await call();
      final int? code = response.statusCode;
      if (code == 502 || code == 504) return <String, dynamic>{};
      return response.data;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw VoltaHttpException(0, 'Request timeout');
      }
      throw VoltaHttpException(
        e.response?.statusCode ?? 0,
        'Network error: ${e.message}',
        body: e.response?.data,
      );
    }
  }

  static bool _warned = false;

  static void _warnOnce() {
    if (_warned) return;
    _warned = true;
    debugPrint(
      '⚠️  VoltaHttp: ĐANG DÙNG TOKEN ÉP CỨNG '
      '(${VoltaDebugOverrides.token}). Vòng làm mới token bị bỏ qua — '
      'sau vài phút sẽ bắt đầu nhận 401. Xoá VoltaDebugOverrides.token để '
      'quay lại token thật.',
    );
  }
}
