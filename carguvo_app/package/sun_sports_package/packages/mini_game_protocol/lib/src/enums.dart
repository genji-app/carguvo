enum MessageRequest {
  loginType(1),
  logoutType(2),
  joinRoomType(3),
  leaveRoomType(4),
  roomPluginType(5),
  zonePluginType(6),
  pingType(7);

  final int code;
  const MessageRequest(this.code);
}

enum MessageResponse {
  loginResponse(1),
  logoutResponse(2),
  joinRoomResponse(3),
  leaveRoomResponse(4),
  extensionResponse(5),
  pingResponse(6);

  final int code;
  const MessageResponse(this.code);

  static MessageResponse? fromCode(int code) {
    for (final v in MessageResponse.values) {
      if (v.code == code) return v;
    }
    return null;
  }
}

const String kMiniGamePort = 'MiniGame';

class GameIds {
  GameIds._();

  static const int miniPoker = 199;
  static const int kimCuong = 202;
  static const int dragonBall = 219;
}
