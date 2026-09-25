import 'package:meta/meta.dart';

@immutable
class VoltaLayoutSpec {
  final double tabBarBlockHeight;
  final double tabContentHeight;

  final double md5TopGap;

  final double md5BlockHeight;
  final double md5ToStageGap;
  final double stageHeight;

  final double stageToGatesGap;

  final double gatesBlockHeight;

  final double chipRowHeight;
  final double actionRowHeight;

  final double betBarHeight;

  final double betBarButtonWidth;

  final double betBarChipSize;

  final double chipIdleRatio;

  final double betBarFadeWidth;

  final double betBarIconSize;

  final double betBarLabelFontSize;

  final double betBarGap;

  final double betBarPadV;

  final double betBarPadH;

  final double betBarChipLift;

  final double betBarRadiusOuter;

  final double betBarRadiusInner;

  final double historySideWidth;

  final double historyLabelFontSize;

  final double countdownTitleFontSize;
  final double countdownDigitsFontSize;

  final double countdownTitleTop;

  final double gateHeight;
  final double gateGap;
  final double gateLogoSize;
  final double gateMyStakeWidth;
  final double gateMyStakeHeight;
  final double gateCornerHeight;

  final double gateNameHeight;
  final double gateGapNameStake;
  final double gateGapStakeMine;
  final double gatePadTop;
  final double gatePadBottom;

  final double gateCornerRadius;
  final double gateRolePadH;

  final double gatePlayersPadStart;
  final double gatePlayersPadEnd;
  final double gatePlayersGap;
  final double gatePlayersIconSize;
  final double gateRoleFontSize;
  final double gatePlayersFontSize;
  final double gateOddsFontSize;
  final double gateNameFontSize;
  final double gateStakeFontSize;
  final double gateMyStakeFontSize;

  final double chipHeight;
  final double chipGap;

  final double actionButtonWidth;
  final double actionButtonHeight;
  final double actionGap;

  final double md5FieldHeight;
  final double md5ActionSize;

  final double chatColumnWidth;

  final double gutter;

  const VoltaLayoutSpec({
    required this.tabBarBlockHeight,
    required this.tabContentHeight,
    required this.md5TopGap,
    required this.md5BlockHeight,
    required this.md5ToStageGap,
    required this.stageHeight,
    required this.stageToGatesGap,
    required this.countdownTitleFontSize,
    required this.countdownDigitsFontSize,
    required this.countdownTitleTop,
    required this.gatesBlockHeight,
    required this.chipRowHeight,
    required this.betBarHeight,
    required this.betBarChipSize,
    required this.chipIdleRatio,
    required this.betBarFadeWidth,
    required this.betBarIconSize,
    required this.betBarLabelFontSize,
    required this.betBarButtonWidth,
    required this.betBarGap,
    required this.betBarPadV,
    required this.betBarPadH,
    required this.betBarChipLift,
    required this.betBarRadiusOuter,
    required this.betBarRadiusInner,
    required this.historySideWidth,
    required this.historyLabelFontSize,
    required this.actionRowHeight,
    required this.gateHeight,
    required this.gateGap,
    required this.gateLogoSize,
    required this.gateMyStakeWidth,
    required this.gateMyStakeHeight,
    required this.gateCornerHeight,
    required this.gateNameHeight,
    required this.gateGapNameStake,
    required this.gateGapStakeMine,
    required this.gatePadTop,
    required this.gatePadBottom,
    required this.gateCornerRadius,
    required this.gateRolePadH,
    required this.gatePlayersPadStart,
    required this.gatePlayersPadEnd,
    required this.gatePlayersGap,
    required this.gatePlayersIconSize,
    required this.gateRoleFontSize,
    required this.gatePlayersFontSize,
    required this.gateOddsFontSize,
    required this.gateNameFontSize,
    required this.gateStakeFontSize,
    required this.gateMyStakeFontSize,
    required this.chipHeight,
    required this.chipGap,
    required this.actionButtonWidth,
    required this.actionButtonHeight,
    required this.actionGap,
    required this.md5FieldHeight,
    required this.md5ActionSize,
    required this.chatColumnWidth,
    required this.gutter,
  });

