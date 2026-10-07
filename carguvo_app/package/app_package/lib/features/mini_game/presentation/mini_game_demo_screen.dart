import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../messages/mini_game_message_streams.dart';
import '../messages/mini_game_senders.dart';
import '../messages/slot_message.dart';
import '../mini_game_lobby.dart';
import '../socket/mini_game_socket_providers.dart';
import '../socket/mini_game_socket_state.dart';

class MiniGameDemoScreen extends ConsumerStatefulWidget {
  const MiniGameDemoScreen({super.key});

  @override
  ConsumerState<MiniGameDemoScreen> createState() => _MiniGameDemoScreenState();
}

class _MiniGameDemoScreenState extends ConsumerState<MiniGameDemoScreen> {
  final List<String> _log = <String>[];
  static const int _maxLog = 200;

  void _append(String line) {
    setState(() {
      final ts = DateTime.now().toIso8601String().substring(11, 19);
      _log.insert(0, '[$ts] $line');
      if (_log.length > _maxLog) _log.removeRange(_maxLog, _log.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<MiniGameSocketState>>(
      miniGameSocketStateProvider,
      (prev, next) {
        next.whenData((s) => _append('socket → $s'));
      },
    );

    ref.listen(taiXiuMessageStreamProvider, (prev, next) {
      next.whenData((m) => _append('TaiXiu: $m'));
    });
    ref.listen(trenDuoiMessageStreamProvider, (prev, next) {
      next.whenData((m) => _append('TrenDuoi: $m'));
    });
    for (final game in SlotGameId.values) {
      ref.listen(slotMessageStreamProvider(game), (prev, next) {
        next.whenData((m) => _append('${game.name}: $m'));
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mini Game — Phase 1 Demo')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _bootLobby,
                  child: const Text('Boot Lobby (auto-subscribe)'),
                ),
                ElevatedButton(
                  onPressed: _connect,
                  child: const Text('Connect (manual)'),
                ),
                ElevatedButton(
                  onPressed: _disconnect,
                  child: const Text('Disconnect'),
                ),
                ElevatedButton(
                  onPressed: _subscribeAll,
                  child: const Text('Subscribe 5 games'),
                ),
                OutlinedButton(
                  onPressed: () => setState(_log.clear),
                  child: const Text('Clear log'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: _log.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Text(
                  _log[i],
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _bootLobby() async {
    try {
      _append('miniGameLobbyProvider warm-up…');
      final client = await ref.read(miniGameLobbyProvider.future);
      _append('lobby ready (state=${client.state}) — auto-subscribe wired');
    } catch (e, st) {
      _append('lobby boot error: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  Future<void> _connect() async {
    try {
      _append('connect() starting…');
      final client = await ref.read(miniGameSocketClientProvider.future);
      await client.connect();
      _append('connect() returned (state=${client.state})');
    } catch (e, st) {
      _append('connect() error: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  Future<void> _disconnect() async {
    try {
      final client = await ref.read(miniGameSocketClientProvider.future);
      await client.disconnect();
      _append('disconnected');
    } catch (e) {
      _append('disconnect() error: $e');
    }
  }

  Future<void> _subscribeAll() async {
    try {
      final client = await ref.read(miniGameSocketClientProvider.future);
      TaiXiuSender(client).subscribe();
      TrenDuoiSender(client).subscribe();
      MiniPokerSender(client).subscribe();
      KimCuongSender(client).subscribe();
      DragonBallSender(client).subscribe();
      _append('5 subscribe packets sent');
    } catch (e) {
      _append('subscribe() error: $e');
    }
  }
}
