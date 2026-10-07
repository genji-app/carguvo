import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_package/core/services/network/sb_http_manager.dart';
import 'package:app_package/core/services/storage/sport_storage.dart';

final sbHttpManagerProvider = Provider<SbHttpManager>(
  (ref) => SbHttpManager.instance,
);

final sportStorageProvider = Provider<SportStorage>(
  (ref) => SportStorage.instance,
);
