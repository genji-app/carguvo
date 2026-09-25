import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/services/network/sb_http_manager.dart';
import 'package:sun_sports/core/services/storage/sport_storage.dart';

final sbHttpManagerProvider = Provider<SbHttpManager>(
  (ref) => SbHttpManager.instance,
);

final sportStorageProvider = Provider<SportStorage>(
  (ref) => SportStorage.instance,
);
