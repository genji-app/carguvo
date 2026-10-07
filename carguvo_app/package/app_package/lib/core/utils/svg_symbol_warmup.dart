import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io' show Directory, File, Platform;
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart' as svg;
import 'package:path_provider/path_provider.dart';
import 'package:app_package/core/constants/app_version.dart';

class SvgSymbolWarmup {
  SvgSymbolWarmup._();

  static const String _diskFormat = 'fsvg2.2.2-vg1.1.19-v1';

  static const int _magic = 0x53564743;

  static final int _nativeConcurrency = kIsWeb
      ? 1
      : math.max(2, math.min(6, Platform.numberOfProcessors - 1));

  static const Set<String> _blockingBundles = <String>{'main'};

  static const Duration _syncSliceBudget = Duration(milliseconds: 6);

  static const int _cacheHeadroom = 150;

  static const Duration _recordWindow = Duration(seconds: 10);

  static const int _maxPriority = 200;

  static bool get _runsInIsolate => !kDebugMode && !kIsWeb;
  static bool get _diskEnabled => !kIsWeb;

  static final Queue<_WarmJob> _hi = Queue<_WarmJob>();
  static final Queue<_WarmJob> _mid = Queue<_WarmJob>();
  static final Queue<_WarmJob> _lo = Queue<_WarmJob>();

  static final Map<String, Completer<void>> _bundleReady =
      <String, Completer<void>>{};
  static int _running = 0;
  static int _runningHi = 0;
  static int _pendingSetup = 0;
  static int _knownSymbols = 0;
  static Completer<void>? _allIdle;
  static Completer<void>? _priorityIdle;

  static Future<Set<String>>? _priorityFuture;
  static final LinkedHashSet<String> _recorded = LinkedHashSet<String>();
  static bool _recording = !kIsWeb;
  static Timer? _recordTimer;

  static Future<Directory?>? _dirFuture;

  static Set<String> _critical = const <String>{};

  static void warm(
    String bundleKey,
    String spriteName,
    Map<String, String> symbols, {
    bool Function()? isStale,
  }) {
    if (symbols.isEmpty) return;
    _pendingSetup++;
    _allIdle ??= Completer<void>();
    _priorityIdle ??= Completer<void>();
    final ready = Completer<void>();
    _bundleReady[bundleKey] = ready;
    unawaited(
      _setup(bundleKey, spriteName, symbols, isStale, ready)
          .catchError((Object e) {
        debugPrint('[SvgSymbolWarmup] $bundleKey: setup lỗi $e');
        _complete(ready);
      }).whenComplete(() {
        _pendingSetup--;
        _kick();
        _checkIdle();
      }),
    );
  }

  static Future<void> whenBundleReady(String bundleKey) =>
      _bundleReady[bundleKey]?.future ?? Future<void>.value();

  static void _complete(Completer<void>? c) {
    if (c != null && !c.isCompleted) c.complete();
  }

  static Future<void> whenReadyForFirstScreen() async {
    final all = _allIdle?.future;
    final pri = _priorityIdle?.future;
    if (all == null) return;
    final priority = await _loadPriority();
    if ((priority.isEmpty && _critical.isEmpty) || pri == null) return all;
    return pri;
  }

  static void setCritical(Iterable<String> symbolIds) {
    _critical = Set<String>.unmodifiable(symbolIds);
  }

  static Future<void> whenIdle() => _allIdle?.future ?? Future<void>.value();

  static void noteUsed(String symbolId) {
    if (!_recording || _recorded.length >= _maxPriority) return;
    _recorded.add(symbolId);
  }

  static void markFirstScreenShown() {
    if (!_recording || _recordTimer != null) return;
    _recordTimer = Timer(_recordWindow, () => unawaited(_finishRecording()));
  }

  static Future<void> _setup(
    String bundleKey,
    String spriteName,
    Map<String, String> symbols,
    bool Function()? isStale,
    Completer<void> ready,
  ) async {
    var priority = const <String>{};
    var disk = const <String, _DiskEntry>{};
    try {
      priority = await _loadPriority();
    } catch (_) {
    }
    try {
      disk = await _readDisk(bundleKey, spriteName);
    } catch (e) {
      debugPrint('[SvgSymbolWarmup] $bundleKey: đọc cache đĩa lỗi $e');
    }
    if (isStale?.call() ?? false) {
      _complete(ready);
      return;
    }

    _knownSymbols += symbols.length;
    final needed = _knownSymbols + _cacheHeadroom;
    if (svg.svg.cache.maximumSize < needed) {
      svg.svg.cache.maximumSize = needed;
    }

    final batch = _SpriteBatch(bundleKey, spriteName, symbols, isStale, ready);
    final blocking = _blockingBundles.contains(bundleKey);
    var fromDisk = 0;
    for (final entry in symbols.entries) {
      final id = entry.key;
      final xml = entry.value;
      if (xml.isEmpty) continue;
      final d = disk[id];
      if (d != null && d.hash == _fnv(xml)) {
        _putCompiled(xml, d.bytes);
        batch.compiled[id] = d.bytes;
        fromDisk++;
        continue;
      }
      batch.remaining++;
      final isHi = _critical.contains(id) || priority.contains(id);
      (isHi ? _hi : (blocking ? _mid : _lo)).add(_WarmJob(batch, id, xml));
    }
    if (batch.remaining == 0) _complete(ready);
    debugPrint(
      '[SvgSymbolWarmup] $bundleKey: ${symbols.length} symbol, '
      '$fromDisk từ đĩa, ${batch.remaining} cần parse',
    );
  }

