import 'dart:async';

import 'models/league_data.dart';
import 'models/event_data.dart';
import 'models/market_data.dart';
import 'models/odds_data.dart';
import '../events/data_change_event.dart';
import '../proto/proto.dart';
import '../utils/perf_hooks.dart';

enum SortMode {
  defaultMode,

  startTimeMode,
}

class PruneStats {
  int removedEvents = 0;
  int removedMarkets = 0;
  int removedOdds = 0;

  int protectedEvents = 0;

  int hotOverlayEvents = 0;

  int betslipProtectedEvents = 0;

  bool get isEmpty =>
      removedEvents == 0 &&
      removedMarkets == 0 &&
      removedOdds == 0 &&
      protectedEvents == 0;

  @override
  String toString() =>
      'PruneStats(events: -$removedEvents, markets: -$removedMarkets, '
      'odds: -$removedOdds, protected: $protectedEvents, '
      'hotOverlay: $hotOverlayEvents, betslip: $betslipProtectedEvents)';
}

class SportDataStore {

  final Map<int, LeagueData> _leagues = {};

  final Map<int, EventData> _events = {};

  final Map<String, MarketData> _markets = {};

  final Map<String, OddsData> _odds = {};

  String? lastPopulateTimeRange;
  int? lastPopulateSportId;

  int populateGeneration = 0;

  final Map<int, Set<int>> _sportToLeagues = {};

  final Map<int, Set<int>> _leagueToEvents = {};

  final Map<int, Set<int>> _hotEventIdsBySport = {};

  final Map<int, List<int>> _hotOrderBySport = {};

  final Map<int, Set<int>> _listEventIdsBySport = {};

  final Map<int, Set<String>> _eventToMarkets = {};

  final Map<String, Set<String>> _marketToOdds = {};

  bool Function(int eventId)? pruneProtection;

  bool isPruneProtected(int eventId) => pruneProtection?.call(eventId) ?? false;

  final StreamController<DataChangeEvent> _changeController =
      StreamController<DataChangeEvent>.broadcast();

  Stream<DataChangeEvent> get onChanged => _changeController.stream;

  final Set<int> _batchUpdatedLeagueIds = {};
  final Set<int> _batchUpdatedEventIds = {};
  final Set<String> _batchUpdatedMarketKeys = {};
  final Set<String> _batchUpdatedOddsKeys = {};
  final List<int> _batchAddedLeagueIds = [];
  final List<int> _batchAddedEventIds = [];
  final List<String> _batchAddedMarketKeys = [];
  final List<String> _batchAddedOddsKeys = [];
  final List<int> _batchRemovedLeagueIds = [];
  final List<int> _batchRemovedEventIds = [];
  final List<String> _batchRemovedMarketKeys = [];
  final List<String> _batchRemovedOddsKeys = [];

  LeagueData? getLeague(int leagueId) => _leagues[leagueId];

  EventData? getEvent(int eventId) => _events[eventId];

  MarketData? getMarket(int eventId, int marketId) =>
      _markets['${eventId}_$marketId'];

  OddsData? getOdds(int eventId, int marketId, String offerId) =>
      _odds['${eventId}_${marketId}_$offerId'];

  List<LeagueData> getLeaguesBySport(int sportId) {
    final leagueIds = _sportToLeagues[sportId];
    if (leagueIds == null) return const [];

    return leagueIds.map((id) => _leagues[id]).whereType<LeagueData>().toList();
  }

  List<EventData> getEventsByLeague(int leagueId) {
    final eventIds = _leagueToEvents[leagueId];
    if (eventIds == null) return const [];

    return eventIds.map((id) => _events[id]).whereType<EventData>().toList();
  }

  void markEventHot(int eventId, int sportId) {
    final event = _events[eventId];
    if (event == null) return;

    final set = _hotEventIdsBySport.putIfAbsent(sportId, () => <int>{});
    final isNew = set.add(eventId);

    if (!event.isHot || isNew) {
      event.isHot = true;
      _batchUpdatedEventIds.add(eventId);
    }
  }

  void reconcileHotSnapshot(int sportId, Set<int> newHotEventIds) {
    final current = _hotEventIdsBySport[sportId];
    if (current == null || current.isEmpty) return;

    final staleIds = current.difference(newHotEventIds);
    if (staleIds.isEmpty) return;

    for (final id in staleIds) {
      current.remove(id);
      _hotOrderBySport[sportId]?.remove(id);
      final event = _events[id];
      if (event != null && event.isHot) {
        event.isHot = false;
        _batchUpdatedEventIds.add(id);
      }
    }

    if (current.isEmpty) {
      _hotEventIdsBySport.remove(sportId);
      _hotOrderBySport.remove(sportId);
    }
  }

  void setHotSnapshotOrder(int sportId, List<int> orderedIds) {
    if (orderedIds.isEmpty) {
      _hotOrderBySport.remove(sportId);
      return;
    }
    final old = _hotOrderBySport[sportId];
    if (old != null && _intListEquals(old, orderedIds)) return;
    _hotOrderBySport[sportId] = List.of(orderedIds);
    _batchUpdatedEventIds.addAll(orderedIds);
  }

  List<int> getHotOrderBySport(int sportId) =>
      List.unmodifiable(_hotOrderBySport[sportId] ?? const <int>[]);

  static bool _intListEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  List<EventData> getHotEventsBySport(int sportId) {
    final ids = _hotEventIdsBySport[sportId];
    if (ids == null || ids.isEmpty) return const [];

    final order = _hotOrderBySport[sportId];
    if (order == null || order.isEmpty) {
      return ids.map((id) => _events[id]).whereType<EventData>().toList();
    }

    final result = <EventData>[];
    final seen = <int>{};
    for (final id in order) {
      if (!ids.contains(id)) continue;
      final event = _events[id];
      if (event != null) {
        result.add(event);
        seen.add(id);
      }
    }
    for (final id in ids) {
      if (seen.contains(id)) continue;
      final event = _events[id];
      if (event != null) result.add(event);
    }
    return result;
  }

