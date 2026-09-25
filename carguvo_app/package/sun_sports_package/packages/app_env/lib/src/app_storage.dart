typedef StorageReader = String? Function(String key);

typedef StorageWriter = void Function(String key, String value);

typedef StorageRemover = void Function(String key);

class AppStorage {
  AppStorage._();

  static StorageReader? _read;
  static StorageWriter? _write;
  static StorageRemover? _remove;

  static bool get isConfigured => _read != null && _write != null;

  static void configure({
    required StorageReader read,
    required StorageWriter write,
    StorageRemover? remove,
  }) {
    _read = read;
    _write = write;
    _remove = remove;
  }

  static void resetForTesting() {
    _read = null;
    _write = null;
    _remove = null;
  }

  static String? get(String key) {
    final read = _read;
    if (read == null) return null;
    try {
      return read(key);
    } catch (_) {
      return null;
    }
  }

  static bool set(String key, String value) {
    final write = _write;
    if (write == null) return false;
    try {
      write(key, value);
      return true;
    } catch (_) {
      return false;
    }
  }

  static bool remove(String key) {
    final remove = _remove;
    if (remove == null) return false;
    try {
      remove(key);
      return true;
    } catch (_) {
      return false;
    }
  }
}