  VoltaLayoutSpec scaledBetBar(double k) => VoltaLayoutSpec(
    tabBarBlockHeight: tabBarBlockHeight,
    tabContentHeight: tabContentHeight,
    md5TopGap: md5TopGap,
    md5BlockHeight: md5BlockHeight,
    md5ToStageGap: md5ToStageGap,
    stageHeight: stageHeight,
    stageToGatesGap: stageToGatesGap,
    countdownTitleFontSize: countdownTitleFontSize,
    countdownDigitsFontSize: countdownDigitsFontSize,
    countdownTitleTop: countdownTitleTop,
    gatesBlockHeight: gatesBlockHeight,
    chipRowHeight: chipRowHeight,
    betBarHeight: betBarHeight * k,
    betBarChipSize: betBarChipSize * k,
    chipIdleRatio: chipIdleRatio,
    betBarFadeWidth: betBarFadeWidth * k,
    betBarIconSize: betBarIconSize * k,
    betBarLabelFontSize: betBarLabelFontSize * k,
    betBarButtonWidth: betBarButtonWidth * k,
    betBarGap: betBarGap * k,
    betBarPadV: betBarPadV * k,
    betBarPadH: betBarPadH * k,
    betBarChipLift: betBarChipLift * k,
    betBarRadiusOuter: betBarRadiusOuter * k,
    betBarRadiusInner: betBarRadiusInner * k,
    historySideWidth: historySideWidth,
    historyLabelFontSize: historyLabelFontSize,
    actionRowHeight: actionRowHeight,
    gateHeight: gateHeight,
    gateGap: gateGap,
    gateLogoSize: gateLogoSize,
    gateMyStakeWidth: gateMyStakeWidth,
    gateMyStakeHeight: gateMyStakeHeight,
    gateCornerHeight: gateCornerHeight,
    gateNameHeight: gateNameHeight,
    gateGapNameStake: gateGapNameStake,
    gateGapStakeMine: gateGapStakeMine,
    gatePadTop: gatePadTop,
    gatePadBottom: gatePadBottom,
    gateCornerRadius: gateCornerRadius,
    gateRolePadH: gateRolePadH,
    gatePlayersPadStart: gatePlayersPadStart,
    gatePlayersPadEnd: gatePlayersPadEnd,
    gatePlayersGap: gatePlayersGap,
    gatePlayersIconSize: gatePlayersIconSize,
    gateRoleFontSize: gateRoleFontSize,
    gatePlayersFontSize: gatePlayersFontSize,
    gateOddsFontSize: gateOddsFontSize,
    gateNameFontSize: gateNameFontSize,
    gateStakeFontSize: gateStakeFontSize,
    gateMyStakeFontSize: gateMyStakeFontSize,
    chipHeight: chipHeight,
    chipGap: chipGap * k,
    actionButtonWidth: actionButtonWidth,
    actionButtonHeight: actionButtonHeight,
    actionGap: actionGap,
    md5FieldHeight: md5FieldHeight,
    md5ActionSize: md5ActionSize,
    chatColumnWidth: chatColumnWidth,
    gutter: gutter,
  );

  double get designHeight =>
      tabBarBlockHeight +
      tabContentHeight +
      md5TopGap +
      md5BlockHeight +
      md5ToStageGap +
      stageHeight +
      stageToGatesGap +
      gatesBlockHeight +
      betBarBlockHeight;

  double get betBarBlockHeight =>
      betBarPadV * 2 + betBarChipLift + betBarHeight;

  double get betBarChipBleed =>
      kVoltaChipGlowOuter * kVoltaChipDiscRadius * betBarChipSize -
      0.5 * betBarHeight;

  double get topBlockHeight =>
      tabBarBlockHeight +
      tabContentHeight +
      md5TopGap +
      md5BlockHeight +
      md5ToStageGap +
      stageHeight;

  bool get hasChatColumn => chatColumnWidth > 0;

  static const VoltaLayoutSpec mobile = VoltaLayoutSpec(
    tabBarBlockHeight: 42,
    tabContentHeight: 97,
    md5TopGap: 0,
    md5BlockHeight: 32,
    md5ToStageGap: 6,
    stageHeight: 190,
    stageToGatesGap: 2,
    countdownTitleFontSize: 18,
    countdownDigitsFontSize: 60,
    countdownTitleTop: 20,
    gatesBlockHeight: 120,
    chipRowHeight: 62,
    actionRowHeight: 71,
    betBarHeight: 60,
    betBarChipSize: 60 * kVoltaSelectedChipBoost,
    chipIdleRatio: kVoltaChipIdleRatio / kVoltaSelectedChipBoost,
    betBarFadeWidth: 24.845,
    betBarIconSize: 33.407,
    betBarLabelFontSize: 22.934,
    betBarButtonWidth: 55,
    betBarGap: 0,
    betBarPadV: 6,
    betBarPadH: 0,
    betBarChipLift: 0,
    betBarRadiusOuter: 19.112,
    betBarRadiusInner: 4.778,
    gateHeight: 115,
    gateGap: 11.5,
    gateLogoSize: 50,
    gateMyStakeWidth: 127,
    gateMyStakeHeight: 20,
    historySideWidth: 55,
    historyLabelFontSize: 10,
    gateCornerHeight: 24,
    gateNameHeight: 18,
    gateGapNameStake: 5,
    gateGapStakeMine: 6,
    gatePadTop: 6,
    gatePadBottom: 6,
    gateCornerRadius: 11.488,
    gateRolePadH: 8.616,
    gatePlayersPadStart: 11.6,
    gatePlayersPadEnd: 8.6,
    gatePlayersGap: 0,
    gatePlayersIconSize: 11.488,
    gateRoleFontSize: 9,
    gatePlayersFontSize: 8,
    gateOddsFontSize: 8,
    gateNameFontSize: 10,
    gateStakeFontSize: 18,
    gateMyStakeFontSize: 12,
    chipHeight: 40,
    chipGap: 4,
    actionButtonWidth: 130,
    actionButtonHeight: 40,
    actionGap: 16,
    md5FieldHeight: 27,
    md5ActionSize: 32,
    chatColumnWidth: 0,
    gutter: 10,
  );

