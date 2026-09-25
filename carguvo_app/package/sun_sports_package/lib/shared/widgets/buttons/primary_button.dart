import 'package:flutter/material.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isExpanded;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(onPressed: SoundTap.wrap(onPressed), child: Text(label));
    if (isExpanded) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
