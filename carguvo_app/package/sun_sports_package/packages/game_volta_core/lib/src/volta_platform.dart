abstract class VoltaPlatform {
  const VoltaPlatform();

  Object? brandConfig(String key);

  bool get isAndroid;

  bool get isDebug;

  void log(String message);

  Object? mainConfig(String key) => null;

  int get agentId => 0;

  String get brand => '';

  String get userToken => '';

  String get apiDomain => '';

  String get appCustLogin => '';
  String get appCustId => '';

  static VoltaPlatform _current = const _FallbackPlatform();

  static VoltaPlatform get instance => _current;

  static void install(VoltaPlatform platform) => _current = platform;

  static void reset() => _current = const _FallbackPlatform();
}

class _FallbackPlatform extends VoltaPlatform {
  const _FallbackPlatform();

  @override
  Object? brandConfig(String key) => null;

  @override
  bool get isAndroid => false;

  @override
  bool get isDebug => false;

  @override
  void log(String message) {}
}

bool get voltaDebug => VoltaPlatform.instance.isDebug;

void voltaLog(String Function() message) {
  final VoltaPlatform platform = VoltaPlatform.instance;
  if (!platform.isDebug) return;
  platform.log(message());
}

bool voltaListEquals<T>(List<T>? a, List<T>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