  void markListMember(int eventId, int sportId) {
    if (!_events.containsKey(eventId)) return;
    _listEventIdsBySport.putIfAbsent(sportId, () => <int>{}).add(eventId);
  }

  bool isListMember(int eventId, int sportId) =>
      _listEventIdsBySport[sportId]?.contains(eventId) ?? false;

  List<MarketData> getMarketsByEvent(int eventId) {
    final marketKeys = _eventToMarkets[eventId];
    if (marketKeys == null) return const [];

    return marketKeys
        .map((key) => _markets[key])
        .whereType<MarketData>()
        .toList();
  }

  List<OddsData> getOddsByMarket(int eventId, int marketId) {
    final marketKey = '${eventId}_$marketId';
    final oddsKeys = _marketToOdds[marketKey];
    if (oddsKeys == null) return const [];

    return oddsKeys.map((key) => _odds[key]).whereType<OddsData>().toList();
  }

  bool hasLeague(int leagueId) => _leagues.containsKey(leagueId);

  bool hasEvent(int eventId) => _events.containsKey(eventId);

  bool hasMarket(int eventId, int marketId) =>
      _markets.containsKey('${eventId}_$marketId');

  bool hasOdds(int eventId, int marketId, String offerId) =>
      _odds.containsKey('${eventId}_${marketId}_$offerId');

  int get leagueCount => _leagues.length;

  int get eventCount => _events.length;

  int get marketCount => _markets.length;

  int get oddsCount => _odds.length;

  Iterable<int> get allEventIds => _events.keys;

  Iterable<int> get allLeagueIds => _leagues.keys;

  void insertLeague(LeagueData league) {
    _leagues[league.leagueId] = league;

    _sportToLeagues.putIfAbsent(league.sportId, () => {}).add(league.leagueId);

    _leagueToEvents.putIfAbsent(league.leagueId, () => {});

    _batchAddedLeagueIds.add(league.leagueId);
  }

  void updateLeague(LeagueData league) {
    final existing = _leagues[league.leagueId];
    if (existing != null) {
      existing.updateFrom({
        'leagueName': league.name,
        'lpo': league.priorityOrder,
        'lg': league.logoUrl,
        'cashout': league.cashout,
      });
      _batchUpdatedLeagueIds.add(league.leagueId);
    } else {
      insertLeague(league);
    }
  }

  void upsertLeagueFromJson(Map<String, dynamic> data) {
    final leagueId = _parseInt(data['leagueId'] ?? data['li']);
    if (leagueId == null) return;

    final existing = _leagues[leagueId];
    if (existing != null) {
      existing.updateFrom(data);
      _batchUpdatedLeagueIds.add(leagueId);
    } else {
      final league = LeagueData.fromJson(data);
      insertLeague(league);
    }
  }

  void insertEvent(EventData event) {
    _events[event.eventId] = event;

    _leagueToEvents.putIfAbsent(event.leagueId, () => {}).add(event.eventId);

    _eventToMarkets.putIfAbsent(event.eventId, () => {});

    _batchAddedEventIds.add(event.eventId);
  }

  void updateEventFromJson(int eventId, Map<String, dynamic> data) {
    final existing = _events[eventId];
    if (existing != null) {
      existing.updateFrom(data);
      _batchUpdatedEventIds.add(eventId);
    }
  }

  void upsertEventFromJson(Map<String, dynamic> data) {
    final eventId = _parseInt(data['eventId'] ?? data['ei']);
    if (eventId == null) return;

    final existing = _events[eventId];
    if (existing != null) {
      existing.updateFrom(data);
      _batchUpdatedEventIds.add(eventId);
    } else {
      final event = EventData.fromJson(data);
      insertEvent(event);
    }
  }

  void removeEvent(int eventId) {
    final event = _events.remove(eventId);
    if (event == null) return;

    _leagueToEvents[event.leagueId]?.remove(eventId);

    final hotSet = _hotEventIdsBySport[event.sportId];
    if (hotSet != null) {
      hotSet.remove(eventId);
      if (hotSet.isEmpty) _hotEventIdsBySport.remove(event.sportId);
    }
    final hotOrder = _hotOrderBySport[event.sportId];
    if (hotOrder != null) {
      hotOrder.remove(eventId);
      if (hotOrder.isEmpty) _hotOrderBySport.remove(event.sportId);
    }

    final memberSet = _listEventIdsBySport[event.sportId];
    if (memberSet != null) {
      memberSet.remove(eventId);
      if (memberSet.isEmpty) _listEventIdsBySport.remove(event.sportId);
    }

    final marketKeys = _eventToMarkets.remove(eventId);
    if (marketKeys != null) {
      for (final marketKey in marketKeys) {
        _markets.remove(marketKey);
        _batchRemovedMarketKeys.add(marketKey);

        final oddsKeys = _marketToOdds.remove(marketKey);
        if (oddsKeys != null) {
          for (final oddsKey in oddsKeys) {
            _odds.remove(oddsKey);
            _batchRemovedOddsKeys.add(oddsKey);
          }
        }
      }
    }

    _batchRemovedEventIds.add(eventId);

  }

  void removeLeague(int leagueId) {
    final league = _leagues.remove(leagueId);
    if (league == null) return;

    _sportToLeagues[league.sportId]?.remove(leagueId);

    _leagueToEvents.remove(leagueId);

    _batchRemovedLeagueIds.add(leagueId);
  }

  void removeMarket(int eventId, int marketId) {
    final marketKey = '${eventId}_$marketId';
    if (_markets.remove(marketKey) == null) return;

    _eventToMarkets[eventId]?.remove(marketKey);
    _batchRemovedMarketKeys.add(marketKey);

    final oddsKeys = _marketToOdds.remove(marketKey);
    if (oddsKeys != null) {
      for (final oddsKey in oddsKeys) {
        _odds.remove(oddsKey);
        _batchRemovedOddsKeys.add(oddsKey);
      }
    }
  }

