import 'package:flutter/foundation.dart' show kDebugMode, mapEquals;
import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

import 'package:sun_sports/core/utils/extensions/rive_helper.dart';

abstract class UpDownRiveHandle {
  void fire(String trigger);

  void reset();
}

class UpDownRive extends StatefulWidget {
  final String name;

  final Map<String, bool> booleans;

  final rive.Fit fit;

  final ValueChanged<UpDownRiveHandle>? onReady;

  const UpDownRive({
    required this.name,
    this.booleans = const <String, bool>{},
    this.fit = rive.Fit.contain,
    this.onReady,
    super.key,
  });

  @override
  State<UpDownRive> createState() => _UpDownRiveState();
}

class _UpDownRiveState extends State<UpDownRive> implements UpDownRiveHandle {
  rive.RiveWidgetController? _controller;

  rive.ViewModelInstance? _vmi;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final file = await RiveHelper.getFile(widget.name);
      if (file == null || !mounted) return;
      final controller = rive.RiveWidgetController(file);
      rive.ViewModelInstance? vmi;
      try {
        vmi = controller.dataBind(rive.DataBind.auto());
      } catch (e) {
        if (kDebugMode) {
          debugPrint('UpDownRive: dataBind fail cho "${widget.name}": $e');
        }
        vmi = null;
      }
      setState(() {
        _controller = controller;
        _vmi = vmi;
      });
      _applyBooleans();
      widget.onReady?.call(this);
    } catch (_) {
    }
  }

  @override
  void didUpdateWidget(UpDownRive oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!mapEquals(oldWidget.booleans, widget.booleans)) _applyBooleans();
  }

  void _applyBooleans() {
    final vmi = _vmi;
    final sm = _controller?.stateMachine;
    widget.booleans.forEach((name, value) {
      final prop = vmi?.boolean(name);
      if (prop != null) {
        prop.value = value;
        return;
      }
      // ignore: deprecated_member_use
      sm?.boolean(name)?.value = value;
    });
  }

  @override
  void fire(String trigger) {
    if (!mounted) return;
    final prop = _vmi?.trigger(trigger);
    if (prop != null) {
      prop.trigger();
      return;
    }
    // ignore: deprecated_member_use
    _controller?.stateMachine.trigger(trigger)?.fire();
  }

  @override
  void reset() {
    if (!mounted) return;
    _vmi?.dispose();
    _controller?.dispose();
    setState(() {
      _vmi = null;
      _controller = null;
    });
    _load();
  }

  @override
  void dispose() {
    _vmi?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) return const SizedBox.shrink();
    return IgnorePointer(
      child: rive.RiveWidget(controller: controller, fit: widget.fit),
    );
  }
}
