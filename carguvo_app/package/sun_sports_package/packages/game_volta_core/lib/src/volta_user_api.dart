import 'package:meta/meta.dart';

import 'volta_endpoints.dart';
import 'volta_http.dart';
import 'volta_platform.dart';
import 'volta_rules.dart';

@immutable
class VoltaUserInfo {
  const VoltaUserInfo({
    required this.uid,
    required this.displayName,
    required this.custLogin,
    required this.custId,
    required this.balance,
    required this.currency,
    required this.status,
  });

  final String uid;
  final String displayName;
  final String custLogin;
  final String custId;

  final int balance;

  final String currency;

  final String status;

  bool get isUsable => custId.isNotEmpty || custLogin.isNotEmpty;

  static VoltaUserInfo? parse(dynamic raw) {
    final Object? node = VoltaHttp.decodeBody(raw);
    if (node is List<Object?>) return _fromIndexed(node);
    if (node is Map) return _fromNamed(node);
    return null;
  }

  static const int _idxCustLogin = 1;
  static const int _idxCurrency = 2;
  static const int _idxBalance = 3;
  static const int _idxStatus = 4;

  static VoltaUserInfo _fromIndexed(List<Object?> row) => VoltaUserInfo(
    uid: '',
    displayName: '',
    custLogin: _str(_at(row, _idxCustLogin)),
    custId: '',
    balance: _money(_at(row, _idxBalance)),
    currency: _str(_at(row, _idxCurrency)),
    status: _str(_at(row, _idxStatus)),
  );

  static VoltaUserInfo? _fromNamed(Map<Object?, Object?> node) {
    if (node.isEmpty) return null;
    final Map<String, dynamic> body = node.cast<String, dynamic>();
    return VoltaUserInfo(
      uid: _str(body['uid']),
      displayName: _str(body['displayName']),
      custLogin: _str(body['cust_login']),
      custId: _str(body['cust_id']),
      balance: _money(body['balance']),
      currency: _str(body['currency']),
      status: _str(body['status']),
    );
  }

  static Object? _at(List<Object?> row, int index) =>
      index >= 0 && index < row.length ? row[index] : null;

  static String _str(Object? value) =>
      value == null || value == 'null' ? '' : '$value';

  static int _money(Object? value) {
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is! String) return 0;
    final String digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }

  @override
  String toString() =>
      'VoltaUserInfo(custLogin: $custLogin, custId: $custId, uid: $uid, '
      'balance: $balance $currency, status: $status)';
}

class VoltaUserService {
  VoltaUserService._();

  static final VoltaUserService instance = VoltaUserService._();

  VoltaUserInfo? _current;
  Future<VoltaUserInfo?>? _inFlight;

  VoltaUserInfo? get current => _current;

  Future<VoltaUserInfo?> load({bool force = false}) {
    if (!force && _isFresh) return Future<VoltaUserInfo?>.value(_current);
    return _inFlight ??= _fetch().whenComplete(() => _inFlight = null);
  }

  static const Duration staleAfter = Duration(seconds: 60);

  DateTime? _loadedAt;

  bool get _isFresh {
    final DateTime? at = _loadedAt;
    if (at == null || _current == null) return false;
    return DateTime.now().difference(at) < staleAfter;
  }

  Future<VoltaUserInfo?> _fetch() async {
    for (final bool legacy in const <bool>[false, true]) {
      final String url = VoltaEndpoints.userByToken(legacy: legacy);
      try {
        final dynamic raw = await VoltaHttp.getPublic(
          url,
        ).timeout(VoltaRules.httpTimeout);
        final VoltaUserInfo? parsed = VoltaUserInfo.parse(raw);
        if (parsed == null || !parsed.isUsable) {
          if (voltaDebug) {
            voltaLog(() => 'VoltaUser: thân không dùng được ($url) — $raw');
          }
          continue;
        }
        _current = parsed;
        _loadedAt = DateTime.now();
        if (voltaDebug) _report(parsed, url);
        return parsed;
      } on VoltaHttpException catch (e) {
        if (voltaDebug) {
          voltaLog(() =>
            'VoltaUser: HTTP ${e.statusCode} ($url) — '
            'server trả=${e.body ?? '(không có thân)'}',
          );
        }
      } on Object catch (e) {
        if (voltaDebug) voltaLog(() => 'VoltaUser: lỗi gọi $url — $e');
      }
    }
    return null;
  }

  static void _report(VoltaUserInfo info, String url) {
    voltaLog(() => 'VoltaUser: $info  ⟵ $url');

    final VoltaPlatform app = VoltaPlatform.instance;
    final List<String> lech = <String>[
      if (app.appCustLogin.isNotEmpty && app.appCustLogin != info.custLogin)
        'cust_login: app="${app.appCustLogin}" vs volta="${info.custLogin}"',
      if (app.appCustId.isNotEmpty && app.appCustId != info.custId)
        'cust_id: app="${app.appCustId}" vs volta="${info.custId}"',
    ];
    if (lech.isNotEmpty) {
      voltaLog(() =>
        '🔴 VoltaUser: backend Volta thấy MỘT TÀI KHOẢN KHÁC — '
        '${lech.join(' | ')}. Mọi thứ sau đó (vé, lịch sử, xếp hạng) sẽ nói '
        'về tài khoản của nó, không phải của app.',
      );
    }
  }

  @visibleForTesting
  void overrideWith(VoltaUserInfo? info) {
    _current = info;
    _loadedAt = info == null ? null : DateTime.now();
  }

  void reset() {
    _current = null;
    _loadedAt = null;
    _inFlight = null;
  }
}
