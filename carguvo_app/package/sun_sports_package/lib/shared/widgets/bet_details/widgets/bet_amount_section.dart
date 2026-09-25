import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sun_sports/core/utils/money_formatter.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/shared/widgets/bet_details/models/betting_popup_data.dart';
import 'package:sun_sports/shared/widgets/scoin_icon.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/stake_keypad/stake_keypad.dart';
import 'package:sun_sports/shared/widgets/stake_keypad/stake_keypad_controller.dart';
import 'package:sun_sports/shared/widgets/stake_keypad/stake_keypad_field.dart';
import 'package:sun_sports/shared/widgets/stake_keypad/stake_keypad_math.dart';

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final numericOnly = newValue.text.replaceAll(',', '');

    if (numericOnly.isEmpty || int.tryParse(numericOnly) == null) {
      return oldValue;
    }

    final formattedText = _formatWithCommas(numericOnly);

    final newSelection = newValue.selection.baseOffset;
    var digitsBeforeCursor = 0;
    for (var i = 0; i < newValue.text.length && i < newSelection; i++) {
      if (newValue.text[i] != ',') {
        digitsBeforeCursor++;
      }
    }

    if (digitsBeforeCursor > numericOnly.length) {
      digitsBeforeCursor = numericOnly.length;
    }

    var newCursorPosition = formattedText.length;
    if (digitsBeforeCursor == 0) {
      newCursorPosition = 0;
    } else {
      var digitCount = 0;
      for (var i = 0; i < formattedText.length; i++) {
        if (formattedText[i] != ',') {
          digitCount++;
          if (digitCount == digitsBeforeCursor) {
            newCursorPosition = i + 1;
            break;
          }
        }
      }
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );
  }

  String _formatWithCommas(String number) {
    if (number.isEmpty) return '';

    final buffer = StringBuffer();
    var counter = 0;

    for (var i = number.length - 1; i >= 0; i--) {
      if (counter > 0 && counter % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(number[i]);
      counter++;
    }

    return buffer.toString().split('').reversed.join('');
  }
}

class BetAmountSection extends StatefulWidget {
  final String betAmount;
  final void Function(String) onBetAmountChanged;
  final BettingPopupData? data;
  final int minStake;
  final int maxStake;

  final int userBalance;

  const BetAmountSection({
    super.key,
    required this.betAmount,
    required this.onBetAmountChanged,
    this.data,
    this.minStake = 0,
    this.maxStake = 0,
    this.userBalance = 0,
  });

  @override
  State<BetAmountSection> createState() => BetAmountSectionState();
}

class BetAmountSectionState extends State<BetAmountSection> {
  static const String _keypadId = StakeKeypadController.popupId;

  late int _stake = _parse(widget.betAmount);
  Timer? _normalizeDebounce;

  static int _parse(String amount) =>
      int.tryParse(amount.replaceAll(',', '')) ?? 0;

  void _normalizeStake() {
    final stake = _stake;
    final floored = MoneyFormatter.floorToThousand(stake);
    if (floored == stake || floored <= 0) return;
    _setStake(floored);
  }

  void _scheduleNormalize() {
    _normalizeDebounce?.cancel();
    _normalizeDebounce = Timer(MoneyFormatter.stakeNormalizeDebounce, () {
      if (mounted) _normalizeStake();
    });
  }

  void _onKeypadClosed() {
    _normalizeDebounce?.cancel();
    _normalizeStake();
  }

  @override
  void didUpdateWidget(BetAmountSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.betAmount != oldWidget.betAmount) {
      final pushed = _parse(widget.betAmount);
      if (pushed != _stake) {
        _stake = pushed;
        StakeKeypadController.instance.adopt(_keypadId, pushed);
      }
    }
  }

  @override
  void dispose() {
    _normalizeDebounce?.cancel();
    super.dispose();
  }

  void _onKeypadChanged(int value, StakeKey key) {
    _scheduleNormalize();
    var next = value;
    final cap = _balanceCap;
    if (cap > 0 && next > cap) {
      next = MoneyFormatter.floorToThousand(cap);
    }
    _setStake(next);
  }

  void _setStake(int value) {
    if (_stake != value) setState(() => _stake = value);
    StakeKeypadController.instance.adopt(_keypadId, value);
    widget.onBetAmountChanged(_formatMoney(value));
  }

  void _clearAmount() => _setStake(0);

  String _formatMoney(int amount) {
    if (amount == 0) return '0';
    return NumberFormat('#,###').format(amount);
  }

  int get _currentStake => _stake;

  int get _minStakeActual => widget.minStake * 1000;

  int get _maxStakeActual => widget.maxStake * 1000;

  int get _balanceCap {
    final maxStake = _maxStakeActual;
    final balance = widget.userBalance;
    if (balance <= 0) return maxStake;
    if (maxStake <= 0) return balance;
    return maxStake < balance ? maxStake : balance;
  }

  void _setMinStake() => _setStake(_minStakeActual);

  void _setMaxStake() => _setStake(_maxStakeActual);

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      StakeKeypadField(
        id: _keypadId,
        value: _stake,
        onChanged: _onKeypadChanged,
        onClosed: _onKeypadClosed,
        suffix: const SCoinIcon(),
        onClear: SoundTap.wrap(_clearAmount),
      ),
      const SizedBox(height: 8),
      _buildStakeLimitInfo(),
      StakeKeypadSlot(
        id: _keypadId,
        maxStake: _maxStakeActual,
        balance: widget.userBalance,
      ),
    ],
  );

  Widget _buildStakeLimitInfo() {
    final stake = _currentStake;
    final minStake = _minStakeActual;
    final maxStake = _maxStakeActual;

    if (stake > 0 && stake < minStake) {
      return Row(
        children: [
          Text(
            'Mức cược tối thiểu: ',
            style: AppTextStyles.paragraphXSmall(color: AppColors.red500),
          ),
          GestureDetector(
            onTap: SoundTap.wrap(_setMinStake),
            child: Text(
              MoneyFormatter.formatCompact(minStake),
              style: AppTextStyles.paragraphXSmall(color: AppColors.yellow500)
                  .copyWith(
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.yellow500,
                  ),
            ),
          ),
        ],
      );
    }

    if (stake > maxStake && maxStake > 0) {
      return Row(
        children: [
          Text(
            'Mức cược tối đa: ',
            style: AppTextStyles.paragraphXSmall(color: AppColors.red500),
          ),
          GestureDetector(
            onTap: SoundTap.wrap(_setMaxStake),
            child: Text(
              MoneyFormatter.formatCompact(maxStake),
              style: AppTextStyles.paragraphXSmall(color: AppColors.yellow500)
                  .copyWith(
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.yellow500,
                  ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Text(
          'Mức cược: ',
          style: AppTextStyles.paragraphXSmall(
            color: AppColorStyles.contentSecondary,
          ),
        ),
        Text(
          '${MoneyFormatter.formatCompact(minStake)} - ${MoneyFormatter.formatCompact(maxStake)}',
          style: AppTextStyles.paragraphXSmall(
            color: AppColorStyles.contentSecondary,
          ),
        ),
      ],
    );
  }
}
