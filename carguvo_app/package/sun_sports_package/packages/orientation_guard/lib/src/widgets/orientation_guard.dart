import 'package:flutter/widgets.dart';

import '../controllers/orientation_controller.dart';
import '../models/orientation_policy.dart';
import '../utils/orientation_log.dart';
import 'orientation_mismatch_view.dart';
import 'orientation_scope.dart';

class OrientationGuard extends StatefulWidget {
  const OrientationGuard({
    super.key,
    required this.policy,
    required this.child,
    this.controller,
    this.mismatchBuilder,
    this.blockOnMismatch,
    this.onMismatchChanged,
  });

  final OrientationPolicy policy;

  final Widget child;

  final OrientationController? controller;

  final WidgetBuilder? mismatchBuilder;

  final bool? blockOnMismatch;

  final ValueChanged<bool>? onMismatchChanged;

  @override
  State<OrientationGuard> createState() => _OrientationGuardState();
}

class _OrientationGuardState extends State<OrientationGuard> {
  OrientationController? _resolvedController;
  OrientationPolicy? _lastAppliedPolicy;
  OrientationPolicy? _previousPolicy;
  bool _capturedPrevious = false;
  final ValueNotifier<bool> _isApplying = ValueNotifier(false);
  bool? _lastMatched;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveAndApply();
    _notifyMismatchChanged();
  }

  @override
  void didUpdateWidget(OrientationGuard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.policy != oldWidget.policy || widget.controller != oldWidget.controller) {
      _resolveAndApply();
      _notifyMismatchChanged();
    }
  }

  @override
  void dispose() {
    if (_resolvedController != null) {
      final controller = _resolvedController!;
      final previous = _previousPolicy;

      if (controller.activePolicy == widget.policy && controller.activePolicy != previous) {
        orientationLog(
          '[OrientationGuard] disposing: ${widget.policy.debugLabel ?? 'unnamed'}, restoring: ${previous?.debugLabel ?? 'none'}',
        );
        controller.restore(previous);
      } else {
        orientationLog(
          '[OrientationGuard] disposing: ${widget.policy.debugLabel ?? 'unnamed'}, restore skipped (already matched or overridden)',
        );
      }
    }
    _isApplying.dispose();
    super.dispose();
  }

  void _resolveAndApply() {
    final controller = widget.controller ?? OrientationScope.of(context);
    _resolvedController = controller;

    if (!_capturedPrevious) {
      _previousPolicy = OrientationScope.maybePolicyOf(context);
      _capturedPrevious = true;
      orientationLog(
        '[OrientationGuard] Captured previous policy: ${_previousPolicy?.debugLabel ?? 'none'} for ${widget.policy.debugLabel ?? 'unnamed'}',
      );
    }

    if (_lastAppliedPolicy != widget.policy) {
      _lastAppliedPolicy = widget.policy;

      final currentOrientation = MediaQuery.of(context).orientation;
      final alreadyMatched = controller.isMatched(
        policy: widget.policy,
        currentOrientation: currentOrientation,
      );

      orientationLog(
        '[OrientationGuard] _resolveAndApply: ${widget.policy.debugLabel ?? 'unnamed'}, alreadyMatched: $alreadyMatched',
      );

      if (alreadyMatched) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            controller.apply(widget.policy);
            _notifyMismatchChanged();
          }
        });
        return;
      }

      _isApplying.value = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted) {
          await controller.apply(widget.policy);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _isApplying.value = false;
              _notifyMismatchChanged();
            }
          });
        }
      });
    }
  }

  void _notifyMismatchChanged() {
    if (widget.onMismatchChanged == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final currentOrientation = MediaQuery.of(context).orientation;
      final controller = _resolvedController ?? widget.controller ?? OrientationScope.of(context);

      final isMatched = _isApplying.value
          ? true
          : controller.isMatched(
              policy: widget.policy,
              currentOrientation: currentOrientation,
            );

      if (_lastMatched != isMatched) {
        _lastMatched = isMatched;
        widget.onMismatchChanged?.call(!isMatched);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = _resolvedController ?? widget.controller ?? OrientationScope.of(context);

    return ListenableBuilder(
      listenable: Listenable.merge([controller, _isApplying]),
      builder: (context, _) {
        final currentOrientation = MediaQuery.of(context).orientation;
        final isApplying = _isApplying.value || controller.isApplying;

        final isMatched = isApplying
            ? true
            : controller.isMatched(policy: widget.policy, currentOrientation: currentOrientation);

        final shouldBlock = widget.blockOnMismatch ?? widget.policy.blockOnMismatch;
        final activePolicy = controller.activePolicy;
        final isOverridden = activePolicy != null && activePolicy != widget.policy;

        orientationLog(
          '[OrientationGuard] build (${widget.policy.debugLabel}): '
          'orientation=$currentOrientation, '
          'activePolicy=${activePolicy?.debugLabel}, '
          'isOverridden=$isOverridden, '
          'isMatched=$isMatched, '
          'shouldBlock=$shouldBlock',
        );

        if (shouldBlock && !isMatched && !isOverridden) {
          orientationLog(
            '[OrientationGuard] Mismatch detected (${widget.policy.debugLabel}): '
            'orientation=$currentOrientation, activePolicy=${activePolicy?.debugLabel}, '
            'isOverridden=$isOverridden',
          );
          if (widget.mismatchBuilder != null) {
            return widget.mismatchBuilder!(context);
          }
          return OrientationMismatchView(policy: widget.policy);
        }

        if (!isMatched && isOverridden) {
          orientationLog(
            '[OrientationGuard] Mismatch suppressed by override (${widget.policy.debugLabel}): '
            'activePolicy=${activePolicy.debugLabel}',
          );
        }

        return OrientationScope(
          controller: controller,
          currentPolicy: widget.policy,
          child: widget.child,
        );
      },
    );
  }
}
