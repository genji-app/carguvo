import 'dart:async';

import 'package:unlock_shorebird_kit/core/net_diag.dart';
import 'package:unlock_shorebird_kit/flow/unlock_flow_coordinator.dart';
import 'package:unlock_shorebird_kit/flow/unlock_shorebird_launch_coordinator.dart';
import 'package:unlock_shorebird_kit/shorebird/update/bloc/update_bloc.dart';
import 'package:unlock_shorebird_kit/shorebird/update/shorebird_restart_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Key SharedPreferences lưu patch number "đã biết" từ session trước.
/// Dùng để compare với `min_patch_force_update` ở session kế tiếp:
/// - Nếu null → first install → silent restart.
/// - Nếu < minForce → show snackbar.
/// - Sau mỗi lần xử lý: update bằng currentPatch hiện tại.
const String _kSavedPatchKey = 'shorebird_last_known_patch';

/// Host provides [executeRestartWithFade] → fade-out then restart app.
///
/// **Quan trọng:** host PHẢI gọi restart với `terminate = true` (ví dụ
/// `Restart.restartApp(terminate: true)`) để Shorebird thực sự apply patch
/// trên process mới. Nếu chỉ restart widget tree (terminate=false), patch
/// vẫn chưa được load.
///
/// Flow UX:
/// - Patch đầu tiên trên binary → silent restart (không snackbar)
/// - Patch sau đó, nếu current patch thấp hơn `min_patch_force_update`
///   → snackbar bắt user restart. Ngược lại vào betting, patch auto apply
///   ở lần mở kế tiếp.
class SplashModeScreen extends StatefulWidget {
  const SplashModeScreen({
    super.key,
    required this.bettingScreenBuilder,
    required this.fakeScreenBuilder,
    required this.executeRestartWithFade,
    this.splashScreenBuilder,
    this.onModeChanged,
    this.initialFlowDelay = const Duration(seconds: 2),
  });

  final Widget Function() bettingScreenBuilder;
  final Widget Function() fakeScreenBuilder;
  final Future<bool> Function(BuildContext context) executeRestartWithFade;

  /// Tuỳ chỉnh màn hình splash. Nếu null, mặc định dùng [SplashView].
  final Widget Function()? splashScreenBuilder;

  /// Được gọi mỗi khi [AppMode] thay đổi (splash → fake/betting).
  ///
  /// Host dùng callback này để SWAP cây widget ở root: khi vào
  /// [AppMode.betting], host render thẳng màn hình betting (vốn tự dựng
  /// `MaterialApp.router` riêng) thay vì để nó nằm LỒNG bên trong `MaterialApp`
  /// của host. Hai `MaterialApp` lồng nhau (đặc biệt `MaterialApp.router` lồng
  /// trong `MaterialApp`) gây màn hình đen sau khi điều hướng
  /// (xem flutter/flutter#142585).
  final ValueChanged<AppMode>? onModeChanged;

  final Duration initialFlowDelay;

  @override
  State<SplashModeScreen> createState() => _SplashModeScreenState();
}

class _SplashModeScreenState extends State<SplashModeScreen> {
  AppMode currentMode = AppMode.splash;
  bool isExecutingFlow = false;
  // bool _shorebirdSyncInProgress = false;
  final UnlockShorebirdLaunchCoordinator _launchCoordinator =
      UnlockShorebirdLaunchCoordinator();

  /// Nhịp tim cho biết DefaultSplashScreen đã quay bao lâu mà chưa đổi mode.
  /// Đây là thứ trả lời trực tiếp câu "vì sao splash đen quay lâu thế".
  Timer? _splashHeartbeatTimer;
  final Stopwatch _splashWatch = Stopwatch()..start();
  static const Duration _splashHeartbeatInterval = Duration(seconds: 5);

