import 'package:flutter/material.dart' hide CloseButton;
import 'package:sun_sports/core/utils/styles/app_color.dart';

import 'package:sun_sports/features/preferences/bet/odds_info.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';
import 'package:styled_text/styled_text.dart';

class OddsStyledTextTags {
  OddsStyledTextTags._();

  static Map<String, StyledTextTag> get tags => {
    'title': StyledTextTag(
      style: AppTextStyles.labelSmall(color: AppColorStyles.contentPrimary),
    ),

    'odds': StyledTextTag(style: const TextStyle(color: AppColors.green300)),

    'content': StyledTextTag(
      style: AppTextStyles.paragraphXSmall(
        color: AppColorStyles.contentPrimary,
      ),
    ),

    'number': StyledTextTag(style: const TextStyle(color: AppColors.green300)),
  };
}

class OddsStyleExplanationContent extends StatelessWidget {
  const OddsStyleExplanationContent({required this.odds, super.key});

  final OddsStyle odds;

  @override
  Widget build(BuildContext context) {
    final baseStyle = AppTextStyles.paragraphXSmall(
      color: AppColorStyles.contentSecondary,
    );

    final tags = OddsStyledTextTags.tags;

    final sections = odds.sections;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          ...sections.map((sectionContent) {
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color.fromRGBO(255, 255, 255, 0.04),
              ),
              child: StyledText(
                text: sectionContent,
                tags: tags,
                style: baseStyle,
              ),
            );
          }),
        ],
      ),
    );
  }
}
