import 'package:flutter/foundation.dart' show VoidCallback;

import 'splash_web_video_rotator_stub.dart'
    if (dart.library.html) 'splash_web_video_rotator_web.dart'
    as impl;

Future<void> rotateWebVideoElement({
  VoidCallback? onSkip,
  void Function(bool muted)? onSoundToggle,
}) =>
    impl.rotateWebVideoElement(onSkip: onSkip, onSoundToggle: onSoundToggle);

void resetWebVideoElement() => impl.resetWebVideoElement();

void showWebSoundButton(void Function(bool muted) onToggle) =>
    impl.showWebSoundButton(onToggle);

void removeWebSoundButton() => impl.removeWebSoundButton();
