import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/mini/diamond/state/diamond_paylines.dart';
import 'package:sun_sports/mini/diamond/widgets/diamond_line_selection.dart';
import 'package:sun_sports/mini/diamond_landscape/widgets/diamond_landscape_list_scaffold.dart';

class DiamondLandscapeLineSelection extends ConsumerStatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onClose;
  final BorderRadius borderRadius;

  const DiamondLandscapeLineSelection({
    this.onBack,
    this.onClose,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    super.key,
  });

  @override
  ConsumerState<DiamondLandscapeLineSelection> createState() =>
      _DiamondLandscapeLineSelectionState();
}

class _DiamondLandscapeLineSelectionState
    extends ConsumerState<DiamondLandscapeLineSelection>
    with DiamondLineSelectionActions {
  static const int _kCols = 5;
  static const double _kTileW = 64.5;
  static const double _kTileH = 46.707;
  static const double _kColGap = 30;
  static const double _kRowGap = 16;

  static const double _kPresetGap = 12;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundQuaternary,
        borderRadius: widget.borderRadius,
      ),
      child: Column(
        children: [
          DiamondLandscapeSubHeader(
            title: I18n.diamondSelectLines,
            onBack: widget.onBack,
            onClose: widget.onClose,
            showBack: true,
          ),
          Expanded(child: Center(child: _grid())),
          _presets(),
        ],
      ),
    );
  }

  Widget _grid() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        child: GridView.count(
          crossAxisCount: _kCols,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          mainAxisSpacing: _kRowGap,
          crossAxisSpacing: _kColGap,
          childAspectRatio: _kTileW / _kTileH,
          children: [
            for (var id = 0; id < kDiamondLineCount; id++)
              DiamondPaylineTile(
                lineId: id,
                selected: selected.contains(id),
                onTap: () => toggleLine(id),
              ),
          ],
        ),
      );

  Widget _presets() => Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: DiamondPresetButton(
                label: I18n.diamondEven,
                highlighted: isEvenPreset,
                onTap: selectEvenLines,
              ),
            ),
            const SizedBox(width: _kPresetGap),
            Expanded(
              child: DiamondPresetButton(
                label: I18n.diamondOdd,
                highlighted: isOddPreset,
                onTap: selectOddLines,
              ),
            ),
            const SizedBox(width: _kPresetGap),
            Expanded(
              child: DiamondPresetButton(
                label: I18n.diamondAll,
                highlighted: selected.length == kDiamondLineCount,
                onTap: selectAllLines,
              ),
            ),
            const SizedBox(width: _kPresetGap),
            Expanded(
              child: DiamondPresetButton(
                label: I18n.diamondClear,
                highlighted: selected.isEmpty,
                onTap: clearLines,
              ),
            ),
          ],
        ),
      );
}
