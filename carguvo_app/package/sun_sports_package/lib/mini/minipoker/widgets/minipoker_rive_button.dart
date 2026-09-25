import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

import 'package:sun_sports/core/utils/extensions/rive_helper.dart';
import 'package:sun_sports/core/utils/styles/app_rive.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

enum MinipokerRiveButtonKind {
  auto('pressed', momentary: false),

  spin('pushed', momentary: true),

  turbo('pressed', momentary: false);

  final String activeAnimation;

  final bool momentary;

  const MinipokerRiveButtonKind(
    this.activeAnimation, {
    required this.momentary,
  });

  String get url => switch (this) {
        auto => AppRive.mpAnimAuto,
        spin => AppRive.dgAnimSpin,
        turbo => AppRive.mpAnimTurbo,
      };
}

class MinipokerRiveButton extends StatefulWidget {
  final MinipokerRiveButtonKind kind;
  final double size;
  final ValueChanged<bool>? onChanged;

  final bool? active;

  const MinipokerRiveButton({
    required this.kind,
    this.size = 64,
    this.onChanged,
    this.active,
    super.key,
  });

  @override
  State<MinipokerRiveButton> createState() => _MinipokerRiveButtonState();
}

class _MinipokerRiveButtonState extends State<MinipokerRiveButton> {
  static const String _kIdle = 'idle';

  rive.File? _file;
  _MinipokerButtonPainter? _painter;

  bool _active = false;

  bool get _controlled => widget.active != null;

  bool get _effectiveActive => widget.active ?? _active;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final file = await RiveHelper.getFile(widget.kind.url);
      if (file == null || !mounted) return;
      final painter = _MinipokerButtonPainter(
        activeAnimation: widget.kind.activeAnimation,
        idleAnimation: _kIdle,
        momentary: widget.kind.momentary,
      );
      setState(() {
        _file = file;
        _painter = painter;
      });
      if (_controlled && !widget.kind.momentary && _effectiveActive) {
        painter.setActive(true);
      }
    } catch (_) {
    }
  }

  @override
  void didUpdateWidget(MinipokerRiveButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controlled &&
        !widget.kind.momentary &&
        widget.active != oldWidget.active) {
      _painter?.setActive(widget.active!);
    }
  }

  void _onTap() {
    final painter = _painter;
    if (painter == null) return;
    if (widget.kind.momentary) {
      painter.fireMomentary();
      widget.onChanged?.call(true);
    } else if (_controlled) {
      widget.onChanged?.call(!widget.active!);
    } else {
      _active = !_active;
      painter.setActive(_active);
      widget.onChanged?.call(_active);
    }
  }

  @override
  void dispose() {
    _painter?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final file = _file;
    final painter = _painter;
    if (file == null || painter == null) {
      return SizedBox.square(dimension: widget.size);
    }
    return SizedBox.square(
      dimension: widget.size,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: SoundTap.wrap(_onTap),
          child: rive.RiveFileWidget(
            file: file,
            painter: painter,
          ),
        ),
      ),
    );
  }
}

base class _MinipokerButtonPainter extends rive.BasicArtboardPainter {
  final String activeAnimation;
  final String idleAnimation;
  final bool momentary;

  rive.Animation? _active;
  rive.Animation? _idle;

  bool _showActive = false;

  _MinipokerButtonPainter({
    required this.activeAnimation,
    required this.idleAnimation,
    required this.momentary,
  }) : super(fit: rive.Fit.contain);

  @override
  void artboardChanged(rive.Artboard artboard) {
    super.artboardChanged(artboard);
    _active = artboard.animationNamed(activeAnimation);
    _idle = artboard.animationNamed(idleAnimation);
    notifyListeners();
  }

  void setActive(bool active) {
    _showActive = active;
    (active ? _active : _idle)?.time = 0;
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
      if (!playing && momentary) {
        _showActive = false;
        _idle?.time = 0;
        return true;
      }
      return playing;
    }
    return _idle?.advanceAndApply(elapsedSeconds) ?? false;
  }
}
