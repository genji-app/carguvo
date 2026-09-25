import 'dart:async';

import 'package:flutter/widgets.dart';

import '../logger.dart';
import 'ih_runner_ctrl.dart';

abstract class IHRunnerBase extends StatefulWidget {
  const IHRunnerBase({
    required this.gameUrl,
    this.logger = silentLogger,
    super.key,
    this.onLoadStart,
    this.onLoadStop,
    this.onError,
    this.onHostMessage,
    this.enableHostMessage = true,
    this.backgroundColor,
  });

  final Color? backgroundColor;

  final String gameUrl;

  final GameEngineLogger logger;

  final VoidCallback? onLoadStart;

  final VoidCallback? onLoadStop;

  final ValueChanged<String>? onError;

  final ValueChanged<GameHostEvent>? onHostMessage;

  final bool enableHostMessage;
}

mixin IHRunnerForwardingMixin<T extends IHRunnerBase> on State<T> {

  IHRunnerCtrl? _ownedController;

  late final IHRunnerCtrl ctrl;

  void initController({
    required IHRunnerCtrl? externalController,
    required IHRunnerCtrl Function() createDefault,
  }) {
    if (externalController != null) {
      ctrl = externalController;
    } else {
      _ownedController = createDefault();
      ctrl = _ownedController!;
    }
  }

  final List<StreamSubscription<dynamic>> _subs = [];

  void setupForwarding() {
    _subs.addAll([
      ctrl.onStateChanged.listen((state) {
        if (!mounted) return;
        switch (state) {
          case IHRunnerState.loading:
            widget.onLoadStart?.call();
          case IHRunnerState.loaded:
            widget.onLoadStop?.call();
          case IHRunnerState.error:
            widget.onError?.call(
              ctrl.lastErrorMessage ?? 'Failed to load game',
            );
          case IHRunnerState.idle:
            break;
        }
      }),
      ctrl.onHostMessage.listen((event) {
        if (!mounted) return;
        widget.onHostMessage?.call(event);
      }),
    ]);
  }

  void disposeForwarding() {
    for (final sub in _subs) {
      sub.cancel();
    }
    _ownedController?.dispose();
  }
}