  static const VoltaLayoutSpec tablet = VoltaLayoutSpec(
    tabBarBlockHeight: 44,
    tabContentHeight: 151,
    md5TopGap: 0,
    md5BlockHeight: 58,
    md5ToStageGap: 6,
    stageHeight: 344,
    stageToGatesGap: 2.5,
    countdownTitleFontSize: 32,
    countdownDigitsFontSize: 109,
    countdownTitleTop: 36,
    gatesBlockHeight: 194,
    chipRowHeight: 70,
    actionRowHeight: 77,
    betBarHeight: 126,
    betBarChipSize: 160.821,
    chipIdleRatio: 116.67 / 158,
    betBarFadeWidth: 46,
    betBarIconSize: 60,
    betBarLabelFontSize: 36,
    betBarButtonWidth: 116,
    betBarGap: 0,
    betBarPadV: 20,
    betBarPadH: 0,
    betBarChipLift: 0,
    betBarRadiusOuter: 40,
    betBarRadiusInner: 10,
    gateHeight: 188,
    gateGap: 12,
    gateLogoSize: 57,
    gateMyStakeWidth: 183,
    gateMyStakeHeight: 29.5,
    historySideWidth: 88,
    historyLabelFontSize: 16,
    gateCornerHeight: 40,
    gateNameHeight: 24,
    gateGapNameStake: 6,
    gateGapStakeMine: 17,
    gatePadTop: 6,
    gatePadBottom: 12.5,
    gateCornerRadius: 19.147,
    gateRolePadH: 12,
    gatePlayersPadStart: 19.3,
    gatePlayersPadEnd: 14.3,
    gatePlayersGap: 0,
    gatePlayersIconSize: 19.147,
    gateRoleFontSize: 16,
    gatePlayersFontSize: 14,
    gateOddsFontSize: 16,
    gateNameFontSize: 16,
    gateStakeFontSize: 28,
    gateMyStakeFontSize: 16,
    chipHeight: 43,
    chipGap: 0,
    actionButtonWidth: 250,
    actionButtonHeight: 43,
    actionGap: 52,
    md5FieldHeight: 40,
    md5ActionSize: 40,
    chatColumnWidth: 237,
    gutter: 12,
  );
}

const double kVoltaChipIdleRatio = 59.265 / 71.669;

const double kVoltaSelectedChipBoost = 1.4;

const double kVoltaChipAspect = 336 / 342;

const double kVoltaChipInnerRatio = 154 / 336;

const double kVoltaChipLabelLift = 160.5 / 342 - 0.5;

const double kVoltaChipDiscHeight = 286 / 342;

const double kVoltaChipDiscRadius = 0.41;

const List<double> kVoltaChipGlowRadii = <double>[
  1.0, 1.05, 1.1, 1.15, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8,
];
const List<double> kVoltaChipGlowAlphas = <double>[
  0.48, 0.48, 0.48, 0.44, 0.37, 0.24, 0.14, 0.07, 0.03, 0.01, 0,
];

const double kVoltaChipGlowOuter = 1.8;

const double kVoltaChipGlowBox =
    2 * kVoltaChipGlowOuter * kVoltaChipDiscRadius;

double voltaChipLabelFontSize(double chipHeight, String label) {
  final double inner = chipHeight * kVoltaChipAspect * kVoltaChipInnerRatio;
  final double byWidth = inner * 0.92 / (label.length * 0.64);
  final double byHeight = inner * 0.62;
  return byWidth < byHeight ? byWidth : byHeight;
}
const int kVoltaChatMinLines = 2;

const int kVoltaChatMaxLines = 6;

int voltaChatVisibleLines({
  required double available,
  required double designHeight,
  required double lineHeight,
  required double listPadding,
  required double topGap,
}) {
  if (lineHeight <= 0) return kVoltaChatMinLines;
  final double spare = available - topGap - listPadding - designHeight;
  if (!spare.isFinite) return kVoltaChatMinLines;
  final int fits = (spare / lineHeight).floor();
  if (fits < kVoltaChatMinLines) return kVoltaChatMinLines;
  if (fits > kVoltaChatMaxLines) return kVoltaChatMaxLines;
  return fits;
}
