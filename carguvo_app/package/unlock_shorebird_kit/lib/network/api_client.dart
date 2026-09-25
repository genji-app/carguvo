import 'dart:convert';

import 'package:unlock_shorebird_kit/models/unlock_command_response.dart';
import 'package:unlock_shorebird_kit/network/config_loader.dart';
import 'package:unlock_shorebird_kit/network/plain_body_dio_transformer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ApiClient {
  static Future<Map<String, dynamic>> getConfig(String url) =>
      ConfigLoader.getConfig(url);

  /// Uses Dio with a plain-body transformer so malformed `Content-Type` does not trigger MIME warnings.
  static Future<UnlockCommandResponse> getUnlockCommandResponse({
    required String url,
  }) async {
    final Stopwatch sw = Stopwatch()..start();
    print('[Unlock Shorebird] getUnlockCommandResponse GET $url');
    final Dio dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    dio.transformer = PlainBodyDioTransformer();
    try {
      final Response<String> response = await dio.get<String>(
        url,
        options: Options(responseType: ResponseType.plain),
      );
      final int httpElapsed = sw.elapsedMilliseconds;
      print(
        '[Unlock Shorebird] HTTP ${response.statusCode} '
        'in ${httpElapsed}ms body.length=${response.data?.length ?? 0}',
      );
      final String rawJson = (response.data ?? '').trim();
      print('[Unlock Shorebird] body=$rawJson');
      if (rawJson.isEmpty) {
        throw Exception('Empty unlock response body');
      }
      final dynamic decoded = jsonDecode(rawJson);
      if (decoded is! Map<String, dynamic>) {
        throw Exception(
          'Unlock response is not a JSON object. body=$rawJson',
        );
      }
      sw.stop();
      print(
        '[Unlock Shorebird] OK total=${sw.elapsedMilliseconds}ms '
        'parsed-keys=${decoded.keys.toList()}',
      );
      return UnlockCommandResponse.fromJson(decoded);
    } on DioException catch (e) {
      sw.stop();
      print(
        '[Unlock Shorebird] DioException after=${sw.elapsedMilliseconds}ms\n'
        '  type=${e.type}\n'
        '  message=${e.message}\n'
        '  statusCode=${e.response?.statusCode}\n'
        '  responseBody=${e.response?.data}',
      );
      rethrow;
    } catch (e) {
      sw.stop();
      print(
        '[Unlock Shorebird] FAILED after=${sw.elapsedMilliseconds}ms '
        'errorType=${e.runtimeType} error=$e',
      );
      rethrow;
    }
  }
}
