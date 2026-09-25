import 'package:flutter_riverpod/flutter_riverpod.dart';

mixin SafeStateNotifierMixin<T> on StateNotifier<T> {
  bool _disposed = false;

  bool get isDisposed => _disposed;

  bool get isMounted => !_disposed;

  @override
  set state(T value) {
    if (!_disposed) {
      super.state = value;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
