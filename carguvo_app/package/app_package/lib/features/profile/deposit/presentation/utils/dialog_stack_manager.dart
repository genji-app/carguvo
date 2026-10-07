import 'package:flutter/material.dart';

class DialogStackManager {
  static final DialogStackManager _instance = DialogStackManager._internal();
  factory DialogStackManager() => _instance;
  DialogStackManager._internal();

  final List<_DialogItem> _stack = [];

  Future<T?> push<T>({
    required BuildContext context,
    required Widget Function(BuildContext, Animation<double>, Animation<double>)
    builder,
    bool barrierDismissible = true,
    Color? barrierColor,
    Duration transitionDuration = const Duration(milliseconds: 200),
  }) async {
    final rootContext = Navigator.of(context, rootNavigator: true).context;

    final dialogItem = _DialogItem(
      builder: builder,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ?? Colors.black.withValues(alpha: 0.5),
      transitionDuration: transitionDuration,
    );
    _stack.add(dialogItem);

    final result = await showGeneralDialog<T>(
      context: rootContext,
      barrierColor: dialogItem.barrierColor,
      barrierDismissible: dialogItem.barrierDismissible,
      barrierLabel: MaterialLocalizations.of(
        rootContext,
      ).modalBarrierDismissLabel,
      transitionDuration: dialogItem.transitionDuration,
      pageBuilder: dialogItem.builder,
    );

    _stack.removeLast();

    if (_stack.isNotEmpty && rootContext.mounted) {
      final previousDialog = _stack.last;
      await Future<void>.delayed(
        const Duration(milliseconds: 200),
      );
      if (rootContext.mounted) {
        await showGeneralDialog(
          context: rootContext,
          barrierColor: previousDialog.barrierColor,
          barrierDismissible: previousDialog.barrierDismissible,
          barrierLabel: MaterialLocalizations.of(
            rootContext,
          ).modalBarrierDismissLabel,
          transitionDuration: previousDialog.transitionDuration,
          pageBuilder: previousDialog.builder,
        );
      }
    }

    return result;
  }

  Future<T?> pushReplacement<T>({
    required BuildContext context,
    required Widget Function(BuildContext, Animation<double>, Animation<double>)
    builder,
    bool barrierDismissible = true,
    Color? barrierColor,
    Duration transitionDuration = const Duration(milliseconds: 200),
  }) async {
    final rootContext = Navigator.of(context, rootNavigator: true).context;

    if (_stack.isNotEmpty) {
      _stack.removeLast();
      Navigator.of(rootContext).pop();
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }

    final dialogItem = _DialogItem(
      builder: builder,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ?? Colors.black.withValues(alpha: 0.5),
      transitionDuration: transitionDuration,
    );
    _stack.add(dialogItem);

    return await showGeneralDialog<T>(
      context: rootContext,
      barrierColor: dialogItem.barrierColor,
      barrierDismissible: dialogItem.barrierDismissible,
      barrierLabel: MaterialLocalizations.of(
        rootContext,
      ).modalBarrierDismissLabel,
      transitionDuration: dialogItem.transitionDuration,
      pageBuilder: dialogItem.builder,
    );
  }

  void pop<T>(BuildContext context, [T? result]) {
    Navigator.of(context, rootNavigator: true).pop(result);
  }

  void popAll(BuildContext context) {
    _stack.clear();
    Navigator.of(
      context,
      rootNavigator: true,
    ).popUntil((route) => route.isFirst);
  }

  bool get hasDialogs => _stack.isNotEmpty;

  int get stackSize => _stack.length;

  void clear() {
    _stack.clear();
  }
}

class _DialogItem {
  final Widget Function(BuildContext, Animation<double>, Animation<double>)
  builder;
  final bool barrierDismissible;
  final Color barrierColor;
  final Duration transitionDuration;

  _DialogItem({
    required this.builder,
    required this.barrierDismissible,
    required this.barrierColor,
    required this.transitionDuration,
  });
}
