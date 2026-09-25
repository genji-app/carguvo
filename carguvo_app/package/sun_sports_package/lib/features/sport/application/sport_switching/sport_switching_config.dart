import 'package:sun_sports/core/services/models/api_v2/sport_constants.dart';

class SportSwitchingConfig {
  final Duration debounceDuration;

  final Duration apiTimeout;

  final int maxRetries;

  final Duration retryDelay;

  final bool enableDebounce;

  final bool enableVersionCheck;

  final bool enableCancelToken;

  final bool logEnabled;

  const SportSwitchingConfig({
    this.debounceDuration = const Duration(milliseconds: 250),
    this.apiTimeout = const Duration(seconds: 15),
    this.maxRetries = 2,
    this.retryDelay = const Duration(seconds: 1),
    this.enableDebounce = true,
    this.enableVersionCheck = true,
    this.enableCancelToken = true,
    this.logEnabled = true,
  });

  static const defaultConfig = SportSwitchingConfig();

  static const testConfig = SportSwitchingConfig(
    debounceDuration: Duration.zero,
    enableDebounce: false,
    apiTimeout: Duration(seconds: 5),
  );

  SportSwitchingConfig copyWith({
    Duration? debounceDuration,
    Duration? apiTimeout,
    int? maxRetries,
    Duration? retryDelay,
    bool? enableDebounce,
    bool? enableVersionCheck,
    bool? enableCancelToken,
    bool? logEnabled,
  }) {
    return SportSwitchingConfig(
      debounceDuration: debounceDuration ?? this.debounceDuration,
      apiTimeout: apiTimeout ?? this.apiTimeout,
      maxRetries: maxRetries ?? this.maxRetries,
      retryDelay: retryDelay ?? this.retryDelay,
      enableDebounce: enableDebounce ?? this.enableDebounce,
      enableVersionCheck: enableVersionCheck ?? this.enableVersionCheck,
      enableCancelToken: enableCancelToken ?? this.enableCancelToken,
      logEnabled: logEnabled ?? this.logEnabled,
    );
  }
}

extension SportTypeValidation on SportType {
  static bool isValidId(int id) {
    return SportType.values.any((e) => e.id == id);
  }

  static List<int> get allIds => SportType.values.map((e) => e.id).toList();
}
