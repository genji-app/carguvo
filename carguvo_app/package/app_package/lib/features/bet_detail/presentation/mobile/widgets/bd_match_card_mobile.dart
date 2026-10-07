library;

import 'package:flutter/material.dart';
import 'package:app_package/core/services/models/league_model.dart';
import 'package:app_package/core/utils/extensions/image_helper.dart';
import 'package:app_package/core/utils/styles/app_color.dart';
import 'package:app_package/core/utils/styles/app_color_styles.dart';
import 'package:app_package/core/utils/styles/app_icons.dart';
import 'package:app_package/core/utils/styles/app_text_styles.dart';
import 'package:app_package/shared/widgets/live/live_consumers.dart';
import 'package:app_package/shared/widgets/sport/match/match_notice_rive_animation.dart';

import 'bd_score_flip_mobile.dart';

enum BdMatchPhase { prematch, live, finished }

class BdMatchCardMobile extends StatelessWidget {
  const BdMatchCardMobile({
    required this.eventData,
    required this.leagueName,
    super.key,
    this.sportId = 1,
    this.ftHandicapPoints = 0,
    this.eventEnded = false,
    this.onShare,
    this.shareCopied = false,
    this.onStats,
    this.statsEnabled = true,
    this.tabs,
    this.hideBottomBorderRadius = false,
    this.homeNotice,
    this.awayNotice,
    this.homeNoticeSeq = 0,
    this.awayNoticeSeq = 0,
    this.onHomeNoticeCompleted,
    this.onAwayNoticeCompleted,
    this.lastScore,
    this.lastPenScore,
    this.homeFlip,
    this.awayFlip,
  });

  final LeagueEventData eventData;
  final String leagueName;
  final int sportId;

  final double ftHandicapPoints;

  final bool eventEnded;

  final VoidCallback? onShare;

  final bool shareCopied;

  final VoidCallback? onStats;
  final bool statsEnabled;

  final Widget? tabs;

  final bool hideBottomBorderRadius;

  final MatchNoticeType? homeNotice;
  final MatchNoticeType? awayNotice;
  final int homeNoticeSeq;
  final int awayNoticeSeq;
  final VoidCallback? onHomeNoticeCompleted;
  final VoidCallback? onAwayNoticeCompleted;

  final (int, int)? lastScore;

  final (int, int)? lastPenScore;

  final BdScoreFlipEvent? homeFlip;
  final BdScoreFlipEvent? awayFlip;

  static const Color _liveBadgeBg = Color(0xFF6B0000);
  static const Color _liveDot = Color(0xFFFF3333);
  static const Color _redCardBg = Color(0xFF8F0625);
  static const Color _yellowCardBg = Color(0xFFC27800);
  static const Color _hairline = Color.fromRGBO(255, 255, 255, 0.12);

  BdMatchPhase get _phase {
    final started = eventData.hasStarted;
    if (eventEnded && started) return BdMatchPhase.finished;
    if (eventData.isLive) return BdMatchPhase.live;
    final hasScore =
        eventData.displayHomeScore > 0 || eventData.displayAwayScore > 0;
    if (started && hasScore) return BdMatchPhase.finished;
    return BdMatchPhase.prematch;
  }

