import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/mini_game_icons.dart';

import '../../common/state/volta_models.dart';
import '../../common/domain/volta_round_clock.dart';
import '../../common/state/volta_state.dart';
import '../../common/state/volta_state_provider.dart';
import '../../common/volta_colors.dart';
import '../../common/volta_gradients.dart';
import '../../common/volta_layout_spec.dart';
import '../../common/widgets/volta_gold_text.dart';
import 'volta_live_player.dart';
import 'volta_live_preloader.dart';

class VoltaStage extends ConsumerStatefulWidget {
  const VoltaStage({super.key, this.widthDriven = false});

  final bool widthDriven;

  static const double horizontalPadding = 0;

  @override
  ConsumerState<VoltaStage> createState() => _VoltaStageState();
}

class _VoltaStageState extends ConsumerState<VoltaStage> {
  @override
  void initState() {
    super.initState();
    _warm(ref.read(voltaStateProvider).round?.liveUrl);
  }

  @override
  void dispose() {
    unawaited(VoltaLivePreloader.instance.clear());
    super.dispose();
  }

  void _warm(String? url) {
    if (url != null && url.isNotEmpty) VoltaLivePreloader.instance.warm(url);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(
      voltaStateProvider.select((VoltaState s) => s.round?.liveUrl),
      (String? _, String? next) => _warm(next),
    );

    final phase = ref.watch(voltaStateProvider.select((s) => s.phase));

    final Widget frame = _frame(phase);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: VoltaStage.horizontalPadding,
      ),
      child: widget.widthDriven
          ? SizedBox(
              width: double.infinity,
              child: AspectRatio(aspectRatio: 16 / 9, child: frame),
            )
          : SizedBox(
              width: double.infinity,
              height: VoltaLayoutScope.of(context).stageHeight,
              child: frame,
            ),
    );
  }

  Widget _frame(VoltaRoundPhase phase) {
    return DecoratedBox(
      decoration: _stageDecoration,
      child: ClipRRect(
        borderRadius: _radius,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: switch (phase) {
                VoltaRoundPhase.betting ||
                VoltaRoundPhase.idle =>
                  const _CountdownScene(),
                VoltaRoundPhase.playing ||
                VoltaRoundPhase.settling =>
                  const _PlayingScene(),
                VoltaRoundPhase.result => const _PlayingScene(),
              },
            ),
          ),
        );
  }

  static const BorderRadius _radius = BorderRadius.all(Radius.circular(12));

  static const BoxDecoration _stageDecoration = BoxDecoration(
    borderRadius: _radius,
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[Color(0xFF120B04), Color(0xFF2A1A08), Color(0xFF0B0703)],
      stops: <double>[0, 0.55, 1],
    ),
  );
}

class _CountdownScene extends StatelessWidget {
  const _CountdownScene();

  @override
  Widget build(BuildContext context) {
    final VoltaLayoutSpec spec = VoltaLayoutScope.of(context);

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Positioned.fill(
          child: ImageHelper.load(
            path: MiniGameIcons.voltaBackgroundCountdown,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: spec.countdownTitleTop,
          left: 0,
          right: 0,
          child: Center(
            child: VoltaGoldText(
              'TRẬN ĐẤU TIẾP THEO',
              gradient: VoltaGradients.countdownTitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelLarge(
                color: VoltaColors.contentPrimary,
                letterSpacing: 1.4,
              ).copyWith(fontSize: spec.countdownTitleFontSize, height: 1.2),
            ),
          ),
        ),
        const Center(child: RepaintBoundary(child: _Countdown())),
      ],
    );
  }
}

class _Countdown extends ConsumerWidget {
  const _Countdown();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int seconds = ref.watch(
      voltaStateProvider.select(
        (VoltaState s) => VoltaRoundClock.countdownDigits(s.secondsRemaining),
      ),
    );
    final VoltaLayoutSpec spec = VoltaLayoutScope.of(context);

    return VoltaGoldText(
      '$seconds',
      gradient: VoltaGradients.countdownDigits,
      style: AppTextStyles.labelLarge(color: VoltaColors.contentPrimary)
          .copyWith(
        fontSize: spec.countdownDigitsFontSize,
        height: 1.1,
      ),
      shadows: const <Shadow>[
        Shadow(color: Color(0xAAFFB732), blurRadius: 18),
      ],
    );
  }
}

class _PlayingScene extends ConsumerWidget {
  const _PlayingScene();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? url = ref.watch(
      voltaStateProvider.select((VoltaState s) => s.round?.liveUrl),
    );
    final int startSecond = ref.watch(
      voltaStateProvider.select((VoltaState s) => s.round?.startSecond ?? 0),
    );

    if (url != null && url.isNotEmpty) {
      return VoltaLivePlayer(
        key: ValueKey<String>(url),
        url: url,
        startSecond: startSecond,
      );
    }

    return const _PlayingPlaceholder();
  }
}

class _PlayingPlaceholder extends StatelessWidget {
  const _PlayingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.sports_soccer,
            size: 40,
            color: VoltaColors.contentPrimary.withAlpha(160),
          ),
          const SizedBox(height: 8),
          Text(
            'TRẬN ĐẤU ĐANG DIỄN RA',
            style: AppTextStyles.labelXSmall(
              color: VoltaColors.contentSecondary,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
