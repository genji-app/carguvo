import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'protocol.dart';
import 'worker_runner.dart';

WorkerRunner createWorkerRunner(String scriptUrl) =>
    _WebWorkerRunner(scriptUrl);

class _WebWorkerRunner implements WorkerRunner {
  _WebWorkerRunner(String scriptUrl) : _worker = web.Worker(scriptUrl.toJS) {
    _worker.onmessage = ((web.MessageEvent e) => _onMessage(e.data)).toJS;
    _worker.onerror = ((web.Event e) {
      final msg = e is web.ErrorEvent ? e.message : 'worker error';
      _events.add(
          {SportRunnerProtocol.type: SportRunnerProtocol.error, 'msg': msg});
      if (!_ready.isCompleted) _ready.completeError(StateError(msg));
    }).toJS;
  }

  final web.Worker _worker;
  final _events = StreamController<Map<String, Object?>>.broadcast();
  final _ready = Completer<void>();
  final _buffered = <Map<String, Object?>>[];

  @override
  Future<void> get ready => _ready.future;

  @override
  Stream<Map<String, Object?>> get events => _events.stream;

  @override
  void send(Map<String, Object?> command) {
    if (!_ready.isCompleted) {
      _buffered.add(command);
      return;
    }
    _worker.postMessage(command.jsify());
  }

  @override
  void terminate() {
    _worker.terminate();
    _events.close();
  }

  void _onMessage(JSAny? data) {
    final decoded = data.dartify();
    if (decoded is! Map) return;
    final msg = decoded.map((k, v) => MapEntry(k.toString(), v));
    if (msg[SportRunnerProtocol.type] == SportRunnerProtocol.ready &&
        !_ready.isCompleted) {
      _ready.complete();
      for (final c in _buffered) {
        _worker.postMessage(c.jsify());
      }
      _buffered.clear();
    }
    _events.add(msg);
  }
}
