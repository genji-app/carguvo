import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart' as rive;
import 'package:app_package/core/utils/extensions/rive_helper.dart';
import 'package:app_package/core/utils/styles/app_rive.dart';

import 'package:app_package/features/mini_game/presentation/mini_game_visibility_provider.dart';
import 'package:app_package/features/mini_game/presentation/widgets/mini_game_countdown_badge.dart';

class MiniGameBadgeTxRive extends ConsumerStatefulWidget {
  final bool? result;

  final bool isLoading;

  final double size;

  final bool showFallback;

  const MiniGameBadgeTxRive({
    this.result,
    this.isLoading = false,
    super.key,
    this.size = 28,
    this.showFallback = true,
  });

  static const double _kArtboardW = 28;

  static const double _kDotW = 22;

  double get canvasSize => size * _kArtboardW / _kDotW;

  @override
  ConsumerState<MiniGameBadgeTxRive> createState() => _MiniGameBadgeTxRiveState();
}

class _MiniGameBadgeTxRiveState extends ConsumerState<MiniGameBadgeTxRive>
    with WidgetsBindingObserver {
  static const String _kRsTaiProp = 'rsTai';
  static const String _kRsXiuProp = 'rsXiu';
  static const String _kIsLoadingProp = 'isLoading';

  bool? _firedResult;

  rive.File? _file;

  rive.RiveWidgetController? _controller;

  rive.ViewModelInstance? _vmi;

  Timer? _settleTimer;
  static const Duration _settleWindow = Duration(seconds: 3);

  static const Duration _resultAnimWindow = Duration(seconds: 15);

  bool _instanceSawLoading = false;

  bool _primePending = false;

  void _armSettleFreeze() {
    _settleTimer?.cancel();
    final controller = _controller;
    if (controller == null) return;
    controller.active = true;
    if (widget.isLoading) return;
    final window = widget.result != null ? _resultAnimWindow : _settleWindow;
    _settleTimer = Timer(window, () {
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
      final file = await RiveHelper.getFile(AppRive.mnBadgeTx);
      if (file == null || !mounted) return;
      _file = file;
      final (controller, vmi) = _build(file);
      setState(() {
        _controller = controller;
        _vmi = vmi;
      });
      _instanceSawLoading = false;
      _firedResult = null;
      _pushInputs();
      _armSettleFreeze();
    } catch (e) {
      debugPrint('[MiniGameRive] ${AppRive.mnBadgeTx} load fail: $e');
    }
  }

  (rive.RiveWidgetController, rive.ViewModelInstance?) _build(rive.File file) {
    final controller = rive.RiveWidgetController(file);
    rive.ViewModelInstance? vmi;
    try {
      vmi = controller.dataBind(rive.DataBind.auto());
      if (vmi.trigger(_kRsTaiProp) == null) {
        vmi.dispose();
        vmi = null;
      }
    } catch (_) {
      vmi = null;
    }
    return (controller, vmi);
  }

  @override
  void didUpdateWidget(MiniGameBadgeTxRive oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.result != null && widget.result == null) {
      _resetToIdle();
    } else if (oldWidget.result != widget.result ||
        oldWidget.isLoading != widget.isLoading) {
      _pushInputs();
      _armSettleFreeze();
    }
  }

  void _pushInputs() {
    final wantsResult = widget.result != null && !widget.isLoading;
    if (wantsResult && !_instanceSawLoading && _vmi != null) {
      _applyInputs(forceLoading: true);
      _instanceSawLoading = true;
      if (_primePending) return;
      _primePending = true;
      WidgetsBinding.instance.ensureVisualUpdate();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          _primePending = false;
          return;
        }
        WidgetsBinding.instance.ensureVisualUpdate();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _primePending = false;
          if (!mounted) return;
          _applyInputs();
          _armSettleFreeze();
        });
      });
      return;
    }
    _applyInputs();
    if (widget.isLoading) _instanceSawLoading = true;
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
    _instanceSawLoading = false;
    _firedResult = null;
    _pushInputs();
    _armSettleFreeze();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      oldVmi?.dispose();
      old?.dispose();
    });
  }

  void _applyInputs({bool forceLoading = false}) {
    final vmi = _vmi;
    if (vmi == null) return;
    vmi.boolean(_kIsLoadingProp)?.value = forceLoading || widget.isLoading;
    final result = widget.result;
    if (forceLoading || result == null || _firedResult == result) return;
    _firedResult = result;
    vmi.trigger(result ? _kRsTaiProp : _kRsXiuProp)?.trigger();
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
      if (!widget.showFallback) {
        return SizedBox.square(dimension: widget.size);
      }
      return widget.result != null
          ? MiniGameTaiXiuResultBadge(isTai: widget.result!, size: widget.size)
          : MiniGameTimePillFrame(size: widget.size);
    }
    final canvas = widget.canvasSize;
    return SizedBox.square(
      dimension: widget.size,
      child: Center(
        child: OverflowBox(
          maxWidth: canvas,
          maxHeight: canvas,
          child: SizedBox.square(
            dimension: canvas,
            child: rive.RiveWidget(
              controller: controller,
              fit: rive.Fit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
