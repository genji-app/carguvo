import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sun_sports/core/services/models/api_v2/event_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/event_model_v2_extensions.dart';
import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';
import 'package:sun_sports/features/sport/presentation/providers/event_live_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/events_v2_provider.dart';
import 'package:sun_sports/shared/widgets/sport/match/match_notice_rive_animation.dart';
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

  void onLeagues(List<LeagueModelV2> leagues) {
    final soccer = <int, notice.NoticeStats>{};
    final activeIds = <int>{};
    for (final l in leagues) {
      for (final e in l.events) {
        if (e.sportId != 1) continue;
        if (!e.isLive) continue;
        final score = e.score;
        if (score == null) continue;
        activeIds.add(e.eventId);
        soccer[e.eventId] = notice.NoticeStats(
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
    }
    _detector.seedEvents(soccer);
    _detector.pruneEvents(activeIds);
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
