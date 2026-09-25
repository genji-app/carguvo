import 'dart:math' show min;

class ProgressiveReveal {
  ProgressiveReveal({this.batch = 2}) : _revealed = batch;

  final int batch;

  int _revealed;
  int _lastTotal = 0;

  int visibleCount(int total) => min(_revealed, total);

  bool isComplete(int total) => _revealed >= total;

  void advance() {
    _revealed += batch;
  }

  void onTotalChanged(int total) {
    if (_lastTotal == 0 && total > 0) {
      _revealed = batch;
    }
    _lastTotal = total;
  }
}
