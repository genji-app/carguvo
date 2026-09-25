import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_rive.dart';
import 'package:sun_sports/mini/up_down/widgets/up_down_common.dart';
import 'package:sun_sports/mini/up_down/widgets/up_down_rive.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class UpDownHintBar extends StatelessWidget {
  const UpDownHintBar({super.key});

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      height: 20 / 14,
      color: Colors.white,
    );
    return Container(
      height: 34,
      width: double.infinity,
      color: AppColorStyles.backgroundTertiary,
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(I18n.upDownTap, style: textStyle),
          const SizedBox(width: 8),
          const UpDownSwapIcon(size: 17),
          const SizedBox(width: 8),
          Text(I18n.upDownToStart, style: textStyle),
        ],
      ),
    );
  }
}

class UpDownStartArea extends StatelessWidget {
  final VoidCallback onStart;

  final bool Function() canStart;

  const UpDownStartArea({
    required this.onStart,
    required this.canStart,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 152,
      width: double.infinity,
      color: AppColorStyles.backgroundQuaternary,
      child: Center(
        child: UpDownStartButton(onTap: onStart, canStart: canStart),
      ),
    );
  }
}

class UpDownStartButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool Function() canStart;

  final double size;

  const UpDownStartButton({
    required this.onTap,
    required this.canStart,
    this.size = 108,
    super.key,
  });

  @override
  State<UpDownStartButton> createState() => _UpDownStartButtonState();
}

class _UpDownStartButtonState extends State<UpDownStartButton> {
  static const String _kTriggerStart = 'triggerStart';

  static const Duration _kPressAnimHold = Duration(milliseconds: 360);

  UpDownRiveHandle? _rive;

  bool _pressing = false;

  Future<void> _onTap() async {
    if (_pressing) return;
    _pressing = true;
    _rive?.fire(_kTriggerStart);
    await Future<void>.delayed(_kPressAnimHold);
    _pressing = false;
    if (!mounted) return;
    if (!widget.canStart()) {
      _rive?.reset();
      return;
    }
    widget.onTap();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _rive?.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: SoundTap.wrap(_onTap),
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: widget.size - 8,
                height: widget.size - 8,
                child: UpDownRive(
                  name: AppRive.upDownBtnStart,
                  onReady: (h) => _rive = h,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
