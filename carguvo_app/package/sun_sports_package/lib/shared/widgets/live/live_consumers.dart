import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/sport/presentation/providers/event_live_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/market_status_provider.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';
import 'package:sun_sports/shared/widgets/sport/match/score/basketball_countdown_timer.dart';
import 'package:betting_domain/betting_domain.dart' as betting;

class LiveScoreConsumer extends StatelessWidget {
  final int eventId;
  final int initialHome;
  final int initialAway;
  final Widget Function(BuildContext context, int homeScore, int awayScore)
  builder;

  const LiveScoreConsumer({
    super.key,
    required this.eventId,
    this.initialHome = 0,
    this.initialAway = 0,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final score = ref.watch(
          eventLiveProvider.select((state) => state.getScore(eventId)),
        );

        final homeScore = score?.$1 ?? initialHome;
        final awayScore = score?.$2 ?? initialAway;

        return builder(context, homeScore, awayScore);
      },
    );
  }
}

class LiveSingleScoreConsumer extends StatelessWidget {
  final int eventId;
  final bool isHome;
  final int initialValue;
  final Widget Function(BuildContext context, int score) builder;

  const LiveSingleScoreConsumer({
    super.key,
    required this.eventId,
    required this.isHome,
    this.initialValue = 0,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final value = ref.watch(
          eventLiveProvider.select((state) {
            final score = state.getScore(eventId);
            return isHome
                ? (score?.$1 ?? initialValue)
                : (score?.$2 ?? initialValue);
          }),
        );
        return builder(context, value);
      },
    );
  }
}

class LiveStatusConsumer extends StatelessWidget {
  final int eventId;
  final String? initialStatus;
  final Widget Function(BuildContext context, String? status) builder;

  const LiveStatusConsumer({
    super.key,
    required this.eventId,
    this.initialStatus,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final status = ref.watch(
          eventLiveProvider.select((state) => state.getLiveStatus(eventId)),
        );
        return builder(context, status ?? initialStatus);
      },
    );
  }
}

class MarketSuspendedConsumer extends StatelessWidget {
  final int eventId;
  final int marketId;
  final Widget Function(BuildContext context, bool isSuspended) builder;

  const MarketSuspendedConsumer({
    super.key,
    required this.eventId,
    required this.marketId,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final isSuspended = ref.watch(
          isMarketSuspendedProvider((eventId, marketId)),
        );
        return builder(context, isSuspended);
      },
    );
  }
}

class MarketAvailableConsumer extends StatelessWidget {
  final int eventId;
  final int marketId;
  final Widget Function(BuildContext context, bool isAvailable) builder;

  const MarketAvailableConsumer({
    super.key,
    required this.eventId,
    required this.marketId,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final isAvailable = ref.watch(
          isMarketAvailableProvider((eventId, marketId)),
        );
        return builder(context, isAvailable);
      },
    );
  }
}

class EventSuspendedConsumer extends StatelessWidget {
  final int eventId;
  final Widget Function(BuildContext context, bool isSuspended) builder;

  const EventSuspendedConsumer({
    super.key,
    required this.eventId,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final isSuspended = ref.watch(isEventSuspendedProvider(eventId));
        return builder(context, isSuspended);
      },
    );
  }
}

class LiveScoreDisplay extends StatelessWidget {
  final int eventId;
  final int initialHome;
  final int initialAway;
  final TextStyle? style;
  final Color? color;

  const LiveScoreDisplay({
    super.key,
    required this.eventId,
    this.initialHome = 0,
    this.initialAway = 0,
    this.style,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final score = ref.watch(
          eventLiveProvider.select((state) => state.getScore(eventId)),
        );
        final homeScore = score?.$1 ?? initialHome;
        final awayScore = score?.$2 ?? initialAway;

        return Text(
          '$homeScore - $awayScore',
          style:
              style ??
              AppTextStyles.textStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color ?? const Color(0xFFFFFEF5),
              ),
        );
      },
    );
  }
}

