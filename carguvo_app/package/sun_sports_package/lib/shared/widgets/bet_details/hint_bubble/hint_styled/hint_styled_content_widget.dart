import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/bet_details/hint_bubble/hint_data.dart';
import 'package:sun_sports/shared/widgets/bet_details/hint_bubble/hint_styled/hint_styled_content.dart';
import 'package:sun_sports/shared/widgets/bet_details/hint_bubble/hint_styled/hint_styled_service.dart';

class HintStyledContentWidget extends StatelessWidget {
  final HintData hintData;

  final String? titleOverride;

  const HintStyledContentWidget({
    required this.hintData,
    super.key,
    this.titleOverride,
  });

  @override
  Widget build(BuildContext context) {
    final content = HintStyledService.generateStyledHint(hintData);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getTitle(),
            style: AppTextStyles.labelSmall(color: AppColors.green300),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          HintStyledContent.buildContent(content: content, spacing: 12.0),
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
