import 'dart:async';
import 'package:sun_sports/core/services/websocket/base_websocket.dart';
import 'package:sun_sports/core/services/websocket/sb_websocket.dart';
import 'package:sun_sports/core/services/websocket/sb_chat_websocket.dart';
import 'package:sun_sports/core/services/websocket/minigame_websocket.dart';
import 'package:sun_sports/core/services/websocket/websocket_messages.dart';
import 'package:sun_sports/core/services/config/sb_config.dart';
import 'package:sun_sports/core/services/network/sb_http_manager.dart';
import 'package:sun_sports/core/utils/app_logger.dart';

class WebSocketManager {
  static WebSocketManager? _instance;
  static WebSocketManager get instance => _instance ??= WebSocketManager._();

  WebSocketManager._();

  final AppLogger _logger = AppLogger();

  final SbWebSocket sportbook = SbWebSocket();

  final SbChatWebSocket chat = SbChatWebSocket();

  final MinigameWebSocket minigame = MinigameWebSocket();

  final StreamController<WebSocketManagerState> _stateController =
      StreamController<WebSocketManagerState>.broadcast();

  WebSocketManagerState _state = const WebSocketManagerState();

  StreamSubscription<WsConnectionState>? _sportbookStateSubscription;
  StreamSubscription<WsConnectionState>? _chatStateSubscription;
  StreamSubscription<WsConnectionState>? _minigameStateSubscription;

  bool _initialized = false;

  WebSocketManagerState get state => _state;

  Stream<WebSocketManagerState> get stateStream => _stateController.stream;

  bool get isAnyConnected =>
      sportbook.isConnected ||
      chat.isConnected ||
      minigame.isConnected;

  bool get isAllConnected =>
      sportbook.isConnected &&
      chat.isConnected;

  void initialize() {
    if (_initialized) {
      _logger.w('WebSocketManager: Already initialized, skipping...');
      return;
    }
    _initialized = true;

    _logger.i('WebSocketManager: Initializing...');

    _sportbookStateSubscription = sportbook.stateStream.listen((state) {
      _updateState(sportbookState: state);
    });

    _chatStateSubscription = chat.stateStream.listen((state) {
      _updateState(chatState: state);
    });

    _minigameStateSubscription = minigame.stateStream.listen((state) {
      _updateState(minigameState: state);
    });
  }

  Future<bool> connectSportbook(String url, {String? custLogin}) async {
    return _connectSportbook(url, custLogin);
  }

  Future<bool> connectChat() async {
    final config = SbConfig.instance;
    final http = SbHttpManager.instance;

    final chatWsUrl = config.chatWs;
    if (chatWsUrl.isEmpty || !chatWsUrl.startsWith('ws')) {
      _logger.e(
        'WebSocketManager: Chat WebSocket URL is invalid: "$chatWsUrl". '
        'Make sure SbLogin.connect() has been called first.',
      );
      return false;
    }

    if (http.userToken.isEmpty) {
      _logger.e(
        'WebSocketManager: userToken is empty. '
        'Make sure SbLogin.connect() has been called first.',
      );
      return false;
    }

    if (config.wsToken.isEmpty) {
      _logger.e(
        'WebSocketManager: wsToken is empty. '
        'Make sure SbLogin.connect() has been called first.',
      );
      return false;
    }

    return _connectChat(
      chatWsUrl,
      http.userToken,
      config.wsToken,
      http.displayName,
    );
  }

  Future<bool> connectMinigame({
    required String url,
    required String username,
    required String password,
    required Map<String, dynamic> mainLoginData,
  }) {
    return minigame.connectWithAuth(
      url: url,
      username: username,
      password: password,
      mainLoginData: mainLoginData,
    );
  }

  Future<void> disconnectAll() async {
    _logger.i('WebSocketManager: Disconnecting all WebSockets...');

    await Future.wait([
      sportbook.disconnect(),
      chat.disconnect(),
      minigame.disconnect(),
    ]);
  }

  void killAll() {
    _logger.i('WebSocketManager: Killing all WebSockets...');
    sportbook.kill();
    chat.kill();
    minigame.kill();
  }

