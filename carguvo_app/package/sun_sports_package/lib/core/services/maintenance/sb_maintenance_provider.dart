import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/services/maintenance/maintenance_service.dart';

class SbMaintenanceNotifier extends Notifier<String?> {
  @override
  String? build() {
    final source = MaintenanceService.instance.message;
    void onChanged() => state = source.value;
    source.addListener(onChanged);
    ref.onDispose(() => source.removeListener(onChanged));
    return source.value;
  }
}

final sbMaintenanceMessageProvider =
    NotifierProvider<SbMaintenanceNotifier, String?>(SbMaintenanceNotifier.new);

final sbMaintenanceProvider = Provider<bool>(
  (ref) => ref.watch(sbMaintenanceMessageProvider) != null,
);
