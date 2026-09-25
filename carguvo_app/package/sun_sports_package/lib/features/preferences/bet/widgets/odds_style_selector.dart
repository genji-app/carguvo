import 'package:flutter/material.dart' hide CloseButton;
import 'package:gap/gap.dart';

import 'package:sun_sports/features/preferences/bet/odds_info.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';
import 'gradient_radio_button.dart';
import 'odds_style_explanation.dart';

class OddsStyleSelector extends StatelessWidget {
  const OddsStyleSelector({super.key, this.onChanged, this.value});

  final ValueChanged<OddsStyle>? onChanged;
  final OddsStyle? value;

  @override
  Widget build(BuildContext context) {
    final children = OddsStyle.values.map((odds) {
      final isSelected = value != null && (value == odds);

      return Row(
        children: [
          Expanded(
            child: GradientRadioButton(
              onChanged: (value) => onChanged?.call(odds),
              selected: isSelected,
              child: Text(odds.label),
            ),
          ),
          const Gap(4),
          OddsStyleExplanationButton(odds: odds),
        ],
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: children,
    );
  }
}