  void _startSplashHeartbeat() {
    _splashHeartbeatTimer?.cancel();
    _splashHeartbeatTimer = Timer.periodic(_splashHeartbeatInterval, (_) {
      if (!mounted || currentMode != AppMode.splash) {
        return;
      }
      netDiag(
        'SplashMode',
        '⏳ vẫn đang ở DefaultSplashScreen — '
        '${(_splashWatch.elapsedMilliseconds / 1000).toStringAsFixed(1)}s. '
        'Xem dòng NetDiag gần nhất của FetchConfig / CheckUnlock / '
        'ShorebirdGate để biết đang chờ ai.',
      );
    });
  }

  @override
  void dispose() {
    _splashHeartbeatTimer?.cancel();
    _splashHeartbeatTimer = null;
    _splashWatch.stop();
    unawaited(_launchCoordinator.executeCloseResources());
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    netDiag(
      'SplashMode',
      'initState — render splashScreenBuilder (DefaultSplashScreen). '
      'Chờ initialFlowDelay=${widget.initialFlowDelay.inMilliseconds}ms '
      'rồi mới chạy unlock flow.',
    );
    _startSplashHeartbeat();
    executeStartFlowAfterDelay();
  }

  Future<void> executeStartFlowAfterDelay() async {
    await Future<void>.delayed(widget.initialFlowDelay);
    if (!mounted) {
      netDiag('SplashMode', 'hết delay nhưng widget đã unmount → dừng');
      return;
    }
    if (isExecutingFlow) {
      netDiag('SplashMode', 'flow đang chạy rồi → bỏ qua lần gọi này');
      return;
    }
    netDiag('SplashMode', 'hết delay → chạy executeUnlockFlowWithShorebirdGate()');
    isExecutingFlow = true;
    try {
      await _launchCoordinator.executeUnlockFlowWithShorebirdGate(
        onAppModeSet: executeSetMode,
        onConnectionErrorPrompt: executeShowRetryDialog,
        isActive: () => mounted,
        onShorebirdSyncVisibilityChanged: ({required bool isShorebirdSyncing}) {
          if (!mounted) {
            return;
          }
          // setState(() {
          //   _shorebirdSyncInProgress = isShorebirdSyncing;
          // });
        },
        onShorebirdRestartRequired: executeHandleShorebirdRestartRequired,
      );
    } finally {
      isExecutingFlow = false;
      netDiag('SplashMode', 'executeUnlockFlowWithShorebirdGate() đã return');
    }
  }

  void executeSetMode(AppMode mode) {
    if (!mounted) {
      netDiag('SplashMode', 'setMode($mode) bị bỏ vì widget đã unmount');
      return;
    }
    final String warning = mode == AppMode.splash
        ? '  ⚠️ về lại splash = DefaultSplashScreen tiếp tục quay'
        : '';
    netDiag('SplashMode', 'ĐỔI MODE: $currentMode → $mode$warning');
    if (mode == AppMode.splash) {
      // Quay lại splash (nhánh lỗi mạng) → bật lại nhịp tim để thấy app kẹt.
      if (_splashHeartbeatTimer == null) {
        _startSplashHeartbeat();
      }
    } else {
      _splashHeartbeatTimer?.cancel();
      _splashHeartbeatTimer = null;
      netDiag(
        'SplashMode',
        'DefaultSplashScreen đã hiển thị tổng cộng '
        '${(_splashWatch.elapsedMilliseconds / 1000).toStringAsFixed(1)}s '
        'trước khi rời splash',
      );
    }
    setState(() {
      currentMode = mode;
    });
    // Báo host biết mode đã đổi để host có thể swap cây ở root (tránh lồng
    // MaterialApp khi vào betting). Gọi SAU setState, ngoài phase build.
    widget.onModeChanged?.call(mode);
  }

