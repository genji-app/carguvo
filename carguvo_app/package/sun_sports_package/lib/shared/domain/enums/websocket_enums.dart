enum WsConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

enum WsMessageType {
  oddsUpdate,

  oddsInsert,

  oddsRemove,

  eventStatus,

  eventInsert,

  eventRemove,

  marketStatus,

  leagueInsert,

  balanceUpdate,

  scoreUpdate,

  connection,

  heartbeat,

  unknown,
}
