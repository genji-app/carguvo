import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'package:sun_sports/core/services/storage/sound_settings.dart';
import 'package:sun_sports/core/utils/bundle_manager.dart';
import 'package:sun_sports/core/utils/styles/app_audios.dart';

class SoundEffects {
  SoundEffects._();

  static SoundEffects? _instance;
  static SoundEffects get instance => _instance ??= SoundEffects._();

  AudioPlayer? _player;

  final Map<String, String> _localPathsByFilename = <String, String>{};

  Future<void>? _prepareFuture;

  AudioPlayer get _playerOrCreate {
    final existing = _player;
    if (existing != null) return existing;

    final created = AudioPlayer();
    _player = created;
    unawaited(created.setReleaseMode(ReleaseMode.stop));
    unawaited(created.setVolume(1.0));
    return created;
  }

  Future<void> prepare() => _prepareFuture ??= _prepareAll();

  static Future<void> configureSession() => _configureSession();

  static Future<void> _configureSession() async {
    if (kIsWeb) return;
    try {
      await AudioPlayer.global.setAudioContext(
         AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: const <AVAudioSessionOptions>{
              AVAudioSessionOptions.mixWithOthers,
            },
          ),
        ),
      );
    } catch (_) {
    }
  }

  Future<void> _prepareAll() async {
    if (kIsWeb) return;
    await _configureSession();
    for (final sound in AppSound.values) {
      await _resolveLocalPath(sound.url);
    }
    for (final sound in MiniGameSound.values) {
      await _resolveLocalPath(sound.url);
    }
    final AudioPlayer player = _playerOrCreate;

    try {
      final Source? tap = await _resolveSource(AppSound.uiTap.url);
      if (tap != null) await player.setSource(tap);
    } catch (_) {
    }
  }

  Future<void> _resolveLocalPath(String filename) async {
    if (kIsWeb || filename.isEmpty) return;
    try {
      final file = await BundleManager.instance.getLocalFile(filename);
      if (file != null && await file.exists()) {
        _localPathsByFilename[filename] = file.path;
      }
    } catch (_) {
    }
  }

  void playTap() => play(AppSound.uiTap);

  void play(AppSound sound) {
    if (!SoundSettings.instance.isEnabled) return;
    unawaited(_playInternal(sound.url));
  }

  void playMiniGame(MiniGameSound sound) {
    if (!SoundSettings.instance.isEnabled) return;
    unawaited(_playInternal(sound.url));
  }

  Future<void> _playInternal(String filename) async {
    try {
      final source = await _resolveSource(filename);
      if (source == null) return;
      await _playerOrCreate.play(source);
    } catch (_) {
    }
  }

  Future<Source?> _resolveSource(String filename) async {
    if (filename.isEmpty) return null;

    if (kIsWeb) return _urlSource(filename);

    if (!_localPathsByFilename.containsKey(filename)) {
      await _resolveLocalPath(filename);
    }
    final path = _localPathsByFilename[filename];
    if (path != null) return DeviceFileSource(path);

    return _urlSource(filename);
  }

  Source? _urlSource(String filename) {
    final url = BundleManager.instance.get(filename)?.url;
    if (url == null || url.isEmpty) return null;
    return UrlSource(url);
  }

  Future<void> release() async {
    await _player?.release();
    _player = null;
  }
}
