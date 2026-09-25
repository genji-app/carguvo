library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

import 'stake_keypad_controller.dart';
import 'stake_keypad_math.dart';

class StakeKeypadSlot extends StatefulWidget {
  const StakeKeypadSlot({
    required this.id,
    required this.maxStake,
    required this.balance,
    this.topGap = 8,
    super.key,
  });

  final String id;

  final int maxStake;

  final int balance;

  final double topGap;

  @override
  State<StakeKeypadSlot> createState() => _StakeKeypadSlotState();
}

class _StakeKeypadSlotState extends State<StakeKeypadSlot> {
  final StakeKeypadController _keypad = StakeKeypadController.instance;
  bool _active = false;

  @override
  void initState() {
    super.initState();
    _active = _keypad.isActive(widget.id);
    _keypad.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(covariant StakeKeypadSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) _active = _keypad.isActive(widget.id);
  }

  @override
  void dispose() {
    _keypad.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    scheduleMicrotask(() {
      if (!mounted) return;
      final active = _keypad.isActive(widget.id);
      if (active == _active) return;
      setState(() => _active = active);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_active) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(top: widget.topGap),
      child: TapRegion(
        groupId: widget.id,
        child: StakeKeypad(maxStake: widget.maxStake, balance: widget.balance),
      ),
    );
  }
}

class StakeKeypad extends StatefulWidget {
  const StakeKeypad({required this.maxStake, required this.balance, super.key});

  final int maxStake;
  final int balance;

  static const double keyHeight = 38;
  static const double gap = 6;

  @override
  State<StakeKeypad> createState() => _StakeKeypadState();
}

class _StakeKeypadState extends State<StakeKeypad> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Scrollable.ensureVisible(
        context,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  void _press(StakeKey key) {
    StakeKeypadController.instance.press(
      key,
      maxStake: widget.maxStake,
      balance: widget.balance,
    );
  }

  @override
  Widget build(BuildContext context) {
    const gap = StakeKeypad.gap;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _row([_digit('1'), _digit('2'), _digit('3'), _side('+50K', const StakeAddKey(50000))]),
        const SizedBox(height: gap),
        _row([_digit('4'), _digit('5'), _digit('6'), _side('+100K', const StakeAddKey(100000))]),
        const SizedBox(height: gap),
        _row([_digit('7'), _digit('8'), _digit('9'), _side('TỐI ĐA', const StakeMaxKey())]),
        const SizedBox(height: gap),
        _row([
          _digit('00'),
          _digit('0'),
          _KeypadKey(
            kind: _KeyKind.digit,
            onPressed: () => _press(const StakeBackspaceKey()),
            child: const Icon(
              Icons.backspace,
              size: 24,
              color: AppColorStyles.contentPrimary,
              semanticLabel: 'Xóa',
            ),
          ),
          _KeypadKey(
            kind: _KeyKind.done,
            onPressed: () => _press(const StakeDoneKey()),
            child: Text(
              'Đã xong',
              style: AppTextStyles.buttonSmall(color: Colors.white),
            ),
          ),
        ]),
      ],
    );
  }

  Widget _row(List<Widget> keys) => Row(
    children: [
      for (var i = 0; i < keys.length; i++) ...[
        if (i > 0) const SizedBox(width: StakeKeypad.gap),
        Expanded(child: keys[i]),
      ],
    ],
  );

  Widget _digit(String digits) => _KeypadKey(
    kind: _KeyKind.digit,
    onPressed: () => _press(StakeDigitsKey(digits)),
    child: Text(
      digits,
      style: AppTextStyles.textStyle(
        fontSize: 18,
        height: 24 / 18,
        fontWeight: FontWeight.bold,
        color: AppColorStyles.contentPrimary,
      ),
    ),
  );

  Widget _side(String label, StakeKey key) => _KeypadKey(
    kind: _KeyKind.side,
    onPressed: () => _press(key),
    child: Text(
      label,
      style: AppTextStyles.buttonSmall(color: AppColors.yellow300),
    ),
  );
}

enum _KeyKind { digit, side, done }

class _KeypadKey extends StatefulWidget {
  const _KeypadKey({
    required this.kind,
    required this.onPressed,
    required this.child,
  });

  final _KeyKind kind;
  final VoidCallback onPressed;
  final Widget child;

  @override
  State<_KeypadKey> createState() => _KeypadKeyState();
}

class _KeypadKeyState extends State<_KeypadKey> {
  static const _radius = BorderRadius.all(Radius.circular(8));

  static const _doneShine = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x3DFFFFFF), Color(0x00FFFFFF)],
    stops: [0.0, 0.5523],
  );

  bool _pressed = false;

  Color get _background => switch (widget.kind) {
    _KeyKind.digit =>
      _pressed
          ? AppColorStyles.backgroundQuaternary
          : AppColorStyles.backgroundTertiary,
    _KeyKind.side =>
      _pressed
          ? AppColorStyles.backgroundTertiary
          : AppColorStyles.backgroundSecondary,
    _KeyKind.done => _pressed ? AppColors.yellow900 : AppColors.yellow700,
  };

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: SoundTap.wrap(widget.onPressed),
      child: Container(
        height: StakeKeypad.keyHeight,
        decoration: BoxDecoration(color: _background, borderRadius: _radius),
        foregroundDecoration: widget.kind == _KeyKind.done && !_pressed
            ? const BoxDecoration(gradient: _doneShine, borderRadius: _radius)
            : null,
        alignment: Alignment.center,
        child: widget.child,
      ),
    );
  }
}
