mixin RequestLock {
  bool _isLocked = false;

  bool get isLocked => _isLocked;

  bool lock() {
    if (!_isLocked) {
      _isLocked = true;
      return false;
    }
    return true;
  }

  void unlock() => _isLocked = false;
}
