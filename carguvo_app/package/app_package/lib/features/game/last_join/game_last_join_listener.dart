import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'game_last_join_provider.dart';
import 'game_last_join_state.dart';
import 'game_last_join_view.dart';

class GameLastJoinListener extends ConsumerStatefulWidget {
  const GameLastJoinListener({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<GameLastJoinListener> createState() =>
      _GameLastJoinListenerState();
}

class _GameLastJoinListenerState extends ConsumerState<GameLastJoinListener> {
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialSession();
    });
  }

  void _checkInitialSession() {
    if (!mounted) return;
    if (!GameLastJoinNotifier.isEnabled &&
        !GameLastJoinNotifier.debugForceFake) {
      return;
    }
    final current = ref.read(gameLastJoinProvider);
    if (current is GameLastJoinAvailable && !current.isDismissed) {
      unawaited(_onSessionAvailable(current));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!GameLastJoinNotifier.isEnabled &&
        !GameLastJoinNotifier.debugForceFake) {
      return widget.child;
    }

    ref.listen<GameLastJoinState>(gameLastJoinProvider, (prev, next) {
      if (next is GameLastJoinAvailable && !next.isDismissed) {
        if (prev is GameLastJoinAvailable &&
            prev.session == next.session &&
            prev.isDismissed == next.isDismissed) {
          return;
        }

        unawaited(_onSessionAvailable(next));
      }
    });

    return widget.child;
  }

  Future<void> _onSessionAvailable(GameLastJoinAvailable state) async {
    if (_isDialogShowing || !mounted) return;
    _isDialogShowing = true;

    try {
      final confirmed = await GameLastJoinView.show(
        context,
        session: state.session,
      );

      if (!mounted) return;

      final notifier = ref.read(gameLastJoinProvider.notifier);
      if (confirmed == true) {
        notifier.rejoin(context, session: state.session);
      } else {
        notifier.dismiss();
      }
    } finally {
      _isDialogShowing = false;
    }
  }
}
