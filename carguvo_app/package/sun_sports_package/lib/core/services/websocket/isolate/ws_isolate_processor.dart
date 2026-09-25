import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:isolate_manager/isolate_manager.dart';

import 'ws_isolate_types.dart';
import 'ws_isolate_worker.dart';

class WsIsolateProcessor {
  IsolateManager<Map<String, dynamic>, Map<String, dynamic>>? _isolateManager;

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    if (kIsWeb) {
      debugPrint(
        'ℹ️ WsIsolateProcessor: Web platform - using optimized main thread processing',
      );
      debugPrint('   (Web Worker disabled due to compatibility issues)');
      _isInitialized = true;
      return;
    }

    debugPrint(
      '🔄 WsIsolateProcessor: Creating isolate manager (Native Isolate)...',
    );

    try {
      _isolateManager = IsolateManager.create(
        wsIsolateWorker,
        workerName: 'wsIsolateWorker',
        concurrent: 1,
      );

      debugPrint('🔄 WsIsolateProcessor: Starting isolate...');

      await _isolateManager!.start().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('⏰ WsIsolateProcessor: Start timeout after 10s');
          throw Exception('Isolate start timeout');
        },
      );

      _isInitialized = true;
      debugPrint(
        '✅ WsIsolateProcessor: Initialized successfully (Native Isolate)',
      );
    } catch (e, stackTrace) {
      debugPrint('❌ WsIsolateProcessor: Failed to initialize: $e');
      debugPrint('   Stack trace: $stackTrace');
      _isolateManager = null;
      rethrow;
    }
  }

  Future<WsIsolateOutput> process(WsIsolateInput input) async {
    if (_isolateManager == null) {
      return _processOnMainThread(input);
    }

    try {
      final resultMap = await _isolateManager!.compute(input.toMap());
      return WsIsolateOutput.fromMap(resultMap);
    } catch (e) {
      debugPrint(
        '⚠️ WsIsolateProcessor: Isolate error, falling back to main thread: $e',
      );
      return _processOnMainThread(input);
    }
  }

  WsIsolateOutput _processOnMainThread(WsIsolateInput input) {
    final resultMap = wsIsolateWorker(input.toMap());
    return WsIsolateOutput.fromMap(resultMap);
  }

  Future<void> dispose() async {
    if (_isolateManager != null) {
      await _isolateManager!.stop();
      _isolateManager = null;
    }
    _isInitialized = false;
    debugPrint('🛑 WsIsolateProcessor: Disposed');
  }
}
