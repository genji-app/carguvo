import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart' as rive;
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/extensions/rive_helper.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_rive.dart';
import 'package:sun_sports/features/mini_game/presentation/mini_game_visibility_provider.dart';

class MiniGameLobbyTxRive extends ConsumerStatefulWidget {
  final bool? result;

  final bool isLoading;

  const MiniGameLobbyTxRive({
    this.result,
    this.isLoading = false,
    super.key,
  });

  @override
  ConsumerState<MiniGameLobbyTxRive> createState() => _MiniGameLobbyTxRiveState();
}

class _MiniGameLobbyTxRiveState extends ConsumerState<MiniGameLobbyTxRive>
    with WidgetsBindingObserver {
  static const String _kIsTaiProp = 'isTai';
  static const String _kIsXiuProp = 'isXiu';
  static const String _kIsLoadingProp = 'isLoading';

  rive.File? _file;

  rive.RiveWidgetController? _controller;

  rive.ViewModelInstance? _vmi;

  Timer? _settleTimer;
  static const Duration _settleWindow = Duration(seconds: 3);

  void _armSettleFreeze() {
    _settleTimer?.cancel();
    final controller = _controller;
    if (controller == null) return;
    controller.active = true;
    if (widget.isLoading) return;
    _settleTimer = Timer(_settleWindow, () {
      if (!mounted || widget.isLoading) return;
      _controller?.active = false;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _armSettleFreeze();
      setState(() {});
    });
  }

  Future<void> _load() async {
    try {
      final file = await RiveHelper.getFile(AppRive.mnlobbytx);
      if (file == null || !mounted) return;
      _file = file;
      final (controller, vmi) = _build(file);
      setState(() {
        _controller = controller;
        _vmi = vmi;
      });
      _applyInputs();
      _armSettleFreeze();
    } catch (e) {
      debugPrint('[MiniGameRive] ${AppRive.mnlobbytx} load fail: $e');
    }
  }

  (rive.RiveWidgetController, rive.ViewModelInstance?) _build(rive.File file) {
    final controller = rive.RiveWidgetController(file);
    rive.ViewModelInstance? vmi;
    try {
      vmi = controller.dataBind(rive.DataBind.auto());
      if (vmi.boolean(_kIsTaiProp) == null) {
        vmi.dispose();
        vmi = null;
      }
    } catch (_) {
      vmi = null;
    }
    return (controller, vmi);
  }

  @override
  void didUpdateWidget(MiniGameLobbyTxRive oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.result != null && widget.result == null) {
      _resetToIdle();
    } else if (oldWidget.result != widget.result ||
        oldWidget.isLoading != widget.isLoading) {
      _applyInputs();
      _armSettleFreeze();
    }
  }

  void _resetToIdle() {
    final file = _file;
    if (file == null) return;
    final old = _controller;
    final oldVmi = _vmi;
    final (controller, vmi) = _build(file);
    setState(() {
      _controller = controller;
      _vmi = vmi;
    });
    _applyInputs();
    _armSettleFreeze();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      oldVmi?.dispose();
      old?.dispose();
    });
  }

  void _applyInputs() {
    final vmi = _vmi;
    if (vmi == null) return;
    vmi.boolean(_kIsTaiProp)?.value = widget.result == true;
    vmi.boolean(_kIsXiuProp)?.value = widget.result == false;
    vmi.boolean(_kIsLoadingProp)?.value = widget.isLoading;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
          _controller?.active = true;
          setState(() {});
        });
      }
    });

    final controller = _controller;
    if (controller == null) {
      return ImageHelper.load(path: AppImages.fabTrophy, fit: BoxFit.fill);
    }
    return rive.RiveWidget(controller: controller, fit: rive.Fit.contain);
  }
}
