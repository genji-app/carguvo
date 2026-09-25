library;

import 'dart:async';

import 'package:flutter/gestures.dart' show kTouchSlop;
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';

import 'stake_keypad_controller.dart';

class StakeKeypadField extends StatefulWidget {
  const StakeKeypadField({
    required this.id,
    required this.value,
    required this.onChanged,
    this.onClosed,
    this.enabled = true,
    this.hintText = 'Nhập số tiền',
    this.height = 44,
    this.suffix,
    this.onClear,
    super.key,
  });

  final String id;

  final int value;

  final StakeKeypadChanged onChanged;

  final VoidCallback? onClosed;

  final bool enabled;
  final String hintText;
  final double height;

  final Widget? suffix;

  final VoidCallback? onClear;

  @override
  State<StakeKeypadField> createState() => _StakeKeypadFieldState();
}

class _StakeKeypadFieldState extends State<StakeKeypadField> {
  static const Color _selectionColor = Color(0x733478F6);
  static final NumberFormat _formatter = NumberFormat('#,###');

  final StakeKeypadController _keypad = StakeKeypadController.instance;
  bool _active = false;
  bool _selectAll = false;
  Offset? _outsideDown;

  @override
  void initState() {
    super.initState();
    _active = _keypad.isActive(widget.id);
    _selectAll = _active && _keypad.selectAll;
    _keypad.addListener(_onKeypadChanged);
  }

  @override
  void didUpdateWidget(covariant StakeKeypadField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      _keypad.closeId(oldWidget.id);
      _active = _keypad.isActive(widget.id);
      _selectAll = _active && _keypad.selectAll;
    }
    if (!widget.enabled) {
      scheduleMicrotask(() {
        if (mounted) _keypad.closeId(widget.id);
      });
    } else if (oldWidget.onChanged != widget.onChanged) {
      _keypad.rebind(widget.id, widget.onChanged);
    }
  }

  @override
  void dispose() {
    _keypad.removeListener(_onKeypadChanged);
    _keypad.closeId(widget.id);
    super.dispose();
  }

  void _onKeypadChanged() {
    scheduleMicrotask(() {
      if (!mounted) return;
      final active = _keypad.isActive(widget.id);
      final selectAll = active && _keypad.selectAll;
      if (active == _active && selectAll == _selectAll) return;
      final closed = _active && !active;
      setState(() {
        _active = active;
        _selectAll = selectAll;
      });
      if (closed) widget.onClosed?.call();
    });
  }

  void _onTap() {
    if (!widget.enabled) return;
    _keypad.open(widget.id, value: widget.value, onChanged: widget.onChanged);
  }

  void _onOutsideDown(PointerDownEvent event) {
    _outsideDown = event.position;
  }

  void _onOutsideUp(PointerUpEvent event) {
    final down = _outsideDown;
    _outsideDown = null;
    if (down == null || (event.position - down).distance > kTouchSlop) return;
    scheduleMicrotask(() {
      if (mounted) _keypad.closeId(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled;
    final active = _active && enabled;
    final value = widget.value;
    final textColor = enabled
        ? AppColorStyles.contentPrimary
        : AppColorStyles.contentQuaternary;

    Widget text;
    if (value <= 0) {
      text = Text(
        widget.hintText,
        style: AppTextStyles.labelMedium(color: AppColorStyles.contentQuaternary),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    } else {
      text = Text(
        _formatter.format(value),
        style: AppTextStyles.labelMedium(color: textColor),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
      if (active && _selectAll) {
        text = DecoratedBox(
          decoration: const BoxDecoration(
            color: _selectionColor,
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
          child: text,
        );
      }
    }

    return TapRegion(
      groupId: widget.id,
      enabled: active,
      onTapOutside: _onOutsideDown,
      onTapUpOutside: _onOutsideUp,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onTap,
        child: Container(
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColorStyles.backgroundSecondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active ? AppColors.yellow300 : AppColorStyles.borderPrimary,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(child: text),
                    if (active && !_selectAll) const _BlinkingCaret(),
                  ],
                ),
              ),
              if (widget.suffix != null) ...[const Gap(8), widget.suffix!],
              if (widget.onClear != null && value > 0)
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: GestureDetector(
                    onTap: widget.onClear,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColorStyles.backgroundTertiary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: AppColorStyles.contentPrimary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BlinkingCaret extends StatefulWidget {
  const _BlinkingCaret();

  @override
  State<_BlinkingCaret> createState() => _BlinkingCaretState();
}

class _BlinkingCaretState extends State<_BlinkingCaret>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blink = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _blink,
      child: Container(
        width: 2,
        height: 20,
        margin: const EdgeInsets.only(left: 1),
        color: AppColorStyles.contentPrimary,
      ),
    );
  }
}
