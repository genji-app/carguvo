import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:app_package/core/services/models/api_v2/event_model_v2.dart';
import 'package:app_package/core/services/models/api_v2/event_model_v2_extensions.dart';
import 'package:app_package/core/services/models/api_v2/league_model_v2.dart';
import 'package:app_package/features/sport/presentation/providers/event_live_provider.dart';
import 'package:app_package/features/sport/presentation/providers/events_v2_provider.dart';
import 'package:app_package/shared/widgets/sport/match/match_notice_rive_animation.dart';
import 'package:sport_notice/sport_notice.dart' as notice;

part 'match_notice_provider.freezed.dart';

@freezed
sealed class MatchNoticeEvent with _$MatchNoticeEvent {
  const factory MatchNoticeEvent.goal({
    required int eventId,
    required bool home,
    required int seq,
  }) = _Goal;

  const factory MatchNoticeEvent.redCard({
    required int eventId,
    required bool home,
    required int seq,
  }) = _RedCard;

  const factory MatchNoticeEvent.yellowCard({
    required int eventId,
    required bool home,
    required int seq,
  }) = _YellowCard;

  const factory MatchNoticeEvent.corner({
    required int eventId,
    required bool home,
    required int seq,
  }) = _Corner;
}

final matchNoticeProvider = StateNotifierProvider.autoDispose<
    MatchNoticeNotifier, Map<String, (MatchNoticeType, int)>>((ref) {
  MatchNoticeRiveAnimation.preload();
  final notifier = MatchNoticeNotifier();
  notifier.onLeagues(ref.read(leaguesV2Provider));
  ref.listen<List<LeagueModelV2>>(
    leaguesV2Provider,
    (_, next) => notifier.onLeagues(next),
  );
  ref.listen<EventLiveState>(eventLiveProvider, (prev, next) {
    final prevEvents = prev?.events;
    for (final entry in next.events.entries) {
      if (!identical(prevEvents?[entry.key], entry.value)) {
        notifier.onEventLive(entry.value);
      }
    }
  });
  return notifier;
});

class MatchNoticeNotifier extends StateNotifier<Map<String, (MatchNoticeType, int)>> {
  MatchNoticeNotifier({DateTime Function()? clock})
      : super(const {}) {
    _detector = notice.MatchNoticeDetector(
      clock: clock,
      onStateChanged: () => _syncState(),
    );
  }

  late notice.MatchNoticeDetector _detector;

  void _syncState() {
    final mapped = <String, (MatchNoticeType, int)>{};
    for (final entry in _detector.activeNotices.entries) {
      mapped[entry.key] = (fromNoticeKind(entry.value.$1), entry.value.$2);
    }
    state = mapped;
  }

  static String homeKey(int eventId) => notice.noticeKey(eventId, home: true);

  static String awayKey(int eventId) => notice.noticeKey(eventId, home: false);

  Set<int> _listIds = const {};
  Set<int> _hotIds = const {};

  static notice.NoticeStats? _statsOf(EventModelV2 e) {
    if (e.sportId != 1) return null;
    if (!e.isLive) return null;
    if (e.score == null) return null;
    return notice.NoticeStats(
      homeGoals: e.homeScoreInt,
      awayGoals: e.awayScoreInt,
      homeYellow: e.yellowCardsHome,
      awayYellow: e.yellowCardsAway,
      homeRed: e.redCardsHome,
      awayRed: e.redCardsAway,
      homeCorner: e.cornersHome,
      awayCorner: e.cornersAway,
    );
  }

  void onLeagues(List<LeagueModelV2> leagues) {
    final soccer = <int, notice.NoticeStats>{};
    for (final l in leagues) {
      for (final e in l.events) {
        final stats = _statsOf(e);
        if (stats != null) soccer[e.eventId] = stats;
      }
    }
    _listIds = soccer.keys.toSet();
    _detector.seedEvents(soccer);
    _detector.pruneEvents({..._listIds, ..._hotIds});
    _syncState();
  }

  void onHotEvents(Iterable<EventModelV2> events) {
    final fresh = <int, notice.NoticeStats>{};
    final ids = <int>{};
    for (final e in events) {
      final stats = _statsOf(e);
      if (stats == null) continue;
      ids.add(e.eventId);
      if (_listIds.contains(e.eventId) || _hotIds.contains(e.eventId)) continue;
      fresh[e.eventId] = stats;
    }
    _hotIds = ids;
    if (fresh.isNotEmpty) _detector.seedEvents(fresh);
    _detector.pruneEvents({..._listIds, ..._hotIds});
    _syncState();
  }

  void onEventLive(EventLiveData data) {
    if (data.sportId != notice.MatchNoticeDetector.soccerSportId) return;
    _detector.onEvent(
      data.eventId,
      notice.NoticeStats(
        homeGoals: data.homeScore,
        awayGoals: data.awayScore,
        homeYellow: data.yellowCardsHome ?? 0,
        awayYellow: data.yellowCardsAway ?? 0,
        homeRed: data.redCardsHome ?? 0,
        awayRed: data.redCardsAway ?? 0,
        homeCorner: data.cornersHome ?? 0,
        awayCorner: data.cornersAway ?? 0,
      ),
    );
    _syncState();
  }

  void clearNotice(String key, int seq) {
    final parts = key.split('-');
    if (parts.length != 2) return;
    final eventId = int.tryParse(parts[0]);
    if (eventId == null) return;
    final home = parts[1] == 'home';
    _detector.clearNotice(eventId, home: home, seq: seq);
    _syncState();
  }

  @override
  void dispose() {
    _detector.dispose();
    super.dispose();
  }
}
