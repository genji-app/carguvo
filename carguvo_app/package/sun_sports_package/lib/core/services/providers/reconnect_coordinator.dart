import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/core/utils/network_manger.dart';

class ReconnectCoordinator {
  ReconnectCoordinator() {
    _startListening();
  }

  final List<VoidCallback> _callbacks = [];
  StreamSubscription<NetworkManagerEvent>? _subscription;

  void _startListening() {
    NetworkManager.instance.startListening();
    _subscription = NetworkManager.instance.stream.listen(_onEvent);
  }

  void _onEvent(NetworkManagerEvent event) {
    if (event == NetworkManagerEvent.connectionRestored) {
      _notifyReconnected();
    }
  }

  void forceReconnectRefresh() => _notifyReconnected();

  void register(VoidCallback onReconnect) {
    if (!_callbacks.contains(onReconnect)) {
      _callbacks.add(onReconnect);
    }
  }

  void unregister(VoidCallback onReconnect) {
    _callbacks.remove(onReconnect);
  }

  void _notifyReconnected() {
    final list = List<VoidCallback>.from(_callbacks);
    for (final cb in list) {
      try {
        cb();
      } catch (e, st) {
        if (kDebugMode) {
          debugPrint('ReconnectCoordinator: callback error $e\n$st');
        }
      }
    }
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _callbacks.clear();
  }
}

final reconnectCoordinatorProvider = Provider<ReconnectCoordinator>((ref) {
  final coordinator = ReconnectCoordinator();
  ref.onDispose(coordinator.dispose);
  return coordinator;
});
