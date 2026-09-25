import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart';

import 'package:sun_sports/core/utils/sound_effects.dart';
import 'package:sun_sports/core/utils/styles/app_audios.dart';

class SoundTap extends StatelessWidget {
  const SoundTap({
    required this.child,
    this.onTap,
    this.onLongPress,
    this.sound = AppSound.uiTap,
    this.behavior = HitTestBehavior.opaque,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  final AppSound sound;

  final HitTestBehavior behavior;

  static VoidCallback? wrap(
    VoidCallback? onTap, {
    AppSound sound = AppSound.uiTap,
  }) {
    if (onTap == null) return null;
    return () {
      onTap();
      SchedulerBinding.instance.addPostFrameCallback(
        (_) => SoundEffects.instance.play(sound),
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: behavior,
      onTap: wrap(onTap, sound: sound),
      onLongPress: onLongPress,
      child: child,
    );
  }
}