  void dispose() {
    _logger.i('WebSocketManager: Disposing...');

    _sportbookStateSubscription?.cancel();
    _chatStateSubscription?.cancel();
    _minigameStateSubscription?.cancel();

    sportbook.dispose();
    chat.dispose();
    minigame.dispose();
    _stateController.close();

    _initialized = false;
    _instance = null;
  }

  void subscribeSport(int sportId) => sportbook.subscribeSport(sportId);

  void subscribeEvent(int eventId) => sportbook.subscribeEvent(eventId);

  void unsubscribeEvent(int eventId) => sportbook.unsubscribeEvent(eventId);

  Stream<OddsUpdateData> get oddsStream => sportbook.oddsStream;

  Stream<OddsRemoveData> get oddsRemoveStream => sportbook.oddsRemoveStream;

  Stream<OddsFullListData> get oddsFullListStream =>
      sportbook.oddsFullListStream;

  Stream<BalanceUpdateData> get balanceStream => sportbook.balanceStream;

  Stream<ScoreUpdateData> get scoreStream => sportbook.scoreStream;

  Stream<EventInsertData> get eventInsertStream => sportbook.eventInsertStream;

  Stream<EventRemoveData> get eventRemoveStream => sportbook.eventRemoveStream;

  Stream<LeagueInsertData> get leagueInsertStream =>
      sportbook.leagueInsertStream;

  Stream<MarketStatusData> get marketStatusStream =>
      sportbook.marketStatusStream;

  void sendChatMessage(String content) => chat.sendChatMessage(content);

  void fetchChatHistory() => chat.fetchChatBox();

  String get chatRoom => chat.activeRoom;

  bool pushChatRoom(String room) => chat.pushRoom(room);

  bool popChatRoom(String room) => chat.popRoom(room);

  Stream<ChatMessageData> get chatMessageStream => chat.chatMessageStream;

  Stream<List<ChatMessageData>> get chatHistoryStream => chat.historyStream;

  Stream<bool> get chatLoginStatusStream => chat.loginStatusStream;

  bool get isChatLoggedIn => chat.isLoggedIn;

  Stream<MinigameSocketEvent> get minigameEventStream => minigame.eventStream;

  Stream<bool> get minigameLoginStatusStream => minigame.loginStatusStream;

  Future<bool> _connectSportbook(String url, String? custLogin) async {
    if (custLogin != null) {
      return sportbook.connectWithAuth(url, custLogin);
    }
    return sportbook.connect(url);
  }

  Future<bool> _connectChat(
    String url,
    String accessToken,
    String wsToken,
    String userName,
  ) async {
    return chat.connectWithAuth(url, accessToken, wsToken, userName);
  }

  void _updateState({
    WsConnectionState? sportbookState,
    WsConnectionState? chatState,
    WsConnectionState? minigameState,
  }) {
    _state = _state.copyWith(
      sportbookState: sportbookState,
      chatState: chatState,
      minigameState: minigameState,
    );
    _stateController.add(_state);
  }
}

class WebSocketManagerState {
  final WsConnectionState sportbookState;
  final WsConnectionState chatState;
  final WsConnectionState minigameState;

  const WebSocketManagerState({
    this.sportbookState = WsConnectionState.disconnected,
    this.chatState = WsConnectionState.disconnected,
    this.minigameState = WsConnectionState.disconnected,
  });

  WebSocketManagerState copyWith({
    WsConnectionState? sportbookState,
    WsConnectionState? chatState,
    WsConnectionState? minigameState,
  }) => WebSocketManagerState(
    sportbookState: sportbookState ?? this.sportbookState,
    chatState: chatState ?? this.chatState,
    minigameState: minigameState ?? this.minigameState,
  );

  bool get isAnyConnected =>
      sportbookState == WsConnectionState.connected ||
      chatState == WsConnectionState.connected ||
      minigameState == WsConnectionState.connected;

  bool get isAllConnected =>
      sportbookState == WsConnectionState.connected &&
      chatState == WsConnectionState.connected;

  bool get isAnyReconnecting =>
      sportbookState == WsConnectionState.reconnecting ||
      chatState == WsConnectionState.reconnecting ||
      minigameState == WsConnectionState.reconnecting;

  bool get hasError =>
      sportbookState == WsConnectionState.error ||
      chatState == WsConnectionState.error ||
      minigameState == WsConnectionState.error;
}
