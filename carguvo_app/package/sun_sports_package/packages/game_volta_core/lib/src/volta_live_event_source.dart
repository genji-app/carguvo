import 'dart:async';

import 'volta_endpoints.dart';
import 'volta_event_source.dart';
import 'volta_platform.dart';
import 'volta_socket.dart';
import 'volta_socket_config.dart';
import 'volta_wire.dart';

class VoltaLiveEventSource implements VoltaEventSource {
  VoltaLiveEventSource({
    required Uri socketUri,
    required Future<String?> Function() tokenProvider,
    VoltaSocketConfig config = const VoltaSocketConfig(),
    VoltaSocketChannel Function(Uri uri)? openChannel,
    VoltaRestEventSource? rest,
  }) : _rest = rest ?? VoltaRestEventSource() {
    _socket = VoltaSocket(
      uri: socketUri,
      tokenProvider: tokenProvider,
      config: config,
      openChannel: openChannel,
    );
    _restSub = _rest.batches.listen(_forward);
    _socketSub = _socket.events.listen(_forward);
    _statusSub = _socket.status.listen(_onStatus);
    unawaited(_socket.connect());
  }

  static const Duration idleRestInterval = Duration(seconds: 10);

  final VoltaRestEventSource _rest;
  late final VoltaSocket _socket;

  StreamSubscription<List<VoltaWireEvent>>? _restSub;
  StreamSubscription<List<VoltaWireEvent>>? _socketSub;
  StreamSubscription<VoltaSocketStatus>? _statusSub;

  final StreamController<List<VoltaWireEvent>> _out =
      StreamController<List<VoltaWireEvent>>.broadcast();

  bool _disposed = false;

  @override
  Stream<List<VoltaWireEvent>> get batches => _out.stream;

  Stream<VoltaSocketStatus> get socketStatus => _socket.status;

  void _forward(List<VoltaWireEvent> events) {
    if (_disposed || _out.isClosed || events.isEmpty) return;
    _out.add(events);
  }

  void _onStatus(VoltaSocketStatus status) {
    if (_disposed) return;
    final bool live = status == VoltaSocketStatus.open;
    _rest.setPollInterval(
      live ? idleRestInterval : VoltaRestEventSource.defaultPollInterval,
    );
    if (voltaDebug) {
      voltaLog(() =>
        'VoltaSocket: $status — nhịp REST '
        '${live ? idleRestInterval.inSeconds : VoltaRestEventSource.defaultPollInterval.inSeconds}s',
      );
    }
  }

  @override
  Future<void> refresh() async {
    await _rest.refresh();
    await _socket.reconnectNow();
  }

  @override
  void setActive(bool active) {
    _rest.setActive(active);
    if (active) {
      _socket.onAppResumed();
    } else {
      _socket.onAppPaused();
    }
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _restSub?.cancel();
    await _socketSub?.cancel();
    await _statusSub?.cancel();
    await _socket.dispose();
    await _rest.dispose();
    await _out.close();
  }
}

VoltaEventSource createVoltaEventSource() {
  final String raw = VoltaEndpoints.socketUrl;
  final Uri? uri = raw.isEmpty ? null : Uri.tryParse(raw);

  if (uri == null || !uri.hasScheme) {
    if (voltaDebug && raw.isNotEmpty) {
      voltaLog(() => 'Volta: domains.socket không phải URL hợp lệ ("$raw") — REST thuần.');
    }
    return VoltaRestEventSource();
  }

  if (voltaDebug) voltaLog(() => 'Volta: dùng socket $uri + ảnh chụp REST.');
  return VoltaLiveEventSource(
    socketUri: uri,
    tokenProvider: () async => VoltaEndpoints.token,
  );
}
