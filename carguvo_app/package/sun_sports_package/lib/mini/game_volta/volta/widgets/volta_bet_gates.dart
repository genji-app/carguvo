import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/core/utils/styles/app_text_styles.dart';

import '../../common/domain/volta_bet_rules.dart';
import '../../common/state/volta_models.dart';
import '../../common/state/volta_state_provider.dart';
import '../../common/volta_colors.dart';
import '../../common/volta_feedback.dart';
import '../../common/volta_layout_spec.dart';
import '../../common/volta_gradients.dart';
import '../../common/volta_icons.dart';
import '../../common/volta_rules.dart';
import '../../common/widgets/volta_gate_background.dart';
import '../../common/widgets/volta_gold_text.dart';
import '../../common/widgets/volta_team_logo.dart';
import 'volta_victory_fx.dart';

class VoltaBetGates extends ConsumerWidget {
  const VoltaBetGates({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final VoltaLayoutSpec spec = VoltaLayoutScope.of(context);
    final double padBottom = spec.gatesBlockHeight - spec.gateHeight - 4;

    return Padding(
      padding: EdgeInsets.fromLTRB(0, 4, 0, padBottom),
      child: SizedBox(
        height: spec.gateHeight,
        child: Row(
          children: <Widget>[
            const Expanded(child: VoltaBetGate(side: VoltaSide.home)),
            SizedBox(width: spec.gateGap),
            const Expanded(child: VoltaBetGate(side: VoltaSide.away)),
          ],
        ),
      ),
    );
  }
}

class VoltaBetGate extends ConsumerWidget {
  const VoltaBetGate({required this.side, super.key});

  final VoltaSide side;

  bool get _isHome => side == VoltaSide.home;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final team = ref.watch(
      voltaStateProvider.select((s) => s.round?.teamOf(side)),
    );
    final stake = ref.watch(
      voltaStateProvider.select((s) => s.round?.stakeOf(side) ?? 0),
    );
    final players = ref.watch(
      voltaStateProvider.select((s) => s.round?.playersOf(side) ?? 0),
    );
    final myStake =
        ref.watch(voltaStateProvider.select((s) => s.myStake.of(side)));

    final bool isWinner = ref.watch(
      voltaStateProvider.select(
        (s) =>
            s.phase == VoltaRoundPhase.result &&
            s.lastResult?.winner ==
                (_isHome ? VoltaWinner.home : VoltaWinner.away),
      ),
    );
    final int fxSeed = voltaFxSeed(
      ref.watch(voltaStateProvider.select((s) => s.round?.eventId ?? '')),
      isHome: _isHome,
    );