  static void _putCompiled(String xml, Uint8List bytes) {
    final key = svg.SvgStringLoader(xml).cacheKey(null);
    unawaited(
      svg.svg.cache.putIfAbsent(
        key,
        () => SynchronousFuture<ByteData>(ByteData.sublistView(bytes)),
      ),
    );
  }

  static void _kick() {
    final queued = _hi.length + _mid.length + _lo.length;
    if (queued == 0) return;
    if (_runsInIsolate) {
      final slots = math.min(_nativeConcurrency - _running, queued);
      for (var i = 0; i < slots; i++) {
        unawaited(_drain());
      }
    } else if (_running == 0) {
      unawaited(_drain());
    }
  }

  static Future<void> _drain() async {
    _running++;
    final sw = Stopwatch()..start();
    try {
      while (_hi.isNotEmpty || _mid.isNotEmpty || _lo.isNotEmpty) {
        final isHi = _hi.isNotEmpty;
        final job = isHi
            ? _hi.removeFirst()
            : (_mid.isNotEmpty ? _mid.removeFirst() : _lo.removeFirst());
        if (isHi) _runningHi++;
        try {
          await _compile(job);
        } finally {
          if (isHi) _runningHi--;
          _checkIdle();
        }
        if (!_runsInIsolate && sw.elapsed >= _syncSliceBudget) {
          await Future<void>.delayed(Duration.zero);
          sw.reset();
        }
      }
    } finally {
      _running--;
      _checkIdle();
    }
  }

  static Future<void> _compile(_WarmJob job) async {
    final batch = job.batch;
    try {
      if (batch.isStale?.call() ?? false) {
        batch.aborted = true;
        return;
      }
      final data = await svg.SvgStringLoader(job.xml).loadBytes(null);
      batch.compiled[job.id] = Uint8List.sublistView(data);
    } catch (e) {
      debugPrint('[SvgSymbolWarmup] ${batch.bundleKey}/${job.id}: parse lỗi $e');
    } finally {
      batch.remaining--;
      if (batch.remaining == 0) {
        debugPrint(
          '[SvgSymbolWarmup] ${batch.bundleKey}: parse xong '
          '${batch.compiled.length}/${batch.symbols.length} symbol trong '
          '${batch.watch.elapsedMilliseconds}ms (song song $_nativeConcurrency)',
        );
        _complete(batch.ready);
        if (!batch.aborted) unawaited(_writeDisk(batch));
      }
    }
  }

  static void _checkIdle() {
    if (_pendingSetup > 0) return;
    if (_hi.isEmpty && _runningHi == 0) {
      final c = _priorityIdle;
      _priorityIdle = null;
      if (c != null && !c.isCompleted) c.complete();
    }
    if (_hi.isEmpty && _mid.isEmpty && _lo.isEmpty && _running == 0) {
      final c = _allIdle;
      _allIdle = null;
      if (c != null && !c.isCompleted) c.complete();
    }
  }

  static Future<Directory?> _cacheDir() => _dirFuture ??= () async {
        if (!_diskEnabled) return null;
        try {
          final base = await getApplicationSupportDirectory();
          final dir = Directory('${base.path}/svg_compiled');
          if (!await dir.exists()) await dir.create(recursive: true);
          return dir;
        } catch (e) {
          debugPrint('[SvgSymbolWarmup] không mở được thư mục cache: $e');
          return null;
        }
      }();

  static String _stamp(String spriteName) =>
      '$spriteName|${AppVersion.code}|$_diskFormat';

