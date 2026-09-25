import 'dart:convert';
import 'dart:math';

import 'package:meta/meta.dart';

import 'volta_endpoints.dart';
import 'volta_http.dart';
import 'volta_platform.dart';
import 'volta_rules.dart';
import 'volta_strings.dart';

@immutable
sealed class VoltaBetResult {
  const VoltaBetResult();
}

@immutable
class VoltaBetAccepted extends VoltaBetResult {
  const VoltaBetAccepted(this.ticketId, {this.status = ''});

  final String ticketId;

  final String status;

  bool get isActive =>
      status.trim().replaceAll('"', '').toLowerCase() == 'active';
}

@immutable
class VoltaBetRejected extends VoltaBetResult {
  const VoltaBetRejected(this.code, this.message);

  final int code;

  final String message;
}

@immutable
class VoltaBetUncertain extends VoltaBetResult {
  const VoltaBetUncertain(this.reason);

  final String reason;
}

enum VoltaTicketStatus {
  active,

  declined,

  waiting,

  unknown,

  unavailable;

  bool get isTerminal =>
      this == VoltaTicketStatus.active || this == VoltaTicketStatus.declined;

  static VoltaTicketStatus parse(String raw) {
    final String value = raw
        .trim()
        .replaceAll('"', '')
        .replaceAll("'", '')
        .toLowerCase();
    if (value.contains('active') || value.contains('accept')) {
      return VoltaTicketStatus.active;
    }
    if (value.contains('declin') ||
        value.contains('reject') ||
        value.contains('cancel')) {
      return VoltaTicketStatus.declined;
    }
    if (value.isEmpty) return VoltaTicketStatus.unknown;
    _noteUnknownWord(value);
    return VoltaTicketStatus.waiting;
  }

  static final Set<String> _seenWords = <String>{};

  static void _noteUnknownWord(String value) {
    if (!voltaDebug) return;
    if (value.contains('pending') || value.contains('settl')) return;
    if (!_seenWords.add(value)) return;
    voltaLog(() =>
      '🟠 Volta: trạng thái vé LẠ "$value" — đang xử như "chờ". Bổ sung vào '
      'VoltaTicketStatus.parse sau khi chốt nghĩa với backend.',
    );
  }
}

@immutable
class VoltaBetRequest {
  VoltaBetRequest({
    required this.selectionId,
    required this.displayOdds,
    required this.stake,
    required this.winnings,
    String? idempotencyKey,
  }) : idempotencyKey = idempotencyKey ?? _newKey();

  final String selectionId;

  final String displayOdds;

  final int stake;

  final int winnings;

  final String idempotencyKey;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'displayOdds': displayOdds,
    'selectionId': selectionId,
    'stake': stake,
    'winnings': winnings,
    if (VoltaBetApi.sendIdempotencyKey) 'requestId': idempotencyKey,
  };

  static final Random _rng = Random.secure();

  static String _newKey() {
    final int a = _rng.nextInt(0xFFFFFFFF);
    final int b = _rng.nextInt(0xFFFFFFFF);
    final int t = DateTime.now().millisecondsSinceEpoch;
    return '$t-${a.toRadixString(16)}${b.toRadixString(16)}';
  }
}

class VoltaBetApi {
  const VoltaBetApi();

  static const bool sendIdempotencyKey = false;

  Future<VoltaBetResult> placeBet(VoltaBetRequest request) async {
    if (!VoltaEndpoints.isReady) {
      return const VoltaBetRejected(0, 'Chưa sẵn sàng, thử lại sau ít giây');
    }
    if (request.selectionId.isEmpty) {
      return const VoltaBetRejected(607, 'Không tìm thấy kèo, thử lại sau');
    }

    try {
      final dynamic raw = await VoltaHttp.post(
        VoltaEndpoints.placeBet(),
        jsonEncode(request.toJson()),
      ).timeout(VoltaRules.httpTimeout);
      return _readPlaceBet(raw, request);
    } on VoltaHttpException catch (e) {
      if (e.statusCode == 0) {
        return VoltaBetUncertain('timeout: ${e.message}');
      }
      if (voltaDebug) {
        voltaLog(() =>
          'VoltaBetApi: place-bet HTTP ${e.statusCode} — ${e.message} '
          '| url=${VoltaEndpoints.placeBet()} '
          '| gửi=${jsonEncode(request.toJson())} '
          '| server trả=${e.body ?? '(không có thân)'}',
        );
      }
      return VoltaBetRejected(0, _networkMessage(e.statusCode));
    } on Object catch (e) {
      return VoltaBetUncertain('$e');
    }
  }

