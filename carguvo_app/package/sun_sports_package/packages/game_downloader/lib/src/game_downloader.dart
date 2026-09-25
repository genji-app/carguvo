import 'dart:async';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import 'exceptions.dart';
import 'game_downloader_config.dart';
import 'local_version_store.dart';
import 'models/download_progress.dart';
import 'models/game_version.dart';
import 'models/version_check_result.dart';
import 'remote_version_source.dart';

typedef StorageDirectoryProvider = Future<Directory> Function();

class GameDownloader {
  final GameDownloaderConfig config;
  final RemoteVersionSource _remote;
  final LocalVersionStore _local;
  final StorageDirectoryProvider _storageDir;
  final Dio _dio;

  final String entryFileName;

  GameDownloader({
    GameDownloaderConfig? config,
    StorageDirectoryProvider? storageDirectoryProvider,
    RemoteVersionSource? remoteVersionSource,
    LocalVersionStore? localVersionStore,
    Dio? dio,
    this.entryFileName = 'index.html',
  })  : config = config ?? const GameDownloaderConfig(),
        _remote = remoteVersionSource ??
            RemoteVersionSource(config: config ?? const GameDownloaderConfig()),
        _local = localVersionStore ?? LocalVersionStore(),
        _storageDir =
            storageDirectoryProvider ?? getApplicationDocumentsDirectory,
        _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(minutes: 10),
              sendTimeout: const Duration(seconds: 30),
              headers: {'User-Agent': 'Flutter-Game-Client'},
            ));

  Future<String> _gamesRoot() async => '${(await _storageDir()).path}/games';

  Future<String> resolveGamePath(String gameName) async =>
      '${await _gamesRoot()}/$gameName';

  Future<String> _zipPath(String gameName) async =>
      '${await resolveGamePath(gameName)}/$gameName.zip';

  Future<String> _tempPath(String gameName) async =>
      '${await _gamesRoot()}/${gameName}_temp';

  Future<GameVersion> fetchServerVersion(String gameName) =>
      _remote.fetchServerVersion(gameName);

  Future<String?> getLocalVersion(String gameName) =>
      _local.getLocalVersion(gameName);

  Future<bool> isGameReady(String gameName) async {
    final entry = File('${await resolveGamePath(gameName)}/$entryFileName');
    return entry.exists();
  }

  Future<VersionCheckResult> checkVersion(String gameName) async {
    final localVersion = await _local.getLocalVersion(gameName);
    final server = await _remote.fetchServerVersion(gameName);
    final ready = await isGameReady(gameName);

    final isSynced = localVersion != null &&
        localVersion.trim().toLowerCase() == server.version.toLowerCase() &&
        ready;

    return VersionCheckResult(
      isSynced: isSynced,
      needsDownload: !isSynced,
      localVersion: localVersion,
      serverVersion: server.version,
      downloadUrl: server.downloadUrl,
      localGamePath: ready ? await resolveGamePath(gameName) : null,
    );
  }

  Stream<DownloadProgress> prepareGame(String gameName) async* {
    final check = await checkVersion(gameName);

    if (!check.needsDownload && check.localGamePath != null) {
      yield DownloadProgress.done(check.localGamePath!);
      return;
    }

    yield* _downloadAndUnzip(
      gameName: gameName,
      downloadUrl: check.downloadUrl,
      version: check.serverVersion,
    );
  }

  Stream<DownloadProgress> _downloadAndUnzip({
    required String gameName,
    required String downloadUrl,
    required String version,
  }) async* {
    final gamePath = await resolveGamePath(gameName);
    final zipPath = await _zipPath(gameName);
    final tempPath = await _tempPath(gameName);

    await Directory(gamePath).create(recursive: true);

    final zipFile = File(zipPath);
    if (!await zipFile.exists()) {
      yield* _download(downloadUrl, zipPath);
    } else {
      yield DownloadProgress.downloading(1.0);
    }

    final tempDir = Directory(tempPath);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
    yield* _unzip(zipPath, tempPath);

    final gameDir = Directory(gamePath);
    if (await gameDir.exists()) {
      await gameDir.delete(recursive: true);
    }
    await tempDir.rename(gamePath);
    if (await zipFile.exists()) {
      await zipFile.delete();
    }
    await _local.saveLocalVersion(gameName, version);

    yield DownloadProgress.done(gamePath);
  }

  Stream<DownloadProgress> _download(String url, String savePath) {
    final controller = StreamController<DownloadProgress>();
    () async {
      try {
        final uri = Uri.parse(url);
        if (!uri.hasScheme || !uri.scheme.startsWith('http')) {
          throw NetworkException('Invalid download URL: $url');
        }

        final dir = File(savePath).parent;
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }

        await _dio.download(
          url,
          savePath,
          onReceiveProgress: (received, total) {
            if (total <= 0) {
              controller.add(DownloadProgress.downloading(0));
              return;
            }
            controller.add(DownloadProgress.downloading(received / total));
          },
        );

        final file = File(savePath);
        if (!await file.exists() || await file.length() == 0) {
          throw const UnexpectedException('Downloaded file is missing or empty');
        }

        controller.add(DownloadProgress.downloading(1.0));
        await controller.close();
      } on DioException catch (error) {
        controller.addError(_mapDioError(error, url));
        await controller.close();
      } on GameDownloaderException catch (error) {
        controller.addError(error);
        await controller.close();
      } catch (error) {
        controller.addError(UnexpectedException(error.toString()));
        await controller.close();
      }
    }();
    return controller.stream;
  }

  Stream<DownloadProgress> _unzip(String zipPath, String extractPath) {
    final controller = StreamController<DownloadProgress>();
    () async {
      try {
        final bytes = await File(zipPath).readAsBytes();
        final archive = ZipDecoder().decodeBytes(bytes);
        if (archive.isEmpty) {
          throw const UnzipException('Zip archive is empty or corrupted');
        }
        final total = archive.length;
        var processed = 0;

        for (final entry in archive) {
          final outPath = '$extractPath/${entry.name}';
          if (entry.isFile) {
            final out = File(outPath);
            await out.parent.create(recursive: true);
            await out.writeAsBytes(entry.content as List<int>);
          } else {
            await Directory(outPath).create(recursive: true);
          }
          processed++;
          controller.add(DownloadProgress.unzipping(processed / total));
        }
        controller.add(DownloadProgress.unzipping(1.0));
        await controller.close();
      } catch (error) {
        controller.addError(UnzipException(error.toString()));
        await controller.close();
      }
    }();
    return controller.stream;
  }

  GameDownloaderException _mapDioError(DioException error, String url) {
    final response = error.response;
    if (response != null) {
      final code = response.statusCode ?? 0;
      if (code == 404) {
        return ServerException('Game file not found (404): $url',
            statusCode: code);
      }
      return ServerException(
        'Download failed: $code ${response.statusMessage}',
        statusCode: code,
      );
    }
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return NetworkException('Network error: ${error.message}');
      default:
        return UnexpectedException('Download failed: ${error.message}');
    }
  }

  Future<void> deleteGame(String gameName) async {
    final dir = Directory(await resolveGamePath(gameName));
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
    await _local.deleteVersion(gameName);
  }
}