  void removeOdds(int eventId, int marketId, String offerId) {
    final oddsKey = '${eventId}_${marketId}_$offerId';
    if (_odds.remove(oddsKey) == null) return;

    final marketKey = '${eventId}_$marketId';
    _marketToOdds[marketKey]?.remove(oddsKey);
    _batchRemovedOddsKeys.add(oddsKey);
  }

  void pruneEventToSnapshot({
    required int eventId,
    required List<int> validMarketIds,
    required Map<int, List<String>> validOfferIdsByMarket,
  }) {
    final validMarketIdSet = validMarketIds.toSet();

    final marketKeys = (_eventToMarkets[eventId] ?? const <String>{}).toList();

    for (final marketKey in marketKeys) {
      final marketId = _markets[marketKey]?.marketId;
      if (marketId == null) continue;

      if (!validMarketIdSet.contains(marketId)) {
        removeMarket(eventId, marketId);
        continue;
      }

      final validOffers =
          (validOfferIdsByMarket[marketId] ?? const <String>[]).toSet();
      final oddsKeys = (_marketToOdds[marketKey] ?? const <String>{}).toList();
      for (final oddsKey in oddsKeys) {
        final offerId = _odds[oddsKey]?.offerId;
        if (offerId != null && !validOffers.contains(offerId)) {
          removeOdds(eventId, marketId, offerId);
        }
      }
    }

    final orderedMarketKeys = <String>{};
    for (final marketId in validMarketIds) {
      final marketKey = '${eventId}_$marketId';
      if (_markets.containsKey(marketKey)) orderedMarketKeys.add(marketKey);
    }
    if (orderedMarketKeys.isNotEmpty || _eventToMarkets.containsKey(eventId)) {
      _eventToMarkets[eventId] = orderedMarketKeys;
    }
    for (final marketId in validMarketIds) {
      final marketKey = '${eventId}_$marketId';
      if (!_markets.containsKey(marketKey)) continue;
      final orderedOddsKeys = <String>{};
      for (final offerId
          in validOfferIdsByMarket[marketId] ?? const <String>[]) {
        final oddsKey = '${marketKey}_$offerId';
        if (_odds.containsKey(oddsKey)) orderedOddsKeys.add(oddsKey);
      }
      _marketToOdds[marketKey] = orderedOddsKeys;
    }
  }

  PruneStats pruneSportToSnapshot({
    required int sportId,
    required Set<int> validEventIds,
    required Map<int, Set<int>> validMarketIdsByEvent,
    required Map<String, Set<String>> validOfferIdsByMarket,
    int protectSocketTouchAfterMs = 0,
    Set<int>? onlyLeagueIds,
  }) {
    final stats = PruneStats();
    final scoped = onlyLeagueIds != null;

    final newMembers = <int>{...validEventIds};

    final scopedMembershipDrops = <int>{};

    final leagueIds = scoped
        ? onlyLeagueIds
            .where(
              (id) => (_sportToLeagues[sportId] ?? const <int>{}).contains(id),
            )
            .toList()
        : (_sportToLeagues[sportId] ?? const <int>{}).toList();

    for (final leagueId in leagueIds) {
      _pruneLeagueForSnapshot(
        leagueId,
        sportId: sportId,
        validEventIds: validEventIds,
        validMarketIdsByEvent: validMarketIdsByEvent,
        validOfferIdsByMarket: validOfferIdsByMarket,
        protectSocketTouchAfterMs: protectSocketTouchAfterMs,
        scoped: scoped,
        newMembers: newMembers,
        scopedMembershipDrops: scopedMembershipDrops,
        stats: stats,
      );
    }

    _commitSnapshotMembership(
      sportId: sportId,
      scoped: scoped,
      newMembers: newMembers,
      scopedMembershipDrops: scopedMembershipDrops,
    );

    return stats;
  }

  Future<PruneStats> pruneSportToSnapshotChunked({
    required int sportId,
    required Set<int> validEventIds,
    required Map<int, Set<int>> validMarketIdsByEvent,
    required Map<String, Set<String>> validOfferIdsByMarket,
    int protectSocketTouchAfterMs = 0,
    Set<int>? onlyLeagueIds,
    Duration sliceBudget = const Duration(milliseconds: 4),
    int yieldEvery = 8,
    bool Function()? shouldContinue,
  }) async {
    final stats = PruneStats();
    final scoped = onlyLeagueIds != null;
    final newMembers = <int>{...validEventIds};
    final scopedMembershipDrops = <int>{};

    final leagueIds = scoped
        ? onlyLeagueIds
            .where(
              (id) => (_sportToLeagues[sportId] ?? const <int>{}).contains(id),
            )
            .toList()
        : (_sportToLeagues[sportId] ?? const <int>{}).toList();

    final wrap = SportSocketPerfHooks.wrap;
    final slice = Stopwatch()..start();
    var sinceYield = 0;
    for (final leagueId in leagueIds) {
      void body() => _pruneLeagueForSnapshot(
            leagueId,
            sportId: sportId,
            validEventIds: validEventIds,
            validMarketIdsByEvent: validMarketIdsByEvent,
            validOfferIdsByMarket: validOfferIdsByMarket,
            protectSocketTouchAfterMs: protectSocketTouchAfterMs,
            scoped: scoped,
            newMembers: newMembers,
            scopedMembershipDrops: scopedMembershipDrops,
            stats: stats,
          );
      if (wrap == null) {
        body();
      } else {
        wrap<void>('populate.prune', body);
      }
      if (++sinceYield >= yieldEvery || slice.elapsed >= sliceBudget) {
        await Future<void>.delayed(Duration.zero);
        slice.reset();
        sinceYield = 0;
        if (shouldContinue != null && !shouldContinue()) return stats;
      }
    }

    if (protectSocketTouchAfterMs > 0) {
      final sweepLeagueIds = scoped
          ? onlyLeagueIds.where(
              (id) => (_sportToLeagues[sportId] ?? const <int>{}).contains(id),
            )
          : (_sportToLeagues[sportId] ?? const <int>{});
      for (final leagueId in sweepLeagueIds) {
        for (final eventId in _leagueToEvents[leagueId] ?? const <int>{}) {
          if (newMembers.contains(eventId)) continue;
          if (scoped && scopedMembershipDrops.contains(eventId)) continue;
          final ev = _events[eventId];
          if (ev == null ||
              ev.lastSocketTouchMs <= protectSocketTouchAfterMs ||
              !ev.canBet) {
            continue;
          }
          if (ev.isHot || isPruneProtected(eventId)) continue;
          stats.protectedEvents++;
          newMembers.add(eventId);
        }
      }
    }

    _commitSnapshotMembership(
      sportId: sportId,
      scoped: scoped,
      newMembers: newMembers,
      scopedMembershipDrops: scopedMembershipDrops,
    );

    return stats;
  }