class LiveSingleScoreDisplay extends StatelessWidget {
  final int eventId;
  final bool isHome;
  final int initialValue;
  final TextStyle? style;

  const LiveSingleScoreDisplay({
    super.key,
    required this.eventId,
    required this.isHome,
    this.initialValue = 0,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final value = ref.watch(
          eventLiveProvider.select((state) {
            final score = state.getScore(eventId);
            return isHome
                ? (score?.$1 ?? initialValue)
                : (score?.$2 ?? initialValue);
          }),
        );

        return Text(
          '$value',
          style:
              style ??
              AppTextStyles.textStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFFFFEF5),
              ),
        );
      },
    );
  }
}

class LiveStatusBadge extends StatelessWidget {
  final int eventId;
  final String? initialStatus;
  final TextStyle? style;

  const LiveStatusBadge({
    super.key,
    required this.eventId,
    this.initialStatus,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final status = ref.watch(
          eventLiveProvider.select((state) => state.getLiveStatus(eventId)),
        );
        final displayStatus = status ?? initialStatus ?? '';

        if (displayStatus.isEmpty) return const SizedBox.shrink();

        return Text(
          displayStatus,
          style:
              style ??
              AppTextStyles.textStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFFFFEF5),
              ),
        );
      },
    );
  }
}

class LiveMatchTimeDisplay extends StatelessWidget {
  final int eventId;
  final String? initialMinute;
  final String? initialPeriod;
  final TextStyle? style;
  final Widget? separator;

  final TextStyle? leadingStyle;

  final int sportId;

  final int? initialCurrentSet;

  final (int, int)? initialSetScore;

  const LiveMatchTimeDisplay({
    super.key,
    required this.eventId,
    this.initialMinute,
    this.initialPeriod,
    this.style,
    this.separator,
    this.leadingStyle,
    this.sportId = 0,
    this.initialCurrentSet,
    this.initialSetScore,
  });

  @override
  Widget build(BuildContext context) {
    if (sportId == 2) return _buildBasketball(context);

    if (sportId == 4) return _buildTennis(context);

    if (sportId == 5) return _buildVolleyball(context);

    if (sportId == 6) return _buildTableTennis(context);

    if (sportId == 7) return _buildBadminton(context);

    return _buildDefault(context);
  }

