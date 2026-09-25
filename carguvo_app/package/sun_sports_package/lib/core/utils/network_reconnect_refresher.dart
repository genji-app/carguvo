import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/utils/network_manger.dart';

class NetworkReconnectRefresher extends ConsumerStatefulWidget {
  const NetworkReconnectRefresher({
    super.key,
    required this.child,
    this.onReconnected,
  });

  final Widget child;

  final VoidCallback? onReconnected;

  @override
  ConsumerState<NetworkReconnectRefresher> createState() =>
      _NetworkReconnectRefresherState();
}

class _NetworkReconnectRefresherState
    extends ConsumerState<NetworkReconnectRefresher> {
  StreamSubscription<NetworkManagerEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startListening());
  }

  void _startListening() {
    NetworkManager.instance.startListening();
    _subscription = NetworkManager.instance.stream.listen((event) {
      if (event == NetworkManagerEvent.connectionRestored && mounted) {
        widget.onReconnected?.call();
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