  void _pruneLeagueForSnapshot(
    int leagueId, {
    required int sportId,
    required Set<int> validEventIds,
    required Map<int, Set<int>> validMarketIdsByEvent,
    required Map<String, Set<String>> validOfferIdsByMarket,
    required int protectSocketTouchAfterMs,
    required bool scoped,
    required Set<int> newMembers,
    required Set<int> scopedMembershipDrops,
    required PruneStats stats,
  }) {
    final eventIds = (_leagueToEvents[leagueId] ?? const <int>{}).toList();

    for (final eventId in eventIds) {
      if (scoped && !validEventIds.contains(eventId)) {
        scopedMembershipDrops.add(eventId);
      }
      if (!validEventIds.contains(eventId) &&
          (_events[eventId]?.isHot ?? false)) {
        stats.hotOverlayEvents++;
        continue;
      }

      if (!validEventIds.contains(eventId) && isPruneProtected(eventId)) {
        stats.betslipProtectedEvents++;
        continue;
      }

      if (!validEventIds.contains(eventId)) {
        if (protectSocketTouchAfterMs > 0) {
          final ev = _events[eventId];
          if (ev != null &&
              ev.lastSocketTouchMs > protectSocketTouchAfterMs &&
              ev.canBet) {
            stats.protectedEvents++;
            newMembers.add(eventId);
            continue;
          }
        }
        removeEvent(eventId);
        stats.removedEvents++;
        continue;
      }

      if (isPruneProtected(eventId)) {
        continue;
      }

      final validMarketIds = validMarketIdsByEvent[eventId] ?? const <int>{};
      final marketKeys =
          (_eventToMarkets[eventId] ?? const <String>{}).toList();

      for (final marketKey in marketKeys) {
        final marketId = _markets[marketKey]?.marketId;
        if (marketId == null) continue;

        if (!validMarketIds.contains(marketId)) {
          continue;
        }

        final validOffers =
            validOfferIdsByMarket[marketKey] ?? const <String>{};
        final oddsKeys =
            (_marketToOdds[marketKey] ?? const <String>{}).toList();
        for (final oddsKey in oddsKeys) {
          final offerId = oddsKey.substring('${eventId}_${marketId}_'.length);
          if (!validOffers.contains(offerId) &&
              (_odds[oddsKey]?.isMainLine ?? false)) {
            removeOdds(eventId, marketId, offerId);
            stats.removedOdds++;
          }
        }
      }
    }
  }

  void _commitSnapshotMembership({
    required int sportId,
    required bool scoped,
    required Set<int> newMembers,
    required Set<int> scopedMembershipDrops,
  }) {
    final Set<int> committed;
    if (scoped) {
      committed = <int>{...?_listEventIdsBySport[sportId]}
        ..removeAll(scopedMembershipDrops)
        ..addAll(newMembers);
    } else {
      committed = newMembers;
    }
    if (committed.isEmpty) {
      _listEventIdsBySport.remove(sportId);
    } else {
      _listEventIdsBySport[sportId] = committed;
    }
  }

  void upsertMarketFromJson(int eventId, Map<String, dynamic> data) {
    final marketId =
        _parseInt(data['marketId'] ?? data['domainMarketId'] ?? data['mi']);
    if (marketId == null) return;

    final marketKey = '${eventId}_$marketId';
    var market = _markets[marketKey];

    if (market != null) {
      market.updateFrom(data);
      _batchUpdatedMarketKeys.add(marketKey);
    } else {
      market = MarketData.fromJson(data, eventId: eventId);
      _markets[marketKey] = market;

      _eventToMarkets.putIfAbsent(eventId, () => {}).add(marketKey);
      _marketToOdds.putIfAbsent(marketKey, () => {});

      _batchAddedMarketKeys.add(marketKey);
    }
  }

  void upsertOddsFromJson(
    int eventId,
    int marketId,
    Map<String, dynamic> data, {
    String timeRange = 'LIVE',
  }) {
    final offerId = data['strOfferId']?.toString() ??
        data['offerId']?.toString() ??
        '${eventId}_${marketId}_${DateTime.now().microsecondsSinceEpoch}';

    final oddsKey = '${eventId}_${marketId}_$offerId';
    final marketKey = '${eventId}_$marketId';

    var odds = _odds[oddsKey];

    if (odds != null) {
      odds.updateFrom(data);
      _batchUpdatedOddsKeys.add(oddsKey);
    } else {
      odds = OddsData.fromJson(
        data,
        eventId: eventId,
        marketId: marketId,
        timeRange: timeRange,
      );
      _odds[oddsKey] = odds;

      _marketToOdds.putIfAbsent(marketKey, () => {}).add(oddsKey);

      _batchAddedOddsKeys.add(oddsKey);
    }
  }

