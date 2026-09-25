import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/profile/deposit/presentation/widgets/ewallet_container.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class EWalletOverlay extends ConsumerStatefulWidget {
  const EWalletOverlay({super.key});

  @override
  ConsumerState<EWalletOverlay> createState() => _EWalletOverlayState();
}

class _EWalletOverlayState extends ConsumerState<EWalletOverlay> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: SoundTap.wrap(() => Navigator.of(context).pop()),
            child: Container(color: Colors.black.withValues(alpha: 0.5)),
          ),
        ),
        const EWalletContainer(),
      ],
    );
  }
}
