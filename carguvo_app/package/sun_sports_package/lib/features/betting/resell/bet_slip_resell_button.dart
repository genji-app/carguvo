import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/utils/app_logger.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/betting/my_bet/my_bet_menu.dart';
import 'package:sun_sports/features/my_bet_hub/my_bet_hub_providers.dart';
import 'package:sun_sports/shared/widgets/buttons/buttons.dart';
import 'package:sun_sports/shared/widgets/texts/texts.dart';

final _log = AppLogger(tag: 'ResellButton');

enum ResellButtonState { initial, confirming, processing }

@immutable
class ResellButtonUiState {
  const ResellButtonUiState({required this.phase, this.secondsLeft = 0});

  final ResellButtonState phase;

  final int secondsLeft;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResellButtonUiState &&
          other.phase == phase &&
          other.secondsLeft == secondsLeft);

  @override
  int get hashCode => Object.hash(phase, secondsLeft);
}

class _ResellButtonNotifier
    extends AutoDisposeFamilyNotifier<ResellButtonUiState, String> {
  Timer? _countdownTimer;
  Duration _confirmTimeout = const Duration(seconds: 15);

  @override
  ResellButtonUiState build(String arg) {
    ref.onDispose(_cancelTimer);

    ref.listen<bool>(myBetOverlayVisibleProvider, (previous, next) {
      if (!next) _resetIfConfirming('hub closed');
    });

    ref.listen<MyBetMenu>(
      myBetHubControllerProvider.select((c) => c.selectedMenu),
      (previous, next) {
        if (next != MyBetMenu.myBets) _resetIfConfirming('menu changed');
      },
    );

    return const ResellButtonUiState(phase: ResellButtonState.initial);
  }

  void setConfirmTimeout(Duration timeout) {
    _confirmTimeout = timeout;
  }

  void _cancelTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  void _resetIfConfirming(String reason) {
    if (state.phase == ResellButtonState.confirming) {
      _log.d('Cancel confirm state - $reason');
      reset();
    }
  }

  void _startCountdown() {
    _cancelTimer();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.phase != ResellButtonState.confirming) {
        _cancelTimer();
        return;
      }
      final remaining = state.secondsLeft - 1;
      if (remaining <= 0) {
        _log.d('Confirm countdown finished - resetting');
        reset();
      } else {
        state = ResellButtonUiState(
          phase: ResellButtonState.confirming,
          secondsLeft: remaining,
        );
      }
    });
  }

  void switchToConfirm() {
    _log.d('Switching to confirm mode');
    state = ResellButtonUiState(
      phase: ResellButtonState.confirming,
      secondsLeft: _confirmTimeout.inSeconds,
    );
    _startCountdown();
  }

  void switchToProcessing() {
    _log.d('Processing resell');
    _cancelTimer();
    state = const ResellButtonUiState(phase: ResellButtonState.processing);
  }

  void reset() {
    _log.d('Resetting to initial');
    _cancelTimer();
    state = const ResellButtonUiState(phase: ResellButtonState.initial);
  }

  void onSuccess() {
    _log.d('Resell successful');
    _cancelTimer();
  }
}

final _resellButtonProvider =
    AutoDisposeNotifierProvider.family<
      _ResellButtonNotifier,
      ResellButtonUiState,
      String
    >(() => _ResellButtonNotifier());

class BetSlipResellButton extends ConsumerStatefulWidget {
  const BetSlipResellButton({
    required this.amount,
    required this.buttonKey,
    super.key,
    this.onConfirm,
    this.size = const Size(double.infinity, 44),
    this.confirmTimeout = const Duration(seconds: 15),
    this.animationDuration = const Duration(milliseconds: 200),
    this.loadingIndicatorSize = 18.0,
    this.loadingIndicatorStroke = 2.0,
  });

  final num amount;

  final String buttonKey;

  final Future<bool> Function()? onConfirm;

  final Size size;

  final Duration confirmTimeout;
  final Duration animationDuration;
  final double loadingIndicatorSize;
  final double loadingIndicatorStroke;

  @override
  ConsumerState<BetSlipResellButton> createState() =>
      _BetSlipResellButtonState();
}

