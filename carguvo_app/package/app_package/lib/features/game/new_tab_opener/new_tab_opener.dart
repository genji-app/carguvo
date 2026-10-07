import 'new_tab_opener_stub.dart'
    if (dart.library.js_interop) 'new_tab_opener_web.dart';

bool openNewTab(String url) {
  return openNewTabDirectly(url);
}

void redirectToUrl(String url) {
  redirectToUrlDirectly(url);
}

bool openProviderBridgeTab({
  required String token,
  required String gameCode,
  required String providerId,
  required String productId,
  required String apiUrl,
  required String lang,
  required bool isMobileLogin,
}) {
  return openProviderBridgeTabDirectly(
    token: token,
    gameCode: gameCode,
    providerId: providerId,
    productId: productId,
    apiUrl: apiUrl,
    lang: lang,
    isMobileLogin: isMobileLogin,
  );
}