  Widget _buildBasketball(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final (gameTimeMs, gamePart) = ref.watch(
          eventLiveProvider.select((state) {
            final data = state.getEvent(eventId);
            return (data?.gameTimeMs ?? 0, data?.gamePart ?? 0);
          }),
        );

        final display = betting.resolveLiveTimeDisplay(
          sportId: 2,
          gamePart: gamePart,
          gameTime: gameTimeMs,
        );
        final period = display.hasLeft ? display.left! : _formatRawPeriod(initialPeriod);

        final defaultStyle =
            style ??
            AppTextStyles.textStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFFFFEF5),
            );

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (period != null) ...[
              Flexible(
                child: Text(
                  period,
                  style: leadingStyle ?? defaultStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              separator ??
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Container(
                      width: 1,
                      height: 10,
                      color: const Color(0xFF74736F),
                    ),
                  ),
            ],
            BasketballCountdownTimer(
              eventId: eventId,
              initialTimeMs: gameTimeMs,
              style: period == null
                  ? (leadingStyle ?? defaultStyle)
                  : defaultStyle,
            ),
          ],
        );
      },
    );
  }

  Widget _buildTennis(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final gamePart = ref.watch(
          eventLiveProvider.select((state) {
            final data = state.getEvent(eventId);
            return data?.gamePart ?? 0;
          }),
        );

        final display = betting.resolveLiveTimeDisplay(
          sportId: 4,
          gamePart: gamePart,
        );
        final period = display.hasLeft ? display.left : _formatRawPeriod(initialPeriod);

        final defaultStyle =
            style ??
            AppTextStyles.textStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFFFFEF5),
            );

        return _buildPeriodScoreRow(
          period: period,
          scoreText: null,
          style: defaultStyle,
        );
      },
    );
  }

  String? get _setScoreText {
    final s = initialSetScore;
    if (s == null) return null;
    return '${s.$1}-${s.$2}';
  }

  Widget _buildVolleyball(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final gamePart = ref.watch(
          eventLiveProvider.select((state) {
            final data = state.getEvent(eventId);
            return data?.gamePart ?? 0;
          }),
        );

        final display = betting.resolveLiveTimeDisplay(
          sportId: 5,
          gamePart: gamePart,
          currentSet: initialCurrentSet,
          homeScore: initialSetScore?.$1,
          awayScore: initialSetScore?.$2,
        );

        final defaultStyle =
            style ??
            AppTextStyles.textStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFFFFEF5),
            );

        return _buildPeriodScoreRow(
          period: display.hasLeft ? display.left : null,
          scoreText: display.hasRight ? display.right : _setScoreText,
          style: defaultStyle,
        );
      },
    );
  }

  Widget _buildBadminton(BuildContext context) {
    final display = betting.resolveLiveTimeDisplay(
      sportId: 7,
      gamePart: 0,
      currentSet: initialCurrentSet,
      homeScore: initialSetScore?.$1,
      awayScore: initialSetScore?.$2,
    );

    final defaultStyle =
        style ??
        AppTextStyles.textStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: const Color(0xFFFFFEF5),
        );

    return _buildPeriodScoreRow(
      period: display.hasLeft ? display.left : null,
      scoreText: display.hasRight ? display.right : _setScoreText,
      style: defaultStyle,
    );
  }

  Widget _buildTableTennis(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final gamePart = ref.watch(
          eventLiveProvider.select((state) {
            final data = state.getEvent(eventId);
            return data?.gamePart ?? 0;
          }),
        );

        final display = betting.resolveLiveTimeDisplay(
          sportId: 6,
          gamePart: gamePart,
        );
        final period = display.hasLeft ? display.left : _formatRawPeriod(initialPeriod);

        final defaultStyle =
            style ??
            AppTextStyles.textStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFFFFEF5),
            );

        return _buildPeriodScoreRow(
          period: period,
          scoreText: null,
          style: defaultStyle,
        );
      },
    );
  }

  Widget _buildPeriodScoreRow({
    String? period,
    String? scoreText,
    required TextStyle style,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (period != null) Text(period, style: leadingStyle ?? style),
        if (period != null && scoreText != null)
          separator ??
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Container(
                  width: 1,
                  height: 10,
                  color: const Color(0xFF74736F),
                ),
              ),
        if (scoreText != null)
          Flexible(
            child: Text(
              scoreText,
              style: period == null ? (leadingStyle ?? style) : style,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }

  Widget _buildDefault(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final (gameTime, gamePart, stoppageTime) = ref.watch(
          eventLiveProvider.select((state) {
            final data = state.getEvent(eventId);
            return (
              data?.gameTime ?? 0,
              data?.gamePart ?? 0,
              data?.stoppageTime ?? 0,
            );
          }),
        );

        String? minute;
        String? period;

        final stoppagePeriod = stoppageTime > 0
            ? _formatStoppagePeriod(gamePart, gameTime)
            : null;

        if (stoppagePeriod != null) {
          minute = "$stoppageTime'";
          period = stoppagePeriod;
        } else {
          if (gameTime > 0) {
            minute = "$gameTime'";
          } else if (gamePart <= GamePart.regulaTimeFinished.value) {
            minute = _isValidMinuteString(initialMinute) ? initialMinute : null;
          } else {
            minute = null;
          }

          if (gamePart > 0) {
            period = _formatPeriod(gamePart, gameTime);
          } else {
            period = _formatRawPeriod(initialPeriod);
          }
        }

        if (period != null && _isStoppedClockPeriod(period)) {
          minute = null;
        }

        final defaultStyle =
            style ??
            AppTextStyles.textStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFFFFEF5),
            );

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (minute != null)
              Text(minute, style: leadingStyle ?? defaultStyle),
            if (minute != null && period != null) ...[
              separator ??
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Container(
                      width: 1,
                      height: 10,
                      color: const Color(0xFF74736F),
                    ),
                  ),
            ],
            if (period != null)
              Flexible(
                child: Text(
                  period,
                  style: minute == null
                      ? (leadingStyle ?? defaultStyle)
                      : defaultStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        );
      },
    );
  }

  String? _formatStoppagePeriod(int gamePart, int gameTime) =>
      GamePart.resolveLive(gamePart, gameTimeMinutes: gameTime).stoppageLabel;

  String _formatPeriod(int gamePart, int gameTime) =>
      GamePart.resolveLive(gamePart, gameTimeMinutes: gameTime).viPeriodLabel;

  static const _stoppedClockPeriods = {
    'Hết hiệp 1',
    'Trận đấu kết thúc',
    'Hết hiệp chính',
    'Hết hiệp phụ 1',
    'Hết hiệp phụ',
    'Nghỉ',
    'Penalty',
  };

  bool _isStoppedClockPeriod(String period) =>
      _stoppedClockPeriods.contains(period);

  bool _isValidMinuteString(String? value) {
    if (value == null || value.isEmpty) return false;
    return value.contains(RegExp(r'\d'));
  }

  String? _formatRawPeriod(String? rawPeriod) {
    if (rawPeriod == null || rawPeriod.isEmpty) return null;

    final normalized = rawPeriod.trim().toUpperCase();
    switch (normalized) {
      case '1H':
      case 'FIRST HALF':
      case '1ST HALF':
        return 'Hiệp 1';
      case '2H':
      case 'SECOND HALF':
      case '2ND HALF':
        return 'Hiệp 2';
      case 'HT':
      case 'HALF TIME':
      case 'HALFTIME':
        return 'Hết hiệp 1';
      case 'FT':
      case 'FULL TIME':
      case 'FULLTIME':
      case 'FINISHED':
        return 'Trận đấu kết thúc';
      case 'ET':
      case 'EXTRA TIME':
      case 'EXTRATIME':
        return 'Hiệp phụ';
      case 'ET1':
      case 'ET 1ST':
      case 'FIRST HALF EXTRA TIME':
        return 'Hiệp phụ 1';
      case 'ET2':
      case 'ET 2ND':
      case 'SECOND HALF EXTRA TIME':
        return 'Hiệp phụ 2';
      case 'ET-HT':
      case 'EXTRA TIME HALF TIME':
        return 'Hết hiệp phụ 1';
      case 'AET':
      case 'AFTER EXTRA TIME':
        return 'Hết hiệp phụ';
      case 'PEN':
      case 'PENALTIES':
      case 'PENALTY':
        return 'Penalty';
      case 'RUNNING':
      case 'LIVE':
      case 'IN PLAY':
        return null;
      case 'NOT STARTED':
      case 'NS':
        return null;
      case 'BRK':
      case 'BREAK':
        return 'Nghỉ';
      case "90'":
        return 'Hết hiệp chính';
      default:
        return rawPeriod;
    }
  }
}

class SuspendedOpacityWrapper extends StatelessWidget {
  final int eventId;
  final int marketId;
  final Widget child;
  final double suspendedOpacity;

  const SuspendedOpacityWrapper({
    super.key,
    required this.eventId,
    required this.marketId,
    required this.child,
    this.suspendedOpacity = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final isSuspended = ref.watch(
          isMarketSuspendedProvider((eventId, marketId)),
        );

        return Opacity(
          opacity: isSuspended ? suspendedOpacity : 1.0,
          child: child,
        );
      },
    );
  }
}

class SuspendedOverlay extends StatelessWidget {
  final int eventId;
  final int marketId;
  final Widget child;

  const SuspendedOverlay({
    super.key,
    required this.eventId,
    required this.marketId,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final isSuspended = ref.watch(
          isMarketSuspendedProvider((eventId, marketId)),
        );

        return Stack(
          children: [
            child,
            if (isSuspended)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  alignment: Alignment.center,
                  child: Text(
                    'Tạm ngưng',
                    style: AppTextStyles.textStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
