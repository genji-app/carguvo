import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/models/api_v2/odds_style_model_v2.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/sport/presentation/mobile/widgets/bet_card_mobile_v2.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';
import 'package:sun_sports/shared/widgets/sport/models/bet_column_v2.dart';

class StaticOddsCell extends StatelessWidget {
  const StaticOddsCell({
    required this.label,
    required this.value,
    this.locked = false,
    this.isDesktop = false,
    this.isCompact = true,
    super.key,
  });

  final String? label;

  final String? value;

  final bool locked;

  final bool isDesktop;

  final bool isCompact;

  static const _labelColor = Color(0xFFAAA49B);
  static final _radius = BorderRadius.circular(6);

  static String? displayValueFor(BetItemV2 item, OddsFormatV2 format) {
    String? display;
    final odds = item.oddsData;
    if (odds != null && item.marketData != null && item.oddsType != null) {
      final raw = switch (item.oddsType!) {
        OddsType.home => odds.getHomeOdds(format),
        OddsType.away => odds.getAwayOdds(format),
        OddsType.draw => odds.getDrawOdds(format) ?? 0.0,
        OddsType.none => 0.0,
      };
      if (raw != 0) display = raw.toStringAsFixed(2);
    }
    display ??= item.value;
    if (display == null) return null;
    return display.endsWith('.00')
        ? display.substring(0, display.length - 3)
        : display;
  }

  @override
  Widget build(BuildContext context) {
    if (locked) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: BetCardMobileV2.defaultBgColor,
          borderRadius: _radius,
        ),
        child: const Center(
          child: Icon(
            Icons.lock,
            size: BetCardMobileV2.lockIconSize,
            color: BetCardMobileV2.lockIconColor,
          ),
        ),
      );
    }

    final isNegativeOdds = value != null && value!.startsWith('-');
    final valueColor = isNegativeOdds ? AppColors.orange400 : AppColors.green300;
    final vertical = !isDesktop;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: BetCardMobileV2.defaultBgColor,
        borderRadius: _radius,
      ),
      child: Padding(
        padding: vertical
            ? (isCompact
                ? const EdgeInsets.symmetric(horizontal: 4)
                : const EdgeInsets.symmetric(horizontal: 4, vertical: 4))
            : const EdgeInsets.all(8),
        child: vertical ? _vertical(valueColor) : _horizontal(valueColor),
      ),
    );
  }

  Widget _vertical(Color valueColor) => SizedBox(
        height: double.infinity,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (label != null && label!.isNotEmpty)
                Text(
                  label!,
                  textAlign: TextAlign.center,
                  style: isCompact
                      ? AppTextStyles.labelXXSmall(color: _labelColor)
                      : AppTextStyles.labelXSmall(color: _labelColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              if (value != null)
                Text(
                  value!,
                  textAlign: TextAlign.center,
                  style: isCompact
                      ? AppTextStyles.labelXSmall(color: valueColor)
                      : AppTextStyles.labelSmall(color: valueColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      );

  Widget _horizontal(Color valueColor) => SizedBox(
        height: double.infinity,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (label != null && label!.isNotEmpty && value != null)
                Flexible(
                  child: Text(
                    label!,
                    textAlign: TextAlign.left,
                    style: AppTextStyles.textStyle(
                      fontSize: isDesktop ? 12 : 11.5,
                      fontWeight: FontWeight.w400,
                      color: _labelColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              else
                const SizedBox.shrink(),
              if (value != null)
                Text(
                  value!,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.displayStyle(
                    fontSize: isDesktop ? 14 : 13,
                    fontWeight: FontWeight.w700,
                    color: valueColor,
                  ),
                ),
            ],
          ),
        ),
      );
}
