import 'package:web_socket_channel/web_socket_channel.dart';

import '../api/auto_refresh_manager.dart';
import '../utils/logger.dart';

class SocketConfig {
  final String url;

  final Duration sampleInterval;

  final int maxParsePerSample;

  final int maxPendingQueueSize;

  final Duration pendingExpiration;

  final Duration reconnectDelay;

  final int maxReconnectAttempts;

  final bool autoReconnect;

  final bool enableMetrics;

  final Duration metricsInterval;

  final Duration pingInterval;

  final Duration pongTimeout;

  final Logger logger;

  final AutoRefreshConfig autoRefreshConfig;

  final Future<String?> Function()? onTokenRefresh;

  final bool useV2Protocol;

  final Duration v2BatchInterval;

  final int v2MaxBatchSize;

  final String v2Language;

  final WebSocketChannel Function(Uri url)? channelFactory;

  const SocketConfig({
    required this.url,
    this.sampleInterval = const Duration(milliseconds: 200),
    this.maxParsePerSample = 500,
    this.maxPendingQueueSize = 5000,
    this.pendingExpiration = const Duration(seconds: 10),
    this.reconnectDelay = const Duration(seconds: 3),
    this.maxReconnectAttempts = 5,
    this.autoReconnect = true,
    this.enableMetrics = true,
    this.metricsInterval = const Duration(seconds: 30),
    this.pingInterval = const Duration(seconds: 30),
    this.pongTimeout = const Duration(seconds: 10),
    this.logger = const ConsoleLogger(),
    this.autoRefreshConfig = const AutoRefreshConfig(),
    this.onTokenRefresh,
    this.useV2Protocol = false,
    this.v2BatchInterval = const Duration(milliseconds: 50),
    this.v2MaxBatchSize = 1000,
    this.v2Language = 'vi',
    this.channelFactory,
  });

  factory SocketConfig.liveMode({
    required String url,
    Logger? logger,
    AutoRefreshConfig? autoRefreshConfig,
    Future<String?> Function()? onTokenRefresh,
    bool useV2Protocol = false,
    String v2Language = 'vi',
    WebSocketChannel Function(Uri url)? channelFactory,
  }) {
    return SocketConfig(
      url: url,
      sampleInterval: const Duration(milliseconds: 100),
      maxParsePerSample: 1000,
      maxPendingQueueSize: 10000,
      pendingExpiration: const Duration(seconds: 5),
      reconnectDelay: const Duration(seconds: 2),
      maxReconnectAttempts: 10,
      autoReconnect: true,
      enableMetrics: true,
      metricsInterval: const Duration(seconds: 30),
      pingInterval: const Duration(seconds: 20),
      pongTimeout: const Duration(seconds: 10),
      logger: logger ?? const ConsoleLogger(),
      autoRefreshConfig: autoRefreshConfig ?? AutoRefreshConfig.live(),
      onTokenRefresh: onTokenRefresh,
      useV2Protocol: useV2Protocol,
      v2BatchInterval: const Duration(milliseconds: 50),
      v2MaxBatchSize: 1000,
      v2Language: v2Language,
      channelFactory: channelFactory,
    );
  }

  factory SocketConfig.preMatchMode({
    required String url,
    Logger? logger,
    AutoRefreshConfig? autoRefreshConfig,
    Future<String?> Function()? onTokenRefresh,
    bool useV2Protocol = false,
    String v2Language = 'vi',
    WebSocketChannel Function(Uri url)? channelFactory,
  }) {
    return SocketConfig(
      url: url,
      sampleInterval: const Duration(milliseconds: 300),
      maxParsePerSample: 500,
      maxPendingQueueSize: 5000,
      pendingExpiration: const Duration(seconds: 15),
      reconnectDelay: const Duration(seconds: 5),
      maxReconnectAttempts: 5,
      autoReconnect: true,
      enableMetrics: true,
      metricsInterval: const Duration(seconds: 60),
      pingInterval: const Duration(seconds: 30),
      pongTimeout: const Duration(seconds: 10),
      logger: logger ?? const ConsoleLogger(),
      autoRefreshConfig: autoRefreshConfig ?? AutoRefreshConfig.preMatch(),
      onTokenRefresh: onTokenRefresh,
      useV2Protocol: useV2Protocol,
      v2BatchInterval: const Duration(milliseconds: 100),
      v2MaxBatchSize: 500,
      v2Language: v2Language,
      channelFactory: channelFactory,
    );
  }

