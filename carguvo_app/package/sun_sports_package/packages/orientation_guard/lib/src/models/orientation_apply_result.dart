import 'orientation_policy.dart';

enum OrientationResultStatus {
  matched,

  mismatched,

  unsupported,

  failed,
}

class OrientationApplyResult {
  const OrientationApplyResult({
    required this.status,
    required this.policy,
    required this.canControlPlatform,
    this.message,
  });

  final OrientationResultStatus status;

  final OrientationPolicy policy;

  final bool canControlPlatform;

  final String? message;

  factory OrientationApplyResult.matched(OrientationPolicy policy) => OrientationApplyResult(
        status: OrientationResultStatus.matched,
        policy: policy,
        canControlPlatform: true,
      );

  factory OrientationApplyResult.unsupported(OrientationPolicy policy, {String? message}) =>
      OrientationApplyResult(
        status: OrientationResultStatus.unsupported,
        policy: policy,
        canControlPlatform: false,
        message: message,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrientationApplyResult &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          policy == other.policy &&
          canControlPlatform == other.canControlPlatform &&
          message == other.message;

  @override
  int get hashCode =>
      status.hashCode ^ policy.hashCode ^ canControlPlatform.hashCode ^ message.hashCode;
}
