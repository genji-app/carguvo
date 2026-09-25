import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/mini_game_icons.dart';
import 'package:sun_sports/mini/diamond/state/diamond_paylines.dart';
import 'package:sun_sports/mini/diamond/state/diamond_state_provider.dart';
import 'package:sun_sports/mini/diamond/widgets/diamond_common.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/texts/gradient_text.dart';

class DiamondLineSelection extends ConsumerStatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onClose;
  final BorderRadius borderRadius;

  const DiamondLineSelection({
    this.onBack,
    this.onClose,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    super.key,
  });

  @override
  ConsumerState<DiamondLineSelection> createState() =>
      _DiamondLineSelectionState();
}

mixin DiamondLineSelectionActions<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  late Set<int> selected;

  @override
  void initState() {
    super.initState();
    selected = {...ref.read(diamondStateProvider).selectedLines};
  }

  void applyLines() {
    ref.read(diamondStateProvider.notifier).setLines(selected.toList());
  }

  void toggleLine(int id) {
    setState(() {
      if (selected.contains(id)) {
        selected.remove(id);
      } else {
        selected.add(id);
      }
    });
    applyLines();
  }

  void selectAllLines() {
    setState(() => selected = {...kDiamondAllLines});
    applyLines();
  }

  void selectEvenLines() {
    setState(() => selected = {
          for (var i = 0; i < kDiamondLineCount; i++)
            if ((i + 1).isEven) i
        });
    applyLines();
  }

  void selectOddLines() {
    setState(() => selected = {
          for (var i = 0; i < kDiamondLineCount; i++)
            if ((i + 1).isOdd) i
        });
    applyLines();
  }

  void clearLines() {
    setState(() => selected = <int>{});
    applyLines();
  }

  bool get isEvenPreset =>
      selected.length == kDiamondLineCount ~/ 2 &&
      selected.every((i) => (i + 1).isEven);

  bool get isOddPreset =>
      selected.length == kDiamondLineCount ~/ 2 &&
      selected.every((i) => (i + 1).isOdd);
}

class _DiamondLineSelectionState extends ConsumerState<DiamondLineSelection>
    with DiamondLineSelectionActions {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF252423),
        borderRadius: widget.borderRadius,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _header(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
            child: GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              childAspectRatio: 51.5 / 32.707,
              children: [
                for (var id = 0; id < kDiamondLineCount; id++)
                  DiamondPaylineTile(
                    lineId: id,
                    selected: selected.contains(id),
                    onTap: () => toggleLine(id),
                  ),
              ],
            ),
          ),
          _presets(),
        ],
      ),
    );
  }

  Widget _header() => Container(
        color: AppColorStyles.backgroundQuaternary,
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            DiamondIconButton(
              iconPath: MiniGameIcons.diamondBack,
              onTap: SoundTap.wrap(widget.onBack),
            ),
            const SizedBox(width: 8),
            Text(
              I18n.diamondSelectLines,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: kDiamondTextPrimary,
              ),
            ),
            const Spacer(),
            DiamondIconButton(
              iconPath: MiniGameIcons.diamondClose,
              onTap: SoundTap.wrap(widget.onClose),
            ),
          ],
        ),
      );

  Widget _presets() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 32, 12, 32),
      child: Row(
        children: [
          Expanded(
            child: DiamondPresetButton(
              label: I18n.diamondEven,
              highlighted: isEvenPreset,
              onTap: selectEvenLines,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DiamondPresetButton(
              label: I18n.diamondOdd,
              highlighted: isOddPreset,
              onTap: selectOddLines,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DiamondPresetButton(
              label: I18n.diamondAll,
              highlighted: selected.length == kDiamondLineCount,
              onTap: selectAllLines,
            ),
          ),
          const SizedBox(width: 12),
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
}

class DiamondPaylineTile extends StatelessWidget {
  final int lineId;
  final bool selected;
  final VoidCallback onTap;

  const DiamondPaylineTile({
    required this.lineId,
    required this.selected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final path = selected
        ? MiniGameIcons.diamondRowsSelected[lineId]
        : MiniGameIcons.diamondRows[lineId];
    return SoundTap(
      onTap: onTap,
      child: ImageHelper.load(path: path, fit: BoxFit.contain),
    );
  }
}

class DiamondPresetButton extends StatelessWidget {
  final String label;
  final bool highlighted;
  final VoidCallback onTap;

  const DiamondPresetButton({
    required this.label,
    required this.onTap,
    this.highlighted = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const activeGradient = LinearGradient(
      begin: Alignment(0, -1.99),
      end: Alignment(0, 1),
      colors: [Colors.transparent, Color(0xFF7D5100)],
    );
    const normalGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF3D3C3B), Color(0xFF252423)],
    );
    return SoundTap(
      onTap: onTap,
      child: Container(
        height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: highlighted ? activeGradient : normalGradient,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14FFFFFF),
                offset: Offset(0, -1),
                blurRadius: 0.5,
              ),
              BoxShadow(
                color: Color(0x3D000000),
                offset: Offset(0, 3),
                blurRadius: 4,
              ),
              BoxShadow(
                color: Color(0x33000000),
                offset: Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
        child: GradientText(
          label,
          gradient: kDiamondGoldGradient,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            height: 24 / 16,
          ),
        ),
      ),
    );
  }
}
