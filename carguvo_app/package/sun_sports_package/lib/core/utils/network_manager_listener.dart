import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/network_manger.dart';
import 'package:sun_sports/shared/widgets/network_offline_banner.dart';

class NetworkManagerListener extends StatefulWidget {
  const NetworkManagerListener({
    super.key,
    required this.child,
    this.onReconnected,
    this.navigatorKey,
  });

  final Widget child;

  final VoidCallback? onReconnected;

  final GlobalKey<NavigatorState>? navigatorKey;

  @override
  State<NetworkManagerListener> createState() => _NetworkManagerListenerState();
}

class _NetworkManagerListenerState extends State<NetworkManagerListener> {
  StreamSubscription<NetworkManagerEvent>? _subscription;
  bool _connectionLost = false;

  bool _showConnectedBanner = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startListening());
  }

  Future<void> _startListening() async {
    await NetworkManager.instance.startListening();
    if (!mounted) return;
    _subscription = NetworkManager.instance.stream.listen(_onEvent);
  }

  void _onEvent(NetworkManagerEvent event) {
    if (!mounted) return;
    switch (event) {
      case NetworkManagerEvent.connectionLost:
        setState(() {
          _connectionLost = true;
          _showConnectedBanner = false;
        });
        break;
      case NetworkManagerEvent.connectionRestored:
        setState(() {
          _connectionLost = false;
          _showConnectedBanner = true;
        });
        break;
    }
  }

  void _onBannerRetry() {
    setState(() => _connectionLost = false);
    widget.onReconnected?.call();
  }

  void _onConnectedBannerDismiss() {
    if (!mounted) return;
    setState(() => _showConnectedBanner = false);
    widget.onReconnected?.call();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(child: widget.child),
        if (_connectionLost)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Material(
              elevation: 4,
              child: NetworkOfflineBanner(
                onRetry: () async {
                  final connected = await NetworkManager.instance
                      .checkIsConnected();
                  if (!mounted) return;
                  if (connected) _onBannerRetry();
                },
              ),
            ),
          ),
        if (_showConnectedBanner)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Material(
              elevation: 4,
              child: NetworkOnlineBanner(
                dismissAfterSeconds: 3,
                onDismiss: _onConnectedBannerDismiss,
              ),
            ),
          ),
      ],
    );
  }
}
