import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:sun_sports/core/utils/app_logger.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/mini_game_icons.dart';

class TaiXiuDiceBowlOverlay extends StatefulWidget {
  final double bowlSize;
  final VoidCallback onOpened;

  const TaiXiuDiceBowlOverlay({
    required this.bowlSize,
    required this.onOpened,
    super.key,
  });

  @override
  State<TaiXiuDiceBowlOverlay> createState() => _TaiXiuDiceBowlOverlayState();
}

class _TaiXiuDiceBowlOverlayState extends State<TaiXiuDiceBowlOverlay> {
  static const double _kOpenRadius = 100;

  static const Duration _kSnapDuration = Duration(milliseconds: 220);

  Offset _offset = Offset.zero;

  bool _dragging = false;

  bool _opened = false;

  void _onPanUpdate(DragUpdateDetails d) {
    if (_opened) return;
    setState(() => _offset += d.delta);
    AppLoggers.ui.d(
      'bowl drag → offset=$_offset dist=${_offset.distance.toStringAsFixed(1)}',
    );
    if (_offset.distance > _kOpenRadius) {
      _opened = true;
      AppLoggers.ui.d('bowl OPEN (dist > $_kOpenRadius) → reveal');
      widget.onOpened();
    }
  }

  void _snapBack() {
    if (_opened) return;
    AppLoggers.ui.d('bowl release → snap về 0 (từ offset=$_offset)');
    setState(() {
      _dragging = false;
      _offset = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.grab,
    child: RawGestureDetector(
      behavior: HitTestBehavior.opaque,
      gestures: {
        TaiXiuEagerPanGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<
              TaiXiuEagerPanGestureRecognizer
            >(TaiXiuEagerPanGestureRecognizer.new, (instance) {
              instance
                ..onStart = (_) {
                  AppLoggers.ui.d('bowl pan start (offset hiện tại=$_offset)');
                  setState(() => _dragging = true);
                }
                ..onUpdate = _onPanUpdate
                ..onCancel = _snapBack
                ..onEnd = (_) => _snapBack();
            }),
      },
      child: AnimatedContainer(
        duration: _dragging ? Duration.zero : _kSnapDuration,
        curve: Curves.easeOut,
        alignment: Alignment.center,
        transform: Matrix4.translationValues(_offset.dx, _offset.dy, 0),
        child: _BowlImage(size: widget.bowlSize),
      ),
    ),
  );
}

class TaiXiuEagerPanGestureRecognizer extends PanGestureRecognizer {
  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }
}

class _BowlImage extends StatelessWidget {
  final double size;

  const _BowlImage({required this.size});

  @override
  Widget build(BuildContext context) => ImageHelper.load(
    path: MiniGameIcons.txBowl,
    width: size,
    height: size,
    fit: BoxFit.contain,
  );
}
