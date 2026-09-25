library;

import 'dart:async';
import 'dart:convert';

import 'package:app_env/app_env.dart' show AppEnv, AppHttp, AppStorage;

import 'league_alias.dart';

typedef LeagueAliasGet = Future<String?> Function(String url);
typedef LeagueAliasRead = String? Function(String key);
typedef LeagueAliasWrite = void Function(String key, String value);

class LeagueAliasStore {
  LeagueAliasStore._({
    required LeagueAliasGet get,
    required LeagueAliasRead read,
    required LeagueAliasWrite write,
    required String Function() fallbackSbConfigUrl,
  }) : _get = get,
       _read = read,
       _write = write,
       _fallbackSbConfigUrl = fallbackSbConfigUrl;

  static final LeagueAliasStore instance = LeagueAliasStore._(
    get: (url) => AppHttp.get(url),
    read: AppStorage.get,
    write: AppStorage.set,
    fallbackSbConfigUrl: () => AppEnv.sbConfigFallbackUrl,
  );

  factory LeagueAliasStore.forTesting({
    required LeagueAliasGet get,
    Map<String, String>? storage,
    String fallbackSbConfigUrl = 'https://fallback/sb_config.json',
  }) {
    final data = storage ?? <String, String>{};
    return LeagueAliasStore._(
      get: get,
      read: (key) => data[key],
      write: (key, value) => data[key] = value,
      fallbackSbConfigUrl: () => fallbackSbConfigUrl,
    );
  }

  static void Function(String message)? log;

  static const String storageKey = 'league_alias_table';
  static const Duration _timeout = Duration(seconds: 10);

  final LeagueAliasGet _get;
  final LeagueAliasRead _read;
  final LeagueAliasWrite _write;
  final String Function() _fallbackSbConfigUrl;

  final List<void Function()> _listeners = [];

  LeagueAliasTable? _table;

  int? _attemptedVersion;

  bool _probedFallback = false;

  LeagueAliasTable get table => _table ??= _readLocal() ?? LeagueAliasTable.empty;

  void addListener(void Function() listener) => _listeners.add(listener);

  void removeListener(void Function() listener) => _listeners.remove(listener);

  void onSbConfig(Map<String, dynamic> sbConfig) {
    if (_apply(sbConfig)) return;
    if (_probedFallback) return;
    _probedFallback = true;
    unawaited(_probeFallback());
  }

  bool _apply(Map<dynamic, dynamic> sbConfig) {
    final url = (sbConfig['league_alias_url']?.toString() ?? '').trim();
    final version = int.tryParse(sbConfig['league_alias_version']?.toString().trim() ?? '');
    if (url.isEmpty || version == null || version <= 0) return false;
    if (version == table.version || version == _attemptedVersion) return true;
    _attemptedVersion = version;
    unawaited(_download(url, version));
    return true;
  }

  Future<void> _probeFallback() async {
    try {
      final cacheBust = DateTime.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerHour;
      final url = Uri.parse(_fallbackSbConfigUrl()).replace(queryParameters: {'_cb': '$cacheBust'});
      final body = await _get('$url').timeout(_timeout);
      if (body == null) return;
      final decoded = jsonDecode(body);
      if (decoded is Map && !_apply(decoded)) {
        log?.call('[LeagueAlias] no alias keys in sb_config, keeping v${table.version}');
      }
    } catch (e) {
      log?.call('[LeagueAlias] sb_config fallback failed ($e), keeping v${table.version}');
    }
  }

  Future<void> _download(String url, int version) async {
    try {
      final uri = Uri.parse(url).replace(queryParameters: {'v': '$version'});
      final body = await _get('$uri').timeout(_timeout);
      if (body == null) {
        _attemptedVersion = null;
        log?.call('[LeagueAlias] download failed, keeping v${table.version}');
        return;
      }
      final parsed = LeagueAliasTable.tryParse(jsonDecode(body));
      if (parsed == null) {
        log?.call('[LeagueAlias] invalid file, keeping v${table.version}');
        return;
      }
      if (parsed.version != version) {
        _attemptedVersion = null;
        if (parsed.version <= table.version) return;
      }
      _table = parsed;
      _write(storageKey, jsonEncode(parsed.toJson()));
      log?.call('[LeagueAlias] v${parsed.version}, ${parsed.length} labels');
      for (final listener in List.of(_listeners)) {
        listener();
      }
    } catch (e) {
      _attemptedVersion = null;
      log?.call('[LeagueAlias] download failed ($e), keeping v${table.version}');
    }
  }

  LeagueAliasTable? _readLocal() {
    final raw = _read(storageKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return LeagueAliasTable.tryParse(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }
}
