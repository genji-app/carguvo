import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../config/mini_game_config_providers.dart';
import 'mini_game_downloader.dart';

final miniGameAssetDioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));
  return dio;
});

final miniGameDownloaderProvider = FutureProvider<MiniGameDownloader>((ref) async {
  final hostUrl = ref.watch(miniGameHostUrlProvider);
  final cacheBase = kIsWeb ? '' : (await getApplicationDocumentsDirectory()).path;
  final dio = ref.watch(miniGameAssetDioProvider);
  return MiniGameDownloader(hostUrl: hostUrl, cacheBase: cacheBase, dio: dio);
});