    final VoltaLayoutSpec spec = VoltaLayoutScope.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => unawaited(_onTap(context, ref)),
      child: DecoratedBox(
          decoration: _isHome ? _homeDecoration : _awayDecoration,
          child: ClipRRect(
            borderRadius: _cardRadius,
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: VoltaGateBackground(
                    home: _isHome,
                    borderRadius: _cardRadius,
                  ),
                ),
                if (isWinner)
                  Positioned.fill(
                    key: ValueKey<String>('glow-$fxSeed'),
                    child: VoltaVictoryGlow(
                      innerGradient: _isHome
                          ? VoltaGradients.homeGate
                          : VoltaGradients.awayGate,
                      borderRadius: _cardRadius,
                      innerLayer: VoltaGateBackground(
                        home: _isHome,
                        borderRadius: _cardRadius,
                        drawBorder: false,
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: _body(spec, team, stake, myStake, isWinner),
                ),
                Positioned(
                  left: _isHome ? 0 : null,
                  right: _isHome ? null : 0,
                  top: 0,
                  child: _roleChip(spec),
                ),
                Positioned(
                  left: _isHome ? null : 0,
                  right: _isHome ? 0 : null,
                  top: 0,
                  child: _playersChip(spec, players),
                ),
                Positioned(
                  left: _isHome ? 8 : null,
                  right: _isHome ? null : 8,
                  top: spec.gateCornerHeight + 1,
                  child: Text(
                    team == null ? '--' : team.odds.toStringAsFixed(2),
                    style: _oddsStyle(spec),
                  ),
                ),
                if (isWinner)
                  Positioned.fill(
                    key: ValueKey<String>('fx-$fxSeed'),
                    child: VoltaVictoryFx(
                      tone: _isHome ? VoltaFxTone.warm : VoltaFxTone.cool,
                      seed: fxSeed,
                    ),
                  ),
              ],
            ),
          ),
        ),
    );
  }

  static const double _logoNameGap = 3;

  Future<void> _onTap(BuildContext context, WidgetRef ref) async {
    VoltaFeedback.click();
    if (!VoltaFeedback.requireSignedIn(context, ref)) return;
    final VoltaBetOutcome outcome = await VoltaBetLoading.run(
      context,
      () => ref.read(voltaStateProvider.notifier).placeBet(side),
    );
    if (!context.mounted) return;
    VoltaBetFeedback.show(context, outcome);
  }

  Widget _body(
    VoltaLayoutSpec spec,
    VoltaTeam? team,
    int stake,
    int myStake,
    bool isWinner,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        SizedBox(height: spec.gatePadTop),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: spec.gateLogoSize,
              height: spec.gateLogoSize,
              child: isWinner
                  ? VoltaWinLogoPulse(child: _logo(spec, team))
                  : _logo(spec, team),
            ),
          ),
        ),
        const SizedBox(height: _logoNameGap),
        SizedBox(
          height: spec.gateNameHeight,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                team?.name ?? '—',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.labelXXSmall(
                  color: _isHome ? VoltaColors.red300 : VoltaColors.yellow300,
                ).copyWith(fontSize: spec.gateNameFontSize),
              ),
            ),
          ),
        ),
        SizedBox(height: spec.gateGapNameStake),
        _stakeBar(spec, stake),
        SizedBox(height: spec.gateGapStakeMine),
        _myStakePill(spec, myStake),
        SizedBox(height: spec.gatePadBottom),
      ],
    );
  }

  Widget _logo(VoltaLayoutSpec spec, VoltaTeam? team) =>
      VoltaTeamLogo(url: team?.logoUrl, size: spec.gateLogoSize);

  Widget _stakeBar(VoltaLayoutSpec spec, int stake) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: RepaintBoundary(
        child: _StakePop(
          stake: stake,
          style: _moneyStyle(spec),
        ),
      ),
    );
  }

  Widget _myStakePill(VoltaLayoutSpec spec, int myStake) {
    final bool placed = myStake > 0;
    return SizedBox(
      width: spec.gateMyStakeWidth,
      height: spec.gateMyStakeHeight,
      child: AnimatedOpacity(
        opacity: placed ? 1 : 0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: DecoratedBox(
          decoration: _isHome ? _homeMyStake : _awayMyStake,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: VoltaGoldText(
                placed ? _money(myStake) : '0',
                style: _myStakeStyle(spec),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleChip(VoltaLayoutSpec spec) {
    return Container(
      height: spec.gateCornerHeight,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: spec.gateRolePadH),
      decoration: BoxDecoration(
        color: _isHome
            ? VoltaColors.gateCornerChip
            : VoltaColors.awayCornerChip,
        borderRadius: _isHome
            ? BorderRadius.only(
                bottomRight: Radius.circular(spec.gateCornerRadius),
              )
            : BorderRadius.only(
                bottomLeft: Radius.circular(spec.gateCornerRadius),
              ),
      ),
      child: Text(
        _isHome ? 'ĐỘI NHÀ' : 'ĐỘI KHÁCH',
        style: AppTextStyles.labelXXSmall(color: VoltaColors.contentPrimary)
            .copyWith(fontSize: spec.gateRoleFontSize),
      ),
    );
  }

  Widget _playersChip(VoltaLayoutSpec spec, int players) {
    final TextStyle countStyle =
        AppTextStyles.paragraphXXSmall(color: VoltaColors.contentSecondary)
            .copyWith(
              fontSize: spec.gatePlayersFontSize,
              height: 12.924 / 8,
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            );
    final Widget count = SizedBox(
      width: _playersWidth(countStyle),
      child: Text(
        _players(players),
        style: countStyle,
        textAlign: TextAlign.center,
        maxLines: 1,
      ),
    );
    final Widget icon = VoltaIcons.users(size: spec.gatePlayersIconSize);
    final Widget gap = SizedBox(width: spec.gatePlayersGap);

    return Container(
      height: spec.gateCornerHeight,
      alignment: Alignment.center,
      padding: EdgeInsets.only(
        left: _isHome ? spec.gatePlayersPadEnd : spec.gatePlayersPadStart,
        right: _isHome ? spec.gatePlayersPadStart : spec.gatePlayersPadEnd,
      ),
      decoration: BoxDecoration(
        color: _isHome
            ? VoltaColors.gateCornerChip
            : VoltaColors.awayCornerChip,
        borderRadius: _isHome
            ? BorderRadius.only(
                bottomLeft: Radius.circular(spec.gateCornerRadius),
              )
            : BorderRadius.only(
                bottomRight: Radius.circular(spec.gateCornerRadius),
                topLeft: _radius.topLeft,
              ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _isHome
            ? <Widget>[icon, gap, count]
            : <Widget>[count, gap, icon],
      ),
    );
  }

  static String _money(int value) {
    final digits = value.abs().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return value < 0 ? '-$buffer' : buffer.toString();
  }

  static const int _playersCap = 100000;

  static const String _playersWidest = '99,999';

  static String _players(int value) =>
      value >= _playersCap ? '100K' : _money(value);

  static final Map<double, double> _playersWidthCache = <double, double>{};

  static double _playersWidth(TextStyle style) {
    final double key = style.fontSize ?? 8;
    final double? cached = _playersWidthCache[key];
    if (cached != null) return cached;
    final TextPainter painter = TextPainter(
      text: TextSpan(text: _playersWidest, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final double width = painter.width;
    painter.dispose();
    _playersWidthCache[key] = width;
    return width;
  }

  static TextStyle _oddsStyle(VoltaLayoutSpec spec) =>
      AppTextStyles.paragraphXXSmall(color: VoltaColors.contentPrimary)
          .copyWith(fontSize: spec.gateOddsFontSize, height: 12.924 / 8);

  static TextStyle _moneyStyle(VoltaLayoutSpec spec) =>
      AppTextStyles.labelSmall()
          .copyWith(fontSize: spec.gateStakeFontSize, height: 1);

  static TextStyle _myStakeStyle(VoltaLayoutSpec spec) =>
      AppTextStyles.labelXSmall()
          .copyWith(fontSize: spec.gateMyStakeFontSize, height: 1);

  BorderRadius get _cardRadius => _radius;

  static const BorderRadius _radius = BorderRadius.only(
    topLeft: Radius.circular(11.5),
    topRight: Radius.circular(30),
    bottomRight: Radius.circular(15),
    bottomLeft: Radius.circular(11.5),
  );

  static final BoxDecoration _homeDecoration = BoxDecoration(
    borderRadius: _radius,
  );

  static final BoxDecoration _awayDecoration = BoxDecoration(
    borderRadius: _radius,
  );

  static final BoxDecoration _homeMyStake = BoxDecoration(
    color: VoltaColors.myStakePill,
    borderRadius: BorderRadius.circular(72),
    border: Border.all(color: VoltaColors.myStakePillBorder, width: 0.72),
  );

  static final BoxDecoration _awayMyStake = BoxDecoration(
    color: VoltaColors.myStakePill,
    borderRadius: BorderRadius.circular(72),
    border: Border.all(
      color: VoltaColors.awayMyStakePillBorder,
      width: 0.72,
    ),
  );
}

class _StakePop extends StatefulWidget {
  const _StakePop({required this.stake, required this.style});

  final int stake;
  final TextStyle style;

  @override
  State<_StakePop> createState() => _StakePopState();
}

class _StakePopState extends State<_StakePop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: VoltaRules.stakeGrowDuration,
    reverseDuration: VoltaRules.stakeShrinkDuration,
  );

  late final Animation<double> _heat = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
    reverseCurve: Curves.easeIn,
  );

  Timer? _idle;

  @override
  void didUpdateWidget(covariant _StakePop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stake == oldWidget.stake) return;

    _controller.forward();
    _idle?.cancel();
    _idle = Timer(VoltaRules.stakeIdleBeforeShrink, () {
      if (mounted) _controller.reverse();
    });
  }

  @override
  void dispose() {
    _idle?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _heat,
      builder: (BuildContext context, Widget? child) => Transform.scale(
        scale: 1 + (VoltaRules.stakeGrowScale - 1) * _heat.value,
        child: child,
      ),
      child: VoltaGoldText(
        VoltaBetGate._money(widget.stake),
        style: widget.style,
        textAlign: TextAlign.center,
      ),
    );
  }
}
