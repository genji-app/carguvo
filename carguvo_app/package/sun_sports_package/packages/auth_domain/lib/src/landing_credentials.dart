import 'dart:convert';

class LandingCredentials {
  final String username;

  final String password;

  const LandingCredentials({required this.username, this.password = ''});

  bool get hasPassword => password.isNotEmpty;
}

const int kMaxLandingHashLength = 8192;

LandingCredentials? parseLandingCredentials(
  String? raw, {
  void Function(String message)? log,
}) {
  if (raw == null) return null;
  var data = raw.trim();
  if (data.isEmpty || data.length > kMaxLandingHashLength) return null;

  try {
    data = Uri.decodeComponent(data);
  } catch (_) {}
  if (data.startsWith('#')) data = data.substring(1);
  if (data.isEmpty) return null;

  final decoded = _tryBase64ToString(data);
  if (decoded == null) {
    log?.call('🔑 [LandingAuth] base64 decode FAILED for "$data"');
    return null;
  }

  try {
    final dynamic json = jsonDecode(decoded);
    if (json is! Map) return null;
    final username = (json['username'] ?? '').toString().trim();
    final password = (json['password'] ?? '').toString();
    if (username.isEmpty) {
      log?.call('🔑 [LandingAuth] thiếu username trong JSON: $decoded');
      return null;
    }
    return LandingCredentials(username: username, password: password);
  } catch (e) {
    log?.call('🔑 [LandingAuth] JSON parse FAILED ("$decoded"): $e');
    return null;
  }
}

String? _tryBase64ToString(String input) {
  var s = input.replaceAll('-', '+').replaceAll('_', '/');
  final mod = s.length % 4;
  if (mod != 0) s = s.padRight(s.length + (4 - mod), '=');
  try {
    return utf8.decode(base64.decode(s));
  } catch (_) {
    return null;
  }
}