  @override
  Widget build(BuildContext context) {
    final showTabs = tabs != null;
    final radius = hideBottomBorderRadius
        ? const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          )
        : BorderRadius.circular(16);
    return ClipRRect(
      borderRadius: radius,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          color: AppColorStyles.backgroundQuaternary,
          border: const Border(top: BorderSide(color: _hairline)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _header(context),
            _buildHairline(),
            _teamsRow(context),
            if (showTabs) tabs!,
            if (!showTabs) const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  static Widget _buildHairline() => Container(
    height: 1,
    width: double.infinity,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.transparent, _hairline, Colors.transparent],
      ),
    ),
  );

  Widget _header(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
    child: Row(
      children: [
        ..._statusBadge(context),
        Expanded(
          child: Text(
            leagueName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.paragraphXXSmall(
              context: context,
              color: AppColorStyles.contentSecondary,
            ),
          ),
        ),
        if (onShare != null) ...[
          const SizedBox(width: 12),
          _shareButton(context),
        ],
        if (onStats != null) ...[
          const SizedBox(width: 16),
          Opacity(
            opacity: statsEnabled ? 1 : 0.4,
            child: GestureDetector(
              onTap: statsEnabled ? onStats : null,
              behavior: HitTestBehavior.opaque,
              child: ImageHelper.load(
                path: AppIcons.iconBarChart,
                width: 14,
                height: 14,
              ),
            ),
          ),
        ],
      ],
    ),
  );

  Widget _shareButton(BuildContext context) {
    if (shareCopied) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(134, 203, 60, 0.14),
          border: Border.all(color: const Color.fromRGBO(134, 203, 60, 0.45)),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          'Đã sao chép',
          style: AppTextStyles.labelXXSmall(
            context: context,
            color: const Color(0xFFA5D75A),
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: onShare,
      behavior: HitTestBehavior.opaque,
      child: ImageHelper.load(path: AppIcons.iconShare, width: 11, height: 14),
    );
  }

  List<Widget> _statusBadge(BuildContext context) {
    Widget pill(Color bg, Color dot, Color fg, String label) => Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelXXSmall(context: context, color: fg),
          ),
        ],
      ),
    );

    return switch (_phase) {
      BdMatchPhase.live => [
        pill(_liveBadgeBg, _liveDot, AppColorStyles.contentPrimary, 'Trực tiếp'),
      ],
      BdMatchPhase.finished => [
        pill(
          AppColorStyles.backgroundQuaternary,
          const Color(0xFF565552),
          AppColorStyles.contentTertiary,
          'Kết thúc',
        ),
      ],
      BdMatchPhase.prematch => const <Widget>[],
    };
  }

  Widget _teamsRow(BuildContext context) {
    final bool? homeUpper = ftHandicapPoints == 0 ? null : ftHandicapPoints < 0;
    final bool? awayUpper = ftHandicapPoints == 0 ? null : ftHandicapPoints > 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: _sideColumn(context, home: true, upper: homeUpper)),
          _centre(context),
          Expanded(child: _sideColumn(context, home: false, upper: awayUpper)),
        ],
      ),
    );
  }

  Widget _sideColumn(
    BuildContext context, {
    required bool home,
    required bool? upper,
  }) {
    final notice = home ? homeNotice : awayNotice;
    final name = Text(
      home ? eventData.homeName : eventData.awayName,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: home ? TextAlign.right : TextAlign.left,
      style: AppTextStyles.labelSmall(
        context: context,
        color: upper == true
            ? AppColors.orange400
            : AppColorStyles.contentPrimary,
      ),
    );
    final label = Text(
      home ? 'Nhà' : 'Khách',
      style: AppTextStyles.labelXXSmall(
        context: context,
        color: AppColorStyles.contentTertiary,
      ),
    );
    final chips = _statChips(context, home: home);
    final column = Column(
      crossAxisAlignment: home
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(padding: const EdgeInsets.all(2), child: name),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Row(
            mainAxisAlignment: home
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: home
                ? [...chips, const SizedBox(width: 6), label]
                : [label, const SizedBox(width: 6), ...chips],
          ),
        ),
      ],
    );
    if (notice == null) return column;
    return Stack(
      alignment: Alignment.center,
      children: [
        column,
        MatchNoticeRiveAnimation(
          key: ValueKey(
            'bd-notice-${eventData.eventId}-${home ? 'h' : 'a'}-'
            '${notice.name}-${home ? homeNoticeSeq : awayNoticeSeq}',
          ),
          type: notice,
          onCompleted: home ? onHomeNoticeCompleted : onAwayNoticeCompleted,
        ),
      ],
    );
  }

  List<Widget> _statChips(BuildContext context, {required bool home}) {
    if (_phase == BdMatchPhase.prematch) return const [];
    if (_phase == BdMatchPhase.finished && !_hasStats) return const [];
    final corners = home ? eventData.cornersHome : eventData.cornersAway;
    final yellow =
        home ? eventData.yellowCardsHome : eventData.yellowCardsAway;
    final red = home ? eventData.redCardsHome : eventData.redCardsAway;
    final redTotal = eventData.redCardsHome + eventData.redCardsAway;

    final redChip = redTotal > 0 ? _cardChip(context, _redCardBg, red) : null;
    final yellowChip = _cardChip(context, _yellowCardBg, yellow);
    final cornerChip = _cornerChip(context, corners, home: home);
    const gap = SizedBox(width: 6);
    return home
        ? [
            if (redChip != null) ...[redChip, gap],
            yellowChip,
            gap,
            cornerChip,
          ]
        : [
            cornerChip,
            gap,
            yellowChip,
            if (redChip != null) ...[gap, redChip],
          ];
  }

  bool get _hasStats =>
      eventData.cornersHome +
          eventData.cornersAway +
          eventData.yellowCardsHome +
          eventData.yellowCardsAway +
          eventData.redCardsHome +
          eventData.redCardsAway >
      0;

  static Widget _cardChip(BuildContext context, Color bg, int value) =>
      Container(
        width: 12,
        height: 16,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text(
          '$value',
          style: AppTextStyles.labelXXSmall(
            context: context,
            color: AppColorStyles.contentPrimary,
          ),
        ),
      );

  static Widget _cornerChip(
    BuildContext context,
    int value, {
    required bool home,
  }) {
    final flag = ImageHelper.load(
      path: AppIcons.iconCornerFlag,
      width: 8,
      height: 12,
    );
    final text = Text(
      '$value',
      style: AppTextStyles.labelXXSmall(
        context: context,
        color: AppColorStyles.contentPrimary,
      ),
    );
    return SizedBox(
      height: 16,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: home
            ? [
                Transform.flip(flipX: true, child: flag),
                const SizedBox(width: 2),
                text,
              ]
            : [text, const SizedBox(width: 2), flag],
      ),
    );
  }

  Widget _centre(BuildContext context) => SizedBox(
    width: 108,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _logo(home: true),
            const SizedBox(width: 5),
            _scoreBox(context),
            const SizedBox(width: 5),
            _logo(home: false),
          ],
        ),
        const SizedBox(height: 6),
        _statusPill(context),
      ],
    ),
  );

  Widget _logo({required bool home}) {
    final url = home
        ? (eventData.homeLogoFirst ?? eventData.homeLogoLast)
        : (eventData.awayLogoFirst ?? eventData.awayLogoLast);
    if (url == null || url.isEmpty) {
      return Container(
        width: 22,
        height: 22,
        decoration: const BoxDecoration(
          color: AppColorStyles.backgroundTertiary,
          shape: BoxShape.circle,
        ),
      );
    }
    return ImageHelper.load(
      path: url,
      width: 22,
      height: 22,
      fit: BoxFit.contain,
      borderRadius: 11,
    );
  }

  Widget _scoreBox(BuildContext context) {
    final (int, int)? score;
    var pen = false;
    switch (_phase) {
      case BdMatchPhase.prematch:
        score = null;
      case BdMatchPhase.finished:
        score = _finishedScore();
      case BdMatchPhase.live:
        pen = eventData.isPenaltyShootout;
        score = pen
            ? (eventData.homeScorePen, eventData.awayScorePen)
            : (eventData.displayHomeScore, eventData.displayAwayScore);
    }
    return BdScoreFlipMobile(
      key: ValueKey<String>(pen ? 'bd-score-pen' : 'bd-score-ft'),
      home: score?.$1,
      away: score?.$2,
      animate: _phase == BdMatchPhase.live,
      style: AppTextStyles.labelSmall(context: context, color: Colors.white),
      homeFlip: homeFlip,
      awayFlip: awayFlip,
    );
  }

  (int, int)? _finishedScore() {
    final h = eventData.displayHomeScore;
    final a = eventData.displayAwayScore;
    if (h > 0 || a > 0) return (h, a);
    return lastScore;
  }

  String _shortStart() {
    final dt = eventData.startDateTime;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.hour)}:${two(dt.minute)} - ${two(dt.day)}/${two(dt.month)}';
  }

  (int, int)? get _penResult {
    if (eventData.homeScorePen > 0 || eventData.awayScorePen > 0) {
      return (eventData.homeScorePen, eventData.awayScorePen);
    }
    return lastPenScore;
  }

  Widget _statusPill(BuildContext context) {
    final style = AppTextStyles.labelXXSmall(
      context: context,
      color: AppColorStyles.contentSecondary,
    );
    Widget shell(Widget child) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: AppColorStyles.contentSecondary),
        borderRadius: BorderRadius.circular(999),
      ),
      child: child,
    );

    return switch (_phase) {
      BdMatchPhase.live => shell(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            LiveMatchTimeDisplay(
              eventId: eventData.eventId,
              initialMinute: eventData.minuteString.isNotEmpty
                  ? eventData.minuteString
                  : null,
              initialPeriod: eventData.gamePartEnum.displayName,
              sportId: sportId,
              style: style,
              separator: Text(' - ', style: style),
            ),
            if (eventData.isPenaltyShootout)
              Text(
                ' · Trận ${eventData.displayHomeScore}-${eventData.displayAwayScore}',
                style: style,
              ),
          ],
        ),
      ),
      BdMatchPhase.finished => shell(
        Text(
          switch (_penResult) {
            final pen? => 'Kết thúc pen ${pen.$1}-${pen.$2}',
            _ => 'Kết thúc',
          },
          style: style,
        ),
      ),
      BdMatchPhase.prematch => shell(
        Text(_shortStart(), style: style),
      ),
    };
  }
}

class BdLiveToggle extends StatelessWidget {
  const BdLiveToggle({
    required this.on,
    super.key,
    this.onTap,
    this.compact = false,
  });

  final bool on;
  final VoidCallback? onTap;

  final bool compact;

  static const Color _onBg = Color(0xFF2B4212);
  static const Color _offBg = Color(0xFF111010);
  static const Color _knob = Color(0xFFC3C2BC);

  @override
  Widget build(BuildContext context) {
    final label = Text(
      on ? 'ON' : 'OFF',
      style: AppTextStyles.paragraphXXSmall(
        context: context,
        color: Colors.white,
      ),
    );
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 50,
        height: 24,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: on ? _onBg : _offBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              left: on ? 26 : 0,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: _knob,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            if (!compact)
              Positioned(left: on ? 7 : 22, top: 3, child: label),
          ],
        ),
      ),
    );
  }
}

class BdMatchCardPane extends StatelessWidget {
  const BdMatchCardPane({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: const BorderRadius.only(
      bottomLeft: Radius.circular(16),
      bottomRight: Radius.circular(16),
    ),
    child: ColoredBox(
      color: AppColorStyles.backgroundQuaternary,
      child: child,
    ),
  );
}
