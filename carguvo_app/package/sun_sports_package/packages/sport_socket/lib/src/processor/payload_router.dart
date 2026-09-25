import '../proto/proto.dart';
import '../data/sport_data_store.dart';
import '../data/models/odds_data.dart';
import '../data/models/odds_change_data.dart';
import '../data/models/odds_update_data.dart';
import '../utils/logger.dart';

typedef ProtoScoreCallback = void Function(
    int eventId, int sportId, ScoreResponse score);

typedef ProtoEventStatusCallback = void Function(
    int eventId, EventResponse event);

typedef ProtoOddsChangeCallback = void Function(OddsChangeData data);

typedef ProtoOddsUpdateCallback = void Function(OddsUpdateData data);

class PayloadRouter {
  final Logger _logger;

  final Set<int> _subscribedTimeRanges = {};

  ProtoScoreCallback? onScoreUpdate;
  ProtoEventStatusCallback? onEventStatusUpdate;
  ProtoOddsChangeCallback? onOddsChange;
  ProtoOddsUpdateCallback? onOddsUpdate;

  PayloadRouter({
    Logger? logger,
  }) : _logger = logger ?? const NoOpLogger();

  void subscribeTimeRange(int timeRange) {
    _subscribedTimeRanges.add(timeRange);
    _logger.debug('Subscribed to timeRange: $timeRange');
  }

  void unsubscribeTimeRange(int timeRange) {
    _subscribedTimeRanges.remove(timeRange);
    _logger.debug('Unsubscribed from timeRange: $timeRange');
  }

  void clearTimeRangeSubscriptions() {
    _subscribedTimeRanges.clear();
  }

  void route(Payload payload, SportDataStore store) {
    final channel = payload.channel;
    final type = payload.type;

    _debugPrintDecodedPayload(payload);

    try {
      if (_isLeagueChannel(channel)) {
        _handleLeaguePayload(payload, type, store);
      } else if (_isHotChannel(channel)) {
        _handleHotPayload(payload, type, store);
      } else if (_isOutrightChannel(channel)) {
        _handleOutrightPayload(payload, type, store);
      } else if (_isMatchChannel(channel) || _isMatchDetailChannel(channel)) {
        _handleMatchPayload(payload, type, store);
      } else {
        if (payload.hasHotEvent()) {
          _handleHotPayload(payload, type, store);
        } else if (payload.hasOutrightEvent()) {
          _handleOutrightPayload(payload, type, store);
        } else if (payload.hasLeague()) {
          _handleLeaguePayload(payload, type, store);
        } else if (payload.hasEvent()) {
          _handleMatchPayload(payload, type, store);
        } else {
          _logger.debug('Unknown payload (no channel + no known data)');
        }
      }
    } catch (e, stackTrace) {
      _logger.error('PayloadRouter error for channel $channel', e, stackTrace);
    }
  }

  void routeBatch(List<Payload> payloads, SportDataStore store) {
    for (final payload in payloads) {
      route(payload, store);
    }
    store.emitBatchChanges();
  }

  bool _isLeagueChannel(String channel) {
    return channel.endsWith(':l') && channel.contains(':s:');
  }

  bool _isMatchChannel(String channel) {
    return channel.endsWith(':e') && channel.contains(':tr:');
  }

  bool _isMatchDetailChannel(String channel) {
    final parts = channel.split(':');
    if (parts.length < 3) return false;
    final eIndex = parts.indexOf('e');
    if (eIndex < 0 || eIndex >= parts.length - 1) return false;
    return int.tryParse(parts[eIndex + 1]) != null;
  }

  bool _isHotChannel(String channel) {
    return channel.endsWith(':e:hot');
  }

  bool _isOutrightChannel(String channel) {
    return channel.endsWith(':e:ort');
  }

  void _handleLeaguePayload(Payload p, String type, SportDataStore store) {
    if (!p.hasLeague()) {
      _logger.debug('League payload missing league data');
      return;
    }

    final league = p.league;

    switch (type) {
      case 'i':
        if (_subscribedTimeRanges.isNotEmpty &&
            !_subscribedTimeRanges.contains(p.timeRange)) {
          _logger.debug(
            'Ignoring league insert for timeRange ${p.timeRange} '
            '(subscribed: $_subscribedTimeRanges)',
          );
          return;
        }
        store.upsertLeagueFromProto(league, timeRange: p.timeRange);
        _logger.debug('League inserted: ${league.leagueId}');

      case 'u':
        store.updateLeagueFromProto(league);
        _logger.debug('League updated: ${league.leagueId}');

      case 'r':
        store.removeLeague(league.leagueId);
        _logger.debug('League removed: ${league.leagueId}');
    }
  }

