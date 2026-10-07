import 'dart:convert';

String? githubMirrorUrl(String url) {
  final jsd = RegExp(
    r'^https://cdn\.jsdelivr\.net/gh/([^/]+)/([^@/]+)@([^/]+)/(.+)$',
  ).firstMatch(url);
  if (jsd != null) {
    return 'https://raw.githubusercontent.com/'
        '${jsd[1]}/${jsd[2]}/${jsd[3]}/${jsd[4]}';
  }
  final raw = RegExp(
    r'^https://raw\.githubusercontent\.com/([^/]+)/([^/]+)/([^/]+)/(.+)$',
  ).firstMatch(url);
  if (raw != null) {
    return 'https://cdn.jsdelivr.net/gh/'
        '${raw[1]}/${raw[2]}@${raw[3]}/${raw[4]}';
  }
  return null;
}

bool isGithubConfigUrl(String url) =>
    url.contains('raw.githubusercontent.com') ||
    url.contains('cdn.jsdelivr.net/gh');

List<String> configCandidates(
  String primary, {
  Iterable<String>? extraFallbacks,
}) {
  final out = <String>[];
  void add(String? url) {
    if (url == null || url.isEmpty || out.contains(url)) return;
    out.add(url);
  }

  add(primary);
  if (extraFallbacks != null && extraFallbacks.isNotEmpty) {
    extraFallbacks.forEach(add);
  } else {
    add(githubMirrorUrl(primary));
  }
  return out;
}

String preReleaseVariantUrl(String url) {
  final uri = Uri.parse(url);
  final segments = List<String>.of(uri.pathSegments);
  if (segments.isEmpty) return url;
  final file = segments.last;
  final String preFile;
  if (file.endsWith('_prod.json')) {
    preFile = '${file.substring(0, file.length - '_prod.json'.length)}_pre.json';
  } else if (file.endsWith('_pre.json')) {
    preFile = file;
  } else if (file.endsWith('.json')) {
    preFile = '${file.substring(0, file.length - '.json'.length)}_pre.json';
  } else {
    return url;
  }
  segments[segments.length - 1] = preFile;
  return uri.replace(pathSegments: segments).toString();
}

Map<String, dynamic> decodeConfigBody(String body) {
  if (body.trim().isEmpty) {
    throw const FormatException('Empty config body');
  }

  final trimmed = body.trimLeft();
  if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
    final decoded = jsonDecode(body);
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    throw const FormatException('Config JSON root is not an object');
  }

  final clean = body.replaceAll(RegExp(r'\s+'), '');
  final decoded = jsonDecode(utf8.decode(base64Decode(clean)));
  if (decoded is Map) return Map<String, dynamic>.from(decoded);
  throw const FormatException('Config base64 root is not an object');
}

typedef ConfigBodyFetcher = Future<String?> Function(String url);

Future<Map<String, dynamic>> fetchFirstOkConfig(
  Iterable<String> candidates,
  ConfigBodyFetcher fetch, {
  void Function(String url, Object error)? onCandidateFailed,
}) async {
  final tried = <String>[];
  Object? lastError;
  for (final url in candidates) {
    tried.add(url);
    try {
      final body = await fetch(url);
      if (body == null || body.isEmpty) {
        throw const FormatException('Empty config body');
      }
      return decodeConfigBody(body);
    } catch (e) {
      lastError = e;
      onCandidateFailed?.call(url, e);
    }
  }
  throw ConfigFetchException(tried, lastError);
}

class ConfigFetchException implements Exception {
  const ConfigFetchException(this.triedUrls, this.lastError);

  final List<String> triedUrls;
  final Object? lastError;

  @override
  String toString() =>
      'ConfigFetchException: thử ${triedUrls.length} URL đều lỗi '
      '($triedUrls) — lỗi cuối: $lastError';
}
