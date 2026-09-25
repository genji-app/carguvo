import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/services/websocket/websocket.dart';

class WebSocketProviderState {
  final WsConnectionState sportbookState;
  final WsConnectionState chatState;
  final bool isInitialized;
  final String? error;

  final List<ChatMessageData> chatMessages;

  final bool isChatLoggedIn;

  const WebSocketProviderState({
    this.sportbookState = WsConnectionState.disconnected,
    this.chatState = WsConnectionState.disconnected,
    this.isInitialized = false,
    this.error,
    this.chatMessages = const [],
    this.isChatLoggedIn = false,
  });

  WebSocketProviderState copyWith({
    WsConnectionState? sportbookState,
    WsConnectionState? chatState,
    bool? isInitialized,
    String? error,
    List<ChatMessageData>? chatMessages,
    bool? isChatLoggedIn,
  }) => WebSocketProviderState(
    sportbookState: sportbookState ?? this.sportbookState,
    chatState: chatState ?? this.chatState,
    isInitialized: isInitialized ?? this.isInitialized,
    error: error,
    chatMessages: chatMessages ?? this.chatMessages,
    isChatLoggedIn: isChatLoggedIn ?? this.isChatLoggedIn,
  );

  bool get isAnyConnected =>
      sportbookState == WsConnectionState.connected ||
      chatState == WsConnectionState.connected;

  bool get isAllConnected =>
      sportbookState == WsConnectionState.connected &&
      chatState == WsConnectionState.connected;

  bool get isSportbookConnected =>
      sportbookState == WsConnectionState.connected;

  bool get isChatConnected => chatState == WsConnectionState.connected;
}

class WebSocketNotifier extends StateNotifier<WebSocketProviderState> {
  WebSocketManager? _boundManager;

  WebSocketManager get _manager {
    final current = WebSocketManager.instance;
    if (!identical(current, _boundManager)) {
      _bindToManager(current);
    }
    return current;
  }

  StreamSubscription<WebSocketManagerState>? _stateSubscription;
  StreamSubscription<ChatMessageData>? _chatMessageSubscription;
  StreamSubscription<List<ChatMessageData>>? _chatHistorySubscription;
  StreamSubscription<bool>? _chatLoginSubscription;

  WebSocketNotifier() : super(const WebSocketProviderState()) {
    _initialize();
  }

  void _cancelSubscriptions() {
    _stateSubscription?.cancel();
    _chatMessageSubscription?.cancel();
    _chatHistorySubscription?.cancel();
    _chatLoginSubscription?.cancel();
  }

  void _initialize() {
    _bindToManager(WebSocketManager.instance);
  }

  void _bindToManager(WebSocketManager manager) {
    _cancelSubscriptions();
    _boundManager = manager;

    manager.initialize();

    _stateSubscription = manager.stateStream.listen((managerState) {
      state = state.copyWith(
        sportbookState: managerState.sportbookState,
        chatState: managerState.chatState,
        isInitialized: true,
      );
    });

    _chatMessageSubscription = manager.chatMessageStream.listen((message) {
      state = state.copyWith(
        chatMessages: _capped(<ChatMessageData>[
          ...state.chatMessages,
          message,
        ]),
      );
    });

    _chatHistorySubscription = manager.chatHistoryStream.listen((history) {
      state = state.copyWith(chatMessages: _capped(history));
    });

    _chatLoginSubscription = manager.chatLoginStatusStream.listen((
      isLoggedIn,
    ) {
      state = state.copyWith(isChatLoggedIn: isLoggedIn);
    });

    state = state.copyWith(
      sportbookState: manager.sportbook.state,
      chatState: manager.chat.state,
      isChatLoggedIn: manager.chat.isLoggedIn,
      isInitialized: true,
    );
  }

  Future<void> connectSportbook(String url, {String? custLogin}) async {
    state = state.copyWith(error: null);

    try {
      await _manager.connectSportbook(url, custLogin: custLogin);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> disconnectAll() async {
    await _manager.disconnectAll();
  }

  void subscribeSport(int sportId) => _manager.subscribeSport(sportId);

  void subscribeEvent(int eventId) => _manager.subscribeEvent(eventId);

  void unsubscribeEvent(int eventId) => _manager.unsubscribeEvent(eventId);

  Future<void> connectChat() async {
    state = state.copyWith(error: null);

    try {
      await _manager.connectChat();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void sendChatMessage(String content) => _manager.sendChatMessage(content);

  void fetchChatHistory() => _manager.fetchChatHistory();

  static const int _maxChatMessages = 200;

  static List<ChatMessageData> _capped(List<ChatMessageData> messages) {
    if (messages.length <= _maxChatMessages) return messages;
    return messages.sublist(messages.length - _maxChatMessages);
  }

  String get chatRoom => _manager.chatRoom;

  bool pushChatRoom(String room) => _switchRoom(_manager.pushChatRoom(room));

  bool popChatRoom(String room) => _switchRoom(_manager.popChatRoom(room));

  bool _switchRoom(bool changed) {
    if (changed && mounted) state = state.copyWith(chatMessages: const []);
    return changed;
  }

  WebSocketManager get manager => _manager;

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }
}

final websocketProvider =
    StateNotifierProvider<WebSocketNotifier, WebSocketProviderState>((ref) {
      return WebSocketNotifier();
    });

final sportbookConnectionProvider = Provider<WsConnectionState>(
  (ref) => ref.watch(websocketProvider).sportbookState,
);

final chatConnectionProvider = Provider<WsConnectionState>(
  (ref) => ref.watch(websocketProvider).chatState,
);

final chatMessageStreamProvider = StreamProvider<ChatMessageData>((ref) {
  final notifier = ref.read(websocketProvider.notifier);
  return notifier.manager.chatMessageStream;
});

final chatHistoryStreamProvider = StreamProvider<List<ChatMessageData>>((ref) {
  final notifier = ref.read(websocketProvider.notifier);
  return notifier.manager.chatHistoryStream;
});

final chatLoginStatusProvider = StreamProvider<bool>((ref) {
  final notifier = ref.read(websocketProvider.notifier);
  return notifier.manager.chatLoginStatusStream;
});

final isChatLoggedInProvider = Provider<bool>((ref) {
  final notifier = ref.read(websocketProvider.notifier);
  return notifier.manager.isChatLoggedIn;
});

final chatMessagesProvider = Provider<List<ChatMessageData>>(
  (ref) => ref.watch(websocketProvider).chatMessages,
);

final chatLoggedInProvider = Provider<bool>(
  (ref) => ref.watch(websocketProvider).isChatLoggedIn,
);
