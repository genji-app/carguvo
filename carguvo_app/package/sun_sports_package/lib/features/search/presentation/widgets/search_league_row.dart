import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/services/models/api_v2/sport_constants.dart'
    show SportType;
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/search/data/models/search_league_item.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class SearchLeagueRow extends StatelessWidget {
  const SearchLeagueRow({
    super.key,
    required this.item,
    this.onTap,
    this.eventCount,
    this.isCounting = false,
  });

  final SearchLeagueItem item;

  final VoidCallback? onTap;

  final int? eventCount;

  final bool isCounting;

  String get _countSuffix {
    final count = eventCount;
    if (count != null) return ' ($count)';
    return isCounting ? ' (...)' : '';
  }

  static const double _minHeight = 48;
  static const double _logoSize = 24;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          color: AppColorStyles.backgroundTertiary,
          child: InkWell(
            onTap: SoundTap.wrap(onTap),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              constraints: const BoxConstraints(minHeight: _minHeight),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              child: Row(
                children: [
                  _buildLeagueIcon(),
                  const Gap(8),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: item.leagueName,
                        style: AppTextStyles.paragraphSmall(
                          color: AppColorStyles.contentPrimary,
                        ),
                        children: [
                          if (_countSuffix.isNotEmpty)
                            TextSpan(
                              text: _countSuffix,
                              style: AppTextStyles.paragraphSmall(
                                color: AppColorStyles.contentQuaternary,
                              ),
                            ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeagueIcon() {
    final url = item.leagueLogoUrl.trim();
    if (url.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(_logoSize / 2),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_logoSize / 2),
          ),
          width: _logoSize,
          height: _logoSize,
          child: ImageHelper.load(
            path: url,
            fit: BoxFit.contain,
            errorWidget: ImageHelper.load(path: _sportIconPath(item.sportId)),
          ),
        ),
      );
    }
    return ImageHelper.load(
      path: _sportIconPath(item.sportId),
      width: _logoSize,
      height: _logoSize,
    );
  }

  static String _sportIconPath(int sportId) {
    final path = SportType.fromId(sportId)?.iconPath ?? '';
    return path.isNotEmpty ? path : AppIcons.iconSoccer;
  }
}
