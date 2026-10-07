import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_package/core/services/auth/display_name_status.dart';
import 'package:app_package/providers/auth_provider.dart';
import 'package:app_package/providers/user_provider/user_provider.dart';
import 'package:app_package/shared/widgets/dialogs/dialog_set_display_name.dart';

class DisplayNameGuard extends ConsumerStatefulWidget {
  const DisplayNameGuard({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<DisplayNameGuard> createState() => _DisplayNameGuardState();
}

class _DisplayNameGuardState extends ConsumerState<DisplayNameGuard> {
  static bool _open = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => _evaluate());
  }

  void _evaluate() {
    if (!mounted || _open) return;
    final isLoggedIn = ref.read(isAuthenticatedProvider);
    if (!DisplayNameStatus.needsDisplayName(isLoggedIn: isLoggedIn)) return;
    _open = true;
    final loginName = ref.read(userProvider).user?.username ?? '';
    DialogSetDisplayName.show(context, loginName: loginName).whenComplete(() {
      _open = false;
      if (mounted) _evaluate();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(isAuthenticatedProvider, (previous, next) {
      if (next == true) _evaluate();
    });
    ref.listen(userProvider, (previous, next) => _evaluate());
    return widget.child;
  }
}
