import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/profile/deposit/presentation/providers/deposit_overlay_provider.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';

class DepositNavigator {
  static final DepositNavigator _instance = DepositNavigator._internal();
  factory DepositNavigator() => _instance;
  DepositNavigator._internal();

  final List<Future<void> Function()> _stack = [];

  bool _isPopping = false;

  Future<T?> push<T>({
    required BuildContext context,
    required Future<void> Function(BuildContext) mobileShowMethod,
    required Future<T?> Function(BuildContext) webShowMethod,
    required Future<void> Function(
      BuildContext rootContext,
      DeviceType deviceType,
    )
    showPreviousDialog,
  }) async {
    final rootContext = Navigator.of(context, rootNavigator: true).context;
    final deviceType = ResponsiveBuilder.getDeviceType(rootContext);

    _stack.add(() => showPreviousDialog(rootContext, deviceType));

    if (deviceType == DeviceType.mobile) {
      if (Navigator.of(rootContext).canPop()) {
        Navigator.of(rootContext).pop();
        await Future<void>.delayed(const Duration(milliseconds: 300));
        if (!rootContext.mounted) return null;
      }
      await mobileShowMethod(rootContext);
      return null;
    } else {
      final container = ProviderScope.containerOf(rootContext, listen: false);
      final isDepositOverlayVisible = container.read(
        depositOverlayVisibleProvider,
      );

      if (isDepositOverlayVisible) {
        container.read(depositOverlayVisibleProvider.notifier).state = false;
        await Future<void>.delayed(const Duration(milliseconds: 300));
        if (!rootContext.mounted) return null;
      }

      final navigatorContext = Navigator.of(
        context,
        rootNavigator: true,
      ).context;
      if (Navigator.of(navigatorContext).canPop()) {
        Navigator.of(navigatorContext).pop();
        await Future<void>.delayed(const Duration(milliseconds: 400));
        if (!rootContext.mounted) {
          return null;
        }
      }

      final result = await webShowMethod(rootContext);

      _isPopping = false;

      return result;
    }
  }

  Future<T?> pushReplacement<T>({
    required BuildContext context,
    required Future<void> Function(BuildContext) mobileShowMethod,
    required Future<T?> Function(BuildContext) webShowMethod,
  }) async {
    final rootContext = Navigator.of(context, rootNavigator: true).context;
    final deviceType = ResponsiveBuilder.getDeviceType(rootContext);

    if (deviceType == DeviceType.mobile) {
      Navigator.of(rootContext).pop();
    } else {
      final container = ProviderScope.containerOf(rootContext, listen: false);
      container.read(depositOverlayVisibleProvider.notifier).state = false;
    }

    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!rootContext.mounted) return null;

    if (deviceType == DeviceType.mobile) {
      await mobileShowMethod(rootContext);
    } else {
      return await webShowMethod(rootContext);
    }
    return null;
  }

  Future<void> pop<T>(BuildContext context, [T? result]) async {
    BuildContext rootContext;
    try {
      rootContext = Navigator.of(context, rootNavigator: true).context;
    } catch (e) {
      rootContext = context;
    }

    if (_isPopping) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(result);
      }
      return;
    }

    _isPopping = true;

    final canPop = Navigator.of(rootContext).canPop();

    if (canPop) {
      Navigator.of(rootContext).pop(result);
    } else {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(result);
      }
    }

    await Future<void>.delayed(const Duration(milliseconds: 50));

    if (_stack.isNotEmpty && rootContext.mounted) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (rootContext.mounted && _stack.isNotEmpty) {
        final showPrevious = _stack.removeLast();
        if (rootContext.mounted) {
          try {
            await showPrevious();
          } catch (e) {
          }
        }
      }
    } else {
      try {
        final deviceType = ResponsiveBuilder.getDeviceType(rootContext);
        if (deviceType != DeviceType.mobile && rootContext.mounted) {
          final container = ProviderScope.containerOf(
            rootContext,
            listen: false,
          );
          container.read(depositOverlayVisibleProvider.notifier).state = true;
        }
      } catch (_) {
      }
    }

    _isPopping = false;
  }

  void clear() {
    _stack.clear();
  }

  Future<void> closeAll<T>(BuildContext context, [T? result]) async {
    _stack.clear();

    BuildContext rootContext;
    try {
      rootContext = Navigator.of(context, rootNavigator: true).context;
    } catch (e) {
      rootContext = context;
    }

    if (Navigator.of(rootContext).canPop()) {
      Navigator.of(rootContext).pop(result);
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(result);
    }
  }

  static Future<T?> showWebDialog<T>({
    required BuildContext context,
    required Widget Function(BuildContext, Animation<double>, Animation<double>)
    builder,
    bool barrierDismissible = true,
    Color? barrierColor,
    Duration transitionDuration = const Duration(milliseconds: 200),
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: builder,
    );
  }

  int get stackSize => _stack.length;
}
