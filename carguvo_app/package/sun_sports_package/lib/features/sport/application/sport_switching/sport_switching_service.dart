import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sport_socket/sport_socket.dart' as socket;
import 'package:sun_sports/features/sport/data/adapters/sport_socket_adapter.dart';
import 'package:sun_sports/core/services/storage/sport_storage.dart';

import 'sport_switch_state.dart';
import 'sport_switching_config.dart';

class SportSwitchingService {
  SportSwitchingService({
    required SportSocketAdapter adapter,
    required SportStorage storage,
    SportSwitchingConfig? config,
  }) : _adapter = adapter,
       _storage = storage,
       _config = config ?? SportSwitchingConfig.defaultConfig {
    _setupReconnectHandler();
  }

  final SportSocketAdapter _adapter;
  final SportStorage _storage;
  final SportSwitchingConfig _config;

  SportSwitchState _currentState = const SportSwitchState();
  final _stateController = StreamController<SportSwitchState>.broadcast();
  StreamSubscription<socket.ConnectionStateEvent>? _reconnectSubscription;

  Stream<SportSwitchState> get stateStream => _stateController.stream;

  SportSwitchState get currentState => _currentState;

  int get currentSportId => _currentState.currentSportId;

  bool get isSwitching => _currentState.isSwitching;

  Timer? _debounceTimer;

  int _requestVersion = 0;

  CancelToken? _cancelToken;

  int _oldSportId = 1;

  Future<void> initialize() async {
    await _storage.init();
    final savedSportId = await _storage.getSportId();
    _log('Initialize with sportId: $savedSportId');

    _currentState = SportSwitchState.initial(sportId: savedSportId);
    _stateController.add(_currentState);

    await _executeSwitch(savedSportId, isInitial: true);
  }

  void changeSport(int newSportId) {
    if (!SportTypeValidation.isValidId(newSportId)) {
      _log('Invalid sportId: $newSportId', isError: true);
      return;
    }

    if (newSportId == currentSportId && !isSwitching) {
      _log('Already on sport $newSportId, skipping');
      return;
    }

    _log('Change sport requested: $currentSportId → $newSportId');

    _oldSportId = _currentState.currentSportId;

    _debounceTimer?.cancel();

    _updateState(_currentState.toPreparing(newSportId));

    if (_config.enableDebounce) {
      _debounceTimer = Timer(_config.debounceDuration, () {
        _log('Debounce complete, executing switch to $newSportId');
        _executeSwitch(newSportId);
      });
    } else {
      _executeSwitch(newSportId);
    }
  }

  Future<void> forceSwitchSport(int sportId) async {
    _debounceTimer?.cancel();
    await _executeSwitch(sportId);
  }

  Future<void> retry() async {
    if (!_currentState.hasError) return;

    final targetSport =
        _currentState.targetSportId ?? _currentState.currentSportId;
    _log('Retrying switch to sport $targetSport');
    await _executeSwitch(targetSport);
  }

  void reset() {
    _debounceTimer?.cancel();
    _cancelToken?.cancel('Reset called');
    _updateState(_currentState.toIdle());
  }

  void dispose() {
    _debounceTimer?.cancel();
    _cancelToken?.cancel('Service disposed');
    _reconnectSubscription?.cancel();
    _stateController.close();
    _log('Service disposed');
  }

  Future<void> _executeSwitch(int sportId, {bool isInitial = false}) async {
    final version = ++_requestVersion;
    _log('Execute switch: sport=$sportId, version=$version');

    if (_config.enableCancelToken) {
      _cancelToken?.cancel('New switch initiated');
      _cancelToken = CancelToken();
    }

    _updateState(_currentState.toSwitching(version));

    try {
      _updateState(_currentState.toLoading());

      await _adapter.changeSport(sportId);

      if (_config.enableVersionCheck && version != _requestVersion) {
        _log(
          '⚠️ Stale response ignored: version=$version, current=$_requestVersion',
        );
        return;
      }

      _updateState(_currentState.toReady(sportId));
      _log('✅ Switch complete: sport=$sportId');
    } on DioException catch (e) {
      await _handleDioError(e, version, sportId);
    } catch (e, stackTrace) {
      await _handleGenericError(e, stackTrace, version, sportId);
    }
  }

  Future<void> _handleDioError(DioException e, int version, int sportId) async {
    if (e.type == DioExceptionType.cancel) {
      _log('Request cancelled for sport $sportId');
      return;
    }

    if (_config.enableVersionCheck && version != _requestVersion) {
      _log('Ignoring error for stale request: version=$version');
      return;
    }

    final errorMessage = _getDioErrorMessage(e);
    _log('❌ API Error: $errorMessage', isError: true);

    await _storage.saveSportId(_oldSportId);

    _updateState(_currentState.toError(errorMessage));
  }

  Future<void> _handleGenericError(
    Object e,
    StackTrace stackTrace,
    int version,
    int sportId,
  ) async {
    if (_config.enableVersionCheck && version != _requestVersion) {
      _log('Ignoring error for stale request: version=$version');
      return;
    }

    _log('❌ Error: $e\n$stackTrace', isError: true);

    await _storage.saveSportId(_oldSportId);

    _updateState(_currentState.toError('Failed to load. Please try again.'));
  }

  String _getDioErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet.';
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      case DioExceptionType.badResponse:
        return 'Server error (${e.response?.statusCode}). Please try again.';
      default:
        return 'Network error. Please try again.';
    }
  }

  void _setupReconnectHandler() {
    _reconnectSubscription = _adapter.onConnectionChanged.listen((event) {
      if (event.currentState == socket.ConnectionState.connected) {
        final sportId = _currentState.currentSportId;
        _log('WebSocket reconnected for sport $sportId');
      }
    });
  }

  void _updateState(SportSwitchState newState) {
    if (_currentState == newState) return;

    _log('State: ${_currentState.status} → ${newState.status}');
    _currentState = newState;
    _stateController.add(newState);
  }

  void _log(String message, {bool isError = false}) {
    if (!_config.logEnabled) return;

    final timestamp = DateTime.now().toIso8601String().substring(11, 23);
    final prefix = isError ? '❌' : '🔄';
    debugPrint('[$timestamp] $prefix [SportSwitch] $message');
  }
}
