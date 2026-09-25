import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Patch-ready snackbar. [executeRestartWithFade] should run fade-out then
/// process restart (e.g. [RestartScope.executeRestartApp] → [TerminateRestart]).
///
/// Màu sắc được hardcode (không phụ thuộc theme) để đảm bảo contrast ổn định
/// trên cả light và dark mode:
/// - Background: trắng
/// - Content text: đen
/// - Action label ("Restart app"): xanh
///
/// **Quan trọng:** onPressed dùng context của [ScaffoldMessengerState] (ở
/// TRÊN `Navigator` trong widget tree) làm **stable context** cho
/// [executeRestartWithFade]. Nếu dùng thẳng context của caller, khi caller
/// là widget bị unmount (vd: home route bị replace qua
/// [Navigator.pushReplacement]) thì context stale → onPressed không chạy được.
void executeShowShorebirdRestartSnackbar(
  BuildContext context, {
  required Future<bool> Function(BuildContext context) executeRestartWithFade,
  String message = 'Bản mới đã được cập nhật. Hãy khởi động lại app.',
  String restartActionLabel = 'Khởi động lại',
}) {
  if (!context.mounted) {
    return;
  }
  const Color backgroundColor = Colors.white;
  const Color contentColor = Colors.black;
  const Color actionColor = Colors.blue;
  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  // Context của ScaffoldMessenger ở trên Navigator → ổn định qua route changes.
  final BuildContext stableContext = messenger.context;
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: backgroundColor,
      elevation: 6,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      content: Text(
        message,
        style: const TextStyle(
          color: contentColor,
          fontSize: 14,
          height: 1.2,
        ),
      ),
      duration: const Duration(seconds: 8),
      action: SnackBarAction(
        label: restartActionLabel,
        textColor: actionColor,
        onPressed: () {
          print(
            '[Unlock Shorebird] snackbar action tapped → invoking executeRestartWithFade',
          );
          // Không check stableContext.mounted — ScaffoldMessenger context
          // stable qua navigation, nếu MaterialApp còn sống là còn dùng được.
          unawaited(executeRestartWithFade(stableContext));
        },
      ),
    ),
  );
}
