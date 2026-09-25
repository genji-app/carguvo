class ChatSessionHooks {
  final bool Function() isTransportAlive;

  final bool Function() canDial;

  final bool Function() isSignedOut;

  final String Function() chatZone;

  final DateTime? Function() wsTokenExpiry;

  final void Function(String frame) sendFrame;

  final Future<void> Function() dial;

  final void Function() teardownTransport;

  final Future<bool> Function({required bool force}) refreshSession;

  final void Function(bool loggedIn) onLoginStateChange;

  final void Function() onLoginSuccess;

  final void Function() onFatalStop;

  final void Function(String message)? log;

  const ChatSessionHooks({
    required this.isTransportAlive,
    required this.canDial,
    required this.isSignedOut,
    required this.chatZone,
    required this.wsTokenExpiry,
    required this.sendFrame,
    required this.dial,
    required this.teardownTransport,
    required this.refreshSession,
    required this.onLoginStateChange,
    required this.onLoginSuccess,
    required this.onFatalStop,
    this.log,
  });
}
