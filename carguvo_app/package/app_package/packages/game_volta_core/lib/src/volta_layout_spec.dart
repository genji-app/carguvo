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
    betBarChipSize: 58.545,
    chipIdleRatio: 47.574 / 55.872,
    betBarFadeWidth: 23.47,
    betBarIconSize: 32.244,
    betBarLabelFontSize: 23.694,
    betBarButtonWidth: 85.171,
    betBarGap: 5,
    betBarPadV: 10,
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
    chipHeight: 33.45,
    chipGap: 15,
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
    betBarHeight: 106,
    betBarChipSize: 102.279,
    chipIdleRatio: 83.114 / 97.611,
    betBarFadeWidth: 41,
    betBarIconSize: 56.331,
    betBarLabelFontSize: 41.394,
    betBarButtonWidth: 148.797,
    betBarGap: 8,
    betBarPadV: 10,
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
    chipHeight: 35.96,
    chipGap: 15,
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

const bool kVoltaGateUseArtwork = true;

const bool kVoltaGateArtworkHasBorder = false;

const double kVoltaChipAspect = 230 / 241;

const double kVoltaChipCellAspect = kVoltaChipAspect;

const double kVoltaChipArtBox = 1.0;

const double kVoltaChipInnerRatio = 146 / 230;

const double kVoltaChipLabelLift = (117.5 / 241 - 0.5) * kVoltaChipArtBox;

const double kVoltaChipDiscHeight = 1.0;

const double kVoltaChipDiscRadius = 0.4903;

const List<double> kVoltaChipGlowRadii = <double>[
  1.0, 1.05, 1.1, 1.15, 1.2, 1.25, 1.3, 1.35, 1.4, 1.45, 1.55,
];
const List<double> kVoltaChipGlowAlphas = <double>[
  0.85, 0.74, 0.60, 0.44, 0.30, 0.19, 0.12, 0.07, 0.04, 0.02, 0,
];

const double kVoltaChipGlowOuter = 1.55;

const double kVoltaChipGlowBox =
    2 * kVoltaChipGlowOuter * kVoltaChipDiscRadius;

const Map<int, double> kVoltaChipLabelScale = <int, double>{
  2: 0.909,
  3: 0.941,
};

double voltaChipLabelFontSize(double chipHeight, String label) {
  final double inner = chipHeight * kVoltaChipAspect * kVoltaChipInnerRatio;
  final double byWidth = inner * 0.92 / (label.length * 0.64);
  final double byHeight = inner * 0.62;
  final double fit = byWidth < byHeight ? byWidth : byHeight;
  return fit * (kVoltaChipLabelScale[label.length] ?? 1.0);
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

const double kVoltaActionChamferY = 0.50;
const double kVoltaActionChamferX = 0.274;

const double kVoltaActionCornerRatio = 0.0948;

const double kVoltaActionGlowX = 0.565;
const double kVoltaActionGlowRX = 0.50;
const double kVoltaActionGlowRY = 0.22;

const List<double> kVoltaActionGlowStops = <double>[
  0, 0.20, 0.30, 0.40, 0.50, 0.60, 0.70, 0.80, 0.90, 1.0,
];

const List<double> kVoltaActionGlowAlphaRebet = <double>[
  1.00, 1.00, 0.98, 0.93, 0.81, 0.65, 0.50, 0.34, 0.20, 0,
];

const List<double> kVoltaActionGlowAlphaDouble = <double>[
  0.70, 0.70, 0.62, 0.52, 0.41, 0.31, 0.20, 0.12, 0.06, 0,
];

const int kVoltaActionGlowCoreRebet = 0xFFFF8B;
const int kVoltaActionGlowCoreDouble = 0xFFEAFF;

const double kVoltaActionBottomRim = 0.17;

const List<double> kVoltaActionBaseStops = <double>[
  0, 0.09, 0.14, 0.19, 0.24, 0.29, 0.34, 0.39, 0.44, 0.49,
  0.54, 0.59, 0.64, 0.69, 0.74, 0.79, 0.84, 0.89, 0.94, 1.0,
];

const List<int> kVoltaActionBaseRebet = <int>[
  0xD0B389, 0xDBB383, 0xD5A978, 0xC29566, 0xAE8253,
  0x9D7142, 0x8C6337, 0x7C562F, 0x6F4D2B, 0x624323,
  0x53381C, 0x4B3219, 0x412B15, 0x392512, 0x382612,
  0x3C2814, 0x453018, 0x553C22, 0x593F23, 0x5E4326,
];

const List<int> kVoltaActionBaseDouble = <int>[
  0xD688C7, 0xD67BC8, 0xCE6ABB, 0xBE56A2, 0xAB468C,
  0x973776, 0x882E65, 0x792958, 0x69234C, 0x5F2243,
  0x521E37, 0x471A2F, 0x3E1525, 0x371421, 0x351521,
  0x3B1829, 0x451D35, 0x522242, 0x5B274B, 0x602A50,
];

List<List<double>> voltaActionOutline(
  double w,
  double h, {
  required bool outerLeft,
}) {
  final double cutY = h * kVoltaActionChamferY;
  final double cutX = w * kVoltaActionChamferX;
  if (outerLeft) {
    return <List<double>>[
      <double>[0, 0],
      <double>[w, 0],
      <double>[w, h],
      <double>[cutX, h],
      <double>[0, cutY],
    ];
  }
  return <List<double>>[
    <double>[0, 0],
    <double>[w, 0],
    <double>[w, cutY],
    <double>[w - cutX, h],
    <double>[0, h],
  ];
}

const double kVoltaRailRadiusRatio = 17 / 106;

const double kVoltaRailTopEdgeRatio = 1.747 / 106;

const double kVoltaRailTopEdgeAlpha = 0.195;

const int kVoltaRailBaseTop = 0x1C0B00;
const int kVoltaRailBaseBottom = 0x110A00;

const double kVoltaRailTopGlowRX = 1.9503;
const double kVoltaRailTopGlowRY = 1.025;
const double kVoltaRailTopGlowCX = 0.5037;
const double kVoltaRailTopGlowCY = 0.0034;
const List<double> kVoltaRailTopGlowStops = <double>[0, 0.30, 0.65, 1.0];
const List<int> kVoltaRailTopGlowColors = <int>[
  0x505050, 0x3F3F3F, 0x202020, 0x202020,
];
const List<double> kVoltaRailTopGlowAlphas = <double>[1.0, 0.5, 0.25, 0];

const double kVoltaRailBottomGlowRX = 1.3501;
const double kVoltaRailBottomGlowRY = 0.2989;
const double kVoltaRailBottomGlowCX = 0.5;
const double kVoltaRailBottomGlowCY = 0.9961;
const double kVoltaRailBottomGlowAlpha = 0.5;

const bool kVoltaActionUseArtwork = true;

const double kVoltaActionLabelShift = 0.0324;

const double kVoltaActionLabelGradientDeg = 61.209;
const int kVoltaActionLabelGradientFrom = 0xFFA0E1;
const int kVoltaActionLabelGradientTo = 0xFFFFFF;
const double kVoltaActionLabelGradientFromStop = 0.0596;
const double kVoltaActionLabelGradientToStop = 0.9994;