  static File _fileFor(Directory dir, String bundleKey) => File(
        '${dir.path}/${bundleKey.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_')}.bin',
      );

  static Future<Map<String, _DiskEntry>> _readDisk(
    String bundleKey,
    String spriteName,
  ) async {
    final dir = await _cacheDir();
    if (dir == null) return const {};
    final file = _fileFor(dir, bundleKey);
    if (!await file.exists()) return const {};

    final raw = await file.readAsBytes();
    final r = _Reader(raw);
    try {
      if (r.u32() != _magic) throw const FormatException('magic');
      if (r.str() != _stamp(spriteName)) return const {};
      final count = r.u32();
      final out = <String, _DiskEntry>{};
      for (var i = 0; i < count; i++) {
        final id = r.str();
        final hash = r.u32();
        final bytes = Uint8List.fromList(r.bytes(r.u32()));
        out[id] = _DiskEntry(hash, bytes);
      }
      return out;
    } catch (e) {
      debugPrint('[SvgSymbolWarmup] $bundleKey: file cache hỏng, xoá ($e)');
      try {
        await file.delete();
      } catch (_) {
      }
      return const {};
    }
  }

  static Future<void> _writeDisk(_SpriteBatch batch) async {
    if (!_diskEnabled || batch.compiled.isEmpty) return;
    final dir = await _cacheDir();
    if (dir == null || (batch.isStale?.call() ?? false)) return;
    try {
      final w = _Writer()
        ..u32(_magic)
        ..str(_stamp(batch.spriteName));
      final entries = batch.compiled.entries
          .where((e) => batch.symbols.containsKey(e.key))
          .toList();
      w.u32(entries.length);
      for (final e in entries) {
        w
          ..str(e.key)
          ..u32(_fnv(batch.symbols[e.key]!))
          ..u32(e.value.length)
          ..bytes(e.value);
      }
      final file = _fileFor(dir, batch.bundleKey);
      final tmp = File('${file.path}.tmp');
      await tmp.writeAsBytes(w.take(), flush: true);
      await tmp.rename(file.path);
      debugPrint(
        '[SvgSymbolWarmup] ${batch.bundleKey}: ghi ${entries.length} symbol xuống đĩa',
      );
    } catch (e) {
      debugPrint('[SvgSymbolWarmup] ${batch.bundleKey}: ghi cache lỗi $e');
    }
  }

  static Future<Set<String>> _loadPriority() => _priorityFuture ??= () async {
        final dir = await _cacheDir();
        if (dir == null) return <String>{};
        try {
          final f = File('${dir.path}/priority.txt');
          if (!await f.exists()) return <String>{};
          final lines = await f.readAsLines();
          return lines.where((l) => l.isNotEmpty).take(_maxPriority).toSet();
        } catch (_) {
          return <String>{};
        }
      }();

  static Future<void> _finishRecording() async {
    _recording = false;
    if (_recorded.isEmpty) return;
    final dir = await _cacheDir();
    if (dir == null) return;
    try {
      final tmp = File('${dir.path}/priority.txt.tmp');
      await tmp.writeAsString(_recorded.join('\n'), flush: true);
      await tmp.rename('${dir.path}/priority.txt');
      debugPrint('[SvgSymbolWarmup] lưu ${_recorded.length} symbol ưu tiên');
    } catch (e) {
      debugPrint('[SvgSymbolWarmup] lưu danh sách ưu tiên lỗi $e');
    }
  }

  static int _fnv(String s) {
    var h = 0x811c9dc5;
    for (var i = 0; i < s.length; i++) {
      h ^= s.codeUnitAt(i);
      h = (h * 0x01000193) & 0xFFFFFFFF;
    }
    return h;
  }
}

class _SpriteBatch {
  _SpriteBatch(
    this.bundleKey,
    this.spriteName,
    this.symbols,
    this.isStale,
    this.ready,
  );

  final String bundleKey;
  final String spriteName;
  final Map<String, String> symbols;
  final bool Function()? isStale;
  final Completer<void> ready;
  final Stopwatch watch = Stopwatch()..start();
  final Map<String, Uint8List> compiled = <String, Uint8List>{};
  int remaining = 0;
  bool aborted = false;
}

class _WarmJob {
  _WarmJob(this.batch, this.id, this.xml);

  final _SpriteBatch batch;
  final String id;
  final String xml;
}

class _DiskEntry {
  const _DiskEntry(this.hash, this.bytes);

  final int hash;
  final Uint8List bytes;
}

class _Writer {
  final BytesBuilder _b = BytesBuilder(copy: false);

  void u32(int v) {
    final d = ByteData(4)..setUint32(0, v, Endian.little);
    _b.add(d.buffer.asUint8List());
  }

  void str(String s) {
    final enc = utf8.encode(s);
    u32(enc.length);
    _b.add(enc);
  }

  void bytes(Uint8List v) => _b.add(v);

  Uint8List take() => _b.takeBytes();
}

class _Reader {
  _Reader(this._data) : _view = ByteData.sublistView(_data);

  final Uint8List _data;
  final ByteData _view;
  int _pos = 0;

  void _need(int n) {
    if (n < 0 || _pos + n > _data.length) {
      throw const FormatException('truncated');
    }
  }

  int u32() {
    _need(4);
    final v = _view.getUint32(_pos, Endian.little);
    _pos += 4;
    return v;
  }

  String str() => utf8.decode(bytes(u32()));

  Uint8List bytes(int n) {
    _need(n);
    final v = Uint8List.sublistView(_data, _pos, _pos + n);
    _pos += n;
    return v;
  }
}
