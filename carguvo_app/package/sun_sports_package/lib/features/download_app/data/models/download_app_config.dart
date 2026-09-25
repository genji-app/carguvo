import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sun_sports/core/utils/web_browser_detect/web_browser_detect.dart';

part 'download_app_config.freezed.dart';
part 'download_app_config.g.dart';

enum DownloadAppPlatform { android, ios }

DownloadAppPlatform? get currentDownloadAppPlatform {
  if (kIsWeb) {
    if (isWebAndroidBrowser) return DownloadAppPlatform.android;
    if (isWebIOSBrowser) return DownloadAppPlatform.ios;
    return null;
  }
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => DownloadAppPlatform.android,
    TargetPlatform.iOS => DownloadAppPlatform.ios,
    _ => null,
  };
}

@freezed
sealed class DownloadAppConfig with _$DownloadAppConfig {
  const factory DownloadAppConfig({
    @JsonKey(name: 'app_name') @Default('') String appName,
    @JsonKey(name: 'description') @Default('') String description,
    @JsonKey(name: 'full_description') @Default('') String fullDescription,
    @JsonKey(name: 'type') @Default('') String type,
    @JsonKey(name: 'url_demo_screen') @Default('') String demoScreenshot,
    @JsonKey(name: 'url_icon_app') @Default('') String urlIconApp,
    @JsonKey(name: 'url_ios_store') @Default('') String urlIosStore,
    @JsonKey(name: 'url_android_store') @Default('') String urlAndroidStore,
    @JsonKey(name: 'url_file_android_apk')
    @Default('')
    String urlFileAndroidApk,
  }) = _DownloadAppConfig;

  factory DownloadAppConfig.fromJson(Map<String, Object?> json) =>
      _$DownloadAppConfigFromJson(json);
}

class DownloadAppRemoteConfig {
  const DownloadAppRemoteConfig({this.android, this.ios});

  final DownloadAppConfig? android;

  final DownloadAppConfig? ios;

  static DownloadAppConfig? _entry(Object? value) => value is Map
      ? DownloadAppConfig.fromJson(Map<String, Object?>.from(value))
      : null;

  factory DownloadAppRemoteConfig.fromJson(Map<String, Object?> json) =>
      DownloadAppRemoteConfig(
        android: _entry(json['android']),
        ios: _entry(json['ios']),
      );

  DownloadAppConfig? forPlatform(DownloadAppPlatform? platform) =>
      switch (platform) {
        DownloadAppPlatform.android => android,
        DownloadAppPlatform.ios => ios,
        null => null,
      };

  DownloadAppConfig? get current => forPlatform(currentDownloadAppPlatform);

  DownloadAppConfig get display =>
      current ?? ios ?? android ?? const DownloadAppConfig();
}
