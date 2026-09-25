import 'package:flutter/material.dart';

class DialogHelper {
  static Future<T?> showWithCallback<T>({
    required BuildContext context,
    required Widget Function(BuildContext, Animation<double>, Animation<double>)
    builder,
    required VoidCallback onPop,
    bool barrierDismissible = true,
    Color? barrierColor,
    Duration transitionDuration = const Duration(milliseconds: 200),
  }) async {
    final rootContext = Navigator.of(context, rootNavigator: true).context;

    final result = await showGeneralDialog<T>(
      context: rootContext,
      barrierColor: barrierColor ?? Colors.black.withValues(alpha: 0.5),
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(
        rootContext,
      ).modalBarrierDismissLabel,
      transitionDuration: transitionDuration,
      pageBuilder: builder,
    );

    if (rootContext.mounted) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      if (rootContext.mounted) {
        onPop();
      }
    }

    return result;
  }

  static void popAndShowPrevious({
    required BuildContext context,
    required VoidCallback showPrevious,
  }) {
    Navigator.of(context, rootNavigator: true).pop();
    Future<void>.delayed(const Duration(milliseconds: 300), () {
      final rootContext = Navigator.of(context, rootNavigator: true).context;
      if (rootContext.mounted) {
        showPrevious();
      }
    });
  }
}