  factory SocketConfig.debugMode({
    required String url,
    Logger? logger,
    AutoRefreshConfig? autoRefreshConfig,
    Future<String?> Function()? onTokenRefresh,
  }) {
    return SocketConfig(
      url: url,
      sampleInterval: const Duration(milliseconds: 500),
      maxParsePerSample: 100,
      maxPendingQueueSize: 1000,
      pendingExpiration: const Duration(seconds: 30),
      reconnectDelay: const Duration(seconds: 1),
      maxReconnectAttempts: 3,
      autoReconnect: true,
      enableMetrics: true,
      metricsInterval: const Duration(seconds: 10),
      pingInterval: const Duration(seconds: 30),
      pongTimeout: const Duration(seconds: 10),
      logger: logger ?? const ConsoleLogger(minLevel: LogLevel.debug),
      autoRefreshConfig: autoRefreshConfig ?? const AutoRefreshConfig(),
      onTokenRefresh: onTokenRefresh,
    );
  }

  factory SocketConfig.test({
    Logger? logger,
    AutoRefreshConfig? autoRefreshConfig,
    Future<String?> Function()? onTokenRefresh,
  }) {
    return SocketConfig(
      url: 'ws://localhost:8080',
      sampleInterval: const Duration(milliseconds: 50),
      maxParsePerSample: 100,
      maxPendingQueueSize: 100,
      pendingExpiration: const Duration(seconds: 5),
      reconnectDelay: const Duration(milliseconds: 100),
      maxReconnectAttempts: 0,
      autoReconnect: false,
      enableMetrics: false,
      metricsInterval: const Duration(seconds: 1),
      pingInterval: const Duration(seconds: 10),
      pongTimeout: const Duration(seconds: 5),
      logger: logger ?? const NoOpLogger(),
      autoRefreshConfig: autoRefreshConfig ?? AutoRefreshConfig.disabled(),
      onTokenRefresh: onTokenRefresh,
    );
  }

  SocketConfig copyWith({
    String? url,
    Duration? sampleInterval,
    int? maxParsePerSample,
    int? maxPendingQueueSize,
    Duration? pendingExpiration,
    Duration? reconnectDelay,
    int? maxReconnectAttempts,
    bool? autoReconnect,
    bool? enableMetrics,
    Duration? metricsInterval,
    Duration? pingInterval,
    Duration? pongTimeout,
    Logger? logger,
    AutoRefreshConfig? autoRefreshConfig,
    Future<String?> Function()? onTokenRefresh,
    bool? useV2Protocol,
    Duration? v2BatchInterval,
    int? v2MaxBatchSize,
    String? v2Language,
  }) {
    return SocketConfig(
      url: url ?? this.url,
      sampleInterval: sampleInterval ?? this.sampleInterval,
      maxParsePerSample: maxParsePerSample ?? this.maxParsePerSample,
      maxPendingQueueSize: maxPendingQueueSize ?? this.maxPendingQueueSize,
      pendingExpiration: pendingExpiration ?? this.pendingExpiration,
      reconnectDelay: reconnectDelay ?? this.reconnectDelay,
      maxReconnectAttempts: maxReconnectAttempts ?? this.maxReconnectAttempts,
      autoReconnect: autoReconnect ?? this.autoReconnect,
      enableMetrics: enableMetrics ?? this.enableMetrics,
      metricsInterval: metricsInterval ?? this.metricsInterval,
      pingInterval: pingInterval ?? this.pingInterval,
      pongTimeout: pongTimeout ?? this.pongTimeout,
      logger: logger ?? this.logger,
      autoRefreshConfig: autoRefreshConfig ?? this.autoRefreshConfig,
      onTokenRefresh: onTokenRefresh ?? this.onTokenRefresh,
      useV2Protocol: useV2Protocol ?? this.useV2Protocol,
      v2BatchInterval: v2BatchInterval ?? this.v2BatchInterval,
      v2MaxBatchSize: v2MaxBatchSize ?? this.v2MaxBatchSize,
      v2Language: v2Language ?? this.v2Language,
    );
  }

  @override
  String toString() {
    return 'SocketConfig(url: $url, sampleInterval: ${sampleInterval.inMilliseconds}ms, '
        'maxParsePerSample: $maxParsePerSample, autoReconnect: $autoReconnect, '
        'useV2Protocol: $useV2Protocol)';
  }
}
