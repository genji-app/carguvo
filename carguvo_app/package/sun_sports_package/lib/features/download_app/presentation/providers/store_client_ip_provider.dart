import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/download_app/data/services/store_client_ip_service.dart';

final storeClientIpServiceProvider = Provider<StoreClientIpService>((ref) {
  final service = StoreClientIpService();
  ref.onDispose(service.dispose);
  return service;
});