  void upsertLeagueFromProto(LeagueResponse proto, {int? timeRange}) {
    final leagueId = proto.leagueId;
    final existing = _leagues[leagueId];

    if (existing != null) {
      existing.updateFrom({
        'leagueName': proto.leagueName,
        'leagueNameEn': proto.leagueNameEn,
        'leagueLogo': proto.leagueLogo,
        if (proto.hasLeagueOrder()) 'leagueOrder': proto.leagueOrder,
        'lpo': proto.leaguePriorityOrder,
        'cashout': proto.isCashOut,
        'isParlay': proto.isParlay,
        'isPin': proto.isPin,
      });
      _batchUpdatedLeagueIds.add(leagueId);
    } else {
      final league = LeagueData.fromJson({
        'leagueId': leagueId,
        'sportId': proto.sportId,
        'leagueName': proto.leagueName,
        'leagueNameEn': proto.leagueNameEn,
        'leagueLogo': proto.leagueLogo,
        if (proto.hasLeagueOrder()) 'leagueOrder': proto.leagueOrder,
        'lpo': proto.leaguePriorityOrder,
        'cashout': proto.isCashOut,
        'isParlay': proto.isParlay,
        'type': proto.type,
        'sportType': proto.sportType,
        'sportTypeId': proto.sportTypeId,
      });
      insertLeague(league);
    }
  }

  void updateLeagueFromProto(LeagueResponse proto) {
    final existing = _leagues[proto.leagueId];
    if (existing != null) {
      existing.updateFrom({
        'leagueName': proto.leagueName,
        'leagueNameEn': proto.leagueNameEn,
        'leagueLogo': proto.leagueLogo,
        if (proto.hasLeagueOrder()) 'leagueOrder': proto.leagueOrder,
        'lpo': proto.leaguePriorityOrder,
        'cashout': proto.isCashOut,
      });
      _batchUpdatedLeagueIds.add(proto.leagueId);
    }
  }

  void ensureLeague({
    required int leagueId,
    required String leagueName,
    required int leagueOrder,
    required int leaguePriorityOrder,
    required String leagueLogo,
    int sportId = 0,
  }) {
    if (!_leagues.containsKey(leagueId)) {
      final league = LeagueData.fromJson({
        'leagueId': leagueId,
        'sportId': sportId,
        'leagueName': leagueName,
        'leagueLogo': leagueLogo,
        'leagueOrder': leagueOrder,
        'lpo': leaguePriorityOrder,
      });
      insertLeague(league);
    }
  }

  void upsertEventFromProto(EventResponse proto) {
    final eventId = proto.eventId.toInt();
    final existing = _events[eventId];
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    if (existing != null) {
      final previousHomeScore = existing.homeScore;
      final previousAwayScore = existing.awayScore;

      _updateEventFromProto(existing, proto);

      existing.previousHomeScore = previousHomeScore;
      existing.previousAwayScore = previousAwayScore;
      existing.lastSocketTouchMs = nowMs;

      _batchUpdatedEventIds.add(eventId);
    } else {
      final event = _createEventFromProto(proto);
      event.lastSocketTouchMs = nowMs;
      insertEvent(event);
    }
  }

  EventData _createEventFromProto(EventResponse proto) {
    return EventData.fromJson({
      'eventId': proto.eventId.toInt(),
      'leagueId': proto.leagueId,
      'sportId': proto.sportId,
      'homeName': proto.homeName,
      'awayName': proto.awayName,
      'homeId': proto.homeId,
      'awayId': proto.awayId,
      'hf': proto.homeLogo,
      'af': proto.awayLogo,
      'startDate': proto.startDate.isNotEmpty
          ? proto.startDate
          : proto.startTime.toInt(),
      'startTime': proto.startTime.toInt(),
      'isSuspended': proto.isSuspended,
      'isHidden': proto.isHidden,
      'isParlay': proto.isParlay,
      ..._eventFlags(proto),
      'isLive': proto.isLive,
      'isGoingLive': proto.isGoingLive,
      'isHot': proto.isHot,
      'isLiveStream': proto.isLiveStream,
      'pinType': proto.pinType,
      'gamePart': proto.gamePart,
      'gameTime': proto.gameTime,
      'stoppageTime': proto.stoppageTime,
      'totalMarketsCount': proto.marketCount,
      'eventStatsId': proto.eventStatsId.toInt(),
      'sportTypeId': proto.sportTypeId,
      'sportTypeName': proto.sportTypeName,
      'specialSituation': proto.specialSituation,
    });
  }

  void _updateEventFromProto(EventData event, EventResponse proto) {
    event.updateFrom({
      'homeName': proto.homeName,
      'awayName': proto.awayName,
      if (proto.homeLogo.isNotEmpty) 'hf': proto.homeLogo,
      if (proto.awayLogo.isNotEmpty) 'af': proto.awayLogo,
      if (proto.startDate.isNotEmpty)
        'startDate': proto.startDate
      else if (proto.startTime.toInt() > 0)
        'startDate': proto.startTime.toInt(),
      'isSuspended': proto.isSuspended,
      'isHidden': proto.isHidden,
      'isLive': proto.isLive,
      'isGoingLive': proto.isGoingLive,
      'isHot': proto.isHot,
      'isLiveStream': proto.isLiveStream,
      'gamePart': proto.gamePart,
      'gameTime': proto.gameTime,
      'stoppageTime': proto.stoppageTime,
      if (proto.hasMarketCount()) 'totalMarketsCount': proto.marketCount,
      ..._eventFlags(proto),
    });

    if (proto.hasLiveScore()) {
      _updateEventScoreFromProto(event, proto.liveScore);
    }
  }

