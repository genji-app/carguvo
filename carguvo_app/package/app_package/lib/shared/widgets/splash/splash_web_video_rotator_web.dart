// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:html' as html;

import 'package:flutter/foundation.dart' show VoidCallback, debugPrint;

const String _markerAttr = 'data-splash-rotated';
const String _skipBtnId = 'splash-skip-btn';
const String _soundBtnId = 'splash-sound-btn';

const Duration _soundToggleCooldown = Duration(milliseconds: 400);

VoidCallback? _activeSkipCallback;
html.ButtonElement? _skipButton;
html.EventListener? _skipListener;
html.EventListener? _viewportListener;

void Function(bool muted)? _activeSoundToggle;
html.ButtonElement? _soundButton;
html.EventListener? _soundListener;
bool _soundMuted = true;
bool _soundToggleLocked = false;

Future<void> rotateWebVideoElement({
  VoidCallback? onSkip,
  void Function(bool muted)? onSoundToggle,
}) async {
  for (var attempt = 0; attempt < 50; attempt++) {
    final videos = html.document.querySelectorAll('video');
    if (videos.isNotEmpty) {
      for (final node in videos) {
        if (node is! html.VideoElement) continue;
        if (node.getAttribute(_markerAttr) == '1') continue;
        node.setAttribute(_markerAttr, '1');
        _prepareElement(node);
      }
      _applyOrientationToAll();
      _ensureViewportListener();
      if (onSkip != null) _ensureSkipButton(onSkip);
      if (onSoundToggle != null) showWebSoundButton(onSoundToggle);
      debugPrint(
        '[Splash] web rotated ${videos.length} video element(s) '
        'viewport=${html.window.innerWidth}x${html.window.innerHeight} '
        'portrait=${_viewportIsPortrait()}',
      );
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  debugPrint('[Splash] web rotate: no <video> element found after 5s');
}

void _prepareElement(html.VideoElement v) {
  if (v.parent != html.document.body) {
    html.document.body!.append(v);
  }

  final s = v.style;
  s.position = 'fixed';
  s.left = '50%';
  s.top = '50%';
  s.setProperty('object-fit', 'cover');
  s.setProperty('max-width', 'none');
  s.setProperty('max-height', 'none');
  s.transformOrigin = 'center center';
  s.zIndex = '999999';
  s.backgroundColor = 'black';
}

bool _viewportIsPortrait() {
  final w = html.window.innerWidth ?? 0;
  final h = html.window.innerHeight ?? 0;
  return h > w;
}

void _applyOrientation(html.VideoElement v) {
  final s = v.style;
  if (_viewportIsPortrait()) {
    s.width = '100vh';
    s.height = '100vw';
    s.marginLeft = '-50vh';
    s.marginTop = '-50vw';
    s.transform = 'rotate(90deg)';
  } else {
    s.width = '100vw';
    s.height = '100vh';
    s.marginLeft = '-50vw';
    s.marginTop = '-50vh';
    s.transform = 'none';
  }
}

void _applyOrientationToAll() {
  final videos = html.document.querySelectorAll('video');
  for (final node in videos) {
    if (node is! html.VideoElement) continue;
    if (node.getAttribute(_markerAttr) != '1') continue;
    _applyOrientation(node);
  }
  _applySkipButtonOrientation();
  _applySoundButtonOrientation();
}

void _onViewportChange(html.Event _) {
  _applyOrientationToAll();
  Future<void>.delayed(
    const Duration(milliseconds: 300),
    _applyOrientationToAll,
  );
}

void _ensureViewportListener() {
  if (_viewportListener != null) return;
  _viewportListener = _onViewportChange;
  html.window.addEventListener('resize', _viewportListener);
  html.window.addEventListener('orientationchange', _viewportListener);
}

void _applySkipButtonOrientation() {
  final btn = _skipButton;
  if (btn == null) return;
  btn.style.transform = _viewportIsPortrait() ? 'rotate(90deg)' : 'none';
}

void _onSkipClick(html.Event _) {
  final cb = _activeSkipCallback;
  if (cb != null) cb();
}

void _ensureSkipButton(VoidCallback onSkip) {
  _activeSkipCallback = onSkip;

  if (_skipButton != null && _skipButton!.isConnected == true) return;

  final btn = html.ButtonElement()
    ..id = _skipBtnId
    ..text = 'Bỏ qua';

  final s = btn.style;
  s.position = 'fixed';
  s.bottom = '24px';
  s.right = '24px';
  s.zIndex = '1000000';
  s.padding = '8px 16px';
  s.backgroundColor = 'rgba(0,0,0,0.5)';
  s.color = 'white';
  s.border = 'none';
  s.borderRadius = '24px';
  s.fontSize = '14px';
  s.fontWeight = '500';
  s.cursor = 'pointer';
  s.fontFamily = 'system-ui, -apple-system, sans-serif';
  s.transformOrigin = 'center center';
  s.setProperty('-webkit-tap-highlight-color', 'transparent');

  _skipListener = _onSkipClick;
  btn.addEventListener('click', _skipListener);

  html.document.body!.append(btn);
  _skipButton = btn;
  _applySkipButtonOrientation();
}

void _applySoundButtonOrientation() {
  final btn = _soundButton;
  if (btn == null) return;
  btn.style.transform = _viewportIsPortrait() ? 'rotate(90deg)' : 'none';
}

String _soundButtonLabel() =>
    _soundMuted ? '🔊 Bật âm thanh' : '🔇 Tắt âm thanh';

void _setVideosMuted(bool muted) {
  final videos = html.document.querySelectorAll('video');
  for (final node in videos) {
    if (node is! html.VideoElement) continue;
    node.muted = muted;
    node.volume = muted ? 0 : 1;
  }
}

void _onSoundToggleClick(html.Event _) {
  if (_soundToggleLocked) return;
  _soundToggleLocked = true;
  Future<void>.delayed(_soundToggleCooldown, () => _soundToggleLocked = false);

  _soundMuted = !_soundMuted;
  _setVideosMuted(_soundMuted);
  _soundButton?.text = _soundButtonLabel();
  _activeSoundToggle?.call(_soundMuted);
}

void showWebSoundButton(void Function(bool muted) onToggle) {
  _activeSoundToggle = onToggle;

  if (_soundButton != null && _soundButton!.isConnected == true) return;

  final btn = html.ButtonElement()
    ..id = _soundBtnId
    ..text = _soundButtonLabel();

  final s = btn.style;
  s.position = 'fixed';
  s.bottom = '24px';
  s.left = '24px';
  s.zIndex = '1000000';
  s.padding = '8px 16px';
  s.backgroundColor = 'rgba(0,0,0,0.5)';
  s.color = 'white';
  s.border = 'none';
  s.borderRadius = '24px';
  s.fontSize = '14px';
  s.fontWeight = '500';
  s.cursor = 'pointer';
  s.fontFamily = 'system-ui, -apple-system, sans-serif';
  s.transformOrigin = 'center center';
  s.setProperty('-webkit-tap-highlight-color', 'transparent');

  _soundListener = _onSoundToggleClick;
  btn.addEventListener('click', _soundListener);

  html.document.body!.append(btn);
  _soundButton = btn;
  _applySoundButtonOrientation();
}

void removeWebSoundButton() {
  _activeSoundToggle = null;
  if (_soundButton != null) {
    if (_soundListener != null) {
      _soundButton!.removeEventListener('click', _soundListener);
    }
    _soundButton!.remove();
    _soundButton = null;
    _soundListener = null;
  }
  _soundMuted = true;
  _soundToggleLocked = false;
}

void resetWebVideoElement() {
  _activeSkipCallback = null;

  if (_viewportListener != null) {
    html.window.removeEventListener('resize', _viewportListener);
    html.window.removeEventListener('orientationchange', _viewportListener);
    _viewportListener = null;
  }

  if (_skipButton != null) {
    if (_skipListener != null) {
      _skipButton!.removeEventListener('click', _skipListener);
    }
    _skipButton!.remove();
    _skipButton = null;
    _skipListener = null;
  }

  removeWebSoundButton();

  final videos = html.document.querySelectorAll('video');
  for (final node in videos) {
    if (node is! html.VideoElement) continue;
    if (node.getAttribute(_markerAttr) != '1') continue;
    node.removeAttribute(_markerAttr);
    node.remove();
  }
}
