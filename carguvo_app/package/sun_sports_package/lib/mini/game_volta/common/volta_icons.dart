import 'package:flutter/widgets.dart';

import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/mini_game_icons.dart';

import 'volta_colors.dart';
import 'volta_layout_spec.dart';

class VoltaIcons {
  VoltaIcons._();

  static Widget copy({double size = 28}) => _icon(MiniGameIcons.voltaCopy, size);

  static Widget guide({double size = 16}) =>
      _icon(MiniGameIcons.voltaGuide, size);

  static Widget history({double size = 16}) =>
      _icon(MiniGameIcons.voltaHistory, size);

  static Widget ranking({double size = 16}) =>
      _icon(MiniGameIcons.voltaRanking, size);

  static Widget redo({double size = 31}) => _icon(MiniGameIcons.voltaRedo, size);

  static Widget users({double size = 19}) =>
      _icon(MiniGameIcons.voltaUser, size);

  static Widget win({double size = 16}) => _icon(MiniGameIcons.voltaWin, size);
  static Widget lose({double size = 16}) => _icon(MiniGameIcons.voltaLose, size);

  static Widget? medalForRank(int rank, {double size = 24}) => switch (rank) {
    1 => _icon(MiniGameIcons.voltaTop1, size),
    2 => _icon(MiniGameIcons.voltaTop2, size),
    3 => _icon(MiniGameIcons.voltaTop3, size),
    _ => null,
  };

  static const double guideBackgroundRatio = 804 / 2441;

  static Widget guideBackground() => AspectRatio(
    aspectRatio: guideBackgroundRatio,
    child: ImageHelper.load(
      path: MiniGameIcons.voltaBackgroundGuide,
      fit: BoxFit.fitWidth,
    ),
  );

  static Widget chip(int index, {required double height}) => ImageHelper.load(
    path: _chipFrame(index),
    width: height * kVoltaChipAspect,
    height: height,
    cacheWidth: (height * kVoltaChipAspect * 2).round(),
    cacheHeight: (height * 2).round(),
    errorWidget: _missingChip(index, height),
  );

  static String _chipFrame(int index) => switch (index) {
    0 => MiniGameIcons.voltaChip1K,
    1 => MiniGameIcons.voltaChip10K,
    2 => MiniGameIcons.voltaChip50K,
    3 => MiniGameIcons.voltaChip100K,
    4 => MiniGameIcons.voltaChip500K,
    5 => MiniGameIcons.voltaChip5M,
    _ => MiniGameIcons.voltaChip20M,
  };

  static Widget _missingChip(int index, double height) => SizedBox(
    width: height * kVoltaChipAspect,
    height: height,
    child: DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: <Color>[
            const Color(0xFF111111),
            const Color(0xFF111111),
            VoltaColors.chipGlow[index],
            VoltaColors.chipGlow[index],
            const Color(0x00000000),
          ],
          stops: const <double>[0, 0.458, 0.458, 0.82, 0.82],
        ),
      ),
    ),
  );

  static Widget _icon(String path, double size) => ImageHelper.load(
    path: path,
    width: size,
    height: size,
    cacheWidth: (size * 2).round(),
    cacheHeight: (size * 2).round(),
  );
}
