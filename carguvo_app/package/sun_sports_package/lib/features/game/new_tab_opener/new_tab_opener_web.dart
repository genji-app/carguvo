import 'dart:convert';
import 'dart:math';
import 'package:web/web.dart' as web;

bool openNewTabDirectly(String url) {
  final popup = web.window.open(url, '_blank');
  return popup != null;
}

void redirectToUrlDirectly(String url) {
  web.window.location.href = url;
}

bool openProviderBridgeTabDirectly({
  required String token,
  required String gameCode,
  required String providerId,
  required String productId,
  required String apiUrl,
  required String lang,
  required bool isMobileLogin,
}) {
  final nonce = Random().nextInt(99999999).toString();
  final storageKey = 's88_game_payload_$nonce';
  bool isLocalStorageSaved = false;

  final payloadMap = {
    'token': token,
    'apiUrl': apiUrl,
    'gameCode': gameCode,
    'providerId': providerId,
    'productId': productId,
    'lang': lang,
    'isMobileLogin': isMobileLogin,
  };

  try {
    web.window.localStorage.setItem(storageKey, jsonEncode(payloadMap));
    isLocalStorageSaved = true;
  } catch (_) {
    isLocalStorageSaved = false;
  }

  final currentUri = Uri.parse(web.window.location.href);
  final Map<String, String> queryParams = {'nonce': nonce};

  if (!isLocalStorageSaved) {
    queryParams.addAll({
      'token': token,
      'api': Uri.encodeComponent(apiUrl),
      'gameCode': gameCode,
      'providerId': providerId,
      'productId': productId,
      'lang': lang,
      'isMobileLogin': isMobileLogin.toString(),
    });
  }

  final targetUri = currentUri.resolve('provider/index.html').replace(
    queryParameters: queryParams,
  );

  final popup = web.window.open(targetUri.toString(), '_blank');
  return popup != null;
}
