import 'package:freezed_annotation/freezed_annotation.dart';

part 'mini_game_remote_config.freezed.dart';
part 'mini_game_remote_config.g.dart';

@freezed
sealed class MiniGameRemoteConfig with _$MiniGameRemoteConfig {
  const factory MiniGameRemoteConfig({
    @JsonKey(name: 'DOMAIN') required String domain,
    @JsonKey(name: 'useWSJSON', fromJson: _boolFromString) required bool useWsJson,
    @JsonKey(name: 'WS_MINIGAME_SOCKET_JSON_URL') required String wsJsonUrl,
    @JsonKey(name: 'WS_MINIGAME_SOCKET_BINARY_URL') required String wsBinaryUrl,
    @JsonKey(name: 'RESOURCE_MINI_GAME_URL_APP_PORTRAIT') required String resourceAppUrl,
    @JsonKey(name: 'RESOURCE_MINI_GAME_URL_WEB_PORTRAIT') required String resourceWebUrl,
    @JsonKey(name: 'HELP_URL') required String helpUrl,
    @JsonKey(name: 'BRAND') required String brand,
  }) = _MiniGameRemoteConfig;

  factory MiniGameRemoteConfig.fromJson(Map<String, dynamic> json) =>
      _$MiniGameRemoteConfigFromJson(json);
}

bool _boolFromString(dynamic v) => v == 'true' || v == true;
