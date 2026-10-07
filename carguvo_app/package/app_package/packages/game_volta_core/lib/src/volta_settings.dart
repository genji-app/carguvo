import 'dart:async';

import 'package:meta/meta.dart';

import 'volta_agent.dart';
import 'volta_http.dart';
import 'volta_platform.dart';
import 'volta_rules.dart';

@immutable
class VoltaSettings {
  const VoltaSettings({
    required this.expose,
    required this.betting,
    required this.oAuth,
    required this.socket,
    required this.videoJs,
    required this.balanceRefresh,
    required this.refreshBalanceWithApi,
    required this.memPoolSize,
  });

  final String expose;

  final String betting;

  final String oAuth;

  final String socket;

  final String videoJs;

  final Duration balanceRefresh;

  final bool refreshBalanceWithApi;

  final int memPoolSize;

  bool get isUsable => expose.isNotEmpty;

  bool get hasSocket => socket.isNotEmpty;

  static VoltaSettings? parse(dynamic raw) {
    if (raw is! Map) return null;
    final Map<String, dynamic> body = raw.cast<String, dynamic>();

    final Object? domainsRaw = body['domains'];
    if (domainsRaw is! Map) return null;
    final Map<String, dynamic> domains = domainsRaw.cast<String, dynamic>();

    final String expose = _trimSlash(_str(domains['expose']));
    if (expose.isEmpty) return null;

    final Map<String, dynamic> update = _map(body['updateBalance']);
    final Map<String, dynamic> balance = _map(body['balance']);
    final int seconds =
        _int(update['timeRefeshBalance']) ??
        _int(balance['refreshBalance']) ??
        VoltaRules.balanceRefresh.inSeconds;

    return VoltaSettings(
      expose: expose,
      betting: _trimSlash(_str(domains['betting'])).isEmpty
          ? expose
          : _trimSlash(_str(domains['betting'])),
      oAuth: _trimSlash(_str(domains['oAuth'])),
      socket: _trimSlash(_str(domains['socket'])),
      videoJs: _trimSlash(_str(domains['urlVideoJS'])),
      balanceRefresh: Duration(seconds: seconds <= 0 ? 300 : seconds),
      refreshBalanceWithApi:
          update['refeshWithAPI'] as bool? ?? balance['refreshAPI'] as bool? ??
          true,
      memPoolSize: _int(_map(body['performance'])['sizeMem']) ?? 10,
    );
  }

  static String _str(Object? value) =>
      value == null || value == 'null' ? '' : '$value';

  static Map<String, dynamic> _map(Object? value) => value is Map
      ? value.cast<String, dynamic>()
      : const <String, dynamic>{};

  static int? _int(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static String _trimSlash(String value) =>
      value.replaceAll(RegExp(r'/+$'), '');

  @override
  String toString() =>
      'VoltaSettings(expose: $expose, socket: $socket, '
      'balanceRefresh: ${balanceRefresh.inSeconds}s)';
}

class VoltaSettingService {
  VoltaSettingService._();

  static final VoltaSettingService instance = VoltaSettingService._();

  VoltaSettings? _current;
  Future<VoltaSettings?>? _inFlight;

  VoltaSettings? get current => _current;

  bool get isLoaded => _current?.isUsable ?? false;

  static String get settingUrl {
    final Object? configured =
        VoltaPlatform.instance.mainConfig('volta_setting_url');
    final String base = configured is String && configured.isNotEmpty
        ? configured
        : _defaultSettingUrl;
    return '$base${VoltaAgent.id}';
  }

  static const String _defaultSettingUrl =
      'https://gali.sb21.net/volta/setting?agentId=';

  Future<VoltaSettings?> load({bool force = false}) {
    if (!force && isLoaded) return Future<VoltaSettings?>.value(_current);
    return _inFlight ??= _fetch().whenComplete(() => _inFlight = null);
  }

  Future<VoltaSettings?> _fetch() async {
    final String url = settingUrl;
    try {
      final dynamic raw = await VoltaHttp.getPublic(
        url,
      ).timeout(VoltaRules.httpTimeout);
      final VoltaSettings? parsed = VoltaSettings.parse(raw);
      if (parsed == null) {
        if (voltaDebug) {
          voltaLog(() => 'VoltaSetting: thân trả lời không dùng được — $raw');
        }
        return null;
      }
      _current = parsed;
      if (voltaDebug) {
        voltaLog(() => 'VoltaSetting: $parsed');
        _reportUnreadKeys(raw);
      }
      return parsed;
    } on Object catch (e) {
      if (voltaDebug) voltaLog(() => 'VoltaSetting: lỗi gọi $url — $e');
      return null;
    }
  }

  static void _reportUnreadKeys(dynamic raw) {
    if (raw is! Map) return;
    const Set<String> read = <String>{
      'domains',
      'updateBalance',
      'balance',
      'performance',
    };

    final List<String> extra = <String>[
      for (final Object? key in raw.keys)
        if (!read.contains('$key')) '$key',
    ];
    if (extra.isNotEmpty) {
      voltaLog(() => 'VoltaSetting: khoá CHƯA đọc — ${extra.join(', ')}');
    }

    final List<String> limits = <String>[];
    void scan(String path, Object? node) {
      if (node is! Map) return;
      node.forEach((Object? key, Object? value) {
        final String name = '$key';
        final String full = path.isEmpty ? name : '$path.$name';
        final String lower = name.toLowerCase();
        if (lower.contains('min') ||
            lower.contains('max') ||
            lower.contains('limit') ||
            lower.contains('stake')) {
          limits.add('$full = $value');
        }
        scan(full, value);
      });
    }

    scan('', raw);
    if (limits.isNotEmpty) {
      voltaLog(() =>
        '🟢 VoltaSetting: CÓ khoá trông như hạn mức cược — '
        '${limits.join(' | ')}. Nếu đúng là min/max thì đọc từ đây thay vì '
        'chờ mã lỗi 605/606 (docs/21 §5 mục 9).',
      );
    }
  }

  @visibleForTesting
  void overrideWith(VoltaSettings? settings) => _current = settings;

  void reset() {
    _current = null;
    _inFlight = null;
  }
}
