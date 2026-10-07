import 'package:app_env/app_env.dart'
    show
        isSbUnavailableStatus,
        kSbMaintenanceCode,
        kSbMaintenanceDebugQueryParam,
        kSbMaintenanceDefaultMessage,
        kSbMaintenanceShortMessage;
import 'package:flutter/foundation.dart';

class MaintenanceService {
  MaintenanceService._();

  static final MaintenanceService instance = MaintenanceService._();

  static const int maintenanceCode = kSbMaintenanceCode;

  static bool isUnavailableStatus(int statusCode) =>
      isSbUnavailableStatus(statusCode);

  static const String debugQueryParam = kSbMaintenanceDebugQueryParam;

  static const String defaultMessage = kSbMaintenanceDefaultMessage;

  static const String shortMessage = kSbMaintenanceShortMessage;

  final ValueNotifier<String?> message = ValueNotifier<String?>(null);

  bool get isUnderMaintenance => message.value != null;

  void trigger([String text = defaultMessage]) {
    if (message.value == text) return;
    message.value = text;
  }

  void clear() {
    if (_debugOverrideActive) return;
    message.value = null;
  }

  bool _debugOverrideActive = false;

  void applyDebugOverride() {
    if (!_debugMaintenanceRequested) return;
    debugPrint('🛠️ [SB] Giả lập bảo trì SB (sb_maintain=1)');
    _debugOverrideActive = true;
    trigger();
  }

  static bool get _debugMaintenanceRequested {
    const native = String.fromEnvironment('SB_MAINTAIN');
    if (native == '1' || native == 'true') return true;
    final raw = Uri.base.queryParameters[debugQueryParam];
    return raw == '1' || raw == 'true';
  }
}
