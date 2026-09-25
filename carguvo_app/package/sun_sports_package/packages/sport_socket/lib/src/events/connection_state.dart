enum ConnectionState {
  disconnected,

  connecting,

  connected,

  reconnecting,

  error,
}

extension ConnectionStateX on ConnectionState {
  bool get isConnected => this == ConnectionState.connected;

  bool get isConnecting =>
      this == ConnectionState.connecting ||
      this == ConnectionState.reconnecting;

  bool get isDisconnected =>
      this == ConnectionState.disconnected || this == ConnectionState.error;

  bool get canConnect =>
      this == ConnectionState.disconnected || this == ConnectionState.error;

  String get description {
    switch (this) {
      case ConnectionState.disconnected:
        return 'Disconnected';
      case ConnectionState.connecting:
        return 'Connecting...';
      case ConnectionState.connected:
        return 'Connected';
      case ConnectionState.reconnecting:
        return 'Reconnecting...';
      case ConnectionState.error:
        return 'Connection Error';
    }
  }
}

class ConnectionStateEvent {
  final ConnectionState previousState;
  final ConnectionState currentState;
  final String? errorMessage;
  final int? reconnectAttempt;
  final DateTime timestamp;

  const ConnectionStateEvent({
    required this.previousState,
    required this.currentState,
    this.errorMessage,
    this.reconnectAttempt,
    required this.timestamp,
  });

  factory ConnectionStateEvent.connected({
    required ConnectionState previousState,
  }) {
    return ConnectionStateEvent(
      previousState: previousState,
      currentState: ConnectionState.connected,
      timestamp: DateTime.now(),
    );
  }

  factory ConnectionStateEvent.disconnected({
    required ConnectionState previousState,
    String? reason,
  }) {
    return ConnectionStateEvent(
      previousState: previousState,
      currentState: ConnectionState.disconnected,
      errorMessage: reason,
      timestamp: DateTime.now(),
    );
  }

  factory ConnectionStateEvent.reconnecting({
    required ConnectionState previousState,
    required int attempt,
  }) {
    return ConnectionStateEvent(
      previousState: previousState,
      currentState: ConnectionState.reconnecting,
      reconnectAttempt: attempt,
      timestamp: DateTime.now(),
    );
  }

  factory ConnectionStateEvent.error({
    required ConnectionState previousState,
    required String message,
  }) {
    return ConnectionStateEvent(
      previousState: previousState,
      currentState: ConnectionState.error,
      errorMessage: message,
      timestamp: DateTime.now(),
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer()
      ..write('ConnectionStateEvent(')
      ..write('$previousState → $currentState');
    if (errorMessage != null) {
      buffer.write(', error: $errorMessage');
    }
    if (reconnectAttempt != null) {
      buffer.write(', attempt: $reconnectAttempt');
    }
    buffer.write(')');
    return buffer.toString();
  }
}
