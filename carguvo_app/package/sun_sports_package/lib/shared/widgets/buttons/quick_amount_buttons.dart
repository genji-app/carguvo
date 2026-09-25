import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class QuickAmountButton {
  final String label;
  final String value;
  final bool isSelected;

  const QuickAmountButton({
    required this.label,
    required this.value,
    this.isSelected = false,
  });
}

class QuickAmountButtons extends StatefulWidget {
  final List<QuickAmountButton> buttons;

  final void Function(String value) onButtonTap;

  final int columnsPerRow;

  final double spacing;

  final bool useExternalSelection;

  final String? externalSelectedValue;

  const QuickAmountButtons({
    super.key,
    required this.buttons,
    required this.onButtonTap,
    this.columnsPerRow = 4,
    this.spacing = 5,
    this.useExternalSelection = false,
    this.externalSelectedValue,
  });

  @override
  State<QuickAmountButtons> createState() => _QuickAmountButtonsState();
}

class _QuickAmountButtonsState extends State<QuickAmountButtons> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    for (final QuickAmountButton button in widget.buttons) {
      if (button.isSelected) {
        _selectedValue = button.value;
        break;
      }
    }
  }

  void _handleTap(QuickAmountButton button) {
    if (!widget.useExternalSelection && _selectedValue != button.value) {
      setState(() => _selectedValue = button.value);
    }
    widget.onButtonTap(button.value);
  }

  @override
  Widget build(BuildContext context) {
    final String? activeValue = widget.useExternalSelection
        ? widget.externalSelectedValue
        : _selectedValue;

    final rows = <List<QuickAmountButton>>[];
    for (var i = 0; i < widget.buttons.length; i += widget.columnsPerRow) {
      rows.add(
        widget.buttons.sublist(
          i,
          i + widget.columnsPerRow > widget.buttons.length
              ? widget.buttons.length
              : i + widget.columnsPerRow,
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          Row(
            children: [
              for (var button in rows[i]) ...[
                Expanded(
                  child: _QuickAmountButton(
                    label: button.label,
                    isSelected: button.value == activeValue,
                    onTap: () => _handleTap(button),
                  ),
                ),
                if (button != rows[i].last) Gap(widget.spacing),
              ],
            ],
          ),
          if (i < rows.length - 1) Gap(widget.spacing),
        ],
      ],
    );
  }
}

class _QuickAmountButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickAmountButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  static final Color _idleBackground = const Color(
    0xFFFDE272,
  ).withValues(alpha: 0.08);

  static const Color _selectedBackground = AppColors.yellow950;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: SoundTap.wrap(onTap),
    borderRadius: BorderRadius.circular(100),
    child: Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? _selectedBackground : _idleBackground,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Center(
        child: Text(
          label,
          style: AppTextStyles.buttonSmall(
            color: const Color(0xFFFEEE95),
          ).copyWith(fontSize: 13),
        ),
      ),
    ),
  );
}
