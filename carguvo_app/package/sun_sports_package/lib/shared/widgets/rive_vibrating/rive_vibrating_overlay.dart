import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart' as rive;
import 'package:sun_sports/shared/widgets/rive_vibrating/rive_vibrating_service.dart';

class RiveVibratingOverlay extends ConsumerStatefulWidget {
  const RiveVibratingOverlay({super.key});

  @override
  ConsumerState<RiveVibratingOverlay> createState() =>
      _RiveVibratingOverlayState();
}

class _RiveVibratingOverlayState extends ConsumerState<RiveVibratingOverlay> {
  rive.RiveWidgetController? _controller;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    final service = ref.read(riveVibratingServiceProvider);
    if (service.isInitialized) {
      _controller = service.createController();
    }
  }

  @override
  void didUpdateWidget(RiveVibratingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller == null) {
      _initController();
      if (_controller != null && mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isServiceReady = ref.watch(riveVibratingInitializedProvider);

    if (isServiceReady && _controller == null) {
      _initController();
    }

    if (_controller == null) {
      return const SizedBox.shrink();
    }

    return RepaintBoundary(
      child: IgnorePointer(
        child: rive.RiveWidget(controller: _controller!, fit: rive.Fit.fill),
      ),
    );
  }
}

class PositionedRiveVibratingOverlay extends StatelessWidget {
  final bool isVisible;

  const PositionedRiveVibratingOverlay({super.key, required this.isVisible});

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return const Positioned.fill(child: RiveVibratingOverlay());
  }
}
