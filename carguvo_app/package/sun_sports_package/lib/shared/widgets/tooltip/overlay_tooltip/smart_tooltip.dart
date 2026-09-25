import 'package:flutter/material.dart';
import 'arrow_position.dart';
import 'composited_tooltip_controller.dart';
import 'smart_tooltip_config.dart';
import 'smart_tooltip_controller.dart';
import 'tooltip_container.dart';
import 'tooltip_strategy.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class SmartTooltip extends StatefulWidget {
  final Widget Function(VoidCallback onClose) contentBuilder;

  final Widget Function(VoidCallback onTap)? triggerBuilder;

  final SmartTooltipConfig config;

  final TooltipStrategy strategy;

  final VoidCallback? onShow;

  final VoidCallback? onHide;

  final SmartTooltipController? controller;

  const SmartTooltip({
    required this.contentBuilder,
    super.key,
    this.triggerBuilder,
    this.config = const SmartTooltipConfig(),
    this.strategy = TooltipStrategy.composited,
    this.onShow,
    this.onHide,
    this.controller,
  });

  @override
  State<SmartTooltip> createState() => _SmartTooltipState();
}

class _SmartTooltipState extends State<SmartTooltip> {
  late final CompositedTooltipController _compositedController;
  bool _isShowing = false;

  @override
  void initState() {
    super.initState();
    _compositedController = CompositedTooltipController();
    _attachExternalController();
  }

  @override
  void didUpdateWidget(SmartTooltip oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.detach();
      _attachExternalController();
    }
  }

  @override
  void dispose() {
    widget.controller?.detach();
    _compositedController.dispose();
    super.dispose();
  }

  void _attachExternalController() {
    widget.controller?.attach(onShow: _showTooltip, onHide: _hideTooltip);
  }

  void _showTooltip() {
    if (_isShowing) return;

    final config = widget.config;

    _compositedController.show(
      context: context,
      targetAnchor: config.targetAnchor,
      followerAnchor: config.followerAnchor,
      offset: config.compositedOffset,
      autoCloseOnScroll: config.autoCloseOnScroll,
      dismissOnTapOutside: config.dismissOnTapOutside,
      rootOverlay: config.rootOverlay,
      builder: (onClose) {
        final content = widget.contentBuilder(() {
          onClose();
          _hideTooltip();
        });

        if (config.tooltipContainerBuilder != null) {
          return config.tooltipContainerBuilder!(content);
        }

        if (content is TooltipContainer) {
          return content;
        }

        return TooltipContainer(
          width: config.tooltipWidth ?? 326,
          padding: config.tooltipPadding ?? EdgeInsets.zero,
          arrowPosition: config.arrowPosition ?? ArrowPosition.topRight,
          arrowOffset: config.arrowOffset ?? 14.0,
          child: content,
        );
      },
    );

    _isShowing = true;
    widget.controller?.updateState(true);
    widget.onShow?.call();
  }

  void _hideTooltip() {
    if (!_isShowing) return;

    _compositedController.remove();
    _isShowing = false;
    widget.controller?.updateState(false);
    widget.onHide?.call();
  }

  Widget _buildDefaultTrigger(VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(widget.config.triggerBorderRadius),
      onTap: SoundTap.wrap(onTap),
      splashColor: widget.config.triggerSplashColor,
      child: Padding(
        padding: widget.config.triggerPadding,
        child: SizedBox.square(
          dimension: widget.config.triggerSize,
          child:
              widget.config.triggerIcon ??
              Icon(
                Icons.info_outline,
                size: widget.config.triggerSize,
                color: widget.config.triggerColor,
              ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trigger =
        widget.triggerBuilder?.call(_showTooltip) ??
        _buildDefaultTrigger(_showTooltip);

    return _compositedController.wrapTarget(child: trigger);
  }
}