  void _updateEventScoreFromProto(EventData event, ScoreResponse score) {
    if (score.hasSoccer()) {
      final s = score.soccer;
      if (s.hasHomeScore()) event.homeScore = s.homeScore;
      if (s.hasAwayScore()) event.awayScore = s.awayScore;
      if (s.hasHomeCorner()) event.cornersHome = s.homeCorner;
      if (s.hasAwayCorner()) event.cornersAway = s.awayCorner;
      if (s.hasYellowCardsHome()) event.yellowCardsHome = s.yellowCardsHome;
      if (s.hasYellowCardsAway()) event.yellowCardsAway = s.yellowCardsAway;
      if (s.hasRedCardsHome()) event.redCardsHome = s.redCardsHome;
      if (s.hasRedCardsAway()) event.redCardsAway = s.redCardsAway;
      if (s.hasHomeScoreOT()) event.homeScoreOT = s.homeScoreOT;
      if (s.hasAwayScoreOT()) event.awayScoreOT = s.awayScoreOT;
      event.trackRegulationBaseline();
    } else if (score.hasBasketball()) {
      final s = score.basketball;
      if (s.hasHomeScoreFT()) event.homeScore = s.homeScoreFT;
      if (s.hasAwayScoreFT()) event.awayScore = s.awayScoreFT;
      _applyLiveScores(event, s.liveScores);
    } else if (score.hasVolleyball()) {
      final s = score.volleyball;
      if (s.hasHomeSetScore()) event.homeScore = s.homeSetScore;
      if (s.hasAwaySetScore()) event.awayScore = s.awaySetScore;
      if (s.hasCurrentSet()) event.currentSet = s.currentSet;
      _applyLiveScores(event, s.liveScores);
      if (s.hasHomeTotalPoint()) event.homeTotalPoint = s.homeTotalPoint;
      if (s.hasAwayTotalPoint()) event.awayTotalPoint = s.awayTotalPoint;
    } else if (score.hasTennis()) {
      final s = score.tennis;
      if (s.hasHomeSetScore()) event.homeScore = s.homeSetScore;
      if (s.hasAwaySetScore()) event.awayScore = s.awaySetScore;
      if (s.hasCurrentSet()) event.currentSet = s.currentSet;
      _applyLiveScores(event, s.liveScores);
      if (s.hasHomeCurrentPoint()) event.homeCurrentPoint = s.homeCurrentPoint;
      if (s.hasAwayCurrentPoint()) event.awayCurrentPoint = s.awayCurrentPoint;
    } else if (score.hasTableTennis()) {
      final s = score.tableTennis;
      if (s.hasHomeSetScore()) event.homeScore = s.homeSetScore;
      if (s.hasAwaySetScore()) event.awayScore = s.awaySetScore;
      if (s.hasCurrentSet()) event.currentSet = s.currentSet;
      _applyLiveScores(event, s.liveScores);
      if (s.hasHomeTotalPoint()) event.homeTotalPoint = s.homeTotalPoint;
      if (s.hasAwayTotalPoint()) event.awayTotalPoint = s.awayTotalPoint;
    } else if (score.hasBadminton()) {
      final s = score.badminton;
      if (s.hasHomeSetScore()) event.homeScore = s.homeSetScore;
      if (s.hasAwaySetScore()) event.awayScore = s.awaySetScore;
      if (s.hasCurrentSet()) event.currentSet = s.currentSet;
      _applyLiveScores(event, s.liveScores);
      if (s.hasHomeTotalPoint()) event.homeTotalPoint = s.homeTotalPoint;
      if (s.hasAwayTotalPoint()) event.awayTotalPoint = s.awayTotalPoint;
    }
  }

  static void _applyLiveScores(EventData event, List<LiveScore> liveScores) {
    if (liveScores.isEmpty) return;
    event.liveScores = [
      for (final ls in liveScores) (ls.homeScore, ls.awayScore),
    ];
  }

  void mergeLiveStatusFromProto(EventResponse proto) {
    final eventId = proto.eventId.toInt();
    final event = _events[eventId];
    if (event == null) return;

    final previousHomeScore = event.homeScore;
    final previousAwayScore = event.awayScore;

    final partChanged = proto.hasGamePart() && proto.gamePart != event.gamePart;

    event.updateFrom({
      if (proto.hasIsSuspended()) 'isSuspended': proto.isSuspended,
      if (proto.hasIsHidden()) 'isHidden': proto.isHidden,
      if (proto.hasIsLive()) 'isLive': proto.isLive,
      if (proto.hasIsGoingLive()) 'isGoingLive': proto.isGoingLive,
      if (proto.hasIsLiveStream()) 'isLiveStream': proto.isLiveStream,
      if (proto.hasGamePart()) 'gamePart': proto.gamePart,
      if (proto.hasGameTime())
        'gameTime': proto.gameTime
      else if (partChanged)
        'gameTime': 0,
      if (proto.hasStoppageTime())
        'stoppageTime': proto.stoppageTime
      else if (partChanged)
        'stoppageTime': 0,
    });

    if (proto.hasLiveScore()) {
      _updateEventScoreFromProto(event, proto.liveScore);
      event.previousHomeScore = previousHomeScore;
      event.previousAwayScore = previousAwayScore;
    }

    event.lastSocketTouchMs = DateTime.now().millisecondsSinceEpoch;
    _batchUpdatedEventIds.add(eventId);
  }

  void upsertMarketFromProto(int eventId, MarketResponse proto) {
    final marketId = proto.marketId;
    final marketKey = '${eventId}_$marketId';
    var market = _markets[marketKey];

    if (market != null) {
      market.updateFrom({
        'isSuspended': proto.isSuspended,
        ..._marketFlags(proto),
      });
      _batchUpdatedMarketKeys.add(marketKey);
    } else {
      market = MarketData.fromJson({
        'marketId': marketId,
        'eventId': eventId,
        'sportId': proto.sportId,
        'leagueId': proto.leagueId,
        'isSuspended': proto.isSuspended,
        ..._marketFlags(proto),
      }, eventId: eventId);
      _markets[marketKey] = market;

      _eventToMarkets.putIfAbsent(eventId, () => {}).add(marketKey);
      _marketToOdds.putIfAbsent(marketKey, () => {});

      _batchAddedMarketKeys.add(marketKey);
    }
  }

