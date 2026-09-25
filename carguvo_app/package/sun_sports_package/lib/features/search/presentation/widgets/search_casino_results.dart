import 'package:flutter/material.dart';
import 'package:provider_game_manager/provider_game_manager.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/spacing_styles.dart';
import 'package:sun_sports/features/search/presentation/widgets/search_casino_result_list.dart';

class SearchCasinoResults extends StatelessWidget {
  const SearchCasinoResults({
    required this.games,
    super.key,
    this.onGameTap,
    this.emptyMessage = 'Không tìm thấy kết quả',
  });

  final List<LobbyGame> games;
  final void Function(LobbyGame game)? onGameTap;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (games.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacingStyles.space600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ImageHelper.load(
                path: AppImages.iconSearchNoResultCasino,
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: AppTextStyles.paragraphMedium(
                  color: AppColorStyles.contentTertiary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SearchCasinoResultList(games: games, onGameTap: onGameTap);
  }
}
