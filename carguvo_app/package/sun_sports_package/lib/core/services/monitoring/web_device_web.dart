import 'package:web/web.dart' as web;

bool? isWebMobileDevice() {
  final nav = web.window.navigator;
  final ua = nav.userAgent.toLowerCase();

  final mobileToken = RegExp(
    r'mobi|android|iphone|ipod|ipad|iemobile|blackberry|opera mini|windows phone|webos',
  );
  if (mobileToken.hasMatch(ua)) return true;

  if (ua.contains('macintosh') && nav.maxTouchPoints > 1) return true;

  return false;
}