  void upsertOddsFromProto(int eventId, int marketId, OddsResponse proto) {
    final offerId = proto.strOfferId.isNotEmpty
        ? proto.strOfferId
        : '${eventId}_${marketId}_${DateTime.now().microsecondsSinceEpoch}';

    final oddsKey = '${eventId}_${marketId}_$offerId';
    final marketKey = '${eventId}_$marketId';

    var odds = _odds[oddsKey];

    if (odds != null) {
      final previousHome = odds.oddsHome;
      final previousAway = odds.oddsAway;
      final previousDraw = odds.oddsDraw;

      _updateOddsFromProto(odds, proto);

      odds.previousHome = previousHome;
      odds.previousAway = previousAway;
      odds.previousDraw = previousDraw;

      _batchUpdatedOddsKeys.add(oddsKey);
    } else {
      odds = _createOddsFromProto(eventId, marketId, proto, offerId);
      _odds[oddsKey] = odds;

      _marketToOdds.putIfAbsent(marketKey, () => {}).add(oddsKey);

      _batchAddedOddsKeys.add(oddsKey);
    }
  }

  OddsData _createOddsFromProto(
    int eventId,
    int marketId,
    OddsResponse proto,
    String offerId,
  ) {
    return OddsData.fromJson({
      'eventId': eventId,
      'marketId': marketId,
      'strOfferId': offerId,
      'selectionIdHome': proto.selectionHomeId,
      'selectionIdAway': proto.selectionAwayId,
      'selectionIdDraw': proto.selectionDrawId,
      'points': proto.points,
      'oddsHome': _parseOddsDecimal(proto.oddsHome),
      'oddsAway': _parseOddsDecimal(proto.oddsAway),
      'oddsDraw': _parseOddsDecimal(proto.oddsDraw),
      'malayHome': proto.oddsHome.malay,
      'malayAway': proto.oddsAway.malay,
      'indoHome': proto.oddsHome.indo,
      'indoAway': proto.oddsAway.indo,
      'hkHome': proto.oddsHome.hk,
      'hkAway': proto.oddsAway.hk,
      ..._drawVariants(proto),
      ..._playerProps(proto),
      'isMainLine': proto.isMainLine,
      'isSuspended': proto.isSuspended,
      'isHidden': proto.isHidden,
    }, eventId: eventId, marketId: marketId, timeRange: 'LIVE');
  }

  void _updateOddsFromProto(OddsData odds, OddsResponse proto) {
    odds.updateFrom({
      'points': proto.points,
      'oddsHome': _parseOddsDecimal(proto.oddsHome),
      'oddsAway': _parseOddsDecimal(proto.oddsAway),
      'oddsDraw': _parseOddsDecimal(proto.oddsDraw),
      'malayHome': proto.oddsHome.malay,
      'malayAway': proto.oddsAway.malay,
      'indoHome': proto.oddsHome.indo,
      'indoAway': proto.oddsAway.indo,
      'hkHome': proto.oddsHome.hk,
      'hkAway': proto.oddsAway.hk,
      ..._drawVariants(proto),
      ..._playerProps(proto),
      'isMainLine': proto.isMainLine,
      'isSuspended': proto.isSuspended,
      'isHidden': proto.isHidden,
    });
  }

  Map<String, dynamic> _playerProps(OddsResponse proto) {
    final m = <String, dynamic>{};
    if (proto.hasPlayerName()) m['playerName'] = proto.playerName;
    if (proto.hasPlayerId()) m['playerId'] = proto.playerId;
    return m;
  }

  Map<String, dynamic> _drawVariants(OddsResponse proto) {
    if (!proto.hasOddsDraw()) return const {};
    return {
      'malayDraw': proto.oddsDraw.malay,
      'indoDraw': proto.oddsDraw.indo,
      'hkDraw': proto.oddsDraw.hk,
    };
  }

  Map<String, dynamic> _marketFlags(MarketResponse proto) {
    return {
      if (proto.hasIsParlay()) 'isParlay': proto.isParlay,
      if (proto.hasIsCashOut()) 'isCashOut': proto.isCashOut,
      if (proto.hasPromotionType()) 'promotionType': proto.promotionType,
      if (proto.hasGroupId()) 'groupId': proto.groupId,
    };
  }

  Map<String, dynamic> _eventFlags(EventResponse proto) {
    return {
      if (proto.hasIsCashOut()) 'isCashOut': proto.isCashOut,
      if (proto.hasType()) 'type': proto.type,
    };
  }

  double? _parseOddsDecimal(OddsStyleResponse style) {
    if (style.decimal.isEmpty) return null;
    return double.tryParse(style.decimal);
  }

  SortMode _currentSortMode = SortMode.defaultMode;

  SortMode get sortMode => _currentSortMode;

  set sortMode(SortMode mode) {
    if (_currentSortMode != mode) {
      _currentSortMode = mode;
    }
  }

  int _compareLeagues(LeagueData a, LeagueData b) {
    final priorityCmp = a.priorityOrder.compareTo(b.priorityOrder);
    if (priorityCmp != 0) return priorityCmp;

    if (a.hasLeagueOrder != b.hasLeagueOrder) {
      return a.hasLeagueOrder ? -1 : 1;
    }
    if (a.hasLeagueOrder && b.hasLeagueOrder) {
      final orderCmp = a.leagueOrder.compareTo(b.leagueOrder);
      if (orderCmp != 0) return orderCmp;
    }

    String key(LeagueData l) =>
        (l.nameEn != null && l.nameEn!.isNotEmpty ? l.nameEn! : l.name)
            .toLowerCase();
    return key(a).compareTo(key(b));
  }

  List<LeagueData> getSortedLeaguesBySport(int sportId) {
    final leagues = getLeaguesBySport(sportId).toList();
    leagues.sort(_compareLeagues);
    return leagues;
  }

