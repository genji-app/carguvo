import 'package:flutter/material.dart';

class AppBottomSheet {
  const AppBottomSheet._();

  static final Animatable<Offset> _slideUp = Tween<Offset>(
    begin: const Offset(0, 1),
    end: Offset.zero,
  ).chain(CurveTween(curve: Curves.easeOutCubic));

  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    Color? barrierColor,
    Duration transitionDuration = const Duration(milliseconds: 300),
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierColor: barrierColor ?? Colors.black.withValues(alpha: 0.5),
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: transitionDuration,
      transitionBuilder: (_, animation, _, child) => SlideTransition(
        position: animation.drive(_slideUp),
        child: child,
      ),
      pageBuilder: (dialogContext, _, _) => builder(dialogContext),
    );
  }
}
