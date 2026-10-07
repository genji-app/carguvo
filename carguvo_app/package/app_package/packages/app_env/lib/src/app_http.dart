typedef HttpGetter = Future<String?> Function(
  String url, {
  Map<String, String>? headers,
});

typedef HttpPoster = Future<String?> Function(
  String url,
  String jsonBody, {
  Map<String, String>? headers,
});

class AppHttp {
  AppHttp._();

  static HttpGetter? _get;
  static HttpPoster? _post;

  static bool get isConfigured => _get != null && _post != null;

  static void configure({required HttpGetter get, required HttpPoster post}) {
    _get = get;
    _post = post;
  }

  static void resetForTesting() {
    _get = null;
    _post = null;
  }

  static Future<String?> get(String url, {Map<String, String>? headers}) async {
    final fn = _get;
    if (fn == null) return null;
    return fn(url, headers: headers);
  }

  static Future<String?> post(
    String url,
    String jsonBody, {
    Map<String, String>? headers,
  }) async {
    final fn = _post;
    if (fn == null) return null;
    return fn(url, jsonBody, headers: headers);
  }
}
