import 'package:casino_jackpot/casino_jackpot.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:provider_game_manager/provider_game_manager.dart';
import 'package:sun_sports/core/services/provider_game/jackpot_provider.dart';
import 'package:sun_sports/core/utils/device_capability/device_capability.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/scroll_aware_controller.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/tab_swipe_activity.dart';
import 'package:sun_sports/features/game/assets/assets.dart';
import 'package:sun_sports/features/game/cocos/widgets/cocos_download_card_overlay.dart';
import 'package:sun_sports/features/game/lobby_game_extensions.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/texts/gradient_text.dart';
import 'package:sun_sports/shared/widgets/viewport_visibility_builder.dart';

part 'game_card_cover.dart';
part 'game_card_jackpot.dart';
part 'game_card_layout.dart';

class GameCard extends StatelessWidget {
  const GameCard({
    required this.gameBlock,
    this.onPressed,

    this.cardWidth,
    super.key,
  });

  final LobbyGame gameBlock;
  final VoidCallback? onPressed;

  final double? cardWidth;

  @override
  Widget build(BuildContext context) {
    final double resolvedCardWidth =
        cardWidth ??
        GameCardLayout.cardWidthFromScreen(MediaQuery.sizeOf(context).width);
    final double tagH = GameCardLayout.tagHeight(resolvedCardWidth);
    final double providerTagH = GameCardLayout.providerTagHeight(tagH);
    final double radius = GameCardLayout.borderRadius(resolvedCardWidth);

    final Widget cover = hasMouse
        ? _GameCoverHoverable(
            imagePath: gameBlock.imagePath,
            gameName: gameBlock.gameName,
            providerName: gameBlock.providerName,
            tagPath: gameBlock.tagPath,
            providerTagPath: gameBlock.providerTagPath,
            gameId: gameBlock.gameId,
            tagHeight: tagH,
            providerTagHeight: providerTagH,
            borderRadius: radius,
            cardWidth: resolvedCardWidth,
          )
        : _GameCoverStatic(
            imagePath: gameBlock.imagePath,
            gameName: gameBlock.gameName,
            providerName: gameBlock.providerName,
            tagPath: gameBlock.tagPath,
            providerTagPath: gameBlock.providerTagPath,
            gameId: gameBlock.gameId,
            tagHeight: tagH,
            providerTagHeight: providerTagH,
            borderRadius: radius,
            cardWidth: resolvedCardWidth,
          );

    final String? bundle = gameBlock.gameBundle;
    final bool hasCocosOverlay =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android) &&
        bundle != null &&
        bundle.isNotEmpty;

    return RepaintBoundary(
      child: GestureDetector(
        onTap: SoundTap.wrap(onPressed),
        behavior: HitTestBehavior.opaque,
        child: AspectRatio(
          aspectRatio: GameCardLayout.cardAspectRatio,
          child: hasCocosOverlay
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    cover,
                    CocosDownloadCardOverlay(
                      gameBundle: bundle,
                      borderRadius: radius,
                    ),
                  ],
                )
              : cover,
        ),
      ),
    );
  }
}