  @visibleForTesting
  VoltaBetResult readPlaceBetBody(dynamic raw, VoltaBetRequest request) =>
      _readPlaceBet(raw, request);

  VoltaBetResult _readPlaceBet(dynamic raw, VoltaBetRequest request) {
    if (raw == null) return const VoltaBetUncertain('empty body');
    if (raw is String && raw.trim().isEmpty) {
      return const VoltaBetUncertain('empty body');
    }
    if (raw is Map && raw.isEmpty) {
      return const VoltaBetUncertain('empty body (502/504)');
    }

    final Object? node = raw is String ? VoltaHttp.decodeBody(raw) : raw;
    if (node is! Map) return VoltaBetUncertain('unexpected body type: $raw');

    final Map<String, dynamic> body = node.cast<String, dynamic>();
    final String? ticketId = _ticketIdOf(body);
    if (ticketId != null && ticketId.isNotEmpty) {
      if (voltaDebug) {
        voltaLog(() =>
          'VoltaBetApi: vé $ticketId đã vào sổ '
          '(trạng thái=${body['status'] ?? '?'} · '
          'tiền=${body['stake'] ?? '?'} · key=${request.idempotencyKey})',
        );
      }
      return VoltaBetAccepted(ticketId, status: '${body['status'] ?? ''}');
    }

    final int code = _errorCodeOf(body);
    final String? key = _errorKeyOf(body);
    return VoltaBetRejected(code, VoltaStrings.betError(key: key, code: code));
  }

  Future<VoltaTicketStatus> ticketStatus(String ticketId) async {
    try {
      final dynamic raw = await VoltaHttp.getText(
        VoltaEndpoints.ticketStatus(ticketId),
      ).timeout(VoltaRules.httpTimeout);
      return VoltaTicketStatus.parse(raw is String ? raw : '$raw');
    } on VoltaHttpException catch (e) {
      final bool clientError = e.statusCode >= 400 && e.statusCode < 500;
      if (voltaDebug) {
        voltaLog(() =>
          'VoltaBetApi: hỏi vé $ticketId — HTTP ${e.statusCode} '
          '| url=${VoltaEndpoints.ticketStatus(ticketId)} '
          '| server trả=${e.body ?? '(không có thân)'}',
        );
      }
      return clientError
          ? VoltaTicketStatus.unavailable
          : VoltaTicketStatus.unknown;
    } on Object catch (e) {
      if (voltaDebug) voltaLog(() => 'VoltaBetApi: hỏi vé $ticketId lỗi — $e');
      return VoltaTicketStatus.unknown;
    }
  }

  static String? _ticketIdOf(Map<String, dynamic> body) {
    for (final String key in const <String>[
      'ticketId',
      'ticket_id',
      'ticketID',
    ]) {
      final Object? value = body[key];
      if (value != null && '$value'.isNotEmpty && '$value' != 'null') {
        return '$value';
      }
    }
    final Object? data = body['data'];
    if (data is Map) return _ticketIdOf(data.cast<String, dynamic>());
    return null;
  }

  static int _errorCodeOf(Map<String, dynamic> body) {
    for (final String key in const <String>[
      'errorCode',
      'error_code',
      'code',
      'status',
    ]) {
      final Object? value = body[key];
      if (value is int) return value;
      if (value is String) {
        final int? parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return 0;
  }

  static String? _errorKeyOf(Map<String, dynamic> body) {
    for (final String key in const <String>[
      'message',
      'errorMessage',
      'error',
      'errorCode',
      'error_code',
      'status',
    ]) {
      final Object? value = body[key];
      if (value is! String) continue;
      final String text = value.trim();
      if (text.isEmpty || text == 'null') continue;
      if (int.tryParse(text) != null) continue;
      return text;
    }
    final Object? data = body['data'];
    if (data is Map) return _errorKeyOf(data.cast<String, dynamic>());
    return null;
  }

  static String _networkMessage(int statusCode) => switch (statusCode) {
    401 || 403 => 'Phiên đăng nhập đã hết hạn, đăng nhập lại giúp bạn nhé',
    _ => 'Lỗi kết nối máy chủ',
  };

  static String messageOf(int code) => VoltaStrings.betError(code: code);
}
