import 'dart:async';

import 'worker_runner_stub.dart'
    if (dart.library.js_interop) 'worker_runner_web.dart' as impl;

abstract class WorkerRunner {
  factory WorkerRunner.spawn(String scriptUrl) =>
      impl.createWorkerRunner(scriptUrl);

  Future<void> get ready;

  Stream<Map<String, Object?>> get events;

  void send(Map<String, Object?> command);

  void terminate();
}
