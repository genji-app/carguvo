// ignore_for_file: depend_on_referenced_packages
import 'package:dart_kit/dart_kit.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dynamic_assets/dynamic_assets.dart';

final gameAssetCacheControllerProvider = Provider<AssetCacheController>((
  ref,
) {
  final assetStorage = HiveAssetStorage();
  final imageCacheManager = AssetImageCacheManager(
    Config(
      'app_resource_images',
      stalePeriod: const Duration(days: 3),
      maxNrOfCacheObjects: 2000,
    ),
  );
  final requestSemaphore = Semaphore(kIsWeb ? 6 : 10);

  return AssetCacheController(
    assetStorage: assetStorage,
    imageCacheManager: imageCacheManager,
    requestSemaphore: requestSemaphore,
    cacheVersionProvider: () => '1',
  );
});