  void _handleMatchPayload(Payload p, String type, SportDataStore store) {
    if (!p.hasEvent()) {
      _logger.debug('Match payload missing event data');
      return;
    }

    final event = p.event;
    final eventId = event.eventId.toInt();

    switch (type) {
      case 'i':
      case 'u':
        final isNew = !store.hasEvent(eventId);
        store.upsertEventFromProto(event);

        if (p.channel.isEmpty || _isMatchChannel(p.channel)) {
          final stored = store.getEvent(eventId);
          if (stored != null) {
            store.markListMember(eventId, stored.sportId);
          }
        }

        _parseMarketsAndOdds(event, store);

        if (_isMatchDetailChannel(p.channel)) {
          _pruneEventTreeToPayload(event, store);
        }

        if (isNew) {
          _logger.debug('Event inserted: $eventId');
        }

        final statusSource = _liveStatusSource(event);
        onEventStatusUpdate?.call(eventId, statusSource);

        if (statusSource.hasLiveScore()) {
          onScoreUpdate?.call(
              eventId, statusSource.sportId, statusSource.liveScore);
        }

      case 'r':
        store.removeEvent(eventId);
        _logger.debug('Event removed: $eventId');
    }
  }

  void _handleHotPayload(Payload p, String type, SportDataStore store) {
    if (!p.hasHotEvent()) {
      _logger.debug('Hot payload missing hotEvent data');
      return;
    }

    final hotEvents = p.hotEvent;

    final newHotIdsBySport = <int, List<int>>{};

    for (final hotEvent in hotEvents.events) {
      if (!hotEvent.hasEvent()) continue;
      final event = hotEvent.event;
      final eventId = event.eventId.toInt();
      final sportId = event.sportId;

      store.ensureLeague(
        leagueId: hotEvent.leagueId,
        leagueName: hotEvent.leagueName,
        leagueOrder: hotEvent.leagueOrder,
        leaguePriorityOrder: hotEvent.leaguePriorityOrder,
        leagueLogo: hotEvent.leagueLogo,
        sportId: sportId,
      );

      store.upsertEventFromProto(event);
      _parseMarketsAndOdds(event, store);
      store.markEventHot(eventId, sportId);

      final orderedIds = newHotIdsBySport.putIfAbsent(sportId, () => <int>[]);
      if (!orderedIds.contains(eventId)) orderedIds.add(eventId);
    }

    newHotIdsBySport.forEach((sportId, orderedIds) {
      store.reconcileHotSnapshot(sportId, orderedIds.toSet());
      store.setHotSnapshotOrder(sportId, orderedIds);
    });

    _logger.debug('Hot events processed: ${hotEvents.events.length}');
  }

  void _handleOutrightPayload(Payload p, String type, SportDataStore store) {

  }

  void _parseMarketsAndOdds(EventResponse event, SportDataStore store) {
    final eventId = event.eventId.toInt();

    for (final market in event.markets) {
      final marketId = market.marketId;
      store.upsertMarketFromProto(eventId, market);

      for (final oddsProto in market.oddsList) {
        final offerId = oddsProto.strOfferId.isNotEmpty
            ? oddsProto.strOfferId
            : '${eventId}_${marketId}_${DateTime.now().microsecondsSinceEpoch}';

        final existingOdds = store.getOdds(eventId, marketId, offerId);
        final previousHome = existingOdds?.oddsHome;
        final previousAway = existingOdds?.oddsAway;
        final previousDraw = existingOdds?.oddsDraw;

        store.upsertOddsFromProto(eventId, marketId, oddsProto);

        final updatedOdds = store.getOdds(eventId, marketId, offerId);

        if (onOddsUpdate != null && updatedOdds != null) {
          onOddsUpdate!.call(
            OddsUpdateData(
              eventId: eventId,
              marketId: marketId,
              offerId: offerId,
              odds: updatedOdds,
              timestamp: DateTime.now(),
            ),
          );
        }

        if (onOddsChange != null &&
            existingOdds != null &&
            updatedOdds != null) {
          _emitOddsChanges(
            eventId: eventId,
            marketId: marketId,
            offerId: offerId,
            previousHome: previousHome,
            previousAway: previousAway,
            previousDraw: previousDraw,
            currentOdds: updatedOdds,
            oddsProto: oddsProto,
          );
        }
      }
    }

    for (final child in event.children) {
      if (child.eventId.toInt() != eventId) {
        store.upsertEventFromProto(child);
      } else {
        store.mergeLiveStatusFromProto(child);
      }
      _parseMarketsAndOdds(child, store);
    }
  }

