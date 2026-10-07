import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

enum NetworkManagerEvent {
  connectionLost,

  connectionRestored,
}

class NetworkManager {
  NetworkManager._() {
    _connectivity = Connectivity();
  }

  static final NetworkManager instance = NetworkManager._();

  late final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  final StreamController<NetworkManagerEvent> _controller =
      StreamController<NetworkManagerEvent>.broadcast();

  bool _wasConnected = true;
  bool _isListening = false;
  Timer? _pollTimer;
  static const Duration _pollInterval = Duration(seconds: 4);

  Stream<NetworkManagerEvent> get stream => _controller.stream;

  void _emitIfChanged(bool connected) {
    if (!connected && _wasConnected) {
      _wasConnected = false;
      if (!_controller.isClosed) {
        _controller.add(NetworkManagerEvent.connectionLost);
      }
    } else if (connected && !_wasConnected) {
      _wasConnected = true;
      if (!_controller.isClosed) {
        _controller.add(NetworkManagerEvent.connectionRestored);
      }
    }
  }

  Future<void> startListening() async {
    if (_isListening) return;
    _isListening = true;

    try {
      final results = await _connectivity.checkConnectivity();
      _wasConnected = _isConnected(results);
    } catch (_) {
      _wasConnected = false;
    }

    _subscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        _emitIfChanged(_isConnected(results));
      },
      onError: (Object e) {
        if (kDebugMode) {
          debugPrint('NetworkManager: onConnectivityChanged error: $e');
        }
      },
      cancelOnError: false,
    );

    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) async {
      try {
        final results = await _connectivity.checkConnectivity();
        _emitIfChanged(_isConnected(results));
      } catch (_) {}
    });
  }

  void stopListening() {
    if (!_isListening) return;
    _isListening = false;
    _subscription?.cancel();
    _subscription = null;
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  bool _isConnected(List<ConnectivityResult> results) {
    return results.any((r) => r != ConnectivityResult.none);
  }

  Future<bool> checkIsConnected() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return _isConnected(results);
    } catch (_) {
      return false;
    }
  }

  void dispose() {
    stopListening();
    if (!_controller.isClosed) {
      _controller.close();
    }
  }
}
