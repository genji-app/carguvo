import 'dart:convert';

class JwtClaims {
  JwtClaims._();

  static Map<String, dynamic>? decode(String? token) {
    if (token == null || token.isEmpty) return null;
    final parts = token.split('.');
    if (parts.length != 3) return null;
    try {
      final normalized =
          base64.normalize(parts[1].replaceAll('-', '+').replaceAll('_', '/'));
      final payload = jsonDecode(utf8.decode(base64.decode(normalized)));
      if (payload is! Map) return null;
      return Map<String, dynamic>.from(payload);
    } catch (_) {
      return null;
    }
  }

  static DateTime? expiry(String? token) {
    final exp = decode(token)?['exp'];
    if (exp is! num) return null;
    return DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000);
  }

  static bool isExpired(String? token) {
    final exp = expiry(token);
    if (exp == null) return true;
    return DateTime.now().isAfter(exp);
  }
}
