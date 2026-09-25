import 'dart:convert';
// ignore: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;

void savePreloadedUrls(List<String> urls) {
  try {
    html.window.localStorage['s88_preloaded_urls'] = jsonEncode(urls);
  } catch (_) {}
}
