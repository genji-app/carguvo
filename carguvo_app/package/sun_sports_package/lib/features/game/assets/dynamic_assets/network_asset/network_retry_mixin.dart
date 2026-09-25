part of 'network_asset.dart';

mixin _NetworkRetryMixin<T extends StatefulWidget> on State<T> {
  int retryCount = 0;
  Timer? retryTimer;

  void cancelRetry() {
    retryTimer?.cancel();
  }

  void resetRetry() {
    retryCount = 0;
    cancelRetry();
  }

  void scheduleRetry({
    required int maxRetries,
    required VoidCallback onRetry,
    VoidCallback? onMaxRetriesReached,
  }) {
    if (retryTimer?.isActive ?? false) return;

    if (retryCount >= maxRetries) {
      onMaxRetriesReached?.call();
      return;
    }

    final delaySeconds = 2 * (1 << retryCount);
    retryTimer = Timer(Duration(seconds: delaySeconds), () {
      if (mounted) {
        setState(() {
          retryCount++;
        });
        onRetry();
      }
    });
  }

  @override
  void dispose() {
    cancelRetry();
    super.dispose();
  }
}
