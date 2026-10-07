import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:path_provider/path_provider.dart';

class VideoCacheManager {
  VideoCacheManager._();
  static final VideoCacheManager instance = VideoCacheManager._();

  static const String _cacheDirName = 'video_cache';
  static const Duration _downloadTimeout = Duration(seconds: 15);

  Directory? _cacheDir;
  final Map<String, Future<File?>> _inflight = {};

  Future<Directory?> _ensureDir() async {
    if (kIsWeb) return null;
    if (_cacheDir != null) return _cacheDir;
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final dir = Directory('${appDir.path}/$_cacheDirName');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      _cacheDir = dir;
      return dir;
    } catch (e) {
      debugPrint('VideoCacheManager._ensureDir failed: $e');
      return null;
    }
  }

  String _fileNameFor(String url) {
    final hash = sha256.convert(utf8.encode(url)).toString();
    final ext = _extractExt(url);
    return '$hash$ext';
  }

  String _extractExt(String url) {
    final cleaned = url.split('?').first;
    final dot = cleaned.lastIndexOf('.');
    if (dot < 0 || dot < cleaned.length - 5) return '.mp4';
    return cleaned.substring(dot);
  }

  Future<File?> getCachedFile(String url) async {
    final dir = await _ensureDir();
    if (dir == null) return null;
    final file = File('${dir.path}/${_fileNameFor(url)}');
    if (await file.exists()) return file;
    return null;
  }

  Future<File?> getOrDownload(String url) {
    return _inflight.putIfAbsent(url, () => _getOrDownload(url));
  }

  Future<File?> _getOrDownload(String url) async {
    try {
      final cached = await getCachedFile(url);
      if (cached != null) return cached;

      final dir = await _ensureDir();
      if (dir == null) return null;

      final tmpPath = '${dir.path}/${_fileNameFor(url)}.part';
      final finalPath = '${dir.path}/${_fileNameFor(url)}';

      final dio = Dio(
        BaseOptions(
          connectTimeout: _downloadTimeout,
          receiveTimeout: _downloadTimeout,
          sendTimeout: _downloadTimeout,
        ),
      );

      await dio.download(url, tmpPath);
      final tmp = File(tmpPath);
      if (!await tmp.exists()) return null;
      final renamed = await tmp.rename(finalPath);
      return renamed;
    } catch (e) {
      debugPrint('VideoCacheManager.getOrDownload failed for $url: $e');
      return null;
    } finally {
      _inflight.remove(url);
    }
  }

  Future<File?> saveBytes(String url, Uint8List bytes) async {
    final dir = await _ensureDir();
    if (dir == null) return null;
    try {
      final tmpPath = '${dir.path}/${_fileNameFor(url)}.part';
      final finalPath = '${dir.path}/${_fileNameFor(url)}';
      final tmp = File(tmpPath);
      await tmp.writeAsBytes(bytes);
      final renamed = await tmp.rename(finalPath);
      return renamed;
    } catch (e) {
      debugPrint('VideoCacheManager.saveBytes failed for $url: $e');
      return null;
    }
  }

  Future<void> clearUrl(String url) async {
    try {
      final dir = await _ensureDir();
      if (dir == null) return;
      final file = File('${dir.path}/${_fileNameFor(url)}');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('VideoCacheManager.clearUrl failed for $url: $e');
    }
  }
}
