import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/providers/pending_toast_provider.dart';
import 'package:sun_sports/router/auth_navigation.dart' show authFlowActive;
import 'package:sun_sports/features/mini_game/socket/mini_game_socket_providers.dart';
import 'package:sun_sports/features/auth/presentation/providers/auth_providers.dart';
import 'package:sun_sports/features/my_bet_hub/my_bet_hub_providers.dart';
import 'package:sun_sports/features/parlay/presentation/providers/parlay_overlay_provider.dart';
import 'package:sun_sports/features/profile/deposit/presentation/providers/deposit_overlay_provider.dart';
import 'package:sun_sports/features/profile/withdraw/presentation/providers/withdraw_overlay_provider.dart';
import 'package:sun_sports/features/profile_hub/profile_hub.dart';
import 'package:sun_sports/providers/auth_provider.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';

class KickEventListener extends ConsumerStatefulWidget {
  final Widget child;

  const KickEventListener({required this.child, super.key});

  @override
  ConsumerState<KickEventListener> createState() => _KickEventListenerState();
}

class _KickEventListenerState extends ConsumerState<KickEventListener> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _showPendingToastIfAny();
    });
  }

  void _showPendingToastIfAny() {
    if (!mounted) return;
    final pendingToast = ref.read(pendingToastProvider);
    if (pendingToast == null) return;
    ref.read(pendingToastProvider.notifier).state = null;

    if (pendingToast.isError) {
      AppToast.showError(
        context,
        message: pendingToast.message,
        title: pendingToast.title,
        duration: pendingToast.duration ?? const Duration(seconds: 5),
      );
    } else {
      AppToast.showSuccess(
        context,
        message: pendingToast.message,
        title: pendingToast.title,
        duration: pendingToast.duration ?? const Duration(seconds: 5),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<String>>(miniGameKickStreamProvider, (previous, next) {
      next.whenData((reason) => _handleKickEvent(context, ref, reason));
    });

    ref.listen<bool>(isAuthenticatedProvider, (previous, next) {
      if (previous == true && next == false) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _showPendingToastIfAny();
        });
      }
    });

    return widget.child;
  }

  void _handleKickEvent(BuildContext context, WidgetRef ref, String reason) {
    if (kDebugMode) {
      debugPrint('🔴 KickEventListener: kicked — $reason');
    }

    ref.read(pendingToastProvider.notifier).state = const PendingToast(
      message: 'Bạn đã đăng nhập trên thiết bị khác!',
      title: 'Thông báo',
      isError: true,
    );

    _closeAllOverlays(context, ref);

    try {
      if (context.mounted && !authFlowActive) {
        Navigator.of(
          context,
          rootNavigator: true,
        ).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('🔴 KickEventListener: popUntil failed — $e');
    }

    try {
      ref.read(authNotifierProvider.notifier).markSignedOut();
    } catch (e) {
      if (kDebugMode) debugPrint('🔴 KickEventListener: authNotifier state — $e');
    }

    try {
      ref.read(authProvider.notifier).logout();
    } catch (e) {
      if (kDebugMode) debugPrint('🔴 KickEventListener: authProvider logout — $e');
    }
  }

  void _closeAllOverlays(BuildContext context, WidgetRef ref) {
    try {
      ProfileHub.closeRemote(ref);
    } catch (e) {
      if (kDebugMode) debugPrint('🔴 KickEventListener: profile overlay — $e');
    }

    try {
      ref.read(myBetHubControllerProvider).close();
    } catch (e) {
      if (kDebugMode) debugPrint('🔴 KickEventListener: myBet overlay — $e');
    }

    try {
      ref.read(depositOverlayVisibleProvider.notifier).state = false;
    } catch (e) {
      if (kDebugMode) debugPrint('🔴 KickEventListener: deposit overlay — $e');
    }

    try {
      ref.read(codepayTransferOverlayVisibleProvider.notifier).state = false;
    } catch (e) {
      if (kDebugMode) debugPrint('🔴 KickEventListener: codepay overlay — $e');
    }

    try {
      ref.read(withdrawOverlayVisibleProvider.notifier).state = false;
    } catch (e) {
      if (kDebugMode) debugPrint('🔴 KickEventListener: withdraw overlay — $e');
    }

    try {
      ref.read(parlayOverlayVisibleProvider.notifier).state = false;
    } catch (e) {
      if (kDebugMode) debugPrint('🔴 KickEventListener: parlay overlay — $e');
    }
  }
}
