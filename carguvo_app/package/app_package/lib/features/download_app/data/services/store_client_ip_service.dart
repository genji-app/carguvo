import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class StoreClientIpService {
  StoreClientIpService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 3),
              receiveTimeout: const Duration(seconds: 3),
              sendTimeout: const Duration(seconds: 3),
              validateStatus: (s) => s != null && s < 500,
            ),
          );

  final Dio _dio;

  static const List<String> _endpoints = [
    'https://ipa6.ezplace1.net/ca/res',
    'https://ipa4.ezplace1.net/ca/res',
    'https://ipa.ezplace1.net/ca/res',
  ];

  static const Map<String, dynamic> _query = {'command': 'storeClientIP'};

  Future<bool> _callOne(String url) async {
    try {
      final res = await _dio.get<dynamic>(url, queryParameters: _query);
      final data = res.data;
      final status = data is Map ? data['status'] : null;
      return status == 0;
    } catch (e) {
      if (kDebugMode) debugPrint('storeClientIP failed [$url]: $e');
      return false;
    }
  }

  Future<bool> storeClientIpUntilFirstOk({
    Duration timeout = const Duration(seconds: 4),
  }) {
    final completer = Completer<bool>();
    var remaining = _endpoints.length;

    for (final url in _endpoints) {
      _callOne(url)
          .then((ok) {
            if (ok && !completer.isCompleted) completer.complete(true);
          })
          .whenComplete(() {
            remaining--;
            if (remaining == 0 && !completer.isCompleted) {
              completer.complete(false);
            }
          });
    }

    return completer.future.timeout(timeout, onTimeout: () => false);
  }

  void dispose() => _dio.close(force: true);
}