  EventResponse _liveStatusSource(EventResponse event) {
    final eventId = event.eventId.toInt();
    for (final child in event.children) {
      if (child.eventId.toInt() != eventId) continue;
      if (child.hasGamePart() || child.hasGameTime() || child.hasLiveScore()) {
        return child;
      }
    }
    return event;
  }

  void _pruneEventTreeToPayload(EventResponse event, SportDataStore store) {
    final eventId = event.eventId.toInt();
    final validMarketIds = <int>[];
    final validOffers = <int, List<String>>{};
    void collect(EventResponse node) {
      for (final m in node.markets) {
        if (!validOffers.containsKey(m.marketId)) {
          validMarketIds.add(m.marketId);
        }
        final offers = validOffers.putIfAbsent(m.marketId, () => <String>[]);
        for (final o in m.oddsList) {
          if (o.strOfferId.isNotEmpty && !offers.contains(o.strOfferId)) {
            offers.add(o.strOfferId);
          }
        }
      }
    }

    collect(event);
    for (final child in event.children) {
      if (child.eventId.toInt() == eventId) {
        collect(child);
      }
    }
    store.pruneEventToSnapshot(
      eventId: eventId,
      validMarketIds: validMarketIds,
      validOfferIdsByMarket: validOffers,
    );

    for (final child in event.children) {
      if (child.eventId.toInt() != eventId) {
        _pruneEventTreeToPayload(child, store);
      }
    }
  }

  void _emitOddsChanges({
    required int eventId,
    required int marketId,
    required String offerId,
    double? previousHome,
    double? previousAway,
    double? previousDraw,
    required OddsData currentOdds,
    required OddsResponse oddsProto,
  }) {
    final timestamp = DateTime.now();

    if (previousHome != null &&
        currentOdds.oddsHome != null &&
        previousHome != currentOdds.oddsHome &&
        currentOdds.selectionIdHome != null &&
        currentOdds.selectionIdHome!.isNotEmpty) {
      final direction = currentOdds.oddsHome! > previousHome
          ? OddsDirection.up
          : OddsDirection.down;

      onOddsChange?.call(OddsChangeData(
        eventId: eventId,
        marketId: marketId,
        offerId: offerId,
        selectionId: currentOdds.selectionIdHome!,
        selectionType: 'home',
        previousValue: previousHome,
        currentValue: currentOdds.oddsHome!,
        direction: direction,
        styleValues: OddsStyleValues(
          decimal: currentOdds.oddsHome!,
          malay: oddsProto.oddsHome.malay,
          indo: oddsProto.oddsHome.indo,
          hk: oddsProto.oddsHome.hk,
        ),
        timestamp: timestamp,
      ));
    }

    if (previousAway != null &&
        currentOdds.oddsAway != null &&
        previousAway != currentOdds.oddsAway &&
        currentOdds.selectionIdAway != null &&
        currentOdds.selectionIdAway!.isNotEmpty) {
      final direction = currentOdds.oddsAway! > previousAway
          ? OddsDirection.up
          : OddsDirection.down;

      onOddsChange?.call(OddsChangeData(
        eventId: eventId,
        marketId: marketId,
        offerId: offerId,
        selectionId: currentOdds.selectionIdAway!,
        selectionType: 'away',
        previousValue: previousAway,
        currentValue: currentOdds.oddsAway!,
        direction: direction,
        styleValues: OddsStyleValues(
          decimal: currentOdds.oddsAway!,
          malay: oddsProto.oddsAway.malay,
          indo: oddsProto.oddsAway.indo,
          hk: oddsProto.oddsAway.hk,
        ),
        timestamp: timestamp,
      ));
    }

    if (previousDraw != null &&
        currentOdds.oddsDraw != null &&
        previousDraw != currentOdds.oddsDraw &&
        currentOdds.selectionIdDraw != null &&
        currentOdds.selectionIdDraw!.isNotEmpty) {
      final direction = currentOdds.oddsDraw! > previousDraw
          ? OddsDirection.up
          : OddsDirection.down;

      onOddsChange?.call(OddsChangeData(
        eventId: eventId,
        marketId: marketId,
        offerId: offerId,
        selectionId: currentOdds.selectionIdDraw!,
        selectionType: 'draw',
        previousValue: previousDraw,
        currentValue: currentOdds.oddsDraw!,
        direction: direction,
        styleValues: OddsStyleValues(
          decimal: currentOdds.oddsDraw!,
          malay: null,
          indo: null,
          hk: null,
        ),
        timestamp: timestamp,
      ));
    }
  }

  void _debugPrintDecodedPayload(Payload payload) {

  }
}
