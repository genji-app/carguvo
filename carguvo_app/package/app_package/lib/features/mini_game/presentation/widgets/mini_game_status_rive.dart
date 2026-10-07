import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart' as rive;
import 'package:app_package/core/utils/extensions/rive_helper.dart';
import 'package:app_package/core/utils/styles/app_rive.dart';
import 'package:app_package/features/mini_game/presentation/mini_game_visibility_provider.dart';

class MiniGameStatusRive extends ConsumerStatefulWidget {
  const MiniGameStatusRive({
    required this.disconnected,
    super.key,
    this.size = 12,
  });

  final bool disconnected;

  final double size;

  @override
  ConsumerState<MiniGameStatusRive> createState() => _MiniGameStatusRiveState();
}

class _MiniGameStatusRiveState extends ConsumerState<MiniGameStatusRive> {
  static const String _kIsDisconnected = 'isDisconnected';
  static const String _kTriggerConnecting = 'triggerConnecting';
  static const String _kTriggerDisconnected = 'triggerDisconnected';

  static const Duration _settleWindow = Duration(seconds: 3);

  rive.RiveWidgetController? _controller;
  rive.ViewModelInstance? _vmi;
  Timer? _settleTimer;

  bool _didStart = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final file = await RiveHelper.getFile(AppRive.miniStatus);
      if (file == null || !mounted) return;
      final controller = rive.RiveWidgetController(file);
      rive.ViewModelInstance? vmi;
      try {
        vmi = controller.dataBind(rive.DataBind.auto());
        if (vmi.boolean(_kIsDisconnected) == null) {
          debugPrint(
            '[MiniGameRive] ${AppRive.miniStatus}: view model has no '
            '"$_kIsDisconnected" — bundle out of date?',
          );
          vmi.dispose();
          vmi = null;
        }
      } catch (_) {
        vmi = null;
      }
      setState(() {
        _controller = controller;
        _vmi = vmi;
      });
      _fireInitial();
      _armSettleFreeze();
    } catch (e) {
      debugPrint('[MiniGameRive] ${AppRive.miniStatus} load fail: $e');
    }
  }

  void _fireInitial() {
    if (_didStart) return;
    final vmi = _vmi;
    if (vmi == null) return;
    if (widget.disconnected) {
      vmi.trigger(_kTriggerDisconnected)?.trigger();
    } else {
      vmi.boolean(_kIsDisconnected)?.value = false;
      vmi.trigger(_kTriggerConnecting)?.trigger();
    }
    _didStart = true;
  }

  void _armSettleFreeze() {
    _settleTimer?.cancel();
    final controller = _controller;
    if (controller == null) return;
    controller.active = true;
    if (!widget.disconnected) return;
    _settleTimer = Timer(_settleWindow, () {
      if (!mounted || !widget.disconnected) return;
      _controller?.active = false;
    });
  }

  @override
  void didUpdateWidget(covariant MiniGameStatusRive oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.disconnected == widget.disconnected) return;
    if (!_didStart) {
      _fireInitial();
    } else {
      _vmi?.boolean(_kIsDisconnected)?.value = widget.disconnected;
    }
    _armSettleFreeze();
  }

  @override
  void dispose() {
    _settleTimer?.cancel();
    _vmi?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(miniGameVisibilityProvider, (prev, next) {
      if (prev == false && next == true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _armSettleFreeze();
          setState(() {});
        });
      }
    });

    final controller = _controller;
    if (controller == null || _vmi == null) {
      return _fallbackDot();
    }
    return SizedBox.square(
      dimension: widget.size,
      child: ClipOval(
        child: rive.RiveWidget(controller: controller, fit: rive.Fit.contain),
      ),
    );
  }

  Widget _fallbackDot() => Container(
    width: widget.size,
    height: widget.size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: widget.disconnected
          ? const Color(0xFFF04438)
          : const Color(0xFFE8A53C),
    ),
  );
}
