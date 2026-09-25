import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terminate_restart/terminate_restart.dart';
import 'package:unlock_shorebird_kit/core/net_diag.dart';

/// Bọc toàn bộ cây app để cung cấp "fade-to-black rồi restart process".
///
/// Vì sao phải restart PROCESS (terminate: true) chứ không remount widget:
/// patch Shorebird chỉ được nạp khi engine boot lại (`libapp.so` đã patch).
/// Remount widget tree giữ nguyên VM → vẫn chạy snapshot cũ → patch KHÔNG
/// có hiệu lực.
///
/// ---
/// ## Vì sao file này nhiều "lớp bảo vệ" đến vậy
///
/// Overlay đen dùng `IgnorePointer(ignoring: !_fadeToBlack)`: khi đang đen
/// thì NUỐT toàn bộ touch. Nên nếu `_fadeToBlack` kẹt ở `true` = app khoá
/// cứng, user phải force-kill. Bốn đường kẹt đã gặp thật:
///
/// 1. `restartApp` ném exception (vd `MissingPluginException` khi patch
///    Shorebird chạy trên binary thiếu plugin `terminate_restart`) → unwind
///    qua chỗ reset → đen vĩnh viễn.
/// 2. `restartApp` trả `true` nhưng process KHÔNG chết (iOS hạn chế
///    `exit(0)`, một số OEM Android chặn `killProcess`) → code tưởng "sắp
///    biến mất, khỏi dọn" → đen vĩnh viễn.
/// 3. Android background trước rồi mới kill; kill hụt → user mở lại rơi
///    thẳng vào màn đen.
/// 4. `!mounted` sau delay fade → trả false mà không reset.
///
/// → MỌI nhánh fail phải đi qua [_abortFade] — điểm thoát DUY NHẤT khỏi
/// trạng thái đen. Thêm nhánh mới thì gọi nó, đừng `setState` trực tiếp.
class RestartScope extends StatefulWidget {
  const RestartScope({super.key, required this.child});

  final Widget child;

  static _RestartScopeState? _state;

  /// Fade-out → restart process. Trả `true` khi native NHẬN lệnh restart
  /// (không phải bằng chứng process đã chết — xem watchdog bên dưới).
  ///
  /// Chữ ký khớp với `SplashModeScreen.executeRestartWithFade`.
  static Future<bool> executeRestartWithFade(BuildContext context) {
    final _RestartScopeState? state = _state;
    if (state == null) {
      netDiag('RestartScope', '❌ chưa có RestartScope trong cây → bỏ qua');
      return Future<bool>.value(false);
    }
    return state.executeRestartApp();
  }

  @override
  State<RestartScope> createState() => _RestartScopeState();
}

class _RestartScopeState extends State<RestartScope>
    with WidgetsBindingObserver {
  static const Duration _fadeDuration = Duration(milliseconds: 300);

  /// `restartApp` trả `true` chỉ là LỜI HỨA, không phải bằng chứng process
  /// đã chết. Cố ý KHÔNG cancel watchdog ở nhánh `true`: nếu sau 5s process
  /// vẫn sống thì chắc chắn restart đã fail → gỡ màn đen.
  static const Duration _watchdog = Duration(seconds: 5);

  bool _fadeToBlack = false;
  bool _restartInFlight = false;
  Timer? _watchdogTimer;
  Key _appKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    RestartScope._state = this;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _watchdogTimer?.cancel();
    _watchdogTimer = null;
    if (identical(RestartScope._state, this)) {
      RestartScope._state = null;
    }
    super.dispose();
  }

  /// Lớp bảo vệ #3: app quay lại foreground mà vẫn đen = kill đã hụt.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _fadeToBlack) {
      netDiag(
        'RestartScope',
        'resumed mà vẫn đen → kill hụt, gỡ overlay để app dùng được',
      );
      _abortFade();
    }
  }

  /// Điểm thoát DUY NHẤT khỏi trạng thái đen.
  void _abortFade() {
    _watchdogTimer?.cancel();
    _watchdogTimer = null;
    _restartInFlight = false;
    if (!mounted) {
      return;
    }
    setState(() {
      _fadeToBlack = false;
    });
  }

  /// Fallback KHI VÀ CHỈ KHI restart process thất bại: dựng lại toàn bộ cây.
  ///
  /// LƯU Ý: remount KHÔNG apply patch Shorebird (VM vẫn là VM cũ). Nó chỉ
  /// cứu app khỏi trạng thái treo. Registry của GetX là static nên phải
  /// `Get.reset()` trước, nếu không cây mới sẽ gặp lại controller singleton cũ.
  void _remountSubtree() {
    netDiag(
      'RestartScope',
      '⚠️ restart process FAIL → remount cây (KHÔNG apply patch Shorebird)',
    );
    Get.reset();
    if (!mounted) {
      return;
    }
    setState(() {
      _appKey = UniqueKey();
    });
  }

  Future<bool> executeRestartApp() async {
    if (_restartInFlight) {
      netDiag('RestartScope', 'đang restart rồi → bỏ qua lần gọi này');
      return false;
    }
    _restartInFlight = true;
    if (!mounted) {
      _restartInFlight = false;
      return false;
    }
    setState(() {
      _fadeToBlack = true;
    });
    netDiag('RestartScope', 'fade-to-black ${_fadeDuration.inMilliseconds}ms');
    await Future<void>.delayed(_fadeDuration);

    // Lớp bảo vệ #4: unmount giữa chừng — vẫn phải hạ cờ.
    if (!mounted) {
      _restartInFlight = false;
      return false;
    }

    // Lớp bảo vệ #2: watchdog bật TRƯỚC khi gọi native và KHÔNG cancel ở
    // nhánh thành công.
    _watchdogTimer?.cancel();
    _watchdogTimer = Timer(_watchdog, () {
      netDiag(
        'RestartScope',
        '⏰ watchdog ${_watchdog.inSeconds}s: process vẫn sống → restart đã '
        'fail, gỡ màn đen + remount',
      );
      _abortFade();
      _remountSubtree();
    });

    // Lớp bảo vệ #1: native call LUÔN nằm trong try/catch.
    bool accepted = false;
    try {
      accepted = await TerminateRestart.instance.restartApp(
        options: const TerminateRestartOptions(terminate: true),
      );
      netDiag('RestartScope', 'restartApp() trả về $accepted');
    } catch (e, st) {
      netDiag(
        'RestartScope',
        '❌ restartApp() NÉM LỖI ${e.runtimeType}: $e\n'
        '${st.toString().split('\n').take(5).join('\n')}',
      );
      _abortFade();
      _remountSubtree();
      return false;
    }

    if (!accepted) {
      _abortFade();
      _remountSubtree();
      return false;
    }
    // accepted == true → CỐ Ý để watchdog chạy tiếp.
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: <Widget>[
          KeyedSubtree(key: _appKey, child: widget.child),
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !_fadeToBlack,
              child: AnimatedOpacity(
                opacity: _fadeToBlack ? 1 : 0,
                duration: _fadeDuration,
                child: const ColoredBox(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
