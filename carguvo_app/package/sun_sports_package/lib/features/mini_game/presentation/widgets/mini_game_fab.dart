import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import '../state/mini_game_countdown_provider.dart';
import 'mini_game_lobby_tx_rive.dart';

class MiniGameFab extends ConsumerWidget {
  static const double size = 120;

  static const double mobileScale = 0.7;

  static const double mobileSize = size * mobileScale;

  static double scaleFor(BuildContext context) =>
      ResponsiveBuilder.isMobile(context) ? mobileScale : 1.0;

  static double sizeFor(BuildContext context) =>
      ResponsiveBuilder.isMobile(context) ? mobileSize : size;

  final VoidCallback onTap;

  const MiniGameFab({required this.onTap, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countdownAsync = ref.watch(miniGameCountdownProvider);
    final (taiXiuSec, taiXiuIsTai, awaiting) = countdownAsync.maybeWhen(
      data: (state) =>
          (state.taiXiuSec, state.taiXiuIsTai, state.taiXiuAwaitingResult),
      orElse: () => (null, null, false),
    );

    return GestureDetector(
      onTap: SoundTap.wrap(onTap),
      child: SizedBox(
        width: sizeFor(context),
        height: sizeFor(context),
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                MiniGameLobbyTxRive(
                  result: taiXiuSec != null ? null : taiXiuIsTai,
                  isLoading: awaiting,
                ),
                if (taiXiuSec != null)
                  Positioned(
                    right: 7,
                    top: 12,
                    child: SizedBox(
                      width: 36,
                      height: 26,
                      child: Center(
                        child: Text(
                          '$taiXiuSec',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFFFFEF5),
                            fontSize: 16,
                            height: 1.0,
                            leadingDistribution: TextLeadingDistribution.even,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
