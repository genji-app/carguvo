import 'dart:async';

class Debouncer {
  Debouncer(this.delay);

  final Duration delay;
  Timer? _timer;

  void call(void Function() callback) {
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }

  void dispose() => _timer?.cancel();
}
