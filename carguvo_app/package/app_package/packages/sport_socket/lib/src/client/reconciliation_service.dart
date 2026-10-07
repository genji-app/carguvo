import '../data/sport_data_store.dart';
import '../data/models/league_data.dart';
import '../data/models/event_data.dart';
import '../utils/logger.dart';

class ReconciliationResult {
  final List<int> addedLeagues = [];

  final List<int> updatedLeagues = [];

  final List<int> removedLeagues = [];

  final List<int> addedEvents = [];

  final List<int> updatedEvents = [];

  final List<int> removedEvents = [];

  int get totalChanges =>
      addedLeagues.length +
      updatedLeagues.length +
      removedLeagues.length +
      addedEvents.length +
      updatedEvents.length +
      removedEvents.length;

  bool get hasChanges => totalChanges > 0;

  @override
  String toString() {
    return 'ReconciliationResult('
        'leagues: +${addedLeagues.length}/~${updatedLeagues.length}/-${removedLeagues.length}, '
        'events: +${addedEvents.length}/~${updatedEvents.length}/-${removedEvents.length})';
  }
}

class ReconciliationService {
  final SportDataStore _store;
  final Logger _logger;

  ReconciliationService({
    required SportDataStore store,
    Logger? logger,
  })  : _store = store,
        _logger = logger ?? const NoOpLogger();

  SportDataStore get store => _store;

  ReconciliationResult reconcile(List<LeagueData> apiLeagues) {
    final result = ReconciliationResult();
    final startTime = DateTime.now();

    _logger.info('Starting reconciliation with ${apiLeagues.length} leagues');

    final validLeagueIds = <int>{};

    for (final league in apiLeagues) {
      validLeagueIds.add(league.leagueId);
      _processLeague(league, result);
    }

    final staleLeagueIds = _store.allLeagueIds
        .where((id) => !validLeagueIds.contains(id))
        .toList();

    for (final leagueId in staleLeagueIds) {
      final hasProtected = _store
          .getEventsByLeague(leagueId)
          .any((e) => _store.isPruneProtected(e.eventId));
      if (hasProtected) continue;
      _store.removeLeague(leagueId);
      result.removedLeagues.add(leagueId);
    }

    _store.emitBatchChanges();

    final duration = DateTime.now().difference(startTime);
    _logger.info(
      'Reconciliation complete: $result (${duration.inMilliseconds}ms)',
    );

    return result;
  }

  ReconciliationResult reconcileEvents({
    required int leagueId,
    required List<EventData> apiEvents,
  }) {
    final result = ReconciliationResult();

    if (!_store.hasLeague(leagueId)) {
      _logger.warning('Cannot reconcile events: league $leagueId not found');
      return result;
    }

    final validEventIds = <int>{};

    for (final event in apiEvents) {
      validEventIds.add(event.eventId);
      _processEvent(event, result);
    }

    final currentEvents = _store.getEventsByLeague(leagueId);
    for (final event in currentEvents) {
      if (!validEventIds.contains(event.eventId) &&
          !_store.isPruneProtected(event.eventId)) {
        _store.removeEvent(event.eventId);
        result.removedEvents.add(event.eventId);
      }
    }

    _store.emitBatchChanges();

    return result;
  }

  ReconciliationResult reconcileSport({
    required int sportId,
    required List<LeagueData> apiLeagues,
  }) {
    final result = ReconciliationResult();

    final validLeagueIds = <int>{};

    for (final league in apiLeagues) {
      if (league.sportId == sportId) {
        validLeagueIds.add(league.leagueId);
        _processLeague(league, result);
      }
    }

    final currentLeagues = _store.getLeaguesBySport(sportId);
    for (final league in currentLeagues) {
      if (!validLeagueIds.contains(league.leagueId)) {
        final events = _store.getEventsByLeague(league.leagueId);
        var keptAny = false;
        for (final event in events) {
          if (_store.isPruneProtected(event.eventId)) {
            keptAny = true;
            continue;
          }
          _store.removeEvent(event.eventId);
          result.removedEvents.add(event.eventId);
        }

        if (keptAny) continue;
        _store.removeLeague(league.leagueId);
        result.removedLeagues.add(league.leagueId);
      }
    }

    _store.emitBatchChanges();

    return result;
  }

  void _processLeague(LeagueData league, ReconciliationResult result) {
    if (_store.hasLeague(league.leagueId)) {
      _store.updateLeague(league);
      result.updatedLeagues.add(league.leagueId);
    } else {
      _store.insertLeague(league);
      result.addedLeagues.add(league.leagueId);
    }
  }

  void _processEvent(EventData event, ReconciliationResult result) {
    if (_store.hasEvent(event.eventId)) {
      _store.updateEventFromJson(event.eventId, {
        'homeName': event.homeName,
        'awayName': event.awayName,
        'homeScore': event.homeScore,
        'awayScore': event.awayScore,
        'isLive': event.isLive,
        'gameTime': event.gameTime,
        'gamePart': event.gamePart,
        'status': event.status,
      });
      result.updatedEvents.add(event.eventId);
    } else {
      _store.insertEvent(event);
      result.addedEvents.add(event.eventId);
    }
  }

  ReconciliationResult fullSync({
    required int sportId,
    required List<LeagueData> apiLeagues,
  }) {
    _logger
        .info('Full sync for sport $sportId with ${apiLeagues.length} leagues');
    final startTime = DateTime.now();
    final result = ReconciliationResult();

    final sportLeagues = apiLeagues.where((l) => l.sportId == sportId).toList();

    final validLeagueIds = <int>{};

    for (final league in sportLeagues) {
      validLeagueIds.add(league.leagueId);
      _processLeague(league, result);
    }

    final currentLeagues = _store.getLeaguesBySport(sportId);
    for (final league in currentLeagues) {
      if (!validLeagueIds.contains(league.leagueId)) {
        final events = _store.getEventsByLeague(league.leagueId);
        var keptAny = false;
        for (final event in events) {
          if (_store.isPruneProtected(event.eventId)) {
            keptAny = true;
            continue;
          }
          _store.removeEvent(event.eventId);
          result.removedEvents.add(event.eventId);
        }

        if (keptAny) continue;
        _store.removeLeague(league.leagueId);
        result.removedLeagues.add(league.leagueId);
      }
    }

    _store.emitBatchChanges();

    final duration = DateTime.now().difference(startTime);
    _logger.info('Full sync complete: $result (${duration.inMilliseconds}ms)');

    return result;
  }
}
