/// Central place for unlock-flow remote config. Update values here only.
abstract final class UnlockFlowConfig {
  UnlockFlowConfig._();

  /// JSON that provides [api_domain] for the unlock API host (not bundleId).
  static const String apiDomainConfigUrl =
      'https://raw.githubusercontent.com/Vulcan-dev-25/configs/refs/heads/main/s88_staging.json';

  /// JSON that provides [bundleId] only ([s88.json](https://raw.githubusercontent.com/Vulcan-dev-25/configs/main/s88.json)).
  static const String bundleIdConfigUrl =
      'https://raw.githubusercontent.com/Vulcan-dev-25/configs/refs/heads/main/s88.json';

  static final DateTime appSubmitDate = DateTime(2026, 9, 8);

  /// Non-empty string from [json], else null.
  static String? readString(Map<String, dynamic> json, String key) {
    final dynamic value = json[key];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    return null;
  }

  /// Int from [json] when value is [int] or [num], else null.
  static int? readOptionalInt(Map<String, dynamic> json, String key) {
    final dynamic value = json[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return null;
  }
}
