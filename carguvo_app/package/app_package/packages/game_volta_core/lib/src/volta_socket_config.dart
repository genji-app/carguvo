import 'package:meta/meta.dart';

@immutable
class VoltaSocketConfig {
  const VoltaSocketConfig({
    this.pingInterval = const Duration(seconds: 5),
    this.pongTimeout,
    this.pingWaitsForPong = true,
    this.connectTimeout = const Duration(seconds: 10),
    this.retryInterval = const Duration(seconds: 5),
    this.useBackoff = false,
    this.maxBackoff = const Duration(seconds: 30),
    this.backoffJitter = 0.2,
    this.maxAttempts,
    this.singleFlightConnect = false,
    this.dedupeDrop = false,
    this.cancelAllTimersOnConnect = true,
    this.distinguishAuthClose = false,
    this.resumeReconnectThreshold = const Duration(seconds: 15),
    this.pingPrefix = 'ping_',
    this.acceptedTypes = const <String>{'current'},
    this.detectArrayPong = true,
    this.arrayPongCommand = 0,
    this.treatAnyMessageAsAlive = false,
    this.sendTokenInQuery = true,
  });

  const VoltaSocketConfig.hardened()
    : pingInterval = const Duration(seconds: 5),
      pongTimeout = const Duration(milliseconds: 12500),
      pingWaitsForPong = false,
      connectTimeout = const Duration(seconds: 10),
      retryInterval = const Duration(seconds: 1),
      useBackoff = true,
      maxBackoff = const Duration(seconds: 30),
      backoffJitter = 0.2,
      maxAttempts = null,
      singleFlightConnect = true,
      dedupeDrop = true,
      cancelAllTimersOnConnect = false,
      distinguishAuthClose = true,
      resumeReconnectThreshold = const Duration(seconds: 15),
      pingPrefix = 'ping_',
      acceptedTypes = const <String>{'current'},
      detectArrayPong = false,
      arrayPongCommand = 0,
      treatAnyMessageAsAlive = true,
      sendTokenInQuery = true;

  final Duration pingInterval;

  final Duration? pongTimeout;

  final bool pingWaitsForPong;

  final Duration connectTimeout;

  final Duration retryInterval;

  final bool useBackoff;

  final Duration maxBackoff;
  final double backoffJitter;

  final int? maxAttempts;

  final bool singleFlightConnect;

  final bool dedupeDrop;

  final bool cancelAllTimersOnConnect;

  final bool distinguishAuthClose;

  final Duration resumeReconnectThreshold;

  final String pingPrefix;

  final Set<String> acceptedTypes;

  final bool detectArrayPong;

  final int arrayPongCommand;

  final bool treatAnyMessageAsAlive;

  final bool sendTokenInQuery;

  static const Set<int> authCloseCodes = <int>{1008, 4001, 4003};
}
