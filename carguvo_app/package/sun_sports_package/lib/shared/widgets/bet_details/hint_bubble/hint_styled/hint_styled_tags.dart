import 'package:flutter/material.dart';
import 'package:styled_text/styled_text.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';

class HintStyledTags {
  HintStyledTags._();

  static const String tagTitle = 'title';
  static const String tagContent = 'content';
  static const String tagBullet = 'bullet';
  static const String tagSimple = 'simple';
  static const String tagExampleTitle = 'example-title';
  static const String tagResultTitle = 'result-title';
  static const String tagBulletPoint = 'bullet-point';

  static const String tagTeam = 'team';
  static const String tagSelection = 'selection';
  static const String tagSelectionTeam = 'selection-team';
  static const String tagPeriod = 'period';

  static const String tagPositive = 'positive';
  static const String tagNegative = 'negative';
  static const String tagHandicap = 'handicap';
  static const String tagScore = 'score';
  static const String tagMoney = 'money';
  static const String tagNumber = 'number';

  static const String tagWin = 'win';
  static const String tagLose = 'lose';
  static const String tagDraw = 'draw';
  static const String tagHalfWin = 'halfwin';
  static const String tagHalfLose = 'halflose';

  static const String tagCase = 'case';
  static const String tagCondition = 'condition';

  static Map<String, StyledTextTag> get tags {
    final base = AppTextStyles.paragraphXSmall(
      color: AppColorStyles.contentPrimary,
    );

    return {
      'title': StyledTextTag(
        style: base.copyWith(
          color: AppColors.green300,
          fontWeight: FontWeight.w600,
        ),
      ),

      'content': StyledTextTag(style: base),

      'bullet': StyledTextTag(style: base),

      'simple': StyledTextTag(style: base.copyWith(color: AppColors.green300)),

      'example-title': StyledTextTag(style: base),

      'result-title': StyledTextTag(style: base),

      'bullet-point': StyledTextTag(style: base),

      'team': StyledTextTag(style: base.copyWith(color: AppColors.yellow300)),

      'selection': StyledTextTag(style: base),

      'selection-team': StyledTextTag(
        style: base.copyWith(color: AppColors.yellow300),
      ),

      'period': StyledTextTag(style: base.copyWith(color: AppColors.green300)),

      'positive': StyledTextTag(
        style: base.copyWith(color: AppColors.green300),
      ),

      'negative': StyledTextTag(style: base.copyWith(color: AppColors.red300)),

      'handicap': StyledTextTag(style: base),

      'score': StyledTextTag(style: base.copyWith(color: AppColors.cyan100)),

      'money': StyledTextTag(style: base),

      'number': StyledTextTag(style: base),

      'win': StyledTextTag(
        style: base.copyWith(
          color: AppColors.green500,
          fontWeight: FontWeight.bold,
        ),
      ),

      'lose': StyledTextTag(
        style: base.copyWith(
          color: AppColors.red500,
          fontWeight: FontWeight.bold,
        ),
      ),

      'draw': StyledTextTag(style: base),

      'halfwin': StyledTextTag(
        style: base.copyWith(
          color: AppColors.green500,
          fontWeight: FontWeight.bold,
        ),
      ),

      'halflose': StyledTextTag(
        style: base.copyWith(
          color: AppColors.red500,
          fontWeight: FontWeight.bold,
        ),
      ),

      'case': StyledTextTag(style: base),

      'condition': StyledTextTag(style: base),
    };
  }
}