class _BetSlipResellButtonState extends ConsumerState<BetSlipResellButton> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(_resellButtonProvider(widget.buttonKey).notifier)
          .setConfirmTimeout(widget.confirmTimeout);
    });
  }

  Future<void> _handleTap() async {
    final notifier = ref.read(_resellButtonProvider(widget.buttonKey).notifier);
    final currentPhase = ref.read(_resellButtonProvider(widget.buttonKey)).phase;

    switch (currentPhase) {
      case ResellButtonState.initial:
        notifier.switchToConfirm();

      case ResellButtonState.confirming:
        notifier.switchToProcessing();

        final success = await widget.onConfirm?.call() ?? false;

        if (success) {
          notifier.onSuccess();
        } else {
          notifier.reset();
        }

      case ResellButtonState.processing:
        _log.d('Ignoring tap - processing');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox.fromSize(
          size: widget.size,
          child: AnimatedSwitcher(
            duration: widget.animationDuration,
            child: SizedBox.expand(
              child: Consumer(
                builder: (context, ref, _) {
                  final phase = ref.watch(
                    _resellButtonProvider(widget.buttonKey)
                        .select((s) => s.phase),
                  );

                  return switch (phase) {
                    ResellButtonState.initial => _SellButton(
                      amount: widget.amount,
                      onPressed: _handleTap,
                    ),
                    ResellButtonState.confirming => _ConfirmButton(
                      amount: widget.amount,
                      onPressed: _handleTap,
                    ),
                    ResellButtonState.processing => _LoadingButton(
                      indicatorSize: widget.loadingIndicatorSize,
                      indicatorStroke: widget.loadingIndicatorStroke,
                    ),
                  };
                },
              ),
            ),
          ),
        ),
        _ConfirmCountdownLabel(buttonKey: widget.buttonKey),
      ],
    );
  }
}

class _ConfirmCountdownLabel extends StatelessWidget {
  const _ConfirmCountdownLabel({required this.buttonKey});

  final String buttonKey;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final secondsLeft = ref.watch(
          _resellButtonProvider(buttonKey).select(
            (s) => s.phase == ResellButtonState.confirming ? s.secondsLeft : -1,
          ),
        );

        if (secondsLeft < 0) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                I18n.txtAutoCancelSellIn,
                style: AppTextStyles.paragraphMedium(
                  color: AppColorStyles.contentSecondary,
                ),
              ),
              const Gap(4),
              Text(
                '${secondsLeft}s',
                style: AppTextStyles.paragraphMedium(color: AppColors.blue400),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SellButton extends StatelessWidget {
  const _SellButton({required this.amount, required this.onPressed});

  final num amount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SecondaryButton.yellow(
      key: const ValueKey('resell_sell'),
      onPressed: onPressed,
      size: SecondaryButtonSize.md,
      label: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(I18n.txtSellTicket),
          const Text(':'),
          const Gap(6),
          CurrencyText.fromNumber(
            amount,
            spacing: 2,
            suffix: Container(
              margin: const EdgeInsets.only(top: 2),
              child: CurrencyText.defaultSuffix(size: 20),
            ),
            style: AppTextStyles.labelMedium(
              color: AppColorStyles.contentPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({required this.amount, required this.onPressed});

  final num amount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: ShineButton(
        key: const ValueKey('resell_confirm'),
        text:
            '${I18n.txtConfirmSellTicket}: ${CurrencyText.formatCurrency(amount)}',
        style: ShineButtonStyle.primaryYellow,
        width: double.infinity,
        onPressed: onPressed,
        trailingIcon: CurrencyText.defaultSuffix(size: 20),
      ),
    );
  }
}

class _LoadingButton extends StatelessWidget {
  const _LoadingButton({
    required this.indicatorSize,
    required this.indicatorStroke,
  });

  final double indicatorSize;
  final double indicatorStroke;

  @override
  Widget build(BuildContext context) {
    return SecondaryButton.yellow(
      key: const ValueKey('resell_loading'),
      onPressed: null,
      label: SizedBox.square(
        dimension: indicatorSize,
        child: CircularProgressIndicator(
          strokeWidth: indicatorStroke,
          color: AppColorStyles.contentTertiary,
        ),
      ),
    );
  }
}
