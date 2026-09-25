import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/utils/extensions/log_helper.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class WakelockController with LoggerMixin {
  @override
  String get logTag => 'Wakelock';

  Future<void> enable() async {
    try {
      await WakelockPlus.enable();
    } catch (e, st) {
      logError('Failed to enable wakelock', e, st);
    }
  }

  Future<void> disable() async {
    try {
      await WakelockPlus.disable();
    } catch (e, st) {
      logError('Failed to disable wakelock', e, st);
    }
  }
}

final wakelockProvider = Provider<WakelockController>((ref) {
  return WakelockController();
});
