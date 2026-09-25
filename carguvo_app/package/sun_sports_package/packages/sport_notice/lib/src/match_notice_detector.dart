import 'match_notice_kind.dart';
import 'notice_gap_rules.dart';
import 'notice_stats.dart';

String noticeKey(int eventId, {required bool home}) =>
    '$eventId-${home ? 'home' : 'away'}';

class MatchNoticeDetector {
  MatchNoticeDetector({
    DateTime Function()? clock,
    void Function()? onStateChanged,
    bool baselineOnUnknown = false,
  })  : _clock = clock ?? DateTime.now,
        _onStateChanged = onStateChanged,
        _baselineOnUnknown = baselineOnUnknown {
    _gapRules = NoticeGapRules(clock: clock, onSuspend: clearAll);
  }

  final DateTime Function() _clock;
  final void Function()? _onStateChanged;

  final bool _baselineOnUnknown;

  static const Duration noticeTtl = Duration(seconds: 6);
  static const int soccerSportId = 1;

  final Map<int, NoticeStats> _snapshot = {};
  final Set<int> _warming = {};
  final Map<String, (MatchNoticeKind, int)> _notices = {};
  final Map<String, DateTime> _expiresAt = {};
  int _seq = 0;

  late final NoticeGapRules _gapRules;

  void _pruneExpired() {
    final now = _clock();
    final expired = <String>[];
    for (final entry in _expiresAt.entries) {
      if (!now.isBefore(entry.value)) expired.add(entry.key);
    }
    for (final key in expired) {
      _expiresAt.remove(key);
      if (_notices.remove(key) != null) _onStateChanged?.call();
    }
  }

  void seedEvents(Map<int, NoticeStats> events) {
    final suppress = _gapRules.shouldSuppress();
    for (final entry in events.entries) {
      final id = entry.key;
      final next = entry.value;
      final prev = _snapshot[id];
      _snapshot[id] = next;
      if (prev == null) {
        _warming.add(id);
        continue;
      }
      if (_warming.remove(id)) continue;
      if (suppress) continue;
      _diffAndTrigger(id, prev, next);
    }
  }

  void pruneEvents(Set<int> activeEventIds) {
    for (final id in _snapshot.keys.toList()) {
      if (!activeEventIds.contains(id)) {
        _snapshot.remove(id);
        _warming.remove(id);
        _clearById(id);
      }
    }
  }

  bool onEvent(int eventId, NoticeStats stats) {
    final prev = _snapshot[eventId];
    if (prev == null) {
      if (!_baselineOnUnknown) return false;
      _snapshot[eventId] = stats;
      _warming.add(eventId);
      return false;
    }
    final suppress = _gapRules.shouldSuppress();

    final next = NoticeStats(
      homeGoals: stats.homeGoals > prev.homeGoals ? stats.homeGoals : prev.homeGoals,
      awayGoals: stats.awayGoals > prev.awayGoals ? stats.awayGoals : prev.awayGoals,
      homeYellow: stats.homeYellow > prev.homeYellow ? stats.homeYellow : prev.homeYellow,
      awayYellow: stats.awayYellow > prev.awayYellow ? stats.awayYellow : prev.awayYellow,
      homeRed: stats.homeRed > prev.homeRed ? stats.homeRed : prev.homeRed,
      awayRed: stats.awayRed > prev.awayRed ? stats.awayRed : prev.awayRed,
      homeCorner: stats.homeCorner > prev.homeCorner ? stats.homeCorner : prev.homeCorner,
      awayCorner: stats.awayCorner > prev.awayCorner ? stats.awayCorner : prev.awayCorner,
    );
    _snapshot[eventId] = next;
    if (_warming.remove(eventId)) return false;
    if (suppress) return false;

    return _diffAndTrigger(eventId, prev, next);
  }

  MatchNoticeKind? _diff(NoticeStats prev, NoticeStats next, {required bool home}) {
    final goal = home ? next.homeGoals > prev.homeGoals : next.awayGoals > prev.awayGoals;
    if (goal) return MatchNoticeKind.goal;
    final red = home ? next.homeRed > prev.homeRed : next.awayRed > prev.awayRed;
    if (red) return MatchNoticeKind.redCard;
    final yellow = home ? next.homeYellow > prev.homeYellow : next.awayYellow > prev.awayYellow;
    if (yellow) return MatchNoticeKind.yellowCard;
    final corner = home ? next.homeCorner > prev.homeCorner : next.awayCorner > prev.awayCorner;
    if (corner) return MatchNoticeKind.corner;
    return null;
  }

  bool _diffAndTrigger(int eventId, NoticeStats prev, NoticeStats next) {
    var fired = false;
    final homeKind = _diff(prev, next, home: true);
    if (homeKind != null) {
      _trigger(eventId, home: true, kind: homeKind);
      fired = true;
    }
    final awayKind = _diff(prev, next, home: false);
    if (awayKind != null) {
      _trigger(eventId, home: false, kind: awayKind);
      fired = true;
    }
    return fired;
  }

  void _trigger(int eventId, {required bool home, required MatchNoticeKind kind}) {
    final key = noticeKey(eventId, home: home);
    _notices[key] = (kind, ++_seq);
    _expiresAt[key] = _clock().add(noticeTtl);
    _onStateChanged?.call();
  }

  void clearNotice(int eventId, {required bool home, required int seq}) {
    final key = noticeKey(eventId, home: home);
    final current = _notices[key];
    if (current == null || current.$2 != seq) return;
    _clear(key);
  }

  void _clear(String key) {
    _expiresAt.remove(key);
    if (_notices.remove(key) != null) _onStateChanged?.call();
  }

  void _clearById(int eventId) {
    for (final home in [true, false]) {
      final key = noticeKey(eventId, home: home);
      _expiresAt.remove(key);
      _notices.remove(key);
    }
    _onStateChanged?.call();
  }

  void clearAll() {
    _expiresAt.clear();
    if (_notices.isNotEmpty) {
      _notices.clear();
      _onStateChanged?.call();
    }
  }

  Map<String, (MatchNoticeKind, int)> get activeNotices {
    _pruneExpired();
    return Map.unmodifiable(_notices);
  }

  (MatchNoticeKind, int)? noticeFor(int eventId, {required bool home}) {
    _pruneExpired();
    return _notices[noticeKey(eventId, home: home)];
  }

  void dispose() {
    _expiresAt.clear();
    _notices.clear();
    _snapshot.clear();
    _warming.clear();
  }
}
