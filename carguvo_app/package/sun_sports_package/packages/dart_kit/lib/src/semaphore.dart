import 'dart:async';

class Semaphore {
  final int _maxCount;
  int _current = 0;
  final _queue = <Completer<void>>[];

  Semaphore(this._maxCount) : assert(_maxCount > 0);

  void dispose({Object? error}) {
    for (final completer in _queue) {
      completer.completeError(error ?? StateError('Semaphore disposed'));
    }
    _queue.clear();
    _current = 0;
  }

  int get currentCount => _current;

  Future<void> acquire() async {
    if (_current < _maxCount) {
      _current++;
      return;
    }
    final completer = Completer<void>();
    _queue.add(completer);
    await completer.future;
    _current++;
  }

  void release() {
    if (_current <= 0) {
      assert(false, 'Semaphore.release() gọi nhiều hơn acquire()');
      return;
    }
    _current--;
    if (_queue.isNotEmpty) {
      _queue.removeAt(0).complete();
    }
  }
}
