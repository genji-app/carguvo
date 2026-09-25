import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/sport/presentation/providers/event_live_provider.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';

class ScoreDisplay extends ConsumerStatefulWidget {
  final int eventId;
  final int initialHome;
  final int initialAway;
  final TextStyle? style;
  final Color? flashColor;
  final Duration flashDuration;

  const ScoreDisplay({
    super.key,
    required this.eventId,
    this.initialHome = 0,
    this.initialAway = 0,
    this.style,
    this.flashColor,
    this.flashDuration = const Duration(milliseconds: 500),
  });

  @override
  ConsumerState<ScoreDisplay> createState() => _ScoreDisplayState();
}

class _ScoreDisplayState extends ConsumerState<ScoreDisplay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flashController;
  late final Animation<Color?> _flashAnimation;

  int? _previousHome;
  int? _previousAway;

  @override
  void initState() {
    super.initState();

    _flashController = AnimationController(
      vsync: this,
      duration: widget.flashDuration,
    );

    final flashColor = widget.flashColor ?? const Color(0xFFFFD700);

    _flashAnimation = ColorTween(
      begin: Colors.transparent,
      end: flashColor.withOpacity(0.3),
    ).animate(CurvedAnimation(parent: _flashController, curve: Curves.easeOut));

    _previousHome = widget.initialHome;
    _previousAway = widget.initialAway;
  }

  @override
  void dispose() {
    _flashController.dispose();
    super.dispose();
  }

  void _triggerFlash() {
    _flashController.forward(from: 0).then((_) {
      if (mounted) {
        _flashController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final score = ref.watch(eventScoreProvider(widget.eventId));
    final homeScore = score?.$1 ?? widget.initialHome;
    final awayScore = score?.$2 ?? widget.initialAway;

    if (_previousHome != null && _previousAway != null) {
      if (homeScore != _previousHome || awayScore != _previousAway) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _triggerFlash();
        });
      }
    }
    _previousHome = homeScore;
    _previousAway = awayScore;

    final textStyle =
        widget.style ??
        AppTextStyles.textStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFFFFEF5),
        );

    return AnimatedBuilder(
      animation: _flashAnimation,
      builder: (context, child) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: _flashAnimation.value,
          borderRadius: BorderRadius.circular(4),
        ),
        child: child,
      ),
      child: Text('$homeScore - $awayScore', style: textStyle),
    );
  }
}

class SingleScoreDisplay extends ConsumerStatefulWidget {
  final int eventId;
  final bool isHome;
  final int initialValue;
  final TextStyle? style;
  final Color? flashColor;

  const SingleScoreDisplay({
    super.key,
    required this.eventId,
    required this.isHome,
    this.initialValue = 0,
    this.style,
    this.flashColor,
  });

  @override
  ConsumerState<SingleScoreDisplay> createState() => _SingleScoreDisplayState();
}

class _SingleScoreDisplayState extends ConsumerState<SingleScoreDisplay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flashController;
  late final Animation<Color?> _flashAnimation;

  int? _previousValue;

  @override
  void initState() {
    super.initState();

    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    final flashColor = widget.flashColor ?? const Color(0xFFFFD700);

    _flashAnimation = ColorTween(
      begin: Colors.transparent,
      end: flashColor.withOpacity(0.3),
    ).animate(CurvedAnimation(parent: _flashController, curve: Curves.easeOut));

    _previousValue = widget.initialValue;
  }

  @override
  void dispose() {
    _flashController.dispose();
    super.dispose();
  }

  void _triggerFlash() {
    _flashController.forward(from: 0).then((_) {
      if (mounted) {
        _flashController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final score = ref.watch(eventScoreProvider(widget.eventId));
    final value = widget.isHome
        ? (score?.$1 ?? widget.initialValue)
        : (score?.$2 ?? widget.initialValue);

    if (_previousValue != null && value != _previousValue) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _triggerFlash();
      });
    }
    _previousValue = value;

    final textStyle =
        widget.style ??
        AppTextStyles.textStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: const Color(0xFFFFFEF5),
        );

    return AnimatedBuilder(
      animation: _flashAnimation,
      builder: (context, child) => Container(
        decoration: BoxDecoration(
          color: _flashAnimation.value,
          borderRadius: BorderRadius.circular(2),
        ),
        child: child,
      ),
      child: Text('$value', style: textStyle, textAlign: TextAlign.center),
    );
  }
}
