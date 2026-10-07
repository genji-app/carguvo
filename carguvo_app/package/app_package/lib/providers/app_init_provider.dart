import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppInitStatus {
  initializing,

  ready,

  error,

  noConnection,
}

class AppInitState {
  final AppInitStatus status;
  final String? errorMessage;

  const AppInitState({
    this.status = AppInitStatus.initializing,
    this.errorMessage,
  });

  bool get isInitializing => status == AppInitStatus.initializing;
  bool get isReady => status == AppInitStatus.ready;
  bool get hasError => status == AppInitStatus.error;
  bool get isNoConnection => status == AppInitStatus.noConnection;

  AppInitState copyWith({AppInitStatus? status, String? errorMessage}) =>
      AppInitState(
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

class AppInitNotifier extends StateNotifier<AppInitState> {
  AppInitNotifier() : super(const AppInitState());

  void startInitializing() {
    state = const AppInitState(status: AppInitStatus.initializing);
  }

  void setReady() {
    state = const AppInitState(status: AppInitStatus.ready);
  }

  void setError([String? message]) {
    state = AppInitState(status: AppInitStatus.error, errorMessage: message);
  }

  void setNoConnection() {
    state = const AppInitState(status: AppInitStatus.noConnection);
  }

  void reset() {
    state = const AppInitState(status: AppInitStatus.ready);
  }
}

class AppInitRetry {
  AppInitRetry._();

  static Future<void> Function()? _handler;

  static void register(Future<void> Function() handler) => _handler = handler;

  static void unregister() => _handler = null;

  static Future<void> run() async {
    final handler = _handler;
    if (handler == null) return;
    await handler();
  }
}

final appInitProvider = StateNotifierProvider<AppInitNotifier, AppInitState>(
  (ref) => AppInitNotifier(),
);

final isAppInitializingProvider = Provider<bool>(
  (ref) => ref.watch(appInitProvider).isInitializing,
);

final isAppReadyProvider = Provider<bool>(
  (ref) => ref.watch(appInitProvider).isReady,
);