  /// Xử lý khi Shorebird fire [UpdateFlowStatus.restartRequired].
  ///
  /// **Inputs:**
  /// - `savedPatch` từ SharedPreferences (= patch session sau sẽ chạy, lưu
  ///   từ session trước).
  /// - `nextPatch` từ Shorebird (= patch vừa download, đang chờ restart).
  ///   Nếu null nghĩa là KHÔNG có patch mới chờ apply.
  /// - `currentPatch` từ Shorebird (= patch đang chạy trong VM hiện tại).
  /// - `minPatchForceUpdate` từ remote config.
  ///
  /// **Logic:**
  /// 1. **First install** (savedPatch == null): silent restart + lưu
  ///    pendingPatch (= nextPatch ?? currentPatch).
  /// 2. **Subsequent**: chỉ show snackbar khi CẢ 2 điều kiện đúng:
  ///    - `nextPatch != null` (thực sự có patch mới chờ apply, không phải
  ///      handler bị gọi không có lý do).
  ///    - `savedPatch < minForce` (patch user đang dùng dưới threshold).
  ///    Sau xử lý, update saved bằng pendingPatch.
  Future<void> executeHandleShorebirdRestartRequired() async {
    if (!mounted) {
      return;
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? savedPatch = prefs.getInt(_kSavedPatchKey);
    final int? nextPatchNumber =
        await _launchCoordinator.executeReadNextPatchNumber();
    final int? currentPatchNumber =
        await _launchCoordinator.executeReadCurrentPatchNumber();
    final int? minPatchForceUpdate = _launchCoordinator.minPatchForceUpdate;
    if (!mounted) {
      return;
    }

    // pendingPatch = patch session SAU sẽ ở.
    final int? pendingPatchNumber = nextPatchNumber ?? currentPatchNumber;

    print(
      '[Unlock Shorebird] handle restartRequired: '
      'savedPatch=$savedPatch '
      'currentPatch=$currentPatchNumber '
      'nextPatch=$nextPatchNumber '
      'pendingPatch=$pendingPatchNumber '
      'minForce=$minPatchForceUpdate '
      'silentAttempted=${UpdateBloc.isSilentRestartAttemptedInSession}',
    );

    // Nhánh 1: First install (chưa có saved patch) → silent restart.
    if (savedPatch == null) {
      if (pendingPatchNumber != null) {
        await prefs.setInt(_kSavedPatchKey, pendingPatchNumber);
        print(
          '[Unlock Shorebird] → first install, saved=$pendingPatchNumber',
        );
      } else {
        // pendingPatch null (Shorebird unavailable) — lưu 0 để session sau
        // không bị nhầm là first install.
        await prefs.setInt(_kSavedPatchKey, 0);
      }
      if (!UpdateBloc.isSilentRestartAttemptedInSession) {
        print('[Unlock Shorebird] → attempting silent restart');
        UpdateBloc.markSilentRestartAttempted();
        await widget.executeRestartWithFade(context);
        return;
      }
      // Silent đã thử & fail → fallback dialog (block) để user manual restart.
      print(
        '[Unlock Shorebird] → silent already attempted, fallback to dialog (BLOCK)',
      );
      if (!mounted) {
        return;
      }
      await executeShowShorebirdRestartDialog(
        context,
        executeRestartWithFade: widget.executeRestartWithFade,
      );
      if (!mounted) {
        return;
      }
      executeSetMode(AppMode.betting);
      return;
    }

    // Nhánh 2: Subsequent — block bằng modal dialog chỉ khi:
    //   (a) thực sự có nextPatch chờ apply, VÀ
    //   (b) savedPatch < minForce
    final bool hasNewPatchToApply = nextPatchNumber != null;
    final bool savedBelowMinForce =
        minPatchForceUpdate != null && savedPatch < minPatchForceUpdate;
    final bool shouldBlockWithDialog =
        hasNewPatchToApply && savedBelowMinForce;

    if (shouldBlockWithDialog) {
      print(
        '[Unlock Shorebird] ▶▶▶ ENTER branch: shouldBlockWithDialog=true '
        '(hasNextPatch=$hasNewPatchToApply, '
        'savedBelowMinForce=$savedBelowMinForce)',
      );
      print(
        '[Unlock Shorebird] → hasNextPatch=true & savedPatch($savedPatch) < '
        'minForce($minPatchForceUpdate) → SHOW DIALOG (BLOCK)',
      );

      // Save TRƯỚC khi show dialog để phòng widget remount fallback (sau
      // khi user tap Restart mà TerminateRestart fail). Khi đó SplashModeScreen
      // mới sẽ đọc savedPatch=$pendingPatchNumber → savedBelowMinForce=false
      // → không show dialog lại → break loop.
      if (pendingPatchNumber != null && pendingPatchNumber != savedPatch) {
        await prefs.setInt(_kSavedPatchKey, pendingPatchNumber);
        print(
          '[Unlock Shorebird] → saved patch BEFORE dialog: '
          '$savedPatch → $pendingPatchNumber',
        );
      }

      print(
        '[Unlock Shorebird] → calling executeShowShorebirdRestartDialog (await)',
      );

      // BLOCK: await dialog. Handler không return cho tới khi dialog đóng.
      // Coordinator (parent) cũng block tại `await onShorebirdRestartRequired()`.
      // Mode vẫn là splash → SplashScreen không render → không pushReplacement
      // sang HomeScreen → dialog hiển thị đúng cách.
      await executeShowShorebirdRestartDialog(
        context,
        executeRestartWithFade: widget.executeRestartWithFade,
      );
      // Sau khi dialog đóng (rất hiếm — chỉ khi restart fail kiểu lạ).
      print('[Unlock Shorebird] → dialog dismissed, going to betting');
      if (!mounted) {
        return;
      }
      executeSetMode(AppMode.betting);
      return;
    }

    print(
      '[Unlock Shorebird] → SKIP dialog '
      '(hasNextPatch=$hasNewPatchToApply, '
      'savedBelowMinForce=$savedBelowMinForce)',
    );

    // Không block dialog → save & vào betting bình thường.
    if (pendingPatchNumber != null && pendingPatchNumber != savedPatch) {
      await prefs.setInt(_kSavedPatchKey, pendingPatchNumber);
      print(
        '[Unlock Shorebird] → saved patch: $savedPatch → $pendingPatchNumber',
      );
    }
    executeSetMode(AppMode.betting);
  }

  Future<bool> executeShowRetryDialog() async {
    if (!mounted) {
      netDiag('RetryDialog', 'không hiện được vì widget đã unmount → false');
      return false;
    }
    netDiag(
      'RetryDialog',
      'HIỆN dialog "Lỗi Internet" đè lên DefaultSplashScreen. Dialog chỉ có 1 '
      'nút "Thử lại"; nếu user bấm back / tap ra ngoài thì kết quả = null '
      '→ false → flow sẽ dừng và app kẹt ở splash.',
    );
    final bool? shouldRetry = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Lỗi Internet'),
          content: const Text('Không thể kết nối đến server. Thử lại?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Thử lại'),
            ),
          ],
        );
      },
    );
    final String how = shouldRetry == null
        ? ' (bị dismiss bằng back/tap ngoài, KHÔNG phải bấm "Thử lại")'
        : '';
    netDiag('RetryDialog', 'ĐÓNG dialog — kết quả=$shouldRetry$how');
    return shouldRetry ?? false;
  }

  /// Mode đã log ở lần build gần nhất — tránh spam log mỗi frame.
  AppMode? _lastLoggedBuildMode;

  @override
  Widget build(BuildContext context) {
    if (_lastLoggedBuildMode != currentMode) {
      _lastLoggedBuildMode = currentMode;
      String rendered =
          'splashScreenBuilder()  [DefaultSplashScreen — màn đen + spinner]';
      if (currentMode == AppMode.fake) {
        rendered = 'fakeScreenBuilder()  [CarguvoApp]';
      } else if (currentMode == AppMode.betting) {
        rendered = 'bettingScreenBuilder()  [App của sun_sports]';
      }
      netDiag('SplashMode', 'build → $rendered');
    }
    if (currentMode == AppMode.fake) {
      return widget.fakeScreenBuilder();
    }
    if (currentMode == AppMode.betting) {
      return widget.bettingScreenBuilder();
    }
    return widget.splashScreenBuilder?.call() ?? const SplashView();
  }
}

class SplashView extends StatelessWidget {
  const SplashView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }
}
