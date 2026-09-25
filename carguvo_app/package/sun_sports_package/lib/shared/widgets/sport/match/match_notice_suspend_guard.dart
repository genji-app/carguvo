import 'package:flutter/widgets.dart';
import 'package:sport_notice/sport_notice.dart' as notice;

class MatchNoticeSuspendGuard with WidgetsBindingObserver {
  MatchNoticeSuspendGuard({required this.onSuspend, DateTime Function()? clock})
      : _gapRules = notice.NoticeGapRules(clock: clock, onSuspend: onSuspend) {
    WidgetsBinding.instance.addObserver(this);
  }

  final VoidCallback onSuspend;

  final notice.NoticeGapRules _gapRules;

  bool _obscured = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        _obscured = true;
        onSuspend();
      case AppLifecycleState.resumed:
        if (_obscured) {
          _obscured = false;
          _gapRules.suppressFor(notice.NoticeGapRules.resumeCooldown);
          onSuspend();
        }
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  bool shouldSuppressTick() {
    if (_obscured) return true;
    return _gapRules.shouldSuppress();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
