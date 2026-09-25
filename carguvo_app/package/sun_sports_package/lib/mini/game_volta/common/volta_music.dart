import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'package:sun_sports/core/services/storage/sound_settings.dart';
import 'package:sun_sports/core/utils/bundle_manager.dart';

import 'state/volta_state.dart';

class VoltaMusic {
  VoltaMusic._();

  static final VoltaMusic instance = VoltaMusic._();

  static const double _normalVolume = 1;

  AudioPlayer? _player;
  VoltaTrack? _current;

  bool _ducked = false;

  bool _paused = false;

  static VoltaTrack? trackFor(VoltaMusicCue cue) => switch (cue) {
    VoltaMusicCue.playing => VoltaTrack.match,
    VoltaMusicCue.won => VoltaTrack.victory,
    VoltaMusicCue.lost => VoltaTrack.timeout,
    VoltaMusicCue.idle => null,
  };

  Future<void> applyCue(VoltaMusicCue cue) async {
    final VoltaTrack? track = trackFor(cue);
    if (track == null) return stop();
    return play(track);
  }

  Future<void> play(VoltaTrack track) async {
    if (_current == track) return;
    _current = track;

    if (!SoundSettings.instance.isEnabled) return;

    try {
      final Source? source = await _resolve(track.filename);
      if (source == null) return;
      if (_current != track) return;

      final AudioPlayer player = _playerOrCreate;
      await player.setReleaseMode(
        track.loops ? ReleaseMode.loop : ReleaseMode.stop,
      );
      await player.setVolume(_volumeNow);
      await player.play(source);
    } catch (_) {
    }
  }

  Future<void> stop() async {
    _current = null;
    try {
      await _player?.stop();
    } catch (_) {
    }
  }

  void setDucked(bool value) {
    if (_ducked == value) return;
    _ducked = value;
    _applyVolume();
  }

  void setPaused(bool value) {
    if (_paused == value) return;
    _paused = value;
    _applyVolume();
  }

  Future<void> release() async {
    await stop();
    try {
      await _player?.release();
    } catch (_) {
    }
    _player = null;
  }

  double get _volumeNow =>
      (_ducked || _paused || !SoundSettings.instance.isEnabled)
      ? 0
      : _normalVolume;

  void _applyVolume() {
    unawaited(_player?.setVolume(_volumeNow).catchError((Object _) {}));
  }

  AudioPlayer get _playerOrCreate => _player ??= AudioPlayer();

  Future<Source?> _resolve(String filename) async {
    if (!kIsWeb) {
      try {
        final file = await BundleManager.instance.getLocalFile(filename);
        if (file != null && await file.exists()) {
          return DeviceFileSource(file.path);
        }
      } catch (_) {
      }
    }
    final String? url = BundleManager.instance.get(filename)?.url;
    if (url == null || url.isEmpty) return null;
    return UrlSource(url);
  }
}

enum VoltaTrack {
  match('volta_bgm_match.mp3', loops: true),

  victory('volta_bgm_victory.mp3', loops: false),

  timeout('volta_bgm_timeout.mp3', loops: false);

  const VoltaTrack(this.filename, {required this.loops});

  final String filename;

  final bool loops;
}
