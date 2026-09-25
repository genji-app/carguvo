import 'package:flutter/material.dart';

/// Modal blocking dialog cho phép user restart app sau khi Shorebird patch
/// download xong. Dùng thay snackbar khi cần FORCE user restart (vd: patch
/// hiện tại < minPatchForceUpdate).
///
/// **Đặc điểm:**
/// - `barrierDismissible: false` — không dismiss bằng tap outside.
/// - `PopScope(canPop: false)` — không dismiss bằng back button (Android).
/// - Chỉ có 1 button "Khởi động lại" — user phải tap để restart.
///
/// **Trả về:** Future hoàn tất khi dialog đóng. Trong happy path (restart
/// thành công via TerminateRestart), process bị kill nên Future không bao
/// giờ resolve. Trong fallback (restart fail dẫn đến widget remount), dialog
/// bị unmount theo subtree → Future cancel.
///
/// **Caller phải await** function này để block flow:
/// ```dart
/// await executeShowShorebirdRestartDialog(context, ...);
/// // Code dưới đây chỉ chạy khi dialog đã đóng (rất hiếm — chỉ khi
/// // restart fail cách lạ).
/// executeSetMode(AppMode.betting);
/// ```
Future<void> executeShowShorebirdRestartDialog(
  BuildContext context, {
  required Future<bool> Function(BuildContext context) executeRestartWithFade,
  String title = 'Cập nhật mới',
  String message =
      'Bản mới đã được cập nhật. Hãy khởi động lại app để tiếp tục sử dụng.',
  String restartLabel = 'Khởi động lại',
  bool allowInAppRestart = true,
}) async {
  if (!context.mounted) {
    // ignore: avoid_print
    print(
      '[Unlock Shorebird] dialog: context.mounted=false → return early',
    );
    return;
  }
  // ignore: avoid_print
  print('[Unlock Shorebird] dialog: showDialog START');
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogCtx) {
      return PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          actions: !allowInAppRestart
              // Chế độ manual-only: KHÔNG có nút restart.
              //
              // Dùng khi restart trong app đã được thử và thất bại
              // (TerminateRestart không kill được process). Nếu vẫn hiện nút
              // "Khởi động lại", mỗi lần bấm sẽ chỉ remount widget subtree →
              // SplashModeScreen mới → flow chạy lại → dialog hiện lại: user
              // thấy force update lặp đi lặp lại. Bỏ nút đi để chặn vòng lặp
              // đó; user đóng hẳn app rồi mở lại là patch được apply.
              ? const <Widget>[]
              : [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () async {
                // ignore: avoid_print
                print(
                  '[Unlock Shorebird] dialog: user tapped Restart button',
                );
                final bool didStartRestart =
                    await executeRestartWithFade(dialogCtx);
                // ignore: avoid_print
                print(
                  '[Unlock Shorebird] dialog: executeRestartWithFade returned '
                  'didStartRestart=$didStartRestart',
                );
                // Nếu kill process thành công → code này không bao giờ chạy.
                // Nếu fail (widget remount fallback) → dialog bị unmount,
                // code dưới đây cũng không chạy.
                // Code này chỉ chạy trong edge case lạ — fallback close
                // dialog để user vào betting (không bị stuck).
                if (!didStartRestart && dialogCtx.mounted) {
                  // ignore: avoid_print
                  print(
                    '[Unlock Shorebird] dialog: restart fail + ctx mounted '
                    '→ pop dialog (fallback)',
                  );
                  Navigator.of(dialogCtx).pop();
                }
              },
              child: Text(restartLabel),
            ),
          ],
        ),
      );
    },
  );
  // ignore: avoid_print
  print('[Unlock Shorebird] dialog: showDialog RETURNED (dismissed)');
}
