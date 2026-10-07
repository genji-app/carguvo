import 'dart:convert';

import 'package:http/http.dart' as http;

import 'exceptions.dart';
import 'game_downloader_config.dart';
import 'models/game_version.dart';

class RemoteVersionSource {
  final GameDownloaderConfig config;
  final http.Client _client;

  RemoteVersionSource({required this.config, http.Client? client})
      : _client = client ?? http.Client();

  Future<GameVersion> fetchServerVersion(String gameName) async {
    final url = Uri.parse('${config.apiBaseUrl}/games/$gameName/version.json');
    try {
      final response = await _client.get(url);
      if (response.statusCode != 200) {
        throw ServerException(
          'Failed to get version: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final serverVersion = (decoded['version'] ?? '').toString().trim();
      if (serverVersion.isEmpty) {
        throw const ServerException('Server version is empty');
      }
      if (!config.versionPattern.hasMatch(serverVersion)) {
        throw ServerException('Invalid version format: $serverVersion');
      }

      return GameVersion(
        version: serverVersion,
        downloadUrl: buildDownloadUrl(gameName, serverVersion),
      );
    } on GameDownloaderException {
      rethrow;
    } catch (error) {
      throw UnexpectedException(error.toString());
    }
  }

  String buildDownloadUrl(String gameName, String version, {String? platform}) {
    final base = config.gameRemoteUrl.endsWith('/')
        ? config.gameRemoteUrl
            .substring(0, config.gameRemoteUrl.length - 1)
        : config.gameRemoteUrl;
    final path = config.downloadPathPattern
        .replaceAll('{game_name}', gameName)
        .replaceAll('{platform}', platform ?? config.platform)
        .replaceAll('{version}', version);
    return '$base$path';
  }

  void close() => _client.close();
}
