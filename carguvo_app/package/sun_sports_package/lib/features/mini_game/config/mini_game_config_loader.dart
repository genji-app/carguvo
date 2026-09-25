import 'dart:convert';

import 'package:dio/dio.dart';

import 'mini_game_remote_config.dart';

class MiniGameConfigLoader {
  static const String configUrl =
      'https://raw.githubusercontent.com/jamesgreenmango/configs/refs/heads/master/cc213AppConfig.json';

  final Dio _dio;

  MiniGameConfigLoader({Dio? dio}) : _dio = dio ?? Dio();

  Future<MiniGameRemoteConfig> load() async {
    final url = '$configUrl?_=${DateTime.now().millisecondsSinceEpoch}';
    final resp = await _dio.get<String>(
      url,
      options: Options(responseType: ResponseType.plain),
    );
    final json = jsonDecode(resp.data ?? '{}') as Map<String, dynamic>;
    return MiniGameRemoteConfig.fromJson(json);
  }
}