  List<EventData> getSortedEventsBySport(int sportId) {
    switch (_currentSortMode) {
      case SortMode.defaultMode:
        return _getEventsSortedDefault(sportId);
      case SortMode.startTimeMode:
        return _getEventsSortedByStartTime(sportId);
    }
  }

  List<EventData> _getEventsSortedDefault(int sportId) {
    final sortedLeagues = getSortedLeaguesBySport(sportId);
    final result = <EventData>[];

    for (final league in sortedLeagues) {
      final events = getEventsByLeague(league.leagueId).toList();
      events.sort(EventData.compareByStartThenId);
      result.addAll(events);
    }
    return result;
  }

  List<EventData> _getEventsSortedByStartTime(int sportId) {
    final allEvents = <EventData>[];

    final leagueIds = _sportToLeagues[sportId];
    if (leagueIds == null) return allEvents;

    for (final leagueId in leagueIds) {
      allEvents.addAll(getEventsByLeague(leagueId));
    }

    final Map<int, List<EventData>> byStartTime = {};
    for (final event in allEvents) {
      final time = event.startDate?.millisecondsSinceEpoch ?? 0;
      byStartTime.putIfAbsent(time, () => []).add(event);
    }

    final sortedTimes = byStartTime.keys.toList()..sort();
    final result = <EventData>[];

    for (final time in sortedTimes) {
      final eventsAtTime = byStartTime[time]!;
      eventsAtTime.sort((a, b) {
        final leagueA = _leagues[a.leagueId];
        final leagueB = _leagues[b.leagueId];
        if (leagueA == null || leagueB == null) return 0;
        final c = _compareLeagues(leagueA, leagueB);
        if (c != 0) return c;
        return a.eventId.compareTo(b.eventId);
      });
      result.addAll(eventsAtTime);
    }
    return result;
  }

  void emitBatchChanges() {
    if (_batchUpdatedLeagueIds.isEmpty &&
        _batchUpdatedEventIds.isEmpty &&
        _batchUpdatedMarketKeys.isEmpty &&
        _batchUpdatedOddsKeys.isEmpty &&
        _batchAddedLeagueIds.isEmpty &&
        _batchAddedEventIds.isEmpty &&
        _batchAddedMarketKeys.isEmpty &&
        _batchAddedOddsKeys.isEmpty &&
        _batchRemovedLeagueIds.isEmpty &&
        _batchRemovedEventIds.isEmpty &&
        _batchRemovedMarketKeys.isEmpty &&
        _batchRemovedOddsKeys.isEmpty) {
      return;
    }

    final event = DataChangeEvent(
      updatedLeagueIds: Set.from(_batchUpdatedLeagueIds),
      updatedEventIds: Set.from(_batchUpdatedEventIds),
      updatedMarketKeys: Set.from(_batchUpdatedMarketKeys),
      updatedOddsKeys: Set.from(_batchUpdatedOddsKeys),
      addedLeagueIds: List.from(_batchAddedLeagueIds),
      addedEventIds: List.from(_batchAddedEventIds),
      addedMarketKeys: List.from(_batchAddedMarketKeys),
      addedOddsKeys: List.from(_batchAddedOddsKeys),
      removedLeagueIds: List.from(_batchRemovedLeagueIds),
      removedEventIds: List.from(_batchRemovedEventIds),
      removedMarketKeys: List.from(_batchRemovedMarketKeys),
      removedOddsKeys: List.from(_batchRemovedOddsKeys),
      timestamp: DateTime.now(),
      batchSize: _batchUpdatedEventIds.length +
          _batchAddedEventIds.length +
          _batchRemovedEventIds.length,
    );

    _batchUpdatedLeagueIds.clear();
    _batchUpdatedEventIds.clear();
    _batchUpdatedMarketKeys.clear();
    _batchUpdatedOddsKeys.clear();
    _batchAddedLeagueIds.clear();
    _batchAddedEventIds.clear();
    _batchAddedMarketKeys.clear();
    _batchAddedOddsKeys.clear();
    _batchRemovedLeagueIds.clear();
    _batchRemovedEventIds.clear();
    _batchRemovedMarketKeys.clear();
    _batchRemovedOddsKeys.clear();

    _changeController.add(event);
  }

  void clearSport(int sportId) {
    final leagueIds = _sportToLeagues[sportId]?.toList() ?? [];
    var keptAnyLeague = false;
    for (final leagueId in leagueIds) {
      final eventIds = _leagueToEvents[leagueId]?.toList() ?? [];
      var keptAnyEvent = false;
      for (final eventId in eventIds) {
        if (isPruneProtected(eventId)) {
          keptAnyEvent = true;
          continue;
        }
        removeEvent(eventId);
      }
      if (keptAnyEvent) {
        keptAnyLeague = true;
      } else {
        removeLeague(leagueId);
      }
    }
    if (!keptAnyLeague) {
      _sportToLeagues.remove(sportId);
    }
    _hotEventIdsBySport.remove(sportId);
    _hotOrderBySport.remove(sportId);
    _listEventIdsBySport.remove(sportId);
  }

  void clear() {
    _leagues.clear();
    _events.clear();
    _markets.clear();
    _odds.clear();
    _sportToLeagues.clear();
    _leagueToEvents.clear();
    _hotEventIdsBySport.clear();
    _hotOrderBySport.clear();
    _listEventIdsBySport.clear();
    _eventToMarkets.clear();
    _marketToOdds.clear();

    _batchUpdatedLeagueIds.clear();
    _batchUpdatedEventIds.clear();
    _batchUpdatedMarketKeys.clear();
    _batchUpdatedOddsKeys.clear();
    _batchAddedLeagueIds.clear();
    _batchAddedEventIds.clear();
    _batchAddedMarketKeys.clear();
    _batchAddedOddsKeys.clear();
    _batchRemovedLeagueIds.clear();
    _batchRemovedEventIds.clear();
    _batchRemovedMarketKeys.clear();
    _batchRemovedOddsKeys.clear();
  }

  void dispose() {
    _changeController.close();
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }
}
