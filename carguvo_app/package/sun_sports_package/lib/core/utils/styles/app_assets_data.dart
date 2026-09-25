import 'package:sun_sports/core/utils/extensions/assets_data.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_rive.dart';

class AppAssetsData {
  AppAssetsData._();

  static final Map<String, int> _versionOverrides = <String, int>{
  };

  static List<AssetsData> get all =>
      _allUrls.map(_buildAsset).toList(growable: false);

  static List<AssetsData> get allIcons =>
      _iconUrls.map(_buildAsset).toList(growable: false);

  static List<AssetsData> get allImages =>
      _imageUrls.map(_buildAsset).toList(growable: false);

  static List<AssetsData> get allRive =>
      _riveUrls.map(_buildAsset).toList(growable: false);

  static Set<String> get _allUrls => <String>{
    ..._iconUrls,
    ..._imageUrls,
    ..._riveUrls,
  };

  static Set<String> get _iconUrls => <String>{
    ...AppIcons.remoteUrlsForPreload,
  
  };

  static Set<String> get _imageUrls => <String>{
    ...AppImages.remoteUrlsForPreload,
  };

  static Set<String> get _riveUrls => <String>{
    ...AppRive.remoteUrlsForPreload,
  };

  static AssetsData _buildAsset(String url) {
    final newV = _versionOverrides[url] ?? 1;
    final oldV = newV > 1 ? newV - 1 : 1;
    return AssetsData(
      label: _labelOf(url),
      urlPath: url,
      oldVersion: oldV,
      newVersion: newV,
    );
  }

  static String _labelOf(String url) {
    final filename = url.split('/').last;
    final base = filename
        .replaceAll(RegExp(r'\.\w+$'), '')
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    return 'asset_$base';
  }
}
