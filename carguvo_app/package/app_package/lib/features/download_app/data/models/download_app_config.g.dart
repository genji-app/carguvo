
part of 'download_app_config.dart';

_DownloadAppConfig _$DownloadAppConfigFromJson(Map<String, dynamic> json) =>
    _DownloadAppConfig(
      appName: json['app_name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      fullDescription: json['full_description'] as String? ?? '',
      type: json['type'] as String? ?? '',
      demoScreenshot: json['url_demo_screen'] as String? ?? '',
      urlIconApp: json['url_icon_app'] as String? ?? '',
      urlIosStore: json['url_ios_store'] as String? ?? '',
      urlAndroidStore: json['url_android_store'] as String? ?? '',
      urlFileAndroidApk: json['url_file_android_apk'] as String? ?? '',
    );

Map<String, dynamic> _$DownloadAppConfigToJson(_DownloadAppConfig instance) =>
    <String, dynamic>{
      'app_name': instance.appName,
      'description': instance.description,
      'full_description': instance.fullDescription,
      'type': instance.type,
      'url_demo_screen': instance.demoScreenshot,
      'url_icon_app': instance.urlIconApp,
      'url_ios_store': instance.urlIosStore,
      'url_android_store': instance.urlAndroidStore,
      'url_file_android_apk': instance.urlFileAndroidApk,
    };
