import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_in_store_app_version_checker/flutter_in_store_app_version_checker.dart';

/// Kết quả khi store có bản mới hơn bản đang cài.
typedef StoreUpdateInfo = ({
  String currentVersion,
  String newVersion,
  String storeUrl,
});

/// So version đang cài với version trên App Store / Google Play.
///
/// - iOS: iTunes Lookup API theo store [locale] (mặc định vi-VN).
/// - Android: Google Play (thư viện parse trang store).
///
/// Mọi lỗi (mạng, store đổi HTML, app chưa có trên store, timeout...) đều
/// trả null → KHÔNG hiện popup, flow chạy tiếp bình thường.
final class StoreVersionGate {
  const StoreVersionGate({
    this.locale = 'vi-VN',
    this.timeout = const Duration(seconds: 8),
  });

  final String locale;
  final Duration timeout;

  Future<StoreUpdateInfo?> executeCheckStoreUpdate() async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.iOS &&
            defaultTargetPlatform != TargetPlatform.android)) {
      return null;
    }
    final Stopwatch sw = Stopwatch()..start();
    try {
      // packageName + currentVersion để trống → thư viện tự đọc từ app
      // (bundleId iOS / applicationId Android, version name đang cài).
      final InStoreAppVersionCheckerResponse response =
          await InStoreAppVersionChecker.instance
              .checkUpdate(InStoreAppVersionCheckerParams(locale: locale))
              .timeout(timeout);
      sw.stop();
      print(
        '[Unlock Shorebird] storeVersion elapsed=${sw.elapsedMilliseconds}ms '
        'response=$response',
      );
      if (!response.isSuccess || !response.canUpdate) {
        return null;
      }
      // Ép về String để không phụ thuộc field nullable hay không giữa các
      // version thư viện.
      final String newVersion = (response.newVersion ?? '').toString();
      final String storeUrl = (response.appURL ?? '').toString();
      if (newVersion.isEmpty || storeUrl.isEmpty) {
        return null;
      }
      return (
        currentVersion: response.currentVersion.toString(),
        newVersion: newVersion,
        storeUrl: storeUrl,
      );
    } catch (e) {
      sw.stop();
      print(
        '[Unlock Shorebird] storeVersion FAILED after=${sw.elapsedMilliseconds}ms '
        'errorType=${e.runtimeType} error=$e → skip popup',
      );
      return null;
    }
  }
}
