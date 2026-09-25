import 'dart:typed_data';

import '../client/v2_subscription_helper.dart';
import '../utils/logger.dart';

sealed class ChannelKey {
  const ChannelKey();

  String channel(String lang);
}

final class LeagueListKey extends ChannelKey {
  final int sportId;
  const LeagueListKey(this.sportId);

  @override
  String channel(String lang) =>
      V2SubscriptionHelper.leagueChannel(sportId, lang: lang);

  @override
  bool operator ==(Object other) =>
      other is LeagueListKey && other.sportId == sportId;

  @override
  int get hashCode => Object.hash(LeagueListKey, sportId);

  @override
  String toString() => 'LeagueListKey(sport=$sportId)';
}

final class MatchListKey extends ChannelKey {
  final int sportId;
  final int timeRange;

  final int? sportTypeId;

  MatchListKey(this.sportId, this.timeRange, {this.sportTypeId}) {
    if (sportTypeId != null && timeRange == V2TimeRange.live) {
      throw ArgumentError(
        'Combat sport (sportTypeId=$sportTypeId) does not support LIVE '
        'time range — only TODAY/EARLY.',
      );
    }
  }

  @override
  String channel(String lang) => V2SubscriptionHelper.matchChannel(
        sportId,
        timeRange,
        lang: lang,
        sportTypeId: sportTypeId,
      );

  @override
  bool operator ==(Object other) =>
      other is MatchListKey &&
      other.sportId == sportId &&
      other.timeRange == timeRange &&
      other.sportTypeId == sportTypeId;

  @override
  int get hashCode => Object.hash(MatchListKey, sportId, timeRange, sportTypeId);

  @override
  String toString() =>
      'MatchListKey(sport=$sportId, tr=$timeRange, st=$sportTypeId)';
}

final class MatchDetailKey extends ChannelKey {
  final int eventId;
  const MatchDetailKey(this.eventId);

  @override
  String channel(String lang) =>
      V2SubscriptionHelper.matchDetailChannel(eventId, lang: lang);

  @override
  bool operator ==(Object other) =>
      other is MatchDetailKey && other.eventId == eventId;

  @override
  int get hashCode => Object.hash(MatchDetailKey, eventId);

  @override
  String toString() => 'MatchDetailKey(event=$eventId)';
}

final class HotMatchKey extends ChannelKey {
  final int sportId;

  final int? timeRange;

  const HotMatchKey(this.sportId, {this.timeRange});

  @override
  String channel(String lang) =>
      V2SubscriptionHelper.hotChannel(sportId, lang: lang, timeRange: timeRange);

  @override
  bool operator ==(Object other) =>
      other is HotMatchKey &&
      other.sportId == sportId &&
      other.timeRange == timeRange;

  @override
  int get hashCode => Object.hash(HotMatchKey, sportId, timeRange);

  @override
  String toString() => 'HotMatchKey(sport=$sportId, tr=$timeRange)';
}

final class LeagueEventsKey extends ChannelKey {
  const LeagueEventsKey(this.leagueId, this.timeRange);

  final int leagueId;
  final int timeRange;

  @override
  String channel(String lang) =>
      V2SubscriptionHelper.leagueEventsChannel(leagueId, timeRange, lang: lang);

  @override
  bool operator ==(Object other) =>
      other is LeagueEventsKey &&
      other.leagueId == leagueId &&
      other.timeRange == timeRange;

  @override
  int get hashCode => Object.hash(LeagueEventsKey, leagueId, timeRange);

  @override
  String toString() => 'LeagueEventsKey(league=$leagueId, tr=$timeRange)';
}

class SubscriptionRegistry {
  SubscriptionRegistry({
    required void Function(Uint8List bytes) send,
    String language = V2SubscriptionHelper.defaultLanguage,
    Logger logger = const NoOpLogger(),
  })  : _send = send,
        _language = language,
        _log = logger;

  final void Function(Uint8List bytes) _send;
  final Logger _log;

  String _language;
  String get language => _language;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  final Map<ChannelKey, Set<String>> _sources = {};

  static String _leagueSourceFor(MatchListKey key, String source) =>
      '$source::ml:${key.sportId}:${key.timeRange}:${key.sportTypeId ?? '-'}';

  void subscribe(ChannelKey key, {required String source}) {
    _subscribeInternal(key, source: source);

    if (key is MatchListKey) {
      _subscribeInternal(
        LeagueListKey(key.sportId),
        source: _leagueSourceFor(key, source),
      );
    }
  }

  void unsubscribe(ChannelKey key, {required String source}) {
    _unsubscribeInternal(key, source: source);

    if (key is MatchListKey) {
      _unsubscribeInternal(
        LeagueListKey(key.sportId),
        source: _leagueSourceFor(key, source),
      );
    }
  }

  void onConnected() {
    _isConnected = true;
    replayAll();
  }

  void onDisconnected() {
    _isConnected = false;
    _log.debug('[Registry] disconnected — desired state kept '
        '(${_sources.length} channels)');
  }

  void replayAll() {
    if (!_isConnected) return;
    for (final key in _sources.keys) {
      _send(V2SubscriptionHelper.subscribeMessage(key.channel(_language)));
    }
    _log.info('[Registry] replayAll: ${_sources.length} channels');
  }

  void setLanguage(String newLanguage) {
    if (newLanguage == _language) return;
    final oldLanguage = _language;

    if (_isConnected) {
      for (final key in _sources.keys) {
        _send(
          V2SubscriptionHelper.unsubscribeMessage(key.channel(oldLanguage)),
        );
      }
    }
    _language = newLanguage;
    replayAll();
    _log.info('[Registry] language: $oldLanguage → $newLanguage');
  }

  Set<String> get activeChannels =>
      _sources.keys.map((k) => k.channel(_language)).toSet();

  Set<String> sourcesOf(ChannelKey key) =>
      Set.unmodifiable(_sources[key] ?? const <String>{});

  bool isSubscribed(ChannelKey key) => _sources.containsKey(key);

  int get channelCount => _sources.length;

  void clear() {
    if (_isConnected) {
      for (final key in _sources.keys) {
        _send(V2SubscriptionHelper.unsubscribeMessage(key.channel(_language)));
      }
    }
    _sources.clear();
    _log.info('[Registry] cleared');
  }

  void _subscribeInternal(ChannelKey key, {required String source}) {
    final sources = _sources.putIfAbsent(key, () => <String>{});
    final isFirst = sources.isEmpty;
    final added = sources.add(source);

    if (isFirst && _isConnected) {
      _send(V2SubscriptionHelper.subscribeMessage(key.channel(_language)));
      _log.debug('[Registry] SUB $key (source: $source)');
    } else if (added && !isFirst) {
      _log.debug('[Registry] +source $key (source: $source, '
          'total: ${sources.length})');
    }
  }

  void _unsubscribeInternal(ChannelKey key, {required String source}) {
    final sources = _sources[key];
    if (sources == null) return;

    sources.remove(source);
    if (sources.isEmpty) {
      _sources.remove(key);
      if (_isConnected) {
        _send(V2SubscriptionHelper.unsubscribeMessage(key.channel(_language)));
        _log.debug('[Registry] UNSUB $key (last source: $source)');
      }
    } else {
      _log.debug('[Registry] -source $key (remaining: ${sources.length})');
    }
  }
}
