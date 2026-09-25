import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'game_launch_config.dart';
import 'game_launch_result.dart';

class GameLauncher {
  static const String _launcherSuffix = '/launcher';
  static const String _availabilityMethod = 'isLauncherAvailable';
  static const String _launchMethod = 'launchGame';

  static void Function(String message)? logSink;

  final String? channelNameOverride;

  MethodChannel? _channel;

  GameLauncher({this.channelNameOverride});

  Future<String> resolveChannelName() async {
    if (channelNameOverride != null) return channelNameOverride!;
    final info = await PackageInfo.fromPlatform();
    final id = info.packageName.trim();
    if (id.isEmpty) {
      throw StateError('Không lấy được package/bundle id từ PackageInfo');
    }
    return '$id$_launcherSuffix';
  }

  Future<MethodChannel> _resolveChannel() async {
    return _channel ??= MethodChannel(await resolveChannelName());
  }

  Future<bool> isLauncherAvailable() async {
    try {
      final channel = await _resolveChannel();
      final result = await channel.invokeMethod<bool>(_availabilityMethod);
      return result ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<GameLaunchResult> launch(GameLaunchConfig config) async {
    if (config.gamePath.trim().isEmpty) {
      return const GameLaunchFailure('gamePath rỗng', code: 'INVALID_PATH');
    }
    try {
      final channel = await _resolveChannel();
      await channel.invokeMethod<dynamic>(
        _launchMethod,
        config.toArguments(),
      );
      logSink?.call('launcher game path: ${config.gamePath}');
      logSink?.call('launcher game arguments: ${config.toArguments()}');
      return const GameLaunchSuccess();
    } on PlatformException catch (e) {
      return GameLaunchFailure(e.message ?? 'Launch failed', code: e.code);
    } on MissingPluginException {
      return const GameLaunchFailure(
        'Native chưa đăng ký channel launcher (host không phải Cocos engine?)',
        code: 'MISSING_PLUGIN',
      );
    } catch (e) {
      return GameLaunchFailure(e.toString(), code: 'UNKNOWN');
    }
  }
}
