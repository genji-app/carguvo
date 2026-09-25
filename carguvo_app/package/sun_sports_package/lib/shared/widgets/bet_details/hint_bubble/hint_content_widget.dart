import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/bet_details/hint_bubble/hint_content_builder.dart';
import 'package:sun_sports/shared/widgets/bet_details/hint_bubble/hint_styled/hint_styled_content_widget.dart';
import 'package:sun_sports/shared/widgets/bet_details/hint_bubble/hint_data.dart';
import 'package:sun_sports/shared/widgets/bet_details/hint_bubble/hint_service.dart';

class HintContentWidget extends StatelessWidget {
  final HintData hintData;

  final String? titleOverride;

  static const bool useStyledText = true;

  const HintContentWidget({
    required this.hintData,
    super.key,
    this.titleOverride,
  });

  @override
  Widget build(BuildContext context) {
    if (useStyledText) {
      return HintStyledContentWidget(
        hintData: hintData,
        titleOverride: titleOverride,
      );
    }

    return _buildLegacyContent(context);
  }

  Widget _buildLegacyContent(BuildContext context) {
    final content = HintService.generateHint(hintData);
    final hintColors = HintContentStyle(
      simpleColor: AppColors.green300,
      defaultColor: AppColorStyles.contentPrimary,
      highlightColor: AppColors.yellow300,
      positiveColor: AppColors.green300,
      negativeColor: AppColors.red500,
      textStyle: AppTextStyles.paragraphXSmall(),
      ratioFontWeight: FontWeight.normal,
    );

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Text(
            _getTitle(),
            style: AppTextStyles.labelSmall(color: AppColors.green300),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          HintContentBuilder.buildContent(
            content: content,
            ratio: hintData.ratio,
            spacing: 12.0,
            ratioPadding: 0,
            linePadding: 0,
            style: hintColors,
            useGap: true,
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    if (titleOverride != null && titleOverride!.isNotEmpty) {
      return titleOverride!;
    }
    final title = MarketHelper.getMarketNameViDisplay(hintData.marketId);
    return _capitalizeFirst(title);
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
