class ChatSessionConfig {
  final Duration healthInterval;

  final Duration loginTimeout;

  final Duration recoverDebounce;

  final Duration retryBaseDelay;
  final Duration retryMaxDelay;

  final Duration refreshLeadTime;

  final Duration refreshMinDelay;

  final Duration refreshFallback;

  final bool healthRunsContinuously;

  final bool recoverImmediatelyOnDrop;

  const ChatSessionConfig({
    this.healthInterval = const Duration(seconds: 5),
    this.loginTimeout = const Duration(seconds: 12),
    this.recoverDebounce = const Duration(seconds: 5),
    this.retryBaseDelay = const Duration(seconds: 5),
    this.retryMaxDelay = const Duration(seconds: 60),
    this.refreshLeadTime = const Duration(seconds: 60),
    this.refreshMinDelay = const Duration(seconds: 10),
    this.refreshFallback = const Duration(minutes: 20),
    this.healthRunsContinuously = false,
    this.recoverImmediatelyOnDrop = true,
  });

  static const ChatSessionConfig app = ChatSessionConfig(
    loginTimeout: Duration(seconds: 12),
    healthRunsContinuously: false,
    recoverImmediatelyOnDrop: true,
  );

  static const ChatSessionConfig web = ChatSessionConfig(
    loginTimeout: Duration(seconds: 15),
    healthRunsContinuously: true,
    recoverImmediatelyOnDrop: false,
  );
}
