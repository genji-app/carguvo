import 'package:flutter/material.dart';
import 'package:styled_text/styled_text.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/bet_details/hint_bubble/hint_styled/hint_styled_service.dart';
import 'package:sun_sports/shared/widgets/bet_details/hint_bubble/hint_styled/hint_styled_tags.dart';

class HintStyledContent {
  HintStyledContent._();

  static const double _defaultSpacing = 12.0;

  static Widget buildContent({
    required StyledHintContent content,
    double spacing = _defaultSpacing,
  }) {
    final tags = HintStyledTags.tags;
    final baseStyle = AppTextStyles.paragraphXSmall(
      color: AppColorStyles.contentPrimary,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        StyledText(text: content.simpleText, tags: tags, style: baseStyle),
        SizedBox(height: spacing),

        if (content.infoText.isNotEmpty) ...[
          StyledText(text: content.infoText, tags: tags, style: baseStyle),
          SizedBox(height: spacing),
        ],

        if (content.ratioText.isNotEmpty) ...[
          StyledText(text: content.ratioText, tags: tags, style: baseStyle),
          SizedBox(height: spacing),
        ],

        if (content.resultText.isNotEmpty) ...[
          StyledText(text: content.resultText, tags: tags, style: baseStyle),
          SizedBox(height: spacing),
        ],

        if (content.exampleText.isNotEmpty)
          StyledText(text: content.exampleText, tags: tags, style: baseStyle),
      ],
    );
  }
}
