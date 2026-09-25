
part of 'mini_game_remote_config.dart';

_MiniGameRemoteConfig _$MiniGameRemoteConfigFromJson(
  Map<String, dynamic> json,
) => _MiniGameRemoteConfig(
  domain: json['DOMAIN'] as String,
  useWsJson: _boolFromString(json['useWSJSON']),
  wsJsonUrl: json['WS_MINIGAME_SOCKET_JSON_URL'] as String,
  wsBinaryUrl: json['WS_MINIGAME_SOCKET_BINARY_URL'] as String,
  resourceAppUrl: json['RESOURCE_MINI_GAME_URL_APP_PORTRAIT'] as String,
  resourceWebUrl: json['RESOURCE_MINI_GAME_URL_WEB_PORTRAIT'] as String,
  helpUrl: json['HELP_URL'] as String,
  brand: json['BRAND'] as String,
);

Map<String, dynamic> _$MiniGameRemoteConfigToJson(
  _MiniGameRemoteConfig instance,
) => <String, dynamic>{
  'DOMAIN': instance.domain,
  'useWSJSON': instance.useWsJson,
  'WS_MINIGAME_SOCKET_JSON_URL': instance.wsJsonUrl,
  'WS_MINIGAME_SOCKET_BINARY_URL': instance.wsBinaryUrl,
  'RESOURCE_MINI_GAME_URL_APP_PORTRAIT': instance.resourceAppUrl,
  'RESOURCE_MINI_GAME_URL_WEB_PORTRAIT': instance.resourceWebUrl,
  'HELP_URL': instance.helpUrl,
  'BRAND': instance.brand,
};
