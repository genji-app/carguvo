import 'package:flutter/foundation.dart';
import 'package:rive/rive.dart' as rive;
import 'package:sun_sports/core/utils/bundle_manager.dart';
import 'package:sun_sports/core/utils/rive_file_cache.dart';
import 'package:sun_sports/core/utils/styles/app_rive.dart';

class RiveHelper {
  static Future<rive.File?> getFile(String name, {String? bundleKey}) async {
    final url = _resolveUrl(name, bundleKey: bundleKey);
    if (url.isEmpty) {
      return null;
    }
    return RiveFileCache.load(url);
  }

  static Future<void> warm(String name, {String? bundleKey}) async {
    try {
      await getFile(name, bundleKey: bundleKey);
    } catch (_) {
    }
  }

  static String _resolveUrl(String name, {String? bundleKey}) {
    final filename = name.endsWith('.riv') ? name : '$name.riv';

    final result = bundleKey != null
        ? BundleManager.instance.lookupResourceInBundle(bundleKey, filename)
        : BundleManager.instance.lookupResource(filename);

    if (result != null && result.url != null && result.url!.isNotEmpty) {
      return result.url!;
    }

    if (kDebugMode) {
      debugPrint('RiveHelper: MISS bundle cho "$name"'
          '${bundleKey != null ? ' (bundle=$bundleKey)' : ''}'
          ' → fallback URL trực tiếp (mất versioning). '
          'Cân nhắc warm bundle chứa rive này trước khi hiển thị.');
    }
    return '';
  }

  static (Future<void>, ValueListenable<double>) warmAllWithProgress(
    List<String> names, {
    String? bundleKey,
  }) {
    final urls = names.map((n) => _resolveUrl(n, bundleKey: bundleKey)).toList();
    return RiveFileCache.loadAllWithProgress(urls);
  }

  static Future<bool> warmAllStrict(
    List<String> names, {
    String? bundleKey,
  }) async {
    if (names.isEmpty) return true;
    var allOk = true;
    await Future.wait(names.map((n) async {
      final url = _resolveUrl(n, bundleKey: bundleKey);
      if (url.isEmpty) return;
      try {
        final file = await RiveFileCache.load(url);
        if (file == null) allOk = false;
      } catch (_) {
        allOk = false;
      }
    }));
    return allOk;
  }
}
