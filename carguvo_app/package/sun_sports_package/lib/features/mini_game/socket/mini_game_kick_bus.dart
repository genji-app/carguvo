import 'dart:async';

class MiniGameKickBus {
  MiniGameKickBus._();

  static final MiniGameKickBus instance = MiniGameKickBus._();

  final StreamController<String> _controller =
      StreamController<String>.broadcast();

  Stream<String> get stream => _controller.stream;

  void emit(String reason) {
    if (_controller.isClosed) return;
    _controller.add(reason);
  }
}
