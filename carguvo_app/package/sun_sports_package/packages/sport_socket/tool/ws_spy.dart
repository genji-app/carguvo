// WS spy — đo payload detail-channel staging (bug vé H1 "Đã bị hủy").
//
// Cách chạy (từ packages/sport_socket):
//   dart run tool/ws_spy.dart find <tên-đội-substring> [tr]
//     → sub list by-sport tr (default 1=TODAY) + in eventId các trận khớp tên.
//   dart run tool/ws_spy.dart spy <eventId> [giây]
//     → sub detail channel ln:vi:e:<id>, dump từng payload: type/#markets/
//       marketIds/children — để phân biệt snapshot full vs delta partial.
//
// KHÔNG dùng trong app — tool chẩn đoán thuần, không import lib client.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:sport_socket/src/proto/proto.dart';

const wsUrl = 'wss://nowsgb.sb21.net';

void main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln('usage: find <name> [tr] | spy <eventId> [seconds]');
    exit(2);
  }
  final mode = args[0];
  final ws = await WebSocket.connect(wsUrl);
  stdout.writeln('# connected $wsUrl');

  void sub(String channel) {
    ws.add(Uint8List.fromList(utf8.encode('SUBSCRIBE:$channel')));
    stdout.writeln('# SUBSCRIBE:$channel');
  }

  final sw = Stopwatch()..start();
  String ts() => (sw.elapsedMilliseconds / 1000).toStringAsFixed(1).padLeft(6);

  void dumpEvent(EventResponse e, {String indent = ''}) {
    final mids = e.markets.map((m) =>
        '${m.marketId}(${m.oddsList.length}${m.isSuspended ? "S" : ""})'
        '[${m.oddsList.map((o) => o.strOfferId).join("|")}]');
    stdout.writeln(
        '$indent  eid=${e.eventId} ct=${e.childType} home="${e.homeName}" '
        'susp=${e.isSuspended} hidden=${e.isHidden} '
        'hasSusp=${e.hasIsSuspended()} hasHidden=${e.hasIsHidden()} '
        'markets=${e.markets.length} [${mids.join(",")}] '
        'children=${e.children.length}');
    for (final c in e.children) {
      dumpEvent(c, indent: '$indent    child>');
    }
  }

  if (mode == 'find') {
    final needle = args[1] == '*' ? '' : args[1].toLowerCase();
    final tr = args.length > 2 ? int.parse(args[2]) : 1;
    final secs = args.length > 3 ? int.parse(args[3]) : 20;
    sub('ln:vi:s:1:tr:$tr:e');
    final seen = <int>{};
    ws.listen((data) {
      if (data is! List<int>) return;
      final p = _parse(data);
      if (p == null || !p.hasEvent()) return;
      final e = p.event;
      final name = '${e.homeName} ${e.awayName}'.toLowerCase();
      if (name.contains(needle) && seen.add(e.eventId.toInt())) {
        stdout.writeln('FOUND eid=${e.eventId} "${e.homeName} - ${e.awayName}" '
            'league=${e.leagueId} start=${e.startDate}');
      }
    });
    await Future<void>.delayed(Duration(seconds: secs));
  } else if (mode == 'spy') {
    final eventId = int.parse(args[1]);
    final secs = args.length > 2 ? int.parse(args[2]) : 180;
    final channel = 'ln:vi:e:$eventId';
    sub(channel);
    ws.listen((data) {
      if (data is! List<int>) return;
      final p = _parse(data);
      if (p == null) return;
      // Chỉ quan tâm channel detail của event này (frame khác in gọn).
      if (p.channel != channel) return;
      stdout.writeln('[${ts()}s] type=${p.type} channel=${p.channel} '
          'hasEvent=${p.hasEvent()}');
      if (p.hasEvent()) dumpEvent(p.event);
    });
    await Future<void>.delayed(Duration(seconds: secs));
  }
  await ws.close();
  stdout.writeln('# done');
  exit(0);
}

Payload? _parse(List<int> data) {
  try {
    return Payload.fromBuffer(Uint8List.fromList(data));
  } catch (_) {
    return null;
  }
}
