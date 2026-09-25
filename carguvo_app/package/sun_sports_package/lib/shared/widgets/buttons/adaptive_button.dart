import 'package:flutter/material.dart';
import '../../responsive/responsive_builder.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class AdaptiveButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const AdaptiveButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBuilder.isDesktop(context);
    final padding = isDesktop
        ? const EdgeInsets.symmetric(horizontal: 24, vertical: 16)
        : const EdgeInsets.symmetric(horizontal: 16, vertical: 12);

    return ElevatedButton(
      onPressed: SoundTap.wrap(onPressed),
      style: ElevatedButton.styleFrom(padding: padding),
      child: Text(label),
    );
  }
}
