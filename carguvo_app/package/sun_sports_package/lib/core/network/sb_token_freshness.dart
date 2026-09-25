import 'dart:convert';

import 'package:dio/dio.dart';

const List<String> kTokenHeaderKeys = ['Authorization', 'token'];

bool isRefreshChainUrl(String url) {
  final lowerUrl = url.toLowerCase();
  if (lowerUrl.contains('command=refreshtoken')) return true;
  if (lowerUrl.endsWith('/refreshtoken')) return true;
  if (lowerUrl.contains('command=loginaccesstoken')) return true;
  if (lowerUrl.contains('command=get-token')) return true;
  return false;
}

bool carriesSbToken(RequestOptions options, String sbToken) {
  if (sbToken.isEmpty) return false;

  for (final key in kTokenHeaderKeys) {
    if (options.headers[key] == sbToken) return true;
  }

  if (options.uri.queryParameters['token'] == sbToken) return true;

  final body = options.data;
  if (body is String && body.contains(sbToken)) return true;

  return false;
}

bool isNonIdempotentWrite(String path) {
  final p = path.toLowerCase();
  if (p.contains('place-bet')) return true;
  if (p.contains('cash-out') && !p.contains('cash-out/get')) return true;
  return false;
}

bool isSuspiciousEmptyBody(dynamic data) {
  if (data == null) return true;
  if (data is String) {
    final trimmed = data.trim();
    return trimmed.isEmpty || trimmed == '[]' || trimmed == '{}';
  }
  if (data is Iterable) return data.isEmpty;
  if (data is Map) return data.isEmpty;
  return false;
}

void reapplySbTokens(
  RequestOptions options, {
  required String oldSb,
  required String oldAccess,
  required String newSb,
  required String newAccess,
}) {
  String? remap(Object? value) {
    if (value == oldSb) return newSb;
    if (value == oldAccess) return newAccess;
    return null;
  }

  for (final key in kTokenHeaderKeys) {
    final value = options.headers[key];
    if (value == null) continue;
    final next = remap(value);
    if (next != null) options.headers[key] = next;
  }

  _remapPathQueryToken(options, remap);

  final queryToken = options.queryParameters['token'];
  if (queryToken != null) {
    final next = remap(queryToken);
    if (next != null) options.queryParameters['token'] = next;
  }

  _remapBodyToken(options, remap, newSb);
}

void _remapPathQueryToken(
  RequestOptions options,
  String? Function(Object? value) remap,
) {
  final path = options.path;
  if (!path.contains('token=')) return;

  final current = Uri.tryParse(path)?.queryParameters['token'];
  if (current == null) return;

  final next = remap(current);
  if (next == null) return;

  for (final prefix in const ['?token=', '&token=']) {
    final needle = '$prefix$current';
    final start = path.indexOf(needle);
    if (start < 0) continue;
    final end = start + needle.length;
    if (end != path.length && path[end] != '&') continue;
    options.path = path.replaceRange(start + prefix.length, end, next);
    return;
  }
}

void _remapBodyToken(
  RequestOptions options,
  String? Function(Object? value) remap,
  String newSb,
) {
  final body = options.data;
  if (body is! String || body.isEmpty) return;
  try {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic> || !decoded.containsKey('token')) {
      return;
    }
    final value = decoded['token'];
    if (value is String && value.isEmpty) {
      decoded['token'] = newSb;
    } else {
      final next = remap(value);
      if (next == null) return;
      decoded['token'] = next;
    }
    options.data = jsonEncode(decoded);
  } catch (_) {
  }
}
