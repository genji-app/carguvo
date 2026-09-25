import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'form_control_builder.dart';
import 'form_control_controller.dart';
import 'form_control_state.dart';

abstract class FormControlBase<T> extends ConsumerStatefulWidget {
  const FormControlBase({
    super.key,
    this.controller,
    this.state = FormControlState.idle,
    this.onSubmit,
    this.animationDuration = const Duration(milliseconds: 200),
    this.successDuration = const Duration(seconds: 1),
    this.errorDuration = const Duration(seconds: 2),
    this.resetOnSuccess = false,
    this.resetOnError = true,
    this.onInit,
    this.onStateChange,
  });

  final FormControlController? controller;

  final void Function(FormControlController controller)? onInit;

  final FormControlState state;

  final Future<bool> Function()? onSubmit;

  final Duration animationDuration;

  final Duration successDuration;

  final Duration errorDuration;

  final bool resetOnSuccess;

  final bool resetOnError;

  final void Function(FormControlState state)? onStateChange;

  FormControlBuilder<T> getBuilder();

  T get data;

  @override
  FormControlBaseState<T> createState();
}

abstract class FormControlBaseState<T>
    extends ConsumerState<FormControlBase<T>> {
  late FormControlController _localController;
  late FormControlState _internalState;
  FormControlController? _previousController;

  FormControlController get _effectiveController =>
      widget.controller ?? _localController;

  @override
  void initState() {
    super.initState();
    _localController = FormControlController(initialState: widget.state);
    _internalState = widget.state;

    _setupControllerListener(_effectiveController);

    _effectiveController.registerSubmitCallback(_handleSubmit);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onInit?.call(_effectiveController);
    });
  }

  @override
  void didUpdateWidget(covariant FormControlBase<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newEffectiveController = widget.controller ?? _localController;
    if (_previousController != newEffectiveController) {
      _previousController?.removeListener(_onControllerStateChanged);
      _setupControllerListener(newEffectiveController);
      newEffectiveController.registerSubmitCallback(_handleSubmit);
    }

    if (oldWidget.state != widget.state && _internalState != widget.state) {
      _updateState(widget.state);
    }

    if (oldWidget.onSubmit != widget.onSubmit) {
      _effectiveController.registerSubmitCallback(_handleSubmit);
    }
  }

  void _setupControllerListener(FormControlController controller) {
    _previousController?.removeListener(_onControllerStateChanged);
    controller.addListener(_onControllerStateChanged);
    _previousController = controller;

    if (_internalState != controller.state) {
      _internalState = controller.state;
    }
  }

  void _onControllerStateChanged() {
    if (_internalState != _effectiveController.state) {
      setState(() {
        _internalState = _effectiveController.state;
      });
      widget.onStateChange?.call(_internalState);
    }
  }

  void _updateState(FormControlState newState) {
    if (!mounted) return;
    setState(() {
      _internalState = newState;
    });
    _effectiveController.setState(newState);
    widget.onStateChange?.call(newState);
  }

  Future<void> _handleSubmit() async {
    if (widget.onSubmit == null) return;
    if (_internalState != FormControlState.idle) return;

    _updateState(FormControlState.processing);

    final success = await widget.onSubmit!();
    if (success) {
      _updateState(FormControlState.success);
      if (widget.resetOnSuccess) {
        await Future<void>.delayed(widget.successDuration);
        _updateState(FormControlState.idle);
      }
    } else {
      _updateState(FormControlState.error);
      if (widget.resetOnError) {
        await Future<void>.delayed(widget.errorDuration);
        _updateState(FormControlState.idle);
      }
    }
  }

  @override
  void dispose() {
    _previousController?.removeListener(_onControllerStateChanged);
    _effectiveController.unregisterSubmitCallback();
    _localController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentState = _internalState;
    final builder = widget.getBuilder();
    final uiData = widget.data;

    return AnimatedSwitcher(
      duration: widget.animationDuration,
      layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
        return Stack(
          alignment: Alignment.center,
          fit: StackFit.passthrough,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      child: KeyedSubtree(
        key: ValueKey<FormControlState>(currentState),
        child: _buildChild(
          context,
          currentState,
          builder,
          uiData,
          _effectiveController,
        ),
      ),
    );
  }

  Widget _buildChild(
    BuildContext context,
    FormControlState currentState,
    FormControlBuilder<T> builder,
    T data,
    FormControlController controller,
  ) {
    switch (currentState) {
      case FormControlState.idle:
        return builder.buildIdle(context, data, controller);
      case FormControlState.disabled:
        return builder.buildDisabled(context, data, controller);
      case FormControlState.processing:
        return builder.buildProcessing(context, data, controller);
      case FormControlState.success:
        return builder.buildSuccess(context, data, controller);
      case FormControlState.error:
        return builder.buildError(context, data, controller);
    }
  }
}
