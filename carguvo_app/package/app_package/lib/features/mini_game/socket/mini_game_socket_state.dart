import 'package:freezed_annotation/freezed_annotation.dart';

export 'package:mini_game_protocol/mini_game_protocol.dart' show RawMessage;

part 'mini_game_socket_state.freezed.dart';

@freezed
sealed class MiniGameSocketState with _$MiniGameSocketState {
  const factory MiniGameSocketState.disconnected() = SocketDisconnected;
  const factory MiniGameSocketState.connecting() = SocketConnecting;
  const factory MiniGameSocketState.connected() = SocketConnected;
  const factory MiniGameSocketState.authenticated() = SocketAuthenticated;
  const factory MiniGameSocketState.reconnecting(int attempt) = SocketReconnecting;
  const factory MiniGameSocketState.failed(String reason) = SocketFailed;
}
