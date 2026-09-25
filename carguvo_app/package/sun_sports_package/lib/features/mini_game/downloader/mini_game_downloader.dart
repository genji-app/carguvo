import 'dart:async';
import 'dart:convert';
import 'dart:io' show File;

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:sun_sports/features/mini_game/downloader/download_progress.dart';
import 'package:sun_sports/features/mini_game/downloader/download_state.dart';

class MiniGameDownloader {
  final String hostUrl;
  final String cacheBase;
  final bool allowFnt;
  final Dio _dio;

  MiniGameDownloader({
    required this.hostUrl,
    required this.cacheBase,
    required Dio dio,
    this.allowFnt = false,
  }) : _dio = dio;

  String resolveLocalPath(String relativePath) {
    if (kIsWeb) {
      return '$hostUrl/$relativePath';
    }
    return '$cacheBase/mini-portrait/cc-mini-game/$relativePath';
  }

  Stream<DownloadProgress> downloadAndExtractZip(String relativePath) async* {
    final url = '$hostUrl/$relativePath?_=${DateTime.now().millisecondsSinceEpoch}';
    final resp = await _dio.get<List<int>>(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    yield const DownloadProgress(stage: 'fetched', percent: 0.35);

    if (kIsWeb) {
      yield const DownloadProgress(stage: 'web-skip-extract', percent: 1.0);
      return;
    }

    final archive = ZipDecoder().decodeBytes(resp.data!);
    final validFiles = archive.files.where(_isValidArchiveEntry).toList();
    if (validFiles.isEmpty) {
      yield const DownloadProgress(stage: 'done', percent: 1.0);
      return;
    }

    final perFilePercent = 0.65 / validFiles.length;
    var current = 0.35;

    for (final file in validFiles) {
      final outPath = '$cacheBase/mini-portrait/cc-mini-game/${file.name}';
      final f = File(outPath);
      await f.create(recursive: true);
      final bytes = file.readBytes();
      if (bytes != null) {
        await f.writeAsBytes(bytes);
      }
      current += perFilePercent;
      yield DownloadProgress(stage: 'extracting', percent: current);
    }

    yield const DownloadProgress(stage: 'done', percent: 1.0);
  }

  bool _isValidArchiveEntry(ArchiveFile f) {
    final name = f.name;
    if (name.contains('.meta') || name.contains('__MACOSX')) return false;
    if (name.endsWith('.png')) return true;
    if (name.endsWith('.atlas')) return true;
    if (name.endsWith('.json')) return true;
    if (allowFnt && name.endsWith('.fnt')) return true;
    return false;
  }

  Future<DownloadState> checkVersion(String configRelativePath) async {
    if (kIsWeb) return DownloadState.undownloaded;

    final localPath = '$cacheBase/mini-portrait/$configRelativePath';
    final localFile = File(localPath);
    String localVer = '0.0.0';
    if (await localFile.exists()) {
      try {
        final data = jsonDecode(await localFile.readAsString()) as Map<String, dynamic>;
        localVer = (data['ver'] as String?) ?? '0.0.0';
      } catch (_) {
        localVer = '0.0.0';
      }
    } else {
      await localFile.create(recursive: true);
      await localFile.writeAsString(jsonEncode({'ver': '0.0.0'}));
    }

    final remoteUrl =
        '$hostUrl/$configRelativePath?_=${DateTime.now().millisecondsSinceEpoch}';
    final resp = await _dio.get<String>(
      remoteUrl,
      options: Options(responseType: ResponseType.plain),
    );
    final remoteData = jsonDecode(resp.data ?? '{}') as Map<String, dynamic>;
    final remoteVer = (remoteData['ver'] as String?) ?? '0.0.0';

    return remoteVer == localVer ? DownloadState.cached : DownloadState.undownloaded;
  }

  Future<void> writeLocalVersion(String configRelativePath, String version) async {
    if (kIsWeb) return;
    final localPath = '$cacheBase/mini-portrait/$configRelativePath';
    final localFile = File(localPath);
    await localFile.create(recursive: true);
    await localFile.writeAsString(jsonEncode({'ver': version}));
  }

  Future<String> downloadSprite(String relativePath) async {
    if (kIsWeb) {
      return '$hostUrl/$relativePath';
    }

    final outPath = '$cacheBase/mini-portrait/cc-mini-game/$relativePath';
    final outFile = File(outPath);
    if (await outFile.exists()) return outPath;

    final url = '$hostUrl/$relativePath?_=${DateTime.now().millisecondsSinceEpoch}';
    final resp = await _dio.get<List<int>>(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    await outFile.create(recursive: true);
    await outFile.writeAsBytes(resp.data!);
    return outPath;
  }
}
