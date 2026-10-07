library;

import 'dart:async';

class MicrotaskBurstCoalescer {
  MicrotaskBurstCoalescer(this._flush);

  final void Function() _flush;
  int _messages = 0;
  bool _armed = false;

  void noteMessage() => _messages++;

  void requestFlush() {
    if (_armed) return;
    _armed = true;
    _check(-1);
  }

  void cancel() => _armed = false;

  void _check(int seen) {
    scheduleMicrotask(() {
      if (!_armed) return;
      if (_messages != seen) {
        _check(_messages);
        return;
      }
      _armed = false;
      _flush();
    });
  }
}
