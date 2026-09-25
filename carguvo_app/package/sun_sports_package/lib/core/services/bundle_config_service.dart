import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:sun_sports/core/constants/app_version.dart';
import 'package:sun_sports/core/services/config/sb_config.dart';

class _VersionResourceConfig {
  final Map<String, String> appVersions;
  final String defaultHash;
  final String? dynamicHash;

  _VersionResourceConfig({
    required this.appVersions,
    required this.defaultHash,
    this.dynamicHash,
  });

  factory _VersionResourceConfig.fromJson(Map<String, dynamic> json) {
    return _VersionResourceConfig(
      appVersions:
          (json['app_versions'] as Map<String, dynamic>?)
                  ?.map((k, v) => MapEntry(k, v as String)) ??
              {},
      defaultHash: (json['default'] as String?) ?? '',
      dynamicHash: json['dynamic'] as String?,
    );
  }
}

class BundleConfigMapping {
  final Map<String, String> bundles;

  BundleConfigMapping({required this.bundles});

  factory BundleConfigMapping.fromJson(Map<String, dynamic> json) {
    final map = <String, String>{};
    for (final entry in json.entries) {
      if (entry.key == 'created_at') continue;
      if (entry.value is String && (entry.value as String).length == 8) {
        map[entry.key] = entry.value as String;
      }
    }
    return BundleConfigMapping(bundles: map);
  }
}

class BundleConfigService {
  BundleConfigService._();
  static final BundleConfigService instance = BundleConfigService._();

  BundleConfigMapping? _cachedMapping;
  String? _dynamicBundleHash;

  String get _cdnBase {
    final base = SbConfig.rsDomain;
    if (base.isEmpty) return '';
    return base.endsWith('/') ? base : '$base/';
  }

  String get _versionConfigUrl => '${_cdnBase}version_resource_config.json?t=${DateTime.now().millisecondsSinceEpoch}';

  String _bundleConfigUrl(String hash) =>
      '${_cdnBase}assets/bundle_config.$hash.json';

  Future<String> _cachePath() async {
    final dir = await getApplicationSupportDirectory();
    final cacheDir = Directory('${dir.path}/bundle_config_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return '${cacheDir.path}/bundle_config.json';
  }

  Future<void> _saveLocal(String body) async {
    if (kIsWeb) return;
    try {
      final path = await _cachePath();
      await File(path).writeAsString(body);
    } catch (_) {}
  }

  Future<String?> _loadLocal() async {
    if (kIsWeb) return null;
    try {
      final path = await _cachePath();
      final file = File(path);
      if (await file.exists()) return await file.readAsString();
    } catch (_) {}
    return null;
  }

  Future<BundleConfigMapping> load() async {
    if (_cachedMapping != null) return _cachedMapping!;

    String bundleConfigHash;

    try {
      final versionResponse = await http
          .get(Uri.parse(_versionConfigUrl))
          .timeout(const Duration(seconds: 10));
      if (versionResponse.statusCode == 200) {
        final versionConfig =
            _VersionResourceConfig.fromJson(
                jsonDecode(versionResponse.body) as Map<String, dynamic>);

        if (versionConfig.dynamicHash != null &&
            versionConfig.dynamicHash!.isNotEmpty) {
          _dynamicBundleHash = versionConfig.dynamicHash;
        }

        if (kIsWeb) {
          bundleConfigHash = versionConfig.defaultHash;
        } else {
          bundleConfigHash =
              versionConfig.appVersions[AppVersion.code] ??
              versionConfig.defaultHash;
        }
      } else {
        throw Exception('HTTP ${versionResponse.statusCode}');
      }
    } catch (e) {
      debugPrint('BundleConfigService: fetch version config failed: $e');
      final local = await _loadLocal();
      if (local != null) {
        _cachedMapping =
            BundleConfigMapping.fromJson(
                jsonDecode(local) as Map<String, dynamic>);
        return _cachedMapping!;
      }
      rethrow;
    }

    if (bundleConfigHash.isEmpty) {
      throw Exception('BundleConfigService: empty hash from version config');
    }

    try {
      final configResponse = await http
          .get(Uri.parse(_bundleConfigUrl(bundleConfigHash)))
          .timeout(const Duration(seconds: 15));
      if (configResponse.statusCode == 200) {
        _cachedMapping =
            BundleConfigMapping.fromJson(
                jsonDecode(configResponse.body) as Map<String, dynamic>);
        await _saveLocal(configResponse.body);
        return _cachedMapping!;
      } else {
        throw Exception('HTTP ${configResponse.statusCode}');
      }
    } catch (e) {
      debugPrint(
          'BundleConfigService: fetch bundle config failed: $e');
      final local = await _loadLocal();
      if (local != null) {
        _cachedMapping =
            BundleConfigMapping.fromJson(
                jsonDecode(local) as Map<String, dynamic>);
        return _cachedMapping!;
      }
      rethrow;
    }
  }

  String getBundleHash(String bundleKey) {
    if (bundleKey == 'dynamic') {
      return getDynamicBundleHash();
    }
    return _cachedMapping?.bundles[bundleKey] ?? '';
  }

  String getDynamicBundleHash() => _dynamicBundleHash ?? '';

  void reset() {
    _cachedMapping = null;
    _dynamicBundleHash = null;
  }
}
