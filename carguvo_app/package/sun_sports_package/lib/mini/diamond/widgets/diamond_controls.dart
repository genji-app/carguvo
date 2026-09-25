import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rive/rive.dart' as rive;

import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/extensions/rive_helper.dart';
import 'package:sun_sports/core/utils/styles/app_rive.dart';
import 'package:sun_sports/core/utils/styles/mini_game_icons.dart';
import 'package:sun_sports/mini/diamond/state/diamond_state_provider.dart';
import 'package:sun_sports/mini/diamond/widgets/diamond_common.dart';
import 'package:sun_sports/providers/user_provider/user_provider.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';

void diamondTrySpin(BuildContext context, WidgetRef ref) {
  final state = ref.read(diamondStateProvider);
  if (ref.read(balanceInVNDProvider) < state.totalBet) {
    AppToast.showError(context, message: I18n.diamondNotEnoughMoney);
    return;
  }
  ref.read(diamondStateProvider.notifier).spin();
}

class DiamondControls extends ConsumerWidget {
  const DiamondControls({super.key});

  static const double _kMinRowWidth = 258;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (fastSpin, spinning, canSpin, autoSpin) = ref.watch(
      diamondStateProvider.select(
        (s) => (s.fastSpin, s.spinning, s.canSpin, s.autoSpin),
      ),
    );
    final notifier = ref.read(diamondStateProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        final rowWidth = constraints.maxWidth.isFinite &&
                constraints.maxWidth < _kMinRowWidth
            ? _kMinRowWidth
            : constraints.maxWidth;
        return FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(
            width: rowWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DiamondSideButton(
                  iconPath: MiniGameIcons.diamondTurbo,
                  iconPathSelected: MiniGameIcons.diamondTurboSelected,
                  label: I18n.diamondTurbo,
                  active: fastSpin,
                  onTap: notifier.toggleFast,
                ),
                DiamondSpinButton(
                  spinning: spinning,
                  enabled: canSpin,
                  onTap: () => diamondTrySpin(context, ref),
                ),
                DiamondSideButton(
                  iconPath: MiniGameIcons.diamondAuto,
                  iconPathSelected: MiniGameIcons.diamondAutoSelected,
                  label: I18n.diamondAuto,
                  active: autoSpin,
                  onTap: notifier.toggleAuto,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DiamondSpinButton extends StatefulWidget {
  final bool spinning;
  final bool enabled;
  final VoidCallback onTap;

  final double size;

  const DiamondSpinButton({
    required this.spinning,
    required this.enabled,
    required this.onTap,
    this.size = 100,
    super.key,
  });

  @override
  State<DiamondSpinButton> createState() => _DiamondSpinButtonState();
}

class _DiamondSpinButtonState extends State<DiamondSpinButton> {
  static const String _kIdle = 'idle';
  static const String _kPushed = 'pushed';

  rive.File? _file;
  _DiamondSpinPainter? _painter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final file = await RiveHelper.getFile(AppRive.spinKimCuong);
      if (file == null || !mounted) return;
      setState(() {
        _file = file;
        _painter = _DiamondSpinPainter(
          activeAnimation: _kPushed,
          idleAnimation: _kIdle,
        );
      });
    } catch (_) {
    }
  }

  @override
  void dispose() {
    _painter?.dispose();
    super.dispose();
  }

  void _onTap() {
    if (!widget.enabled) return;
    _painter?.fireMomentary();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final file = _file;
    final painter = _painter;
    final Widget visual = (file != null && painter != null)
        ? rive.RiveFileWidget(file: file, painter: painter)
        : ImageHelper.load(
            path: MiniGameIcons.diamondStart,
            width: widget.size,
            height: widget.size,
            fit: BoxFit.contain,
          );
    return Opacity(
      opacity: widget.enabled || widget.spinning ? 1 : 0.6,
      child: SizedBox.square(
        dimension: widget.size,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.enabled ? SoundTap.wrap(_onTap) : null,
            child: visual,
          ),
        ),
      ),
    );
  }
}

base class _DiamondSpinPainter extends rive.BasicArtboardPainter {
  final String activeAnimation;
  final String idleAnimation;

  rive.Animation? _active;
  rive.Animation? _idle;
  bool _showActive = false;

  _DiamondSpinPainter({
    required this.activeAnimation,
    required this.idleAnimation,
  }) : super(fit: rive.Fit.contain);

  @override
  void artboardChanged(rive.Artboard artboard) {
    super.artboardChanged(artboard);
    _active = artboard.animationNamed(activeAnimation);
    _idle = artboard.animationNamed(idleAnimation);
    notifyListeners();
  }

  void fireMomentary() {
    _active?.time = 0;
    _showActive = true;
    notifyListeners();
  }

  @override
  bool advance(double elapsedSeconds) {
    if (_showActive) {
      final playing = _active?.advanceAndApply(elapsedSeconds) ?? false;
      if (!playing) {
        _showActive = false;
        _idle?.time = 0;
        return true;
      }
      return playing;
    }
    return _idle?.advanceAndApply(elapsedSeconds) ?? false;
  }
}

class DiamondSideButton extends StatelessWidget {
  final String iconPath;
  final String iconPathSelected;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final double iconSize;

  const DiamondSideButton({
    required this.iconPath,
    required this.iconPathSelected,
    required this.label,
    required this.active,
    required this.onTap,
    this.iconSize = 75,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SoundTap(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: ImageHelper.load(
              path: active ? iconPathSelected : iconPath,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              height: 16 / 10,
              letterSpacing: 0.5,
              color: active ? const Color(0xFFFFB732) : kDiamondTextTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
